import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/weather/providers/lake_conditions_providers.dart';
import 'package:slabhaul/features/weather/providers/weather_providers.dart';
import 'package:slabhaul/shared/widgets/skeleton_loader.dart';
import '../providers/lake_level_providers.dart';
import '../widgets/lake_level_chart.dart';
import '../widgets/level_trend_indicator.dart';
import '../widgets/level_fishing_tips.dart';

/// Full-screen detailed view for lake level monitoring
class LakeLevelScreen extends ConsumerWidget {
  const LakeLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionsAsync = ref.watch(lakeConditionsProvider);
    final analysis = ref.watch(levelAnalysisProvider);
    final selectedRange = ref.watch(levelHistoryRangeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Lake Level',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.teal),
            onPressed: () => ref.invalidate(lakeConditionsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: conditionsAsync.when(
        data: (conditions) {
          final diff = conditions.levelDifference;
          final status = conditions.levelStatus;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(lakeConditionsProvider);
              await ref.read(lakeConditionsProvider.future);
            },
            color: AppColors.teal,
            backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lake name
                  Row(
                    children: [
                      const Icon(Icons.water, color: AppColors.teal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        ref.watch(selectedWeatherLakeProvider).name,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Current Level Card
                  _CurrentLevelCard(
                    waterLevel: conditions.waterLevelFt,
                    normalPool: conditions.normalPoolFt,
                    difference: diff,
                    status: status,
                  ),
                  const SizedBox(height: 16),

                  // Trend Indicator
                  if (analysis != null)
                    LevelTrendIndicator(
                      trend: analysis.trend,
                      change24h: analysis.change24h,
                      changePerDay: analysis.changePerDay,
                    ),
                  const SizedBox(height: 16),

                  // Chart Section
                  Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.show_chart,
                                  color: AppColors.teal, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Level History',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Range Selector
                          ChartRangeSelector(
                            selected: selectedRange,
                            onChanged: (range) {
                              ref.read(levelHistoryRangeProvider.notifier)
                                  .state = range;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Chart
                          SizedBox(
                            height: 220,
                            child: LakeLevelChart(
                              readings: conditions.recentReadings,
                              normalPool: conditions.normalPoolFt,
                              trend: analysis?.trend,
                              daysToShow: selectedRange.days,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 7-Day Stats
                  if (analysis != null) ...[
                    _StatsCard(
                      change7d: analysis.change7d,
                      changePerDay: analysis.changePerDay,
                      readings: conditions.recentReadings,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Fishing Tips
                  if (analysis != null && analysis.fishingTips.isNotEmpty)
                    LevelFishingTips(
                      tips: analysis.fishingTips,
                      expanded: true,
                    ),
                  const SizedBox(height: 16),

                  // Data Source
                  _DataSourceCard(
                    gageId: conditions.usgsGageId,
                    lastUpdated: conditions.lastUpdated,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SkeletonCard(height: 120),
              const SizedBox(height: 16),
              const SkeletonCard(height: 80),
              const SizedBox(height: 16),
              const SkeletonCard(height: 280),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: _ErrorState(
            onRetry: () => ref.invalidate(lakeConditionsProvider),
          ),
        ),
      ),
    );
  }
}

class _CurrentLevelCard extends StatelessWidget {
  final double? waterLevel;
  final double? normalPool;
  final double? difference;
  final String status;

  const _CurrentLevelCard({
    this.waterLevel,
    this.normalPool,
    this.difference,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main level display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  waterLevel?.toStringAsFixed(2) ?? '--',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'ft',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Current Water Level',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'Normal Pool',
                    value: normalPool != null
                        ? '${normalPool!.toStringAsFixed(1)} ft'
                        : '--',
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.cardBorder,
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Delta',
                    value: difference != null
                        ? '${difference! >= 0 ? '+' : ''}${difference!.toStringAsFixed(2)} ft'
                        : '--',
                    color: statusColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.cardBorder,
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Status',
                    value: status,
                    color: statusColor,
                  ),
                ),
              ],
            ),
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
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final double? change7d;
  final double? changePerDay;
  final List readings;

  const _StatsCard({
    this.change7d,
    this.changePerDay,
    required this.readings,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate min/max from recent readings
    double? minLevel;
    double? maxLevel;

    if (readings.isNotEmpty) {
      for (final r in readings) {
        final val = r.valueFt;
        if (minLevel == null || val < minLevel) minLevel = val;
        if (maxLevel == null || val > maxLevel) maxLevel = val;
      }
    }

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined,
                    color: AppColors.teal, size: 18),
                SizedBox(width: 8),
                Text(
                  '7-Day Statistics',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatBox(
                  icon: Icons.arrow_upward,
                  label: 'High',
                  value: maxLevel?.toStringAsFixed(2) ?? '--',
                  unit: 'ft',
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  icon: Icons.arrow_downward,
                  label: 'Low',
                  value: minLevel?.toStringAsFixed(2) ?? '--',
                  unit: 'ft',
                  color: AppColors.error,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  icon: Icons.trending_flat,
                  label: 'Change',
                  value: change7d != null
                      ? '${change7d! >= 0 ? '+' : ''}${change7d!.toStringAsFixed(2)}'
                      : '--',
                  unit: 'ft',
                  color: _changeColor(change7d),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _changeColor(double? change) {
    if (change == null) return AppColors.textMuted;
    if (change > 0.05) return AppColors.success;
    if (change < -0.05) return AppColors.error;
    return AppColors.teal;
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSourceCard extends StatelessWidget {
  final String? gageId;
  final DateTime? lastUpdated;

  const _DataSourceCard({
    this.gageId,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gageId != null)
                  Text(
                    'USGS Gage: $gageId',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                if (lastUpdated != null)
                  Text(
                    'Last updated: ${_formatUpdated(lastUpdated!)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off, color: AppColors.error, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Failed to load lake level data',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16, color: AppColors.teal),
          label: const Text('Retry', style: TextStyle(color: AppColors.teal)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.teal),
          ),
        ),
      ],
    );
  }
}
