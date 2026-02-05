import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/generation_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/time_ago.dart';
import 'package:slabhaul/features/generation/providers/generation_detail_providers.dart';
import 'package:slabhaul/shared/widgets/skeleton_loader.dart';
import '../widgets/generation_history_graph.dart';

/// Full-screen detailed view for dam generation monitoring
class GenerationDetailScreen extends ConsumerWidget {
  const GenerationDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genAsync = ref.watch(generationDetailProvider);
    final selectedRange = ref.watch(generationHistoryRangeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Dam Generation',
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
            onPressed: () => ref.invalidate(generationDetailProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: genAsync.when(
        data: (data) {
          if (data == null) {
            return const Center(
              child: Text(
                'No generation data available for this lake',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          return _GenerationDetailContent(
            data: data,
            selectedRange: selectedRange,
            ref: ref,
          );
        },
        loading: () => const _LoadingState(),
        error: (error, _) => _ErrorState(
          onRetry: () => ref.invalidate(generationDetailProvider),
        ),
      ),
    );
  }
}

class _GenerationDetailContent extends StatelessWidget {
  final GenerationData data;
  final HistoryRange selectedRange;
  final WidgetRef ref;

  const _GenerationDetailContent({
    required this.data,
    required this.selectedRange,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(generationDetailProvider);
        await ref.read(generationDetailProvider.future);
      },
      color: AppColors.teal,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dam/Lake info
            Row(
              children: [
                const Icon(Icons.water, color: AppColors.teal, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.damName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${data.lakeName} • ${data.powerAuthority}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current Status Card
            _CurrentStatusCard(data: data),
            const SizedBox(height: 16),

            // Upcoming Schedule
            if (data.upcomingSchedule.isNotEmpty) ...[
              _UpcomingScheduleCard(schedule: data.upcomingSchedule),
              const SizedBox(height: 16),
            ],

            // 7-Day History Chart
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.show_chart, color: AppColors.teal, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Generation History',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Range selector
                    _RangeSelector(
                      selected: selectedRange,
                      onChanged: (range) {
                        ref.read(generationHistoryRangeProvider.notifier)
                            .state = range;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Chart
                    GenerationHistoryGraph(
                      readings: data.recentReadings,
                      baseflow: data.baseflowCfs,
                      daysToShow: selectedRange.days,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Card
            if (data.history7Day != null)
              _StatisticsCard(history: data.history7Day!),
            if (data.history7Day != null) const SizedBox(height: 16),

            // Pattern Detection
            if (data.detectedPattern != null &&
                data.detectedPattern!.confidence > 0.3) ...[
              _PatternCard(pattern: data.detectedPattern!),
              const SizedBox(height: 16),
            ],

            // Fishing Tips
            _FishingTipsCard(status: data.currentStatus),
            const SizedBox(height: 16),

            // Safety Notice
            _SafetyNoticeCard(),
            const SizedBox(height: 16),

            // Data Source
            _DataSourceCard(
              damId: data.damId,
              lastUpdated: data.lastUpdated,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Current Status Card
// ---------------------------------------------------------------------------

class _CurrentStatusCard extends StatelessWidget {
  final GenerationData data;

  const _CurrentStatusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data.currentStatus;
    final statusColor = _statusColor(status);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status badge with glow for generating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: status == GenerationStatus.generating
                        ? [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                          boxShadow: status == GenerationStatus.generating
                              ? [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _statusText(status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Generator count if generating
            if (data.currentGeneratorCount != null &&
                data.currentGeneratorCount! > 0) ...[
              Text(
                '${data.currentGeneratorCount} Generator${data.currentGeneratorCount! > 1 ? 's' : ''} Running',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Main flow display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.currentDischargeCfs != null
                      ? _formatLargeNumber(data.currentDischargeCfs!)
                      : '--',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'cfs',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Current Discharge',
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
                    label: 'Baseflow',
                    value: data.baseflowCfs != null
                        ? '${_formatNumber(data.baseflowCfs!)} cfs'
                        : '--',
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.cardBorder),
                Expanded(
                  child: _StatColumn(
                    label: 'Flow Ratio',
                    value: data.dischargeRatio != null
                        ? '${data.dischargeRatio!.toStringAsFixed(1)}x'
                        : '--',
                    color: data.dischargeRatio != null &&
                            data.dischargeRatio! >= 2.0
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.cardBorder),
                Expanded(
                  child: _StatColumn(
                    label: 'Next Expected',
                    value: _formatTimeUntil(data.timeUntilGeneration),
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.generating:
        return AppColors.success;
      case GenerationStatus.scheduled:
        return AppColors.warning;
      case GenerationStatus.idle:
        return AppColors.textMuted;
      case GenerationStatus.unknown:
        return AppColors.textMuted;
    }
  }

  String _statusText(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.generating:
        return 'GENERATING';
      case GenerationStatus.scheduled:
        return 'SCHEDULED';
      case GenerationStatus.idle:
        return 'IDLE';
      case GenerationStatus.unknown:
        return 'UNKNOWN';
    }
  }

  String _formatTimeUntil(Duration? d) {
    if (d == null) return 'Unknown';
    if (d == Duration.zero) return 'Now';
    if (d.inHours >= 24) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }

  String _formatNumber(double n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  String _formatLargeNumber(double n) {
    if (n >= 100000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
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

// ---------------------------------------------------------------------------
// Upcoming Schedule Card
// ---------------------------------------------------------------------------

class _UpcomingScheduleCard extends StatelessWidget {
  final List<ScheduledGeneration> schedule;

  const _UpcomingScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    // Show next 4 scheduled windows
    final upcoming = schedule.take(4).toList();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.schedule, color: AppColors.info, size: 18),
                SizedBox(width: 8),
                Text(
                  'Forecast (48hr)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Based on typical patterns',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            ...upcoming.map((sched) => _ScheduleRow(schedule: sched)),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final ScheduledGeneration schedule;

  const _ScheduleRow({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final start = schedule.startTime;
    final now = DateTime.now();
    final isToday = start.day == now.day;
    final isTomorrow = start.day == now.add(const Duration(days: 1)).day;

    String dayStr;
    if (isToday) {
      dayStr = 'Today';
    } else if (isTomorrow) {
      dayStr = 'Tomorrow';
    } else {
      dayStr = _dayName(start.weekday);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.info.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$dayStr ${_formatTime(start)} - ${schedule.endTime != null ? _formatTime(schedule.endTime!) : '?'}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          if (schedule.notes != null)
            Expanded(
              child: Text(
                schedule.notes!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

// ---------------------------------------------------------------------------
// Range Selector
// ---------------------------------------------------------------------------

class _RangeSelector extends StatelessWidget {
  final HistoryRange selected;
  final Function(HistoryRange) onChanged;

  const _RangeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: HistoryRange.values.map((range) {
        final isSelected = range == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(range),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.teal.withValues(alpha: 0.15)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(color: AppColors.teal.withValues(alpha: 0.5))
                    : null,
              ),
              child: Text(
                range.label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.teal : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Statistics Card
// ---------------------------------------------------------------------------

class _StatisticsCard extends StatelessWidget {
  final GenerationHistory history;

  const _StatisticsCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppColors.teal, size: 18),
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
                  icon: Icons.power,
                  label: 'Gen Time',
                  value: '${history.generatingPercent.toStringAsFixed(0)}%',
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  icon: Icons.arrow_upward,
                  label: 'Max Flow',
                  value: '${(history.maxFlowCfs / 1000).toStringAsFixed(0)}K',
                  unit: 'cfs',
                  color: AppColors.info,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  icon: Icons.trending_flat,
                  label: 'Avg Flow',
                  value: '${(history.averageFlowCfs / 1000).toStringAsFixed(0)}K',
                  unit: 'cfs',
                  color: AppColors.teal,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total generation: ${_formatDuration(history.totalGenerationTime)}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${history.generationWindows.length} generation windows',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 24) {
      return '${d.inDays}d ${d.inHours % 24}h';
    }
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
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
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
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
                  if (unit != null)
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

// ---------------------------------------------------------------------------
// Pattern Detection Card
// ---------------------------------------------------------------------------

class _PatternCard extends StatelessWidget {
  final DetectedPattern pattern;

  const _PatternCard({required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pattern,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Detected Pattern',
                    style: TextStyle(
                      fontSize: 15,
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
                    color: _confidenceColor(pattern.confidence)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(pattern.confidence * 100).toStringAsFixed(0)}% confidence',
                    style: TextStyle(
                      fontSize: 10,
                      color: _confidenceColor(pattern.confidence),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              pattern.description,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PatternStat(
                    label: 'Weekday Frequency',
                    value: '${(pattern.weekdayFrequency * 100).toStringAsFixed(0)}%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PatternStat(
                    label: 'Weekend Frequency',
                    value: '${(pattern.weekendFrequency * 100).toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.7) return AppColors.success;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.textMuted;
  }
}

class _PatternStat extends StatelessWidget {
  final String label;
  final String value;

  const _PatternStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fishing Tips Card
// ---------------------------------------------------------------------------

class _FishingTipsCard extends StatelessWidget {
  final GenerationStatus status;

  const _FishingTipsCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final tips = _getTips(status);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.teal, size: 18),
                SizedBox(width: 8),
                Text(
                  'Fishing Tips',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
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

  List<String> _getTips(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.generating:
        return [
          'Current is ON! Fish the eddies behind structure where baitfish congregate.',
          'Crappie move to current breaks to ambush prey. Target bridge pilings and ledges.',
          'Use slightly heavier jigs (1/8 - 1/4 oz) to maintain contact in moving water.',
          'Fish downstream faces of structure where current creates slack water.',
        ];
      case GenerationStatus.scheduled:
        return [
          'Generation expected soon. Position near main-channel points.',
          'Fish will start moving toward current breaks before flow starts.',
          'Pre-stage on ledges at 15-25 ft where fish wait for current.',
          'Have heavier tackle ready for when the current kicks on.',
        ];
      case GenerationStatus.idle:
        return [
          'No current means tighter fish. Work brushpiles and timber slowly.',
          'Light jigs (1/16 oz) and slow presentations are key.',
          'Fish relate closely to structure without current to position them.',
          'Focus on secondary points and creek channel intersections.',
        ];
      case GenerationStatus.unknown:
        return [
          'Watch for water movement and baitfish activity.',
          'Start shallow and work deeper if conditions change.',
          'Be ready to adjust when generation status becomes clear.',
        ];
    }
  }
}

// ---------------------------------------------------------------------------
// Safety Notice Card
// ---------------------------------------------------------------------------

class _SafetyNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Notice',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dam releases can cause rapid water level changes. '
                  'Stay alert near the dam and in tailwaters. '
                  'Listen for warning sirens before generation starts.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data Source Card
// ---------------------------------------------------------------------------

class _DataSourceCard extends StatelessWidget {
  final String damId;
  final DateTime? lastUpdated;

  const _DataSourceCard({
    required this.damId,
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
                const Text(
                  'Data: USGS Water Services + TVA Patterns',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
                if (lastUpdated != null)
                  Text(
                    'Last updated: ${formatTimeAgo(lastUpdated!)}',
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
}

// ---------------------------------------------------------------------------
// Loading State
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonCard(height: 180),
          SizedBox(height: 16),
          SkeletonCard(height: 120),
          SizedBox(height: 16),
          SkeletonCard(height: 200),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error State
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Failed to load generation data',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
      ),
    );
  }
}
