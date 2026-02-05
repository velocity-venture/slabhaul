import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:slabhaul/core/models/water_clarity.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/clarity_providers.dart';

/// Map layer showing water clarity zones with color-coded polygons.
/// 
/// Colors follow the industry standard for water clarity visualization:
/// - Blue: Clear/Crystal (5+ ft visibility)
/// - Green: Light Stain (3-5 ft visibility)
/// - Yellow-Green: Stained (1-3 ft visibility)
/// - Brown: Muddy (<1 ft visibility)
class ClarityLayer extends ConsumerWidget {
  const ClarityLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(clarityLayerEnabledProvider);
    if (!enabled) return const SizedBox.shrink();

    final zonesAsync = ref.watch(clarityZonesProvider);

    return zonesAsync.when(
      data: (zones) {
        if (zones.isEmpty) {
          return _NoDataOverlay();
        }
        
        return Stack(
          children: [
            // Zone polygons
            _ClarityPolygonsLayer(zones: zones),
            // Zone labels
            _ClarityLabelsLayer(zones: zones),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Polygon overlays for each clarity zone
class _ClarityPolygonsLayer extends ConsumerWidget {
  final List<ClarityZone> zones;

  const _ClarityPolygonsLayer({required this.zones});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedClarityZoneProvider);
    
    final polygons = zones.map((zone) {
      final clarity = zone.currentClarity;
      final isSelected = selectedZone?.id == zone.id;
      
      // Convert boundary to LatLng points
      final points = zone.boundary
          .map((p) => LatLng(p[0], p[1]))
          .toList();
      
      // Close the polygon if not already closed
      if (points.isNotEmpty && points.first != points.last) {
        points.add(points.first);
      }
      
      return Polygon(
        points: points,
        color: _clarityFillColor(clarity?.level, isSelected),
        borderColor: _clarityBorderColor(clarity?.level, isSelected),
        borderStrokeWidth: isSelected ? 3.0 : 1.5,
      );
    }).toList();

    return PolygonLayer(polygons: polygons);
  }

  Color _clarityFillColor(ClarityLevel? level, bool isSelected) {
    final opacity = isSelected ? 0.45 : 0.30;
    
    switch (level) {
      case ClarityLevel.crystal:
        return const Color(0xFF38BDF8).withValues(alpha: opacity); // Sky blue
      case ClarityLevel.clear:
        return const Color(0xFF3B82F6).withValues(alpha: opacity); // Blue
      case ClarityLevel.lightStain:
        return const Color(0xFF22C55E).withValues(alpha: opacity); // Green
      case ClarityLevel.stained:
        return const Color(0xFF84CC16).withValues(alpha: opacity); // Yellow-green
      case ClarityLevel.muddy:
        return const Color(0xFFA16207).withValues(alpha: opacity); // Brown
      case null:
        return const Color(0xFF9CA3AF).withValues(alpha: opacity); // Gray fallback
    }
  }

  Color _clarityBorderColor(ClarityLevel? level, bool isSelected) {
    final opacity = isSelected ? 1.0 : 0.7;
    
    switch (level) {
      case ClarityLevel.crystal:
        return const Color(0xFF0EA5E9).withValues(alpha: opacity);
      case ClarityLevel.clear:
        return const Color(0xFF2563EB).withValues(alpha: opacity);
      case ClarityLevel.lightStain:
        return const Color(0xFF16A34A).withValues(alpha: opacity);
      case ClarityLevel.stained:
        return const Color(0xFF65A30D).withValues(alpha: opacity);
      case ClarityLevel.muddy:
        return const Color(0xFF92400E).withValues(alpha: opacity);
      case null:
        return const Color(0xFF6B7280).withValues(alpha: opacity);
    }
  }
}

/// Labels for each clarity zone showing name and clarity level
class _ClarityLabelsLayer extends ConsumerWidget {
  final List<ClarityZone> zones;

  const _ClarityLabelsLayer({required this.zones});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markers = zones.map((zone) {
      final clarity = zone.currentClarity;
      
      return Marker(
        point: LatLng(zone.centerLat, zone.centerLon),
        width: 100,
        height: 50,
        child: GestureDetector(
          onTap: () {
            ref.read(selectedClarityZoneProvider.notifier).state = zone;
          },
          child: _ZoneLabel(
            zoneName: zone.name,
            clarity: clarity,
          ),
        ),
      );
    }).toList();

    return MarkerLayer(markers: markers);
  }
}

/// Individual zone label widget
class _ZoneLabel extends StatelessWidget {
  final String zoneName;
  final ClarityEstimate? clarity;

  const _ZoneLabel({
    required this.zoneName,
    required this.clarity,
  });

  @override
  Widget build(BuildContext context) {
    final level = clarity?.level ?? ClarityLevel.lightStain;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Color(level.mapColor).withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            zoneName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                level.icon,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 2),
              Text(
                '${clarity?.visibilityFt.toStringAsFixed(1) ?? "?"} ft',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(level.mapColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Overlay shown when no clarity data is available
class _NoDataOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Silent fail - just don't show layer
  }
}

/// Legend widget showing clarity level color meanings
class ClarityLegend extends StatelessWidget {
  const ClarityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Water Clarity',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _legendItem(ClarityLevel.crystal),
          _legendItem(ClarityLevel.clear),
          _legendItem(ClarityLevel.lightStain),
          _legendItem(ClarityLevel.stained),
          _legendItem(ClarityLevel.muddy),
        ],
      ),
    );
  }

  Widget _legendItem(ClarityLevel level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 12,
            decoration: BoxDecoration(
              color: Color(level.mapColor).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Color(level.mapColor),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            level.icon,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            '${level.displayName} (${level.visibilityRange})',
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

/// Toggle button for enabling/disabling clarity layer
class ClarityLayerToggle extends ConsumerWidget {
  const ClarityLayerToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(clarityLayerEnabledProvider);
    
    return IconButton(
      icon: Icon(
        Icons.water_drop,
        color: enabled ? AppColors.teal : AppColors.textSecondary,
      ),
      tooltip: enabled ? 'Hide water clarity' : 'Show water clarity',
      onPressed: () {
        ref.read(clarityLayerEnabledProvider.notifier).state = !enabled;
      },
    );
  }
}

/// Expanded toggle button with label
class ClarityLayerToggleChip extends ConsumerWidget {
  const ClarityLayerToggleChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(clarityLayerEnabledProvider);
    
    return FilterChip(
      label: const Text('Clarity'),
      avatar: Icon(
        Icons.water_drop,
        size: 18,
        color: enabled ? AppColors.teal : AppColors.textSecondary,
      ),
      selected: enabled,
      onSelected: (value) {
        ref.read(clarityLayerEnabledProvider.notifier).state = value;
      },
      selectedColor: AppColors.teal.withValues(alpha: 0.2),
      checkmarkColor: AppColors.teal,
    );
  }
}
