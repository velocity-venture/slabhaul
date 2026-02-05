import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:slabhaul/core/models/wind_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/wind_providers.dart';

/// Map layer showing wind effects: bank exposure colors, calm pockets, and wind arrows.
class WindEffectsLayer extends ConsumerWidget {
  const WindEffectsLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windEnabled = ref.watch(windEnabledProvider);
    final effectsEnabled = ref.watch(windEffectsLayerEnabledProvider);
    
    if (!windEnabled || !effectsEnabled) return const SizedBox.shrink();

    final analysisAsync = ref.watch(windAnalysisProvider);

    return analysisAsync.when(
      data: (analysis) {
        if (analysis == null) return const SizedBox.shrink();
        
        return Stack(
          children: [
            // Bank exposure polylines
            _BankExposureLayer(analysis: analysis),
            // Calm pocket circles
            _CalmPocketsLayer(analysis: analysis),
            // Wind direction arrows
            _WindArrowsLayer(analysis: analysis),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Polylines showing bank exposure levels (windward/lee)
class _BankExposureLayer extends StatelessWidget {
  final LakeWindAnalysis analysis;

  const _BankExposureLayer({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final polylines = analysis.affectedBanks.map((bank) {
      return Polyline(
        points: [
          LatLng(bank.startLat, bank.startLon),
          LatLng(bank.endLat, bank.endLon),
        ],
        color: _exposureColor(bank.exposure, bank.waveHeightFt),
        strokeWidth: _exposureWidth(bank.exposure),
        // Use pattern for sheltered banks (dashed effect)
        pattern: bank.exposure == BankExposure.sheltered 
            ? const StrokePattern.dotted() 
            : const StrokePattern.solid(),
      );
    }).toList();

    return PolylineLayer(polylines: polylines);
  }

  Color _exposureColor(BankExposure exposure, double waveHeight) {
    switch (exposure) {
      case BankExposure.exposed:
        // Gradient from orange to red based on wave height
        if (waveHeight > 2.0) return const Color(0xFFEF4444); // Red
        if (waveHeight > 1.0) return const Color(0xFFF97316); // Orange
        return const Color(0xFFFBBF24); // Yellow-orange
      case BankExposure.partial:
        return const Color(0xB3EAB308); // Yellow at ~70% opacity
      case BankExposure.sheltered:
        return const Color(0xB322C55E); // Green at ~70% opacity
    }
  }

  double _exposureWidth(BankExposure exposure) {
    switch (exposure) {
      case BankExposure.exposed:
        return 5.0;
      case BankExposure.partial:
        return 3.5;
      case BankExposure.sheltered:
        return 3.0;
    }
  }
}

/// Circles showing calm pocket areas
class _CalmPocketsLayer extends StatelessWidget {
  final LakeWindAnalysis analysis;

  const _CalmPocketsLayer({required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.calmPockets.isEmpty) return const SizedBox.shrink();

    final circles = analysis.calmPockets.map((pocket) {
      // Convert radius in miles to approximate circle polygon
      final center = LatLng(pocket.centerLat, pocket.centerLon);
      final radiusMeters = pocket.radiusMiles * 1609.34;
      
      return CircleMarker(
        point: center,
        radius: radiusMeters / 50, // Scale for visibility
        color: const Color(0x2622C55E), // Green at ~15% opacity
        borderColor: const Color(0x8022C55E), // Green at ~50% opacity
        borderStrokeWidth: 2,
        useRadiusInMeter: false,
      );
    }).toList();

    return CircleLayer(circles: circles);
  }
}

/// Wind direction arrows showing wind flow across the lake
class _WindArrowsLayer extends StatelessWidget {
  final LakeWindAnalysis analysis;

  const _WindArrowsLayer({required this.analysis});

  @override
  Widget build(BuildContext context) {
    // Create a grid of wind arrows
    final markers = <Marker>[];
    
    // Get bounds from affected banks
    if (analysis.affectedBanks.isEmpty) return const SizedBox.shrink();

    double minLat = double.infinity, maxLat = -double.infinity;
    double minLon = double.infinity, maxLon = -double.infinity;

    for (final bank in analysis.affectedBanks) {
      minLat = math.min(minLat, math.min(bank.startLat, bank.endLat));
      maxLat = math.max(maxLat, math.max(bank.startLat, bank.endLat));
      minLon = math.min(minLon, math.min(bank.startLon, bank.endLon));
      maxLon = math.max(maxLon, math.max(bank.startLon, bank.endLon));
    }

    // Create a 3x3 grid of arrows within the lake
    const gridSize = 3;
    final latStep = (maxLat - minLat) / (gridSize + 1);
    final lonStep = (maxLon - minLon) / (gridSize + 1);

    for (int i = 1; i <= gridSize; i++) {
      for (int j = 1; j <= gridSize; j++) {
        final lat = minLat + latStep * i;
        final lon = minLon + lonStep * j;

        markers.add(Marker(
          point: LatLng(lat, lon),
          width: 40,
          height: 40,
          child: _WindArrowMarker(
            windDeg: analysis.wind.directionDeg,
            speedMph: analysis.wind.speedMph,
          ),
        ));
      }
    }

    return MarkerLayer(markers: markers);
  }
}

/// Individual wind arrow marker
class _WindArrowMarker extends StatelessWidget {
  final int windDeg;
  final double speedMph;

  const _WindArrowMarker({
    required this.windDeg,
    required this.speedMph,
  });

  @override
  Widget build(BuildContext context) {
    // Arrow points in direction wind is blowing TO
    final blowingToRad = (windDeg + 180) * math.pi / 180;

    return Transform.rotate(
      angle: blowingToRad,
      child: Icon(
        Icons.arrow_upward,
        color: _speedColor70(),
        size: 24 + (speedMph / 5).clamp(0, 12),
      ),
    );
  }

  Color _speedColor70() {
    // Return colors at 70% opacity
    if (speedMph < 5) return const Color(0xB322C55E); // windCalm
    if (speedMph < 12) return const Color(0xB3EAB308); // windModerate
    if (speedMph < 20) return const Color(0xB3F97316); // windStrong
    return const Color(0xB3EF4444); // windDangerous
  }
}

/// Legend widget showing wind effect color meanings
class WindEffectsLegend extends StatelessWidget {
  const WindEffectsLegend({super.key});

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
            'Bank Exposure',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _legendItem(const Color(0xFFEF4444), 'Windward (rough)'),
          _legendItem(const Color(0xFFFBBF24), 'Exposed'),
          _legendItem(const Color(0xFFEAB308), 'Partial'),
          _legendItem(const Color(0xFF22C55E), 'Sheltered (calm)'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
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
