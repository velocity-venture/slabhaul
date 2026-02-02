import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/tides_service.dart';
import '../../../core/models/tides_data.dart';
import '../../../core/models/lake.dart';
import '../../weather/providers/weather_providers.dart';

/// Provider for the tides service singleton.
final tidesServiceProvider = Provider((ref) => TidesService());

/// Provider for all configured tidal waters.
final tidalWatersProvider = FutureProvider<List<TidalWater>>((ref) async {
  final service = ref.read(tidesServiceProvider);
  return service.loadTidalWaters();
});

/// Provider to check if a lake has tidal influence.
/// 
/// Usage:
/// ```dart
/// final isTidal = ref.watch(tidesEnabledProvider(lakeId));
/// ```
final tidesEnabledProvider = FutureProvider.family<bool, String>((ref, lakeId) async {
  final service = ref.read(tidesServiceProvider);
  return service.isLakeTidal(lakeId);
});

/// Provider for tidal water info for a specific lake.
final tidalWaterProvider = FutureProvider.family<TidalWater?, String>((ref, lakeId) async {
  final service = ref.read(tidesServiceProvider);
  return service.getTidalWater(lakeId);
});

/// Provider to check if currently selected lake is tidal.
final selectedLakeTidesEnabledProvider = FutureProvider<bool>((ref) async {
  final lake = ref.watch(selectedWeatherLakeProvider);
  if (lake.id == null) return false;
  return ref.watch(tidesEnabledProvider(lake.id!).future);
});

/// Provider for nearest tide station to a lake.
final nearestTideStationProvider = FutureProvider.family<TideStation?, Lake>((ref, lake) async {
  final service = ref.read(tidesServiceProvider);
  return service.findNearestStation(lake.centerLat, lake.centerLon);
});

/// Provider for current tide conditions for a lake.
/// 
/// Only returns data if the lake is tidal.
final currentTideProvider = FutureProvider.family<TideConditions?, String>((ref, lakeId) async {
  final service = ref.read(tidesServiceProvider);
  return service.getConditionsForLake(lakeId);
});

/// Provider for tide conditions for the currently selected lake.
final selectedLakeTideConditionsProvider = FutureProvider<TideConditions?>((ref) async {
  final lake = ref.watch(selectedWeatherLakeProvider);
  if (lake.id == null) return null;
  final service = ref.read(tidesServiceProvider);
  return service.getConditionsForLake(lake.id!);
});

/// Provider for tide predictions for a station.
final tidePredictionsProvider = FutureProvider.family<List<TidePrediction>, String>((ref, stationId) async {
  final service = ref.read(tidesServiceProvider);
  return service.getPredictions(stationId, hours: 72);
});

/// Provider for hourly tide predictions (for chart display).
final hourlyTidePredictionsProvider = FutureProvider.family<List<TideReading>, String>((ref, stationId) async {
  final service = ref.read(tidesServiceProvider);
  return service.getHourlyPredictions(stationId, hours: 48);
});

/// Provider for fishing windows based on tide.
final tideFishingWindowsProvider = FutureProvider.family<List<TideFishingWindow>, String>((ref, stationId) async {
  final service = ref.read(tidesServiceProvider);
  return service.getFishingWindows(stationId, hours: 48);
});

/// Provider for tide fishing impact assessment.
final tideFishingImpactProvider = FutureProvider.family<TideFishingImpact?, String>((ref, lakeId) async {
  final conditions = await ref.watch(currentTideProvider(lakeId).future);
  if (conditions == null) return null;
  return TideFishingImpact.fromConditions(conditions);
});

/// Combined tide data for selected lake (conditions + windows + hourly).
class TideDisplayData {
  final TideConditions conditions;
  final List<TideFishingWindow> fishingWindows;
  final List<TideReading> hourlyPredictions;
  final TidalWater tidalWater;
  final TideFishingImpact impact;

  const TideDisplayData({
    required this.conditions,
    required this.fishingWindows,
    required this.hourlyPredictions,
    required this.tidalWater,
    required this.impact,
  });
}

/// Provider for full tide display data for selected lake.
final selectedLakeTideDataProvider = FutureProvider<TideDisplayData?>((ref) async {
  final lake = ref.watch(selectedWeatherLakeProvider);
  if (lake.id == null) return null;
  
  final service = ref.read(tidesServiceProvider);

  // Check if lake is tidal
  final tidalWater = await service.getTidalWater(lake.id!);
  if (tidalWater == null) return null;

  // Fetch all data
  final results = await Future.wait([
    service.getConditions(tidalWater.primaryStationId),
    service.getFishingWindows(tidalWater.primaryStationId, hours: 48),
    service.getHourlyPredictions(tidalWater.primaryStationId, hours: 48),
  ]);

  final conditions = results[0] as TideConditions?;
  final windows = results[1] as List<TideFishingWindow>;
  final hourly = results[2] as List<TideReading>;

  if (conditions == null) return null;

  return TideDisplayData(
    conditions: conditions,
    fishingWindows: windows,
    hourlyPredictions: hourly,
    tidalWater: tidalWater,
    impact: TideFishingImpact.fromConditions(conditions),
  );
});

/// Notifier for tide state management (for manual refresh, etc.)
class TideStateNotifier extends StateNotifier<AsyncValue<TideConditions?>> {
  final TidesService _service;

  TideStateNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadForLake(String lakeId) async {
    state = const AsyncValue.loading();
    try {
      final conditions = await _service.getConditionsForLake(lakeId);
      state = AsyncValue.data(conditions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadForStation(String stationId) async {
    state = const AsyncValue.loading();
    try {
      final conditions = await _service.getConditions(stationId);
      state = AsyncValue.data(conditions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// StateNotifier provider for tide state.
final tideStateProvider = StateNotifierProvider<TideStateNotifier, AsyncValue<TideConditions?>>((ref) {
  return TideStateNotifier(ref.read(tidesServiceProvider));
});
