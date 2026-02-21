import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/streamflow_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/streamflow_providers.dart';
import 'package:slabhaul/features/streamflow/widgets/streamflow_graph.dart';

/// Bottom sheet showing detailed streamflow information for selected inflow.
class StreamflowBottomSheet extends ConsumerWidget {
  const StreamflowBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInflow = ref.watch(selectedInflowProvider);
    
    if (selectedInflow == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // Prevent taps from dismissing
        child: Container(
          constraints: const BoxConstraints(maxHeight: 420),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Header
                _Header(inflow: selectedInflow),
                const SizedBox(height: 16),

                // Current conditions
                _CurrentConditions(inflow: selectedInflow),
                const SizedBox(height: 16),

                // Streamflow graph (if live data available)
                if (selectedInflow.hasLiveData) ...[
                  const _StreamflowHistorySection(),
                  const SizedBox(height: 16),
                ],

                // Fishing impact
                if (selectedInflow.hasLiveData)
                  const _FishingImpactSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final InflowConditions inflow;

  const _Header({required this.inflow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            inflow.hasLiveData ? Icons.sensors : Icons.water_drop,
            color: AppColors.info,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),

        // Name and stream
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                inflow.inflow.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                inflow.inflow.streamName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Close button
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textMuted),
          onPressed: () {
            ref.read(selectedInflowProvider.notifier).state = null;
          },
        ),
      ],
    );
  }
}

class _CurrentConditions extends StatelessWidget {
  final InflowConditions inflow;

  const _CurrentConditions({required this.inflow});

  @override
  Widget build(BuildContext context) {
    final hasLive = inflow.hasLiveData;
    final conditions = inflow.conditions;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Current flow
              Expanded(
                child: _StatItem(
                  icon: Icons.water,
                  label: hasLive ? 'Current Flow' : 'Avg. Annual Flow',
                  value: _formatFlow(inflow.currentFlowCfs),
                  valueColor: AppColors.textPrimary,
                ),
              ),

              // Trend (if live)
              if (hasLive)
                Expanded(
                  child: _StatItem(
                    icon: _trendIcon(inflow.trend),
                    label: 'Trend',
                    value: _trendLabel(inflow.trend),
                    valueColor: _trendColor(inflow.trend),
                  ),
                ),
            ],
          ),

          if (hasLive && conditions != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 12),
            Row(
              children: [
                // Comparison to normal
                Expanded(
                  child: _StatItem(
                    icon: Icons.compare_arrows,
                    label: 'vs Normal',
                    value: _comparisonLabel(conditions.comparisonToNormal),
                    valueColor: _comparisonColor(conditions.comparisonToNormal),
                  ),
                ),

                // 24h change
                if (conditions.change24HourPercent != null)
                  Expanded(
                    child: _StatItem(
                      icon: Icons.schedule,
                      label: '24h Change',
                      value: '${conditions.change24HourPercent! >= 0 ? '+' : ''}${conditions.change24HourPercent!.toStringAsFixed(0)}%',
                      valueColor: conditions.change24HourPercent! > 0
                          ? AppColors.success
                          : conditions.change24HourPercent! < 0
                              ? AppColors.warning
                              : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],

          // Gage height (if available)
          if (conditions?.currentReading.gageHeightFt != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.height,
                    label: 'Gage Height',
                    value: '${conditions!.currentReading.gageHeightFt!.toStringAsFixed(2)} ft',
                    valueColor: AppColors.textPrimary,
                  ),
                ),
                if (inflow.inflow.drainageAreaSqMi != null)
                  Expanded(
                    child: _StatItem(
                      icon: Icons.landscape,
                      label: 'Drainage Area',
                      value: '${inflow.inflow.drainageAreaSqMi!.toStringAsFixed(0)} sq mi',
                      valueColor: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ],

          // Live data badge
          if (hasLive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live USGS data • ${inflow.inflow.usgsGageId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Estimated data (no USGS gage)',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFlow(double flow) {
    if (flow >= 10000) {
      return '${(flow / 1000).toStringAsFixed(1)}K cfs';
    }
    return '${flow.toStringAsFixed(0)} cfs';
  }

  IconData _trendIcon(FlowTrend trend) {
    switch (trend) {
      case FlowTrend.rising:
        return Icons.trending_up;
      case FlowTrend.falling:
        return Icons.trending_down;
      case FlowTrend.stable:
        return Icons.trending_flat;
    }
  }

  String _trendLabel(FlowTrend trend) {
    switch (trend) {
      case FlowTrend.rising:
        return 'Rising';
      case FlowTrend.falling:
        return 'Falling';
      case FlowTrend.stable:
        return 'Stable';
    }
  }

  Color _trendColor(FlowTrend trend) {
    switch (trend) {
      case FlowTrend.rising:
        return AppColors.success;
      case FlowTrend.falling:
        return AppColors.warning;
      case FlowTrend.stable:
        return AppColors.textSecondary;
    }
  }

  String _comparisonLabel(FlowComparison comparison) {
    switch (comparison) {
      case FlowComparison.unknown:
        return 'Unknown';
      case FlowComparison.muchBelowNormal:
        return 'Much Below';
      case FlowComparison.belowNormal:
        return 'Below Normal';
      case FlowComparison.normal:
        return 'Normal';
      case FlowComparison.aboveNormal:
        return 'Above Normal';
      case FlowComparison.muchAboveNormal:
        return 'Much Above';
    }
  }

  Color _comparisonColor(FlowComparison comparison) {
    switch (comparison) {
      case FlowComparison.unknown:
        return AppColors.textMuted;
      case FlowComparison.muchBelowNormal:
        return AppColors.error;
      case FlowComparison.belowNormal:
        return AppColors.warning;
      case FlowComparison.normal:
        return AppColors.success;
      case FlowComparison.aboveNormal:
        return AppColors.info;
      case FlowComparison.muchAboveNormal:
        return const Color(0xFFEC4899); // Pink
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StreamflowHistorySection extends ConsumerWidget {
  const _StreamflowHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(selectedInflowHistoryProvider);
    final selectedInflow = ref.watch(selectedInflowProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.show_chart, size: 18, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              '7-Day Flow History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          data: (readings) {
            if (readings.isEmpty) {
              return Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.card.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Unable to load history',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              );
            }

            return StreamflowGraph(
              readings: readings,
              historicalMedian: selectedInflow?.conditions?.historicalMedianCfs,
            );
          },
          loading: () => Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.info),
            ),
          ),
          error: (_, __) => Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Error loading data',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FishingImpactSection extends ConsumerWidget {
  const _FishingImpactSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impact = ref.watch(inflowFishingImpactProvider);

    if (impact == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.catching_pokemon,
              size: 18,
              color: _impactColor(impact.overallImpact),
            ),
            const SizedBox(width: 8),
            const Text(
              'Fishing Impact',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _impactColor(impact.overallImpact).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _impactLabel(impact.overallImpact),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _impactColor(impact.overallImpact),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                impact.summary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),

              if (impact.positives.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...impact.positives.map((p) => _ImpactBullet(
                  text: p,
                  icon: Icons.add_circle_outline,
                  color: AppColors.success,
                )),
              ],

              if (impact.negatives.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...impact.negatives.map((n) => _ImpactBullet(
                  text: n,
                  icon: Icons.remove_circle_outline,
                  color: AppColors.warning,
                )),
              ],

              if (impact.recommendations.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Recommendations:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                ...impact.recommendations.map((r) => _ImpactBullet(
                  text: r,
                  icon: Icons.lightbulb_outline,
                  color: AppColors.info,
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _impactColor(FlowImpactLevel level) {
    switch (level) {
      case FlowImpactLevel.poor:
        return AppColors.error;
      case FlowImpactLevel.fair:
        return AppColors.warning;
      case FlowImpactLevel.good:
        return AppColors.success;
      case FlowImpactLevel.excellent:
        return AppColors.teal;
    }
  }

  String _impactLabel(FlowImpactLevel level) {
    switch (level) {
      case FlowImpactLevel.poor:
        return 'Poor';
      case FlowImpactLevel.fair:
        return 'Fair';
      case FlowImpactLevel.good:
        return 'Good';
      case FlowImpactLevel.excellent:
        return 'Excellent';
    }
  }
}

class _ImpactBullet extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _ImpactBullet({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
