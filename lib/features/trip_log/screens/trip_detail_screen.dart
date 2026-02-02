import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/trip_log.dart';
import '../../../core/utils/constants.dart';
import '../providers/trip_log_providers.dart';

class TripDetailScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripByIdProvider(tripId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Trip Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Trip'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: tripAsync.when(
        data: (trip) {
          if (trip == null) {
            return const Center(
              child: Text(
                'Trip not found',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          return _TripDetailView(trip: trip);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Trip?'),
        content: const Text(
          'This will permanently delete this trip and all its catches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(tripLogServiceProvider);
      await service.deleteTrip(tripId);
      ref.invalidate(tripsProvider);
      ref.invalidate(aggregateStatsProvider);
      if (context.mounted) {
        context.go('/trips');
      }
    }
  }
}

class _TripDetailView extends StatelessWidget {
  final FishingTrip trip;

  const _TripDetailView({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final stats = trip.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(trip.startedAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${timeFormat.format(trip.startedAt)} - ${trip.endedAt != null ? timeFormat.format(trip.endedAt!) : 'In Progress'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trip.durationDisplay,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Trip stats
          _StatsCard(stats: stats),

          const SizedBox(height: 16),

          // Conditions (if available)
          if (trip.conditions != null) ...[
            _ConditionsCard(conditions: trip.conditions!),
            const SizedBox(height: 16),
          ],

          // What worked summary
          if (stats.catchesByBait.isNotEmpty) ...[
            _WhatWorkedCard(stats: stats),
            const SizedBox(height: 16),
          ],

          // Catches list
          const Text(
            'Catches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (trip.catches.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No catches recorded',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            )
          else
            ...trip.catches.reversed
                .toList()
                .asMap()
                .entries
                .map((entry) => _CatchDetailCard(
                      catch_: entry.value,
                      index: trip.catches.length - entry.key,
                    )),

          // Notes
          if (trip.notes != null && trip.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  trip.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final TripStats stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              value: stats.totalCatches.toString(),
              label: 'Total Catches',
              icon: Icons.phishing,
            ),
            _StatColumn(
              value: stats.crappieCount.toString(),
              label: 'Crappie',
              icon: Icons.water,
            ),
            _StatColumn(
              value: stats.biggestLengthInches != null
                  ? '${stats.biggestLengthInches!.toStringAsFixed(1)}"'
                  : '--',
              label: 'Biggest',
              icon: Icons.straighten,
              valueColor: AppColors.warning,
            ),
            _StatColumn(
              value: stats.averageLengthInches != null
                  ? '${stats.averageLengthInches!.toStringAsFixed(1)}"'
                  : '--',
              label: 'Average',
              icon: Icons.trending_flat,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? valueColor;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  final TripConditions conditions;

  const _ConditionsCard({required this.conditions});

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
                Icon(Icons.cloud, size: 18, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  'Conditions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (conditions.weather?.tempF != null)
                  _ConditionChip(
                    icon: Icons.thermostat,
                    label: '${conditions.weather!.tempF!.round()}°F Air',
                  ),
                if (conditions.waterTempF != null)
                  _ConditionChip(
                    icon: Icons.water,
                    label: '${conditions.waterTempF!.round()}°F Water',
                  ),
                if (conditions.weather?.windSpeedMph != null)
                  _ConditionChip(
                    icon: Icons.air,
                    label:
                        '${conditions.weather!.windSpeedMph!.round()} mph Wind',
                  ),
                if (conditions.clarity != null)
                  _ConditionChip(
                    icon: Icons.visibility,
                    label: conditions.clarity!.displayName,
                  ),
                if (conditions.moonPhase != null)
                  _ConditionChip(
                    icon: Icons.nightlight,
                    label: conditions.moonPhase!.displayName,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ConditionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
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

class _WhatWorkedCard extends StatelessWidget {
  final TripStats stats;

  const _WhatWorkedCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final topBaits = stats.catchesByBait.entries.take(3).toList();

    return Card(
      color: AppColors.teal.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, size: 18, color: AppColors.teal),
                SizedBox(width: 6),
                Text(
                  'What Worked',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...topBaits.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value} fish',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
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

class _CatchDetailCard extends StatelessWidget {
  final CatchRecord catch_;
  final int index;

  const _CatchDetailCard({required this.catch_, required this.index});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: catch_.species.isCrappie
                    ? AppColors.teal.withValues(alpha: 0.2)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '#$index',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: catch_.species.isCrappie
                      ? AppColors.teal
                      : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        catch_.species.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (catch_.lengthInches != null ||
                          catch_.weightLbs != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          catch_.sizeDisplay,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.tealLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    children: [
                      Text(
                        timeFormat.format(catch_.caughtAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (catch_.depthFt != null)
                        Text(
                          '${catch_.depthFt!.round()}ft deep',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      if (catch_.bait != null)
                        Text(
                          catch_.bait!.display,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  if (catch_.notes != null && catch_.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      catch_.notes!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Released indicator
            if (!catch_.released)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Kept',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
