import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/trip_plan.dart';
import '../../../core/utils/constants.dart';
import '../providers/trip_planner_providers.dart';

class SmartTripPlannerScreen extends ConsumerWidget {
  final String? lakeName;

  const SmartTripPlannerScreen({
    super.key,
    this.lakeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripPlanAsync = ref.watch(currentTripPlanProvider);

    // If a lake name was provided via route, update the parameters
    if (lakeName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentParams = ref.read(tripPlannerParamsProvider);
        if (currentParams.lakeName != lakeName) {
          ref.read(tripPlannerParamsProvider.notifier).state = 
              currentParams.copyWith(lakeName: lakeName);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Smart Trip Planner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentTripPlanProvider);
            },
            tooltip: 'Refresh Analysis',
          ),
        ],
      ),
      body: tripPlanAsync.when(
        data: (plan) => _TripPlanContent(plan: plan),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Analyzing conditions...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to generate trip plan',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(currentTripPlanProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripPlanContent extends StatelessWidget {
  final TripPlan plan;

  const _TripPlanContent({
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Rating Card
          _OverallRatingCard(plan: plan),
          const SizedBox(height: 16),

          // Conditions Radar Chart
          _ConditionsRadarCard(plan: plan),
          const SizedBox(height: 16),

          // Best Fishing Windows
          _FishingWindowsCard(plan: plan),
          const SizedBox(height: 16),

          // Depth Strategy
          _DepthStrategyCard(plan: plan),
          const SizedBox(height: 16),

          // Tactics & Baits Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _TacticsCard(plan: plan)),
              const SizedBox(width: 8),
              Expanded(child: _TopBaitsCard(plan: plan)),
            ],
          ),
          const SizedBox(height: 16),

          // Warnings (if any)
          if (plan.warnings.isNotEmpty) ...[
            _WarningsCard(plan: plan),
            const SizedBox(height: 16),
          ],

          // Conditions Breakdown
          _ConditionsBreakdownCard(plan: plan),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OverallRatingCard extends StatelessWidget {
  final TripPlan plan;

  const _OverallRatingCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final ratingColor = switch (plan.rating) {
      TripRating.excellent => AppColors.success,
      TripRating.good => AppColors.teal,
      TripRating.fair => AppColors.warning,
      TripRating.poor => AppColors.error,
    };

    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              ratingColor.withValues(alpha: 0.2),
              ratingColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan.ratingEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.ratingLabel,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ratingColor,
                        ),
                      ),
                      Text(
                        '${plan.overallScore.round()}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                plan.summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConditionsRadarCard extends StatelessWidget {
  final TripPlan plan;

  const _ConditionsRadarCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final conditions = plan.conditions;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.radar, size: 20, color: AppColors.teal),
                SizedBox(width: 8),
                Text(
                  'Conditions Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.3),
                  ),
                  tickBorderData: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.2),
                  ),
                  gridBorderData: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.2),
                  ),
                  radarTouchData: RadarTouchData(enabled: false),
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppColors.teal.withValues(alpha: 0.2),
                      borderColor: AppColors.teal,
                      entryRadius: 4,
                      dataEntries: [
                        RadarEntry(value: conditions.tempScore * 100),      // Temperature
                        RadarEntry(value: conditions.pressureScore * 100),  // Pressure
                        RadarEntry(value: conditions.windScore * 100),      // Wind
                        RadarEntry(value: conditions.solunarScore * 100),   // Solunar
                        RadarEntry(value: conditions.clarityScore * 100),   // Clarity
                      ],
                    ),
                  ],
                  getTitle: (index, angle) {
                    const titles = [
                      'Temperature',
                      'Pressure',
                      'Wind',
                      'Solunar',
                      'Clarity',
                    ];
                    return RadarChartTitle(
                      text: titles[index],
                      angle: angle,
                      positionPercentageOffset: 0.05,
                    );
                  },
                  titleTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  tickCount: 4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 3,
                  color: AppColors.teal,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Current Conditions',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
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

class _FishingWindowsCard extends StatelessWidget {
  final TripPlan plan;

  const _FishingWindowsCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final topWindows = plan.bestWindows.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.schedule, size: 20, color: AppColors.teal),
                SizedBox(width: 8),
                Text(
                  'Best Fishing Windows',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topWindows.map((window) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WindowItem(window: window),
            )),
          ],
        ),
      ),
    );
  }
}

class _WindowItem extends StatelessWidget {
  final TimeWindow window;

  const _WindowItem({required this.window});

  @override
  Widget build(BuildContext context) {
    final windowColor = window.feedingType == FeedingWindow.major
        ? AppColors.success
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: windowColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: windowColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            window.feedingType == FeedingWindow.major
                ? Icons.star
                : Icons.star_half,
            size: 16,
            color: windowColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  window.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: windowColor,
                  ),
                ),
                Text(
                  window.reason,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: windowColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(window.activityScore * 100).round()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: windowColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepthStrategyCard extends StatelessWidget {
  final TripPlan plan;

  const _DepthStrategyCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final depth = plan.depthStrategy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.layers, size: 20, color: AppColors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Depth Strategy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    depth.depthRange,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              depth.zone,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              depth.reasoning,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TacticsCard extends StatelessWidget {
  final TripPlan plan;

  const _TacticsCard({required this.plan});

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
                Icon(Icons.psychology, size: 18, color: AppColors.warning),
                SizedBox(width: 6),
                Text(
                  'Tactics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.tactics.map((tactic) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tactic,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TopBaitsCard extends StatelessWidget {
  final TripPlan plan;

  const _TopBaitsCard({required this.plan});

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
                Icon(Icons.phishing, size: 18, color: AppColors.success),
                SizedBox(width: 6),
                Text(
                  'Top Baits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.topBaits.asMap().entries.map((entry) {
              final index = entry.key;
              final bait = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bait,
                        style: const TextStyle(
                          fontSize: 12,
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

class _WarningsCard extends StatelessWidget {
  final TripPlan plan;

  const _WarningsCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber, size: 20, color: AppColors.error),
                SizedBox(width: 8),
                Text(
                  'Warnings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.warnings.map((warning) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                warning,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ConditionsBreakdownCard extends StatelessWidget {
  final TripPlan plan;

  const _ConditionsBreakdownCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final conditions = plan.conditions;

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
                  'Conditions Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ConditionItem(
              label: 'Water Temperature',
              value: '${conditions.waterTempF.round()}°F',
              score: conditions.tempScore,
              icon: Icons.thermostat,
            ),
            _ConditionItem(
              label: 'Barometric Pressure',
              value: '${conditions.pressureMb.round()} mb (${conditions.pressureTrend})',
              score: conditions.pressureScore,
              icon: Icons.speed,
            ),
            _ConditionItem(
              label: 'Wind Speed',
              value: '${conditions.windSpeedMph.round()} mph',
              score: conditions.windScore,
              icon: Icons.air,
            ),
            _ConditionItem(
              label: 'Solunar Period',
              value: 'Rating: ${(conditions.solunarScore * 10).toStringAsFixed(1)}/10',
              score: conditions.solunarScore,
              icon: Icons.brightness_2,
            ),
            _ConditionItem(
              label: 'Water Clarity',
              value: 'Good for ${conditions.season.toLowerCase()}',
              score: conditions.clarityScore,
              icon: Icons.visibility,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  final String label;
  final String value;
  final double score;
  final IconData icon;

  const _ConditionItem({
    required this.label,
    required this.value,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = score >= 0.7
        ? AppColors.success
        : score >= 0.5
            ? AppColors.warning
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(score * 100).round()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}