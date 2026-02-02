import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/trip_log.dart';
import '../../../core/services/trip_log_service.dart';

// ---------------------------------------------------------------------------
// Service Provider
// ---------------------------------------------------------------------------

final tripLogServiceProvider = Provider<TripLogService>((ref) {
  return TripLogService();
});

// ---------------------------------------------------------------------------
// Trip Providers
// ---------------------------------------------------------------------------

/// All trips, automatically refreshes when trips change
final tripsProvider = FutureProvider<List<FishingTrip>>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getAllTrips();
});

/// Currently active trip (if any)
final activeTripProvider = FutureProvider<FishingTrip?>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getActiveTrip();
});

/// Single trip by ID
final tripByIdProvider =
    FutureProvider.family<FishingTrip?, String>((ref, tripId) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getTrip(tripId);
});

/// Last catch (for "Same as last" feature)
final lastCatchProvider = FutureProvider<CatchRecord?>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getLastCatch();
});

// ---------------------------------------------------------------------------
// Statistics Providers
// ---------------------------------------------------------------------------

/// Aggregate statistics across all trips
final aggregateStatsProvider = FutureProvider<AggregateStats>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getAggregateStats();
});

/// Catches grouped by bait
final catchesByBaitProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getCatchesByBait();
});

/// Catches grouped by weather conditions
final catchesByConditionsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getCatchesByConditions();
});

/// Catches by hour of day
final catchesByHourProvider = FutureProvider<Map<int, int>>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getCatchesByHour();
});

/// Catches by month (seasonal trends)
final catchesByMonthProvider = FutureProvider<Map<int, int>>((ref) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getCatchesByMonth();
});

// ---------------------------------------------------------------------------
// Filter Providers
// ---------------------------------------------------------------------------

/// Trips filtered by lake
final tripsByLakeProvider =
    FutureProvider.family<List<FishingTrip>, String>((ref, lakeId) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getTripsByLake(lakeId);
});

/// Trips filtered by date range
final tripsByDateRangeProvider = FutureProvider.family<List<FishingTrip>,
    ({DateTime start, DateTime end})>((ref, range) async {
  final service = ref.watch(tripLogServiceProvider);
  return service.getTripsByDateRange(range.start, range.end);
});

// ---------------------------------------------------------------------------
// Active Trip State Management
// ---------------------------------------------------------------------------

/// Notifier for managing active trip state
class ActiveTripNotifier extends StateNotifier<AsyncValue<FishingTrip?>> {
  final TripLogService _service;
  final Ref _ref;

  ActiveTripNotifier(this._service, this._ref)
      : super(const AsyncValue.loading()) {
    _loadActiveTrip();
  }

  Future<void> _loadActiveTrip() async {
    try {
      final trip = await _service.getActiveTrip();
      state = AsyncValue.data(trip);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Start a new trip
  Future<FishingTrip> startTrip({
    String? lakeId,
    String? lakeName,
    TripConditions? conditions,
  }) async {
    final trip = await _service.startTrip(
      lakeId: lakeId,
      lakeName: lakeName,
      conditions: conditions,
    );
    state = AsyncValue.data(trip);
    _invalidateProviders();
    return trip;
  }

  /// End the current trip
  Future<void> endTrip() async {
    final currentTrip = state.valueOrNull;
    if (currentTrip == null) return;

    await _service.endTrip(currentTrip.id);
    state = const AsyncValue.data(null);
    _invalidateProviders();
  }

  /// Add a catch to the active trip
  Future<CatchRecord?> addCatch({
    required FishSpecies species,
    double? lengthInches,
    double? weightLbs,
    double? depthFt,
    BaitUsed? bait,
    CatchLocation? location,
    String? photoPath,
    String? notes,
    bool released = true,
  }) async {
    final currentTrip = state.valueOrNull;
    if (currentTrip == null) return null;

    final catch_ = await _service.addCatch(
      tripId: currentTrip.id,
      species: species,
      lengthInches: lengthInches,
      weightLbs: weightLbs,
      depthFt: depthFt,
      bait: bait,
      location: location,
      photoPath: photoPath,
      notes: notes,
      released: released,
    );

    // Reload the active trip to reflect new catch
    await _loadActiveTrip();
    _invalidateProviders();
    
    return catch_;
  }

  /// Delete a catch from the active trip
  Future<void> deleteCatch(String catchId) async {
    final currentTrip = state.valueOrNull;
    if (currentTrip == null) return;

    await _service.deleteCatch(currentTrip.id, catchId);
    await _loadActiveTrip();
    _invalidateProviders();
  }

  /// Update trip notes
  Future<void> updateNotes(String notes) async {
    final currentTrip = state.valueOrNull;
    if (currentTrip == null) return;

    final updated = currentTrip.copyWith(notes: notes);
    await _service.saveTrip(updated);
    await _loadActiveTrip();
  }

  void _invalidateProviders() {
    _ref.invalidate(tripsProvider);
    _ref.invalidate(aggregateStatsProvider);
    _ref.invalidate(catchesByBaitProvider);
    _ref.invalidate(catchesByConditionsProvider);
    _ref.invalidate(catchesByHourProvider);
    _ref.invalidate(catchesByMonthProvider);
    _ref.invalidate(lastCatchProvider);
  }

  /// Reload the active trip
  Future<void> reload() => _loadActiveTrip();
}

final activeTripNotifierProvider =
    StateNotifierProvider<ActiveTripNotifier, AsyncValue<FishingTrip?>>((ref) {
  final service = ref.watch(tripLogServiceProvider);
  return ActiveTripNotifier(service, ref);
});

// ---------------------------------------------------------------------------
// Trip Timer Provider
// ---------------------------------------------------------------------------

/// Provides a stream of elapsed time for the active trip
final tripTimerProvider = StreamProvider<Duration>((ref) async* {
  final activeTrip = ref.watch(activeTripNotifierProvider).valueOrNull;
  
  if (activeTrip == null || !activeTrip.isActive) {
    yield Duration.zero;
    return;
  }

  while (true) {
    yield DateTime.now().difference(activeTrip.startedAt);
    await Future.delayed(const Duration(seconds: 1));
  }
});
