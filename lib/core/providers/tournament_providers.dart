import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tournament.dart';
import '../models/trip_log.dart';

// ---------------------------------------------------------------------------
// Tournament Config
// ---------------------------------------------------------------------------

/// The active tournament configuration, or null when no tournament is running.
final tournamentConfigProvider = StateProvider<TournamentConfig?>((ref) {
  return null;
});

// ---------------------------------------------------------------------------
// Tournament Bag Notifier
// ---------------------------------------------------------------------------

/// Manages the mutable tournament bag state.
class TournamentBagNotifier extends StateNotifier<TournamentBag> {
  TournamentBagNotifier() : super(const TournamentBag());

  /// Initialise (or re-initialise) the bag with a new config's bag limit.
  void configure(TournamentConfig config) {
    state = TournamentBag(
      fish: const [],
      bagLimit: config.bagLimit,
      cullHistory: const [],
    );
  }

  /// Generate a simple unique ID (same pattern used by TripLogService).
  String _generateId() {
    final now = DateTime.now();
    final micro = (now.microsecond % 1000).toString().padLeft(3, '0');
    return '${now.millisecondsSinceEpoch}_$micro';
  }

  /// Add a fish to the bag (when bag is not yet full).
  /// Returns the created [TournamentFish].
  TournamentFish addFish({
    required double weightLbs,
    required double lengthInches,
    required FishSpecies species,
    DateTime? caughtAt,
  }) {
    final fish = TournamentFish(
      id: _generateId(),
      weightLbs: weightLbs,
      lengthInches: lengthInches,
      species: species,
      caughtAt: caughtAt ?? DateTime.now(),
    );
    state = state.addFish(fish);
    return fish;
  }

  /// Attempt to cull the smallest fish if [newFish] params are heavier.
  /// Returns the [CullResult] or null if no improvement.
  CullResult? cullSmallest({
    required double weightLbs,
    required double lengthInches,
    required FishSpecies species,
    DateTime? caughtAt,
  }) {
    final newFish = TournamentFish(
      id: _generateId(),
      weightLbs: weightLbs,
      lengthInches: lengthInches,
      species: species,
      caughtAt: caughtAt ?? DateTime.now(),
    );

    final (:bag, :result) = state.cullSmallest(newFish);
    state = bag;
    return result;
  }

  /// Remove a specific fish by ID.
  void removeFish(String fishId) {
    state = state.removeFish(fishId);
  }

  /// Reset the bag to empty, keeping the current bag limit.
  void reset() {
    state = state.reset();
  }
}

/// Manages the tournament bag during an active tournament.
final tournamentBagProvider =
    StateNotifierProvider<TournamentBagNotifier, TournamentBag>((ref) {
  return TournamentBagNotifier();
});

// ---------------------------------------------------------------------------
// Derived / Convenience Providers
// ---------------------------------------------------------------------------

/// Whether a tournament is currently active.
final isTournamentActiveProvider = Provider<bool>((ref) {
  return ref.watch(tournamentConfigProvider) != null;
});

/// The potential weight gain if the given weight were to cull the smallest fish.
/// Returns null when the bag is not full or the weight would not improve.
final potentialCullGainProvider =
    Provider.family<double?, double>((ref, newWeightLbs) {
  final bag = ref.watch(tournamentBagProvider);
  if (!bag.isFull) return null;
  final smallest = bag.smallestFish;
  if (smallest == null) return null;
  final gain = newWeightLbs - smallest.weightLbs;
  return gain > 0 ? gain : null;
});
