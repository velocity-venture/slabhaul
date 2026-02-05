import 'package:flutter/material.dart';
import 'package:slabhaul/core/models/generation_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/time_ago.dart';
import 'generation_history_graph.dart';

/// Card showing current dam generation status with schedule and history.
class GenerationStatusCard extends StatelessWidget {
  final GenerationData data;

  const GenerationStatusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data.currentStatus;
    final statusColor = _statusColor(status);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dam name
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _statusIcon(status),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dam Generation',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        data.damName,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                          boxShadow: status == GenerationStatus.generating
                              ? [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusText(status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current discharge stats
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'Current Flow',
                    value: data.currentDischargeCfs != null
                        ? '${_formatNumber(data.currentDischargeCfs!)} cfs'
                        : '--',
                    valueColor: statusColor,
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: 'Baseflow',
                    value: data.baseflowCfs != null
                        ? '${_formatNumber(data.baseflowCfs!)} cfs'
                        : '--',
                    valueColor: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: 'Flow Ratio',
                    value: data.dischargeRatio != null
                        ? '${data.dischargeRatio!.toStringAsFixed(1)}x'
                        : '--',
                    valueColor: data.dischargeRatio != null &&
                            data.dischargeRatio! >= 2.0
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Next scheduled generation
            if (!data.isGenerating && data.nextScheduled != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppColors.info,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Next Expected Generation',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatScheduledTime(data.nextScheduled!),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTimeUntil(data.timeUntilGeneration),
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Generation history chart (now with intensity colors)
            if (data.recentReadings.isNotEmpty) ...[
              const Text(
                '48hr Generation History',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: GenerationHistoryMini(
                  readings: data.recentReadings,
                  baseflow: data.baseflowCfs,
                ),
              ),
            ],

            // Fishing tip
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.teal,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getFishingTip(status),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Last updated
            if (data.lastUpdated != null) ...[
              const SizedBox(height: 10),
              Text(
                'Updated: ${formatTimeAgo(data.lastUpdated!)}',
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

  IconData _statusIcon(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.generating:
        return Icons.waves;
      case GenerationStatus.scheduled:
        return Icons.schedule;
      case GenerationStatus.idle:
        return Icons.water_drop_outlined;
      case GenerationStatus.unknown:
        return Icons.help_outline;
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

  String _formatNumber(double n) {
    if (n >= 10000) {
      return '${(n / 1000).toStringAsFixed(0)}K';
    }
    return n.toStringAsFixed(0);
  }

  String _formatScheduledTime(ScheduledGeneration sched) {
    final start = sched.startTime;
    final now = DateTime.now();
    final isToday = start.day == now.day &&
        start.month == now.month &&
        start.year == now.year;
    final isTomorrow = start.day == now.add(const Duration(days: 1)).day &&
        start.month == now.add(const Duration(days: 1)).month;

    final timeStr = _formatTime(start);
    if (isToday) return 'Today $timeStr';
    if (isTomorrow) return 'Tomorrow $timeStr';
    return '${_dayName(start.weekday)} $timeStr';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatTimeUntil(Duration? d) {
    if (d == null) return '--';
    if (d == Duration.zero) return 'Now';
    if (d.inHours >= 24) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }


  String _getFishingTip(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.generating:
        return 'Current is ON! Fish the eddies behind structure. '
            'Crappie move to current breaks to ambush baitfish.';
      case GenerationStatus.scheduled:
        return 'Generation expected soon. Position near ledges and '
            'main-channel points where fish stage before current starts.';
      case GenerationStatus.idle:
        return 'No current - fish will be tighter to cover. '
            'Work brushpiles and standing timber more slowly.';
      case GenerationStatus.unknown:
        return 'Watch for water movement and baitfish activity '
            'to determine if generation has started.';
    }
  }
}

// ---------------------------------------------------------------------------
// Stat block
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
