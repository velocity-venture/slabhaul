import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:slabhaul/core/models/streamflow_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/streamflow_providers.dart';

/// Map layer showing inflow points with flow-rate-based sizing and coloring.
/// Color gradient matches Deep Dive: blue (low) → pink/magenta (high).
class InflowLayer extends ConsumerWidget {
  const InflowLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamflowEnabled = ref.watch(streamflowEnabledProvider);
    
    if (!streamflowEnabled) return const SizedBox.shrink();

    final conditionsAsync = ref.watch(displayInflowConditionsProvider);

    return conditionsAsync.when(
      data: (conditions) {
        if (conditions.isEmpty) return const SizedBox.shrink();

        return Stack(
          children: [
            // Flow direction lines (from inflow point toward lake center)
            _FlowDirectionLines(conditions: conditions),
            // Inflow markers
            _InflowMarkers(conditions: conditions),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Markers at each inflow point.
class _InflowMarkers extends ConsumerWidget {
  final List<InflowConditions> conditions;

  const _InflowMarkers({required this.conditions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInflow = ref.watch(selectedInflowProvider);

    // Calculate max flow for relative sizing
    final maxFlow = conditions.fold<double>(
      100, // minimum baseline
      (max, c) => c.currentFlowCfs > max ? c.currentFlowCfs : max,
    );

    final markers = conditions.map((condition) {
      final isSelected = selectedInflow?.inflow.id == condition.inflow.id;
      final size = _calculateMarkerSize(condition.currentFlowCfs, maxFlow);
      final color = _flowColor(condition.currentFlowCfs, maxFlow);

      return Marker(
        point: LatLng(condition.inflow.latitude, condition.inflow.longitude),
        width: size + 8,
        height: size + 8,
        child: GestureDetector(
          onTap: () {
            ref.read(selectedInflowProvider.notifier).state = condition;
          },
          child: _InflowMarkerWidget(
            condition: condition,
            size: size,
            color: color,
            isSelected: isSelected,
          ),
        ),
      );
    }).toList();

    return MarkerLayer(markers: markers);
  }

  double _calculateMarkerSize(double flow, double maxFlow) {
    // Map flow to size: min 20, max 50
    final ratio = (flow / maxFlow).clamp(0.1, 1.0);
    return 20 + (ratio * 30);
  }

  /// Color gradient: blue (low) → cyan → green → yellow → pink/magenta (high)
  /// Matches Deep Dive style
  Color _flowColor(double flow, double maxFlow) {
    final ratio = (flow / maxFlow).clamp(0.0, 1.0);

    // Blue → Cyan → Green → Yellow → Pink
    if (ratio < 0.25) {
      // Blue to Cyan
      return Color.lerp(
        const Color(0xFF3B82F6), // Blue
        const Color(0xFF06B6D4), // Cyan
        ratio * 4,
      )!;
    } else if (ratio < 0.5) {
      // Cyan to Green
      return Color.lerp(
        const Color(0xFF06B6D4), // Cyan
        const Color(0xFF22C55E), // Green
        (ratio - 0.25) * 4,
      )!;
    } else if (ratio < 0.75) {
      // Green to Yellow
      return Color.lerp(
        const Color(0xFF22C55E), // Green
        const Color(0xFFEAB308), // Yellow
        (ratio - 0.5) * 4,
      )!;
    } else {
      // Yellow to Pink/Magenta
      return Color.lerp(
        const Color(0xFFEAB308), // Yellow
        const Color(0xFFEC4899), // Pink
        (ratio - 0.75) * 4,
      )!;
    }
  }
}

/// Individual inflow marker widget with trend indicator.
class _InflowMarkerWidget extends StatelessWidget {
  final InflowConditions condition;
  final double size;
  final Color color;
  final bool isSelected;

  const _InflowMarkerWidget({
    required this.condition,
    required this.size,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow for selected
        if (isSelected)
          Container(
            width: size + 8,
            height: size + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),

        // Main circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.85),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white70,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: _buildTrendIcon(),
          ),
        ),

        // Live data indicator (small dot)
        if (condition.hasLiveData)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrendIcon() {
    final iconSize = size * 0.45;
    
    if (!condition.hasLiveData) {
      return Icon(
        Icons.water_drop,
        size: iconSize,
        color: Colors.white,
      );
    }

    switch (condition.trend) {
      case FlowTrend.rising:
        return Icon(
          Icons.trending_up,
          size: iconSize,
          color: Colors.white,
        );
      case FlowTrend.falling:
        return Icon(
          Icons.trending_down,
          size: iconSize,
          color: Colors.white,
        );
      case FlowTrend.stable:
        return Icon(
          Icons.trending_flat,
          size: iconSize,
          color: Colors.white,
        );
    }
  }
}

/// Lines showing flow direction from inflow toward lake.
class _FlowDirectionLines extends StatelessWidget {
  final List<InflowConditions> conditions;

  const _FlowDirectionLines({required this.conditions});

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty) return const SizedBox.shrink();

    // Calculate lake center (average of all inflow points)
    final centerLat = conditions.fold<double>(0, (sum, c) => sum + c.inflow.latitude) / 
                     conditions.length;
    final centerLon = conditions.fold<double>(0, (sum, c) => sum + c.inflow.longitude) / 
                     conditions.length;

    final maxFlow = conditions.fold<double>(
      100,
      (max, c) => c.currentFlowCfs > max ? c.currentFlowCfs : max,
    );

    final polylines = conditions.map((condition) {
      final start = LatLng(condition.inflow.latitude, condition.inflow.longitude);
      
      // Calculate direction toward lake center
      final dx = centerLon - condition.inflow.longitude;
      final dy = centerLat - condition.inflow.latitude;
      final distance = math.sqrt(dx * dx + dy * dy);
      
      // Normalize and create short line (0.02 degrees ~ 1-2km)
      final lineLength = 0.015;
      final endLat = condition.inflow.latitude + (dy / distance) * lineLength;
      final endLon = condition.inflow.longitude + (dx / distance) * lineLength;
      
      final end = LatLng(endLat, endLon);

      // Line width based on flow
      final flowRatio = (condition.currentFlowCfs / maxFlow).clamp(0.2, 1.0);
      final strokeWidth = 2.0 + (flowRatio * 4.0);

      return Polyline(
        points: [start, end],
        color: _flowColor(condition.currentFlowCfs, maxFlow).withOpacity(0.7),
        strokeWidth: strokeWidth,
        pattern: const StrokePattern.dotted(spacingFactor: 1.5),
      );
    }).toList();

    return PolylineLayer(polylines: polylines);
  }

  Color _flowColor(double flow, double maxFlow) {
    final ratio = (flow / maxFlow).clamp(0.0, 1.0);

    if (ratio < 0.25) {
      return Color.lerp(
        const Color(0xFF3B82F6),
        const Color(0xFF06B6D4),
        ratio * 4,
      )!;
    } else if (ratio < 0.5) {
      return Color.lerp(
        const Color(0xFF06B6D4),
        const Color(0xFF22C55E),
        (ratio - 0.25) * 4,
      )!;
    } else if (ratio < 0.75) {
      return Color.lerp(
        const Color(0xFF22C55E),
        const Color(0xFFEAB308),
        (ratio - 0.5) * 4,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFEAB308),
        const Color(0xFFEC4899),
        (ratio - 0.75) * 4,
      )!;
    }
  }
}

/// Legend widget for the inflow layer.
class InflowLayerLegend extends StatelessWidget {
  const InflowLayerLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water, size: 16, color: AppColors.info),
              SizedBox(width: 4),
              Text(
                'Streamflow',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LegendItem(color: const Color(0xFF3B82F6), label: 'Low'),
          _LegendItem(color: const Color(0xFF22C55E), label: 'Normal'),
          _LegendItem(color: const Color(0xFFEAB308), label: 'High'),
          _LegendItem(color: const Color(0xFFEC4899), label: 'Very High'),
          const SizedBox(height: 6),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: AppColors.success),
              SizedBox(width: 4),
              Text(
                'Live USGS data',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white54, width: 1),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact flow info overlay (like wind overlay).
class StreamflowOverlay extends ConsumerWidget {
  const StreamflowOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(streamflowEnabledProvider);
    if (!enabled) return const SizedBox.shrink();

    final trendSummary = ref.watch(lakeTrendSummaryProvider);

    return Positioned(
      bottom: 16,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: trendSummary != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water, size: 18, color: AppColors.info),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trendSummary.flowDisplay,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTrendIcon(trendSummary.dominantTrend),
                          const SizedBox(width: 4),
                          Text(
                            trendSummary.trendLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${trendSummary.liveDataCount} live',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water, size: 18, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Text(
                    'No inflow data',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTrendIcon(FlowTrend trend) {
    switch (trend) {
      case FlowTrend.rising:
        return const Icon(Icons.trending_up, size: 14, color: AppColors.success);
      case FlowTrend.falling:
        return const Icon(Icons.trending_down, size: 14, color: AppColors.warning);
      case FlowTrend.stable:
        return const Icon(Icons.trending_flat, size: 14, color: AppColors.textSecondary);
    }
  }
}
