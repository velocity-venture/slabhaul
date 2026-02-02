import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/trip_log.dart';
import '../../../core/utils/constants.dart';
import '../providers/trip_log_providers.dart';

class TripInsightsScreen extends ConsumerWidget {
  const TripInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(aggregateStatsProvider);
    final baitStatsAsync = ref.watch(catchesByBaitProvider);
    final hourStatsAsync = ref.watch(catchesByHourProvider);
    final monthStatsAsync = ref.watch(catchesByMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Fishing Insights',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lifetime stats
            statsAsync.when(
              data: (stats) => _LifetimeStatsCard(stats: stats),
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Personal bests
            statsAsync.when(
              data: (stats) => _PersonalBestsCard(stats: stats),
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Best baits chart
            baitStatsAsync.when(
              data: (baitStats) {
                if (baitStats.isEmpty) return const SizedBox.shrink();
                return _BestBaitsCard(baitStats: baitStats);
              },
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Catches by hour chart
            hourStatsAsync.when(
              data: (hourStats) {
                if (hourStats.isEmpty) return const SizedBox.shrink();
                return _CatchesByHourCard(hourStats: hourStats);
              },
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Seasonal trends
            monthStatsAsync.when(
              data: (monthStats) {
                if (monthStats.isEmpty) return const SizedBox.shrink();
                return _SeasonalTrendsCard(monthStats: monthStats);
              },
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LifetimeStatsCard extends StatelessWidget {
  final AggregateStats stats;

  const _LifetimeStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, size: 20, color: AppColors.teal),
                SizedBox(width: 8),
                Text(
                  'Lifetime Stats',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BigStat(
                    value: stats.totalTrips.toString(),
                    label: 'Trips',
                    icon: Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _BigStat(
                    value: stats.totalCatches.toString(),
                    label: 'Total Fish',
                    icon: Icons.phishing,
                  ),
                ),
                Expanded(
                  child: _BigStat(
                    value: stats.totalCrappie.toString(),
                    label: 'Crappie',
                    icon: Icons.water,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BigStat(
                    value: stats.totalTimeDisplay,
                    label: 'Time Fishing',
                    icon: Icons.timer,
                  ),
                ),
                Expanded(
                  child: _BigStat(
                    value: stats.averageCatchesPerTrip != null
                        ? stats.averageCatchesPerTrip!.toStringAsFixed(1)
                        : '--',
                    label: 'Avg per Trip',
                    icon: Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _BigStat(
                    value: stats.mostSuccessfulLake ?? '--',
                    label: 'Best Lake',
                    icon: Icons.location_on,
                    smallValue: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool smallValue;

  const _BigStat({
    required this.value,
    required this.label,
    required this.icon,
    this.smallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: smallValue ? 14 : 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PersonalBestsCard extends StatelessWidget {
  final AggregateStats stats;

  const _PersonalBestsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final hasPB =
        stats.personalBestLengthInches != null ||
        stats.personalBestWeightLbs != null;

    if (!hasPB) {
      return Card(
        color: AppColors.warning.withValues(alpha: 0.1),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: AppColors.warning),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Log your catches with sizes to track your personal bests!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.warning),
                SizedBox(width: 8),
                Text(
                  'Personal Bests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (stats.personalBestLengthInches != null)
                  Expanded(
                    child: _PBItem(
                      label: 'Longest',
                      value:
                          '${stats.personalBestLengthInches!.toStringAsFixed(1)}"',
                    ),
                  ),
                if (stats.personalBestWeightLbs != null)
                  Expanded(
                    child: _PBItem(
                      label: 'Heaviest',
                      value:
                          '${stats.personalBestWeightLbs!.toStringAsFixed(2)} lbs',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PBItem extends StatelessWidget {
  final String label;
  final String value;

  const _PBItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BestBaitsCard extends StatelessWidget {
  final Map<String, int> baitStats;

  const _BestBaitsCard({required this.baitStats});

  @override
  Widget build(BuildContext context) {
    final topBaits = baitStats.entries.take(5).toList();
    final maxCount = topBaits.isNotEmpty ? topBaits.first.value : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.stars, size: 20, color: AppColors.teal),
                SizedBox(width: 8),
                Text(
                  'Top Baits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topBaits.asMap().entries.map((entry) {
              final index = entry.key;
              final bait = entry.value;
              final percent = bait.value / maxCount;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Rank
                    SizedBox(
                      width: 24,
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: index == 0
                              ? AppColors.warning
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    // Bait name
                    Expanded(
                      flex: 2,
                      child: Text(
                        bait.key,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Bar
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.teal
                                  .withValues(alpha: 0.3 + 0.7 * percent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Count
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${bait.value}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CatchesByHourCard extends StatelessWidget {
  final Map<int, int> hourStats;

  const _CatchesByHourCard({required this.hourStats});

  @override
  Widget build(BuildContext context) {
    // Create bar data for all hours
    final spots = <FlSpot>[];
    for (int hour = 0; hour < 24; hour++) {
      spots.add(FlSpot(hour.toDouble(), (hourStats[hour] ?? 0).toDouble()));
    }

    // Find peak hour
    int peakHour = 0;
    int peakCount = 0;
    hourStats.forEach((hour, count) {
      if (count > peakCount) {
        peakHour = hour;
        peakCount = count;
      }
    });

    String formatHour(int hour) {
      if (hour == 0) return '12AM';
      if (hour == 12) return '12PM';
      if (hour < 12) return '${hour}AM';
      return '${hour - 12}PM';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: AppColors.teal),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Catches by Time of Day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Peak: ${formatHour(peakHour)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 6 ||
                              value == 12 ||
                              value == 18) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                formatHour(value.toInt()),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.teal,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.teal.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: 23,
                  minY: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Dawn/Dusk indicators
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TimeLabel(icon: Icons.wb_twilight, label: 'Dawn', hour: '5-7 AM'),
                _TimeLabel(icon: Icons.wb_sunny, label: 'Midday', hour: '11-2 PM'),
                _TimeLabel(icon: Icons.nights_stay, label: 'Dusk', hour: '6-8 PM'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hour;

  const _TimeLabel({
    required this.icon,
    required this.label,
    required this.hour,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _SeasonalTrendsCard extends StatelessWidget {
  final Map<int, int> monthStats;

  const _SeasonalTrendsCard({required this.monthStats});

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final maxCount = monthStats.values.fold<int>(1, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, size: 20, color: AppColors.teal),
                SizedBox(width: 8),
                Text(
                  'Seasonal Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (index) {
                  final month = index + 1;
                  final count = monthStats[month] ?? 0;
                  final height = count > 0 ? (count / maxCount) * 60 + 10 : 4;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text(
                              count.toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Container(
                            height: height.toDouble(),
                            decoration: BoxDecoration(
                              color: _getSeasonColor(month)
                                  .withValues(alpha: count > 0 ? 0.8 : 0.2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            monthNames[index],
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeasonColor(int month) {
    // Winter: Dec, Jan, Feb
    if (month == 12 || month <= 2) return AppColors.info;
    // Spring: Mar, Apr, May
    if (month <= 5) return AppColors.success;
    // Summer: Jun, Jul, Aug
    if (month <= 8) return AppColors.warning;
    // Fall: Sep, Oct, Nov
    return AppColors.error;
  }
}
