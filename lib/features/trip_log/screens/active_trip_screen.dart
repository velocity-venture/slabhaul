import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/trip_log.dart';
import '../../../core/models/tournament.dart';
import '../../../core/models/livewell.dart';
import '../../../core/utils/constants.dart';
import '../../../core/providers/tournament_providers.dart';
import '../../../core/providers/livewell_providers.dart';
import '../providers/trip_log_providers.dart';
import '../widgets/add_catch_dialog.dart';
import '../widgets/start_trip_dialog.dart';
import '../widgets/tournament_bag_widget.dart';

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
    final isTournament = ref.watch(isTournamentActiveProvider);
    final livewellAlert = ref.watch(livewellAlertProvider);

    return Column(
      children: [
        // Trip header with timer
        _TripHeader(
          trip: trip,
          duration: timerAsync.valueOrNull ?? Duration.zero,
          onEndTrip: () => _confirmEndTrip(context, ref),
        ),

        // Tournament bag (when tournament is active)
        if (isTournament)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TournamentBagWidget(),
          ),

        // Livewell alert (when conditions are being tracked)
        if (livewellAlert != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _LivewellAlertCard(alert: livewellAlert),
          ),

        // Catches list
        Expanded(
          child: trip.catches.isEmpty
              ? _EmptyCatchesState()
              : _CatchesList(
                  catches: trip.catches.reversed.toList(),
                  isTournament: isTournament,
                ),
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

class _TripHeader extends ConsumerWidget {
  final FishingTrip trip;
  final Duration duration;
  final VoidCallback onEndTrip;

  const _TripHeader({
    required this.trip,
    required this.duration,
    required this.onEndTrip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const SizedBox(height: 8),
          // Trip tools row
          Row(
            children: [
              _TripToolChip(
                icon: Icons.emoji_events,
                label: 'Tournament',
                onTap: () => _showTournamentSetup(context),
              ),
              const SizedBox(width: 8),
              _TripToolChip(
                icon: Icons.water_drop,
                label: 'Livewell',
                onTap: () => _showLivewellSetup(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTournamentSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _TournamentSetupSheet(),
    );
  }

  void _showLivewellSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _LivewellSetupSheet(),
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
  final bool isTournament;

  const _CatchesList({required this.catches, this.isTournament = false});

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

    if (result == null) return;

    // Log to trip
    await ref.read(activeTripNotifierProvider.notifier).addCatch(
          species: result.species,
          lengthInches: result.lengthInches,
          weightLbs: result.weightLbs,
          depthFt: result.depthFt,
          bait: result.bait,
          notes: result.notes,
          released: result.released,
        );

    // Tournament bag integration
    if (isTournament &&
        result.weightLbs != null &&
        result.lengthInches != null) {
      final bagNotifier = ref.read(tournamentBagProvider.notifier);
      final bag = ref.read(tournamentBagProvider);

      if (!bag.isFull) {
        bagNotifier.addFish(
          weightLbs: result.weightLbs!,
          lengthInches: result.lengthInches!,
          species: result.species,
        );
      } else {
        // Check for cull opportunity
        final cullResult = bagNotifier.cullSmallest(
          weightLbs: result.weightLbs!,
          lengthInches: result.lengthInches!,
          species: result.species,
        );
        if (cullResult != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success.withValues(alpha: 0.9),
              content: Text(
                'Culled ${cullResult.removedFish.weightLbs.toStringAsFixed(2)} lbs  '
                '+${cullResult.weightGain.toStringAsFixed(2)} lbs gained!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Update livewell fish count if tracking
      final conditions = ref.read(livewellConditionsProvider);
      if (conditions != null) {
        ref.read(livewellConditionsProvider.notifier).state =
            conditions.copyWith(fishCount: conditions.fishCount + 1);
      }
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

// ---------------------------------------------------------------------------
// Trip Tool Chip (header action buttons)
// ---------------------------------------------------------------------------

class _TripToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TripToolChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tournament Setup Sheet
// ---------------------------------------------------------------------------

class _TournamentSetupSheet extends ConsumerStatefulWidget {
  const _TournamentSetupSheet();

  @override
  ConsumerState<_TournamentSetupSheet> createState() =>
      _TournamentSetupSheetState();
}

class _TournamentSetupSheetState
    extends ConsumerState<_TournamentSetupSheet> {
  int _bagLimit = 7;
  double _minLength = 9.0;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(tournamentConfigProvider);
    if (existing != null) {
      _bagLimit = existing.bagLimit;
      _minLength = existing.minLengthInches;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = ref.watch(isTournamentActiveProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tournament Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your bag, cull the smallest fish, and optimize your total weight.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Bag limit
          Row(
            children: [
              const Text('Bag Limit',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Text('$_bagLimit fish',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealLight)),
            ],
          ),
          Slider(
            value: _bagLimit.toDouble(),
            min: 3,
            max: 15,
            divisions: 12,
            onChanged: (v) => setState(() => _bagLimit = v.round()),
          ),

          // Min length
          Row(
            children: [
              const Text('Min Length',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Text('${_minLength.toStringAsFixed(1)}"',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealLight)),
            ],
          ),
          Slider(
            value: _minLength,
            min: 7.0,
            max: 15.0,
            divisions: 16,
            onChanged: (v) => setState(() => _minLength = v),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              if (isActive)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(tournamentConfigProvider.notifier).state = null;
                      ref.read(tournamentBagProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('End Tournament',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ),
              if (isActive) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final config = TournamentConfig(
                      bagLimit: _bagLimit,
                      minLengthInches: _minLength,
                    );
                    ref.read(tournamentConfigProvider.notifier).state = config;
                    ref.read(tournamentBagProvider.notifier).configure(config);
                    Navigator.pop(context);
                  },
                  child: Text(isActive ? 'Update' : 'Start Tournament'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Livewell Setup Sheet
// ---------------------------------------------------------------------------

class _LivewellSetupSheet extends ConsumerStatefulWidget {
  const _LivewellSetupSheet();

  @override
  ConsumerState<_LivewellSetupSheet> createState() =>
      _LivewellSetupSheetState();
}

class _LivewellSetupSheetState extends ConsumerState<_LivewellSetupSheet> {
  int _fishCount = 0;
  double _waterTempF = 72;
  bool _hasAerator = false;
  bool _hasRecirculator = false;
  bool _isInsulated = false;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(livewellConditionsProvider);
    if (existing != null) {
      _fishCount = existing.fishCount;
      _waterTempF = existing.waterTempF;
      _hasAerator = existing.hasAerator;
      _hasRecirculator = existing.hasRecirculator;
      _isInsulated = existing.isInsulated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = ref.watch(livewellConditionsProvider) != null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Livewell Monitor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track conditions to keep your crappie alive and healthy.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Fish count
          Row(
            children: [
              const Text('Fish in Livewell',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Text('$_fishCount',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealLight)),
            ],
          ),
          Slider(
            value: _fishCount.toDouble(),
            min: 0,
            max: 30,
            divisions: 30,
            onChanged: (v) => setState(() => _fishCount = v.round()),
          ),

          // Water temp
          Row(
            children: [
              const Text('Livewell Water Temp',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Text('${_waterTempF.round()}F',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealLight)),
            ],
          ),
          Slider(
            value: _waterTempF,
            min: 40,
            max: 100,
            divisions: 60,
            onChanged: (v) => setState(() => _waterTempF = v),
          ),

          // Equipment toggles
          const SizedBox(height: 4),
          _EquipmentToggle(
            label: 'Aerator Running',
            value: _hasAerator,
            onChanged: (v) => setState(() => _hasAerator = v),
          ),
          _EquipmentToggle(
            label: 'Recirculating Pump',
            value: _hasRecirculator,
            onChanged: (v) => setState(() => _hasRecirculator = v),
          ),
          _EquipmentToggle(
            label: 'Insulated Livewell',
            value: _isInsulated,
            onChanged: (v) => setState(() => _isInsulated = v),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              if (isTracking)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(livewellConditionsProvider.notifier).state =
                          null;
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Stop Tracking',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ),
              if (isTracking) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(livewellConditionsProvider.notifier).state =
                        LivewellConditions(
                      waterTempF: _waterTempF,
                      airTempF: _waterTempF + 10, // rough estimate
                      fishCount: _fishCount,
                      hasAerator: _hasAerator,
                      hasRecirculator: _hasRecirculator,
                      isInsulated: _isInsulated,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(isTracking ? 'Update' : 'Start Monitoring'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
        ],
      ),
    );
  }
}

class _EquipmentToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _EquipmentToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.teal.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? AppColors.teal
                  : AppColors.textMuted;
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Livewell Alert Card
// ---------------------------------------------------------------------------

class _LivewellAlertCard extends StatelessWidget {
  final LivewellAlert alert;

  const _LivewellAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final IconData statusIcon;
    switch (alert.status) {
      case LivewellStatus.safe:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
      case LivewellStatus.caution:
        statusColor = AppColors.warning;
        statusIcon = Icons.warning;
      case LivewellStatus.danger:
        statusColor = AppColors.error;
        statusIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 8),
              Text(
                'Livewell: ${alert.status.displayName}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          if (alert.recommendation.isNotEmpty &&
              alert.status != LivewellStatus.safe) ...[
            const SizedBox(height: 4),
            Text(
              alert.recommendation,
              style: TextStyle(
                fontSize: 10,
                color: statusColor.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
