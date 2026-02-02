import 'package:flutter/material.dart';
import 'package:slabhaul/core/models/lake_conditions.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/weather/widgets/water_level_chart.dart';

class LakeConditionsCard extends StatelessWidget {
  final LakeConditions conditions;

  const LakeConditionsCard({super.key, required this.conditions});

  @override
  Widget build(BuildContext context) {
    final diff = conditions.levelDifference;
    final status = conditions.levelStatus;
    final statusColor = _statusColor(status);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Row(
              children: [
                Icon(Icons.water, color: AppColors.teal, size: 20),
                SizedBox(width: 8),
                Text(
                  'Lake Conditions',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stats row
            Row(
              children: [
                // Water level
                Expanded(
                  child: _StatBlock(
                    label: 'Water Level',
                    value: conditions.waterLevelFt != null
                        ? '${conditions.waterLevelFt!.toStringAsFixed(1)} ft'
                        : '--',
                    valueColor: AppColors.textPrimary,
                  ),
                ),

                // Normal pool
                Expanded(
                  child: _StatBlock(
                    label: 'Normal Pool',
                    value: conditions.normalPoolFt != null
                        ? '${conditions.normalPoolFt!.toStringAsFixed(1)} ft'
                        : '--',
                    valueColor: AppColors.textSecondary,
                  ),
                ),

                // Water temp
                Expanded(
                  child: _StatBlock(
                    label: 'Water Temp',
                    value: conditions.waterTempF != null
                        ? '${conditions.waterTempF!.round()}\u00B0F'
                        : '--',
                    valueColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Level difference + status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(status),
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (diff != null)
                    Text(
                      '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)} ft',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Water level chart
            if (conditions.recentReadings.isNotEmpty)
              SizedBox(
                height: 160,
                child: WaterLevelChart(
                  readings: conditions.recentReadings,
                  normalPool: conditions.normalPoolFt,
                ),
              ),

            // Last updated
            if (conditions.lastUpdated != null) ...[
              const SizedBox(height: 10),
              Text(
                'Updated: ${_formatUpdated(conditions.lastUpdated!)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Above Normal':
        return AppColors.success;
      case 'Below Normal':
        return AppColors.error;
      default:
        return AppColors.teal;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Above Normal':
        return Icons.arrow_upward;
      case 'Below Normal':
        return Icons.arrow_downward;
      default:
        return Icons.horizontal_rule;
    }
  }

  String _formatUpdated(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ---------------------------------------------------------------------------
// Stat block (label + value)
// ---------------------------------------------------------------------------

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
