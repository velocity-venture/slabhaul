import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/trip_log.dart';
import '../../../core/utils/constants.dart';
import '../providers/trip_log_providers.dart';
import '../widgets/add_catch_dialog.dart';
import '../widgets/start_trip_dialog.dart';

class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTripAsync = ref.watch(activeTripNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Current Trip',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trips'),
        ),
      ),
      body: activeTripAsync.when(
        data: (trip) {
          if (trip == null) {
            return _NoActiveTrip(
              onStartTrip: () => _showStartTripDialog(context, ref),
            );
          }
          return _ActiveTripView(trip: trip);
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

  Future<void> _showStartTripDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String? lakeId, String? lakeName})>(
      context: context,
      builder: (context) => const StartTripDialog(),
    );

    if (result != null) {
      await ref.read(activeTripNotifierProvider.notifier).startTrip(
            lakeId: result.lakeId,
            lakeName: result.lakeName,
          );
    }
  }
}

class _NoActiveTrip extends StatelessWidget {
  final VoidCallback onStartTrip;

  const _NoActiveTrip({required this.onStartTrip});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_boat,
                size: 64,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ready to Fish?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start a trip to track your catches\nand build your fishing database.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onStartTrip,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text(
                'Start Trip',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveTripView extends ConsumerWidget {
  final FishingTrip trip;

  const _ActiveTripView({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerAsync = ref.watch(tripTimerProvider);

    return Column(
      children: [
        // Trip header with timer
        _TripHeader(
          trip: trip,
          duration: timerAsync.valueOrNull ?? Duration.zero,
          onEndTrip: () => _confirmEndTrip(context, ref),
        ),

        // Catches list
        Expanded(
          child: trip.catches.isEmpty
              ? _EmptyCatchesState()
              : _CatchesList(catches: trip.catches.reversed.toList()),
        ),
      ],
    );
  }

  Future<void> _confirmEndTrip(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('End Trip?'),
        content: Text(
          'You\'ve caught ${trip.catches.length} fish. Ready to wrap up?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Fishing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(activeTripNotifierProvider.notifier).endTrip();
      if (context.mounted) {
        context.go('/trips');
      }
    }
  }
}

class _TripHeader extends StatelessWidget {
  final FishingTrip trip;
  final Duration duration;
  final VoidCallback onEndTrip;

  const _TripHeader({
    required this.trip,
    required this.duration,
    required this.onEndTrip,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Lake name and duration
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: AppColors.success,
                          size: 10,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          trip.lakeName ?? 'Fishing Trip',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Started ${timeFormat.format(trip.startedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 16, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats and actions row
          Row(
            children: [
              // Catch count
              _QuickStat(
                icon: Icons.phishing,
                value: trip.catches.length.toString(),
                label: 'Catches',
              ),
              const SizedBox(width: 16),
              // Crappie count
              _QuickStat(
                icon: Icons.water,
                value: trip.catches
                    .where((c) => c.species.isCrappie)
                    .length
                    .toString(),
                label: 'Crappie',
              ),
              const Spacer(),
              // End trip button
              TextButton.icon(
                onPressed: onEndTrip,
                icon: const Icon(Icons.stop_circle, color: AppColors.error),
                label: const Text(
                  'End Trip',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyCatchesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.catching_pokemon,
            size: 48,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No catches yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button when you catch one!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatchesList extends ConsumerWidget {
  final List<CatchRecord> catches;

  const _CatchesList({required this.catches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: catches.length,
          itemBuilder: (context, index) {
            final catch_ = catches[index];
            return _CatchCard(
              catch_: catch_,
              index: catches.length - index,
              onDelete: () => _deleteCatch(context, ref, catch_),
            );
          },
        ),
        // Add catch FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddCatchDialog(context, ref),
            backgroundColor: AppColors.teal,
            icon: const Icon(Icons.add),
            label: const Text('Add Catch'),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCatchDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<CatchDialogResult>(
      context: context,
      builder: (context) => const AddCatchDialog(),
    );

    if (result != null) {
      await ref.read(activeTripNotifierProvider.notifier).addCatch(
            species: result.species,
            lengthInches: result.lengthInches,
            weightLbs: result.weightLbs,
            depthFt: result.depthFt,
            bait: result.bait,
            notes: result.notes,
            released: result.released,
          );
    }
  }

  Future<void> _deleteCatch(
    BuildContext context,
    WidgetRef ref,
    CatchRecord catch_,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Catch?'),
        content: Text(
          'Remove this ${catch_.species.displayName}?',
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
      await ref.read(activeTripNotifierProvider.notifier).deleteCatch(catch_.id);
    }
  }
}

class _CatchCard extends StatelessWidget {
  final CatchRecord catch_;
  final int index;
  final VoidCallback onDelete;

  const _CatchCard({
    required this.catch_,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Index badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '#$index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Catch info
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
                      const SizedBox(width: 8),
                      Text(
                        catch_.sizeDisplay,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.tealLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        timeFormat.format(catch_.caughtAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (catch_.depthFt != null) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        Text(
                          '${catch_.depthFt!.round()}ft',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (catch_.bait != null) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        Flexible(
                          child: Text(
                            catch_.bait!.display,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textMuted,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
