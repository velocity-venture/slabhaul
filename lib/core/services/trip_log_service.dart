import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_log.dart';
import '../utils/app_logger.dart';

/// Service for managing trip log data using SharedPreferences
/// 
/// Stores trips and catches as JSON for simplicity.
/// Can be migrated to SQLite later if needed.
class TripLogService {
  static const String _tripsKey = 'trip_log_trips';
  static const String _activeTripKey = 'trip_log_active_trip_id';
  static const String _lastCatchKey = 'trip_log_last_catch';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------------------------------------------------------------------------
  // Trip CRUD Operations
  // ---------------------------------------------------------------------------

  /// Get all trips, sorted by date (newest first)
  Future<List<FishingTrip>> getAllTrips() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_tripsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final trips = jsonList
          .map((j) => FishingTrip.fromJson(j as Map<String, dynamic>))
          .toList();
      
      // Sort by date, newest first
      trips.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return trips;
    } catch (e, st) {
      AppLogger.error('TripLogService', 'getAllTrips (JSON parse)', e, st);
      return [];
    }
  }

  /// Get a single trip by ID
  Future<FishingTrip?> getTrip(String tripId) async {
    final trips = await getAllTrips();
    try {
      return trips.firstWhere((t) => t.id == tripId);
    } catch (_) {
      AppLogger.warn('TripLogService', 'Trip not found: $tripId');
      return null;
    }
  }

  /// Get the currently active trip, if any
  Future<FishingTrip?> getActiveTrip() async {
    final prefs = await _preferences;
    final activeTripId = prefs.getString(_activeTripKey);
    
    if (activeTripId == null) return null;
    
    final trip = await getTrip(activeTripId);
    return trip?.isActive == true ? trip : null;
  }

  /// Save a trip (creates or updates)
  Future<void> saveTrip(FishingTrip trip) async {
    final trips = await getAllTrips();
    
    // Remove existing trip with same ID
    trips.removeWhere((t) => t.id == trip.id);
    
    // Add the new/updated trip
    trips.add(trip);
    
    await _saveAllTrips(trips);
    
    // Track active trip
    if (trip.isActive) {
      final prefs = await _preferences;
      await prefs.setString(_activeTripKey, trip.id);
    }
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    final trips = await getAllTrips();
    trips.removeWhere((t) => t.id == tripId);
    await _saveAllTrips(trips);
    
    // Clear active trip if it was deleted
    final prefs = await _preferences;
    final activeTripId = prefs.getString(_activeTripKey);
    if (activeTripId == tripId) {
      await prefs.remove(_activeTripKey);
    }
  }

  Future<void> _saveAllTrips(List<FishingTrip> trips) async {
    final prefs = await _preferences;
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsKey, json.encode(jsonList));
  }

  // ---------------------------------------------------------------------------
  // Active Trip Management
  // ---------------------------------------------------------------------------

  /// Start a new fishing trip
  Future<FishingTrip> startTrip({
    String? lakeId,
    String? lakeName,
    TripConditions? conditions,
  }) async {
    // End any existing active trip first
    final existingActive = await getActiveTrip();
    if (existingActive != null) {
      await endTrip(existingActive.id);
    }

    final trip = FishingTrip(
      id: _generateId(),
      lakeId: lakeId,
      lakeName: lakeName,
      startedAt: DateTime.now(),
      conditions: conditions,
      catches: [],
      isActive: true,
    );

    await saveTrip(trip);
    return trip;
  }

  /// End the active trip
  Future<FishingTrip?> endTrip(String tripId) async {
    final trip = await getTrip(tripId);
    if (trip == null) return null;

    final updatedTrip = trip.copyWith(
      endedAt: DateTime.now(),
      isActive: false,
    );

    await saveTrip(updatedTrip);
    
    // Clear active trip reference
    final prefs = await _preferences;
    await prefs.remove(_activeTripKey);

    return updatedTrip;
  }

  // ---------------------------------------------------------------------------
  // Catch Operations
  // ---------------------------------------------------------------------------

  /// Add a catch to a trip
  Future<CatchRecord> addCatch({
    required String tripId,
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
    final trip = await getTrip(tripId);
    if (trip == null) {
      throw Exception('Trip not found: $tripId');
    }

    final catchRecord = CatchRecord(
      id: _generateId(),
      tripId: tripId,
      species: species,
      lengthInches: lengthInches,
      weightLbs: weightLbs,
      depthFt: depthFt,
      bait: bait,
      location: location,
      caughtAt: DateTime.now(),
      photoPath: photoPath,
      notes: notes,
      released: released,
    );

    final updatedCatches = [...trip.catches, catchRecord];
    final updatedTrip = trip.copyWith(catches: updatedCatches);
    await saveTrip(updatedTrip);

    // Store last catch for "Same as last" feature
    await _saveLastCatch(catchRecord);

    return catchRecord;
  }

  /// Update a catch record
  Future<void> updateCatch(CatchRecord catch_) async {
    final trip = await getTrip(catch_.tripId);
    if (trip == null) return;

    final updatedCatches = trip.catches.map((c) {
      return c.id == catch_.id ? catch_ : c;
    }).toList();

    final updatedTrip = trip.copyWith(catches: updatedCatches);
    await saveTrip(updatedTrip);
  }

  /// Delete a catch record
  Future<void> deleteCatch(String tripId, String catchId) async {
    final trip = await getTrip(tripId);
    if (trip == null) return;

    final updatedCatches = trip.catches.where((c) => c.id != catchId).toList();
    final updatedTrip = trip.copyWith(catches: updatedCatches);
    await saveTrip(updatedTrip);
  }

  /// Get the last recorded catch (for "Same as last" feature)
  Future<CatchRecord?> getLastCatch() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_lastCatchKey);
    
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      return CatchRecord.fromJson(json.decode(jsonString));
    } catch (e, st) {
      AppLogger.error('TripLogService', 'getLastCatch (JSON parse)', e, st);
      return null;
    }
  }

  Future<void> _saveLastCatch(CatchRecord catch_) async {
    final prefs = await _preferences;
    await prefs.setString(_lastCatchKey, json.encode(catch_.toJson()));
  }

  // ---------------------------------------------------------------------------
  // Statistics & Analysis
  // ---------------------------------------------------------------------------

  /// Get aggregate statistics across all trips
  Future<AggregateStats> getAggregateStats() async {
    final trips = await getAllTrips();
    return AggregateStats.fromTrips(trips);
  }

  /// Get catches grouped by bait across all trips
  Future<Map<String, int>> getCatchesByBait() async {
    final trips = await getAllTrips();
    final counts = <String, int>{};

    for (final trip in trips) {
      for (final catch_ in trip.catches) {
        if (catch_.bait != null) {
          counts[catch_.bait!.display] =
              (counts[catch_.bait!.display] ?? 0) + 1;
        }
      }
    }

    // Sort by count descending
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  /// Get catches grouped by weather conditions
  Future<Map<String, int>> getCatchesByConditions() async {
    final trips = await getAllTrips();
    final counts = <String, int>{};

    for (final trip in trips) {
      if (trip.conditions?.weather?.conditions != null) {
        final condition = trip.conditions!.weather!.conditions!;
        counts[condition] = (counts[condition] ?? 0) + trip.catches.length;
      }
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  /// Get catches by time of day
  Future<Map<int, int>> getCatchesByHour() async {
    final trips = await getAllTrips();
    final counts = <int, int>{};

    for (final trip in trips) {
      for (final catch_ in trip.catches) {
        counts[catch_.caughtAt.hour] =
            (counts[catch_.caughtAt.hour] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Get catches by month (for seasonal trends)
  Future<Map<int, int>> getCatchesByMonth() async {
    final trips = await getAllTrips();
    final counts = <int, int>{};

    for (final trip in trips) {
      for (final catch_ in trip.catches) {
        counts[catch_.caughtAt.month] =
            (counts[catch_.caughtAt.month] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Get trips for a specific lake
  Future<List<FishingTrip>> getTripsByLake(String lakeId) async {
    final trips = await getAllTrips();
    return trips.where((t) => t.lakeId == lakeId).toList();
  }

  /// Get trips in a date range
  Future<List<FishingTrip>> getTripsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final trips = await getAllTrips();
    return trips.where((t) {
      return t.startedAt.isAfter(start) && t.startedAt.isBefore(end);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  /// Export all trips to JSON string
  Future<String> exportToJson() async {
    final trips = await getAllTrips();
    final exportData = {
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0',
      'trips': trips.map((t) => t.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Import trips from JSON string
  Future<int> importFromJson(String jsonString) async {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final tripList = data['trips'] as List<dynamic>;
    
    int imported = 0;
    for (final tripJson in tripList) {
      try {
        final trip = FishingTrip.fromJson(tripJson as Map<String, dynamic>);
        await saveTrip(trip);
        imported++;
      } catch (e, st) {
        AppLogger.error('TripLogService', 'importFromJson (trip parse)', e, st);
      }
    }
    
    return imported;
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  String _generateId() {
    final now = DateTime.now();
    final micro = (now.microsecond % 1000).toString().padLeft(3, '0');
    return '${now.millisecondsSinceEpoch}_$micro';
  }

  /// Clear all trip data (use with caution!)
  Future<void> clearAllData() async {
    final prefs = await _preferences;
    await prefs.remove(_tripsKey);
    await prefs.remove(_activeTripKey);
    await prefs.remove(_lastCatchKey);
  }
}
