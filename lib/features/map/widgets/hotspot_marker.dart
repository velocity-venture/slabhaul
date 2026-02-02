import 'package:flutter/material.dart';
import 'package:slabhaul/core/models/fishing_hotspot.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// A map marker for fishing hotspots.
/// 
/// Distinct from attractor markers with a star/fire icon.
/// Color-coded by current rating:
/// - Green = Excellent (80%+)
/// - Yellow = Good (60-79%)
/// - Orange = Fair (40-59%)
/// - Gray = Poor or Off-Season (<40%)
/// 
/// Size varies by ranking (top 3 are larger).
class HotspotMarker extends StatelessWidget {
  final HotspotRating rating;
  final int? rank;

  const HotspotMarker({
    super.key,
    required this.rating,
    this.rank,
  });

  Color get _markerColor {
    if (rating.ratingLabel == 'Off-Season') {
      return AppColors.textMuted;
    }
    if (rating.isExcellent) {
      return AppColors.success;
    }
    if (rating.isGood) {
      return AppColors.warning;
    }
    if (rating.isFair) {
      return const Color(0xFFF97316); // Orange
    }
    return AppColors.textMuted;
  }

  IconData get _markerIcon {
    switch (rating.hotspot.structureType) {
      case 'brush_pile':
        return Icons.forest;
      case 'bridge_piling':
        return Icons.account_balance;
      case 'dock':
        return Icons.directions_boat;
      case 'creek_channel':
        return Icons.water;
      case 'point':
        return Icons.navigation;
      case 'timber':
        return Icons.park;
      case 'flat':
        return Icons.waves;
      case 'ledge':
        return Icons.terrain;
      case 'hump':
        return Icons.landscape;
      case 'riprap':
        return Icons.construction;
      default:
        return Icons.local_fire_department;
    }
  }

  double get _markerSize {
    // Top 3 ranked spots get larger markers
    if (rank != null && rank! <= 3) {
      return 44.0 - (rank! - 1) * 4.0; // 44, 40, 36 for ranks 1, 2, 3
    }
    return 32.0;
  }

  @override
  Widget build(BuildContext context) {
    final color = _markerColor;
    final size = _markerSize;
    final iconSize = size * 0.5;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main marker
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: rank != null && rank! <= 3 ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: rank != null && rank! <= 3 ? 2 : 1,
              ),
            ],
          ),
          child: Icon(
            _markerIcon,
            color: Colors.white,
            size: iconSize,
          ),
        ),

        // Rank badge for top 3
        if (rank != null && rank! <= 3)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // Match percentage badge
        if (rank == null || rank! > 3)
          Positioned(
            bottom: -2,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                '${rating.matchPercentage}%',
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A simplified marker for when clustering hotspots.
class HotspotClusterMarker extends StatelessWidget {
  final int count;
  final double? averageScore;

  const HotspotClusterMarker({
    super.key,
    required this.count,
    this.averageScore,
  });

  Color get _clusterColor {
    if (averageScore == null) return AppColors.teal;
    if (averageScore! >= 0.8) return AppColors.success;
    if (averageScore! >= 0.6) return AppColors.warning;
    return AppColors.teal;
  }

  @override
  Widget build(BuildContext context) {
    final color = _clusterColor;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 16,
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
