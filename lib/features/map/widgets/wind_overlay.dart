import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/wind_providers.dart';

/// Compact wind indicator card shown at the bottom-right of the map.
///
/// It displays a rotated arrow, wind speed in mph, and the compass direction.
/// Only visible when [windEnabledProvider] is true. Uses mock data for now.
class WindOverlay extends ConsumerWidget {
  const WindOverlay({super.key});

  // Mock wind data
  static const double _windSpeedMph = 8.5;
  static const double _windDegrees = 210.0; // SSW
  static const String _windDirection = 'SSW';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windEnabled = ref.watch(windEnabledProvider);
    if (!windEnabled) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wind direction arrow
            Transform.rotate(
              angle: _windDegrees * math.pi / 180,
              child: Icon(
                Icons.navigation,
                color: _windSpeedColor(_windSpeedMph),
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            // Speed and direction text
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_windSpeedMph.toStringAsFixed(1)} mph',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _windSpeedColor(_windSpeedMph),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'from $_windDirection',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a colour representing the wind severity.
  Color _windSpeedColor(double mph) {
    if (mph < 5) return AppColors.windCalm;
    if (mph < 12) return AppColors.windModerate;
    if (mph < 20) return AppColors.windStrong;
    return AppColors.windDangerous;
  }
}
