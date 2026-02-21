import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/models/hatch_recommendation.dart';
import '../../../core/utils/constants.dart';
import '../providers/match_the_hatch_providers.dart';
import '../../weather/providers/solunar_providers.dart';

class AutoConditionsPanel extends ConsumerWidget {
  const AutoConditionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auto = ref.watch(autoHatchConditionsProvider);
    final solunar = ref.watch(solunarForecastProvider);

    if (auto == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Loading conditions...', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auto-Detected Conditions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(Icons.thermostat, '${auto.airTempF.round()}°F air'),
              _chip(Icons.speed, '${auto.pressureMb.round()} mb ${_trendArrow(auto.pressureTrend)}'),
              _chip(Icons.air, '${auto.windSpeedMph.round()} mph'),
              _chip(
                Icons.nightlight_round,
                '${solunar.moonEmoji} ${(auto.solunarRating * 100).round()}%',
              ),
              _chip(Icons.map, auto.region.displayName),
              if (auto.season != null)
                _chip(Icons.calendar_today, auto.season!.displayName),
              if (auto.targetDepthFt != null)
                _chip(Icons.straighten, '${auto.targetDepthFt!.round()} ft target'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.teal),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _trendArrow(String trend) {
    switch (trend) {
      case 'Rising':
        return '\u2191';
      case 'Falling':
        return '\u2193';
      default:
        return '\u2192';
    }
  }
}
