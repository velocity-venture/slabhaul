// Tournament Bag & Cull Tracker Models
//
// Manage tournament fishing bags with bag limits, minimum lengths,
// cull logic, and weight tracking. Crappie-tournament-focused.

import 'package:flutter/foundation.dart';

import 'trip_log.dart';

// ---------------------------------------------------------------------------
// Tournament Configuration
// ---------------------------------------------------------------------------

/// Configuration for a tournament session.
@immutable
class TournamentConfig {
  /// Maximum number of fish allowed in the bag.
  final int bagLimit;

  /// Minimum legal length in inches. Fish shorter than this are not eligible.
  final double minLengthInches;

  /// Optional maximum total bag weight in pounds (some formats cap weight).
  final double? maxWeightLbs;

  /// Species that count toward the tournament bag.
  final List<FishSpecies> speciesAllowed;

  const TournamentConfig({
    this.bagLimit = 7,
    this.minLengthInches = 9.0,
    this.maxWeightLbs,
    this.speciesAllowed = const [
      FishSpecies.whiteCrappie,
      FishSpecies.blackCrappie,
    ],
  });

  TournamentConfig copyWith({
    int? bagLimit,
    double? minLengthInches,
    double? maxWeightLbs,
    List<FishSpecies>? speciesAllowed,
  }) {
    return TournamentConfig(
      bagLimit: bagLimit ?? this.bagLimit,
      minLengthInches: minLengthInches ?? this.minLengthInches,
      maxWeightLbs: maxWeightLbs ?? this.maxWeightLbs,
      speciesAllowed: speciesAllowed ?? this.speciesAllowed,
    );
  }

  Map<String, dynamic> toJson() => {
        'bag_limit': bagLimit,
        'min_length_inches': minLengthInches,
        'max_weight_lbs': maxWeightLbs,
        'species_allowed': speciesAllowed.map((s) => s.name).toList(),
      };

  factory TournamentConfig.fromJson(Map<String, dynamic> json) {
    return TournamentConfig(
      bagLimit: json['bag_limit'] as int? ?? 7,
      minLengthInches:
          (json['min_length_inches'] as num?)?.toDouble() ?? 9.0,
      maxWeightLbs: (json['max_weight_lbs'] as num?)?.toDouble(),
      speciesAllowed: (json['species_allowed'] as List<dynamic>?)
              ?.map((name) => FishSpecies.values.firstWhere(
                    (e) => e.name == name,
                    orElse: () => FishSpecies.whiteCrappie,
                  ))
              .toList() ??
          const [FishSpecies.whiteCrappie, FishSpecies.blackCrappie],
    );
  }

  /// Check whether a species is allowed in this tournament.
  bool isSpeciesAllowed(FishSpecies species) =>
      speciesAllowed.contains(species);

  /// Check whether a fish meets the minimum length requirement.
  bool meetsMinLength(double lengthInches) =>
      lengthInches >= minLengthInches;
}

// ---------------------------------------------------------------------------
// Tournament Fish
// ---------------------------------------------------------------------------

/// A single fish in the tournament bag.
@immutable
class TournamentFish {
  final String id;
  final double weightLbs;
  final double lengthInches;
  final FishSpecies species;
  final DateTime caughtAt;

  const TournamentFish({
    required this.id,
    required this.weightLbs,
    required this.lengthInches,
    required this.species,
    required this.caughtAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight_lbs': weightLbs,
        'length_inches': lengthInches,
        'species': species.name,
        'caught_at': caughtAt.toIso8601String(),
      };

  factory TournamentFish.fromJson(Map<String, dynamic> json) {
    return TournamentFish(
      id: json['id'] as String,
      weightLbs: (json['weight_lbs'] as num).toDouble(),
      lengthInches: (json['length_inches'] as num).toDouble(),
      species: FishSpecies.values.firstWhere(
        (e) => e.name == json['species'],
        orElse: () => FishSpecies.whiteCrappie,
      ),
      caughtAt: DateTime.parse(json['caught_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentFish &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// Cull Result
// ---------------------------------------------------------------------------

/// Describes the outcome of culling the smallest fish for a new, heavier one.
@immutable
class CullResult {
  /// The fish that was removed from the bag.
  final TournamentFish removedFish;

  /// The fish that was added to the bag.
  final TournamentFish addedFish;

  /// Weight gained by this cull (positive means improvement).
  final double weightGain;

  const CullResult({
    required this.removedFish,
    required this.addedFish,
    required this.weightGain,
  });
}

// ---------------------------------------------------------------------------
// Tournament Bag
// ---------------------------------------------------------------------------

/// Holds the current tournament bag state and provides operations on it.
@immutable
class TournamentBag {
  final List<TournamentFish> fish;
  final int bagLimit;
  final List<CullResult> cullHistory;

  const TournamentBag({
    this.fish = const [],
    this.bagLimit = 7,
    this.cullHistory = const [],
  });

  // -- Computed properties --------------------------------------------------

  /// Whether the bag has reached its fish limit.
  bool get isFull => fish.length >= bagLimit;

  /// Total weight of all fish in the bag.
  double get totalWeight =>
      fish.fold<double>(0.0, (sum, f) => sum + f.weightLbs);

  /// Average weight per fish (0 if bag is empty).
  double get averageWeight => fish.isEmpty ? 0.0 : totalWeight / fish.length;

  /// The lightest fish in the bag (cull candidate), or null if empty.
  TournamentFish? get smallestFish {
    if (fish.isEmpty) return null;
    return fish.reduce((a, b) => a.weightLbs <= b.weightLbs ? a : b);
  }

  /// The heaviest fish in the bag, or null if empty.
  TournamentFish? get biggestFish {
    if (fish.isEmpty) return null;
    return fish.reduce((a, b) => a.weightLbs >= b.weightLbs ? a : b);
  }

  /// Fish sorted by weight, heaviest first.
  List<TournamentFish> get sortedByWeight {
    final sorted = List<TournamentFish>.from(fish);
    sorted.sort((a, b) => b.weightLbs.compareTo(a.weightLbs));
    return sorted;
  }

  /// Number of fish currently in the bag.
  int get count => fish.length;

  /// The total weight gained through all culls so far.
  double get totalCullGain =>
      cullHistory.fold<double>(0.0, (sum, c) => sum + c.weightGain);

  // -- Mutation methods (return new instances) --------------------------------

  /// Add a fish to the bag. Returns the new bag state.
  /// Throws [StateError] if the bag is already full.
  TournamentBag addFish(TournamentFish newFish) {
    if (isFull) {
      throw StateError(
        'Bag is full ($bagLimit fish). Use cullSmallest() instead.',
      );
    }
    return TournamentBag(
      fish: [...fish, newFish],
      bagLimit: bagLimit,
      cullHistory: cullHistory,
    );
  }

  /// Replace the smallest fish with [newFish] if it is heavier.
  /// Returns a [CullResult] describing the swap, or null if the new fish
  /// is not heavier than the current smallest.
  /// Also returns the updated bag via the record return type.
  ({TournamentBag bag, CullResult? result}) cullSmallest(
    TournamentFish newFish,
  ) {
    final smallest = smallestFish;
    if (smallest == null) {
      throw StateError('Cannot cull from an empty bag.');
    }

    if (newFish.weightLbs <= smallest.weightLbs) {
      // New fish is not an improvement — no cull.
      return (bag: this, result: null);
    }

    final weightGain = newFish.weightLbs - smallest.weightLbs;
    final result = CullResult(
      removedFish: smallest,
      addedFish: newFish,
      weightGain: weightGain,
    );

    final updatedFish = fish.where((f) => f.id != smallest.id).toList()
      ..add(newFish);

    return (
      bag: TournamentBag(
        fish: updatedFish,
        bagLimit: bagLimit,
        cullHistory: [...cullHistory, result],
      ),
      result: result,
    );
  }

  /// Remove a specific fish by ID. Returns the updated bag.
  TournamentBag removeFish(String fishId) {
    return TournamentBag(
      fish: fish.where((f) => f.id != fishId).toList(),
      bagLimit: bagLimit,
      cullHistory: cullHistory,
    );
  }

  /// Reset the bag to empty, preserving configuration.
  TournamentBag reset() {
    return TournamentBag(
      fish: const [],
      bagLimit: bagLimit,
      cullHistory: const [],
    );
  }
}
