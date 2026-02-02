import 'package:flutter/material.dart';
import '../../../core/models/fishing_hotspot.dart';
import '../../../core/utils/constants.dart';

/// A compact bar showing current conditions used for hotspot scoring.
class ConditionsSummaryBar extends StatelessWidget {
  final CurrentConditions conditions;

  const ConditionsSummaryBar({super.key, required this.conditions});

  String get _seasonLabel {
    switch (conditions.season) {
      case 'pre_spawn':
        return 'Pre-Spawn';
      case 'spawn':
        return 'Spawn';
      case 'post_spawn':
        return 'Post-Spawn';
      case 'summer':
        return 'Summer';
      case 'fall':
        return 'Fall';
      case 'winter':
        return 'Winter';
      default:
        return conditions.season;
    }
  }

  String get _timeLabel {
    switch (conditions.timeOfDay) {
      case 'early_morning':
        return 'Early AM';
      case 'midday':
        return 'Midday';
      case 'evening':
        return 'Evening';
      case 'night':
        return 'Night';
      default:
        return conditions.timeOfDay;
    }
  }

  IconData get _seasonIcon {
    switch (conditions.season) {
      case 'pre_spawn':
      case 'spawn':
        return Icons.eco;
      case 'post_spawn':
        return Icons.wb_sunny;
      case 'summer':
        return Icons.wb_sunny;
      case 'fall':
        return Icons.park;
      case 'winter':
        return Icons.ac_unit;
      default:
        return Icons.calendar_today;
    }
  }

  Color get _seasonColor {
    switch (conditions.season) {
      case 'pre_spawn':
      case 'spawn':
        return AppColors.success;
      case 'post_spawn':
      case 'summer':
        return AppColors.warning;
      case 'fall':
        return const Color(0xFFF97316);
      case 'winter':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.card,
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.teal,
              ),
              const SizedBox(width: 6),
              const Text(
                'Current Conditions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Rankings based on real-time data',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Conditions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Season
              _ConditionChip(
                icon: _seasonIcon,
                label: _seasonLabel,
                sublabel: 'Season',
                color: _seasonColor,
              ),

              // Temperature
              if (conditions.waterTempF != null)
                _ConditionChip(
                  icon: Icons.thermostat,
                  label: '${conditions.waterTempF!.round()}°F',
                  sublabel: 'Est. Water',
                  color: _getTempColor(conditions.waterTempF!),
                ),

              // Time of day
              _ConditionChip(
                icon: _getTimeIcon(conditions.timeOfDay),
                label: _timeLabel,
                sublabel: 'Time',
                color: AppColors.textSecondary,
              ),

              // Wind
              if (conditions.windSpeedMph != null)
                _ConditionChip(
                  icon: Icons.air,
                  label: '${conditions.windSpeedMph!.round()} mph',
                  sublabel: conditions.windDirection ?? 'Wind',
                  color: _getWindColor(conditions.windSpeedMph!),
                ),

              // Pressure trend
              if (conditions.pressureTrend != null)
                _ConditionChip(
                  icon: _getPressureIcon(conditions.pressureTrend!),
                  label: conditions.pressureTrend!.capitalize(),
                  sublabel: 'Pressure',
                  color: _getPressureColor(conditions.pressureTrend!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTimeIcon(String timeOfDay) {
    switch (timeOfDay) {
      case 'early_morning':
        return Icons.wb_twilight;
      case 'midday':
        return Icons.wb_sunny;
      case 'evening':
        return Icons.nights_stay;
      case 'night':
        return Icons.nightlight;
      default:
        return Icons.schedule;
    }
  }

  Color _getTempColor(double tempF) {
    if (tempF < 50) return AppColors.info;
    if (tempF < 60) return const Color(0xFF14B8A6); // Teal
    if (tempF < 70) return AppColors.success;
    if (tempF < 80) return AppColors.warning;
    return AppColors.error;
  }

  Color _getWindColor(double windMph) {
    if (windMph < 5) return AppColors.success;
    if (windMph < 10) return AppColors.teal;
    if (windMph < 15) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getPressureIcon(String trend) {
    switch (trend) {
      case 'rising':
        return Icons.trending_up;
      case 'falling':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getPressureColor(String trend) {
    switch (trend) {
      case 'rising':
        return AppColors.success;
      case 'falling':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ConditionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _ConditionChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          sublabel,
          style: TextStyle(
            fontSize: 9,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
