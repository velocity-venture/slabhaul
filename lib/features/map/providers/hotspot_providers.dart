import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/fishing_hotspot.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';
import 'package:slabhaul/features/weather/providers/weather_providers.dart';

/// Provider for the hotspot service (uses the app-level provider).
final hotspotServiceProvider = hotspotServiceProviderImpl;

/// Loads all hotspots.
final allHotspotsProvider = FutureProvider<List<FishingHotspot>>((ref) async {
  final service = ref.watch(hotspotServiceProvider);
  return service.getHotspots();
});

/// Hotspots filtered by the currently selected lake.
/// Returns all hotspots if no lake is selected.
final filteredHotspotsProvider =
    FutureProvider<List<FishingHotspot>>((ref) async {
  final service = ref.watch(hotspotServiceProvider);
  final selectedLake = ref.watch(selectedLakeProvider);
  return service.getHotspots(lakeId: selectedLake);
});

/// Toggle for showing hotspots on the map.
final hotspotsEnabledProvider = StateProvider<bool>((ref) => true);

/// Current conditions derived from weather data and time.
final currentConditionsProvider = Provider<CurrentConditions>((ref) {
  final weatherAsync = ref.watch(weatherDataProvider);
  final baroTrend = ref.watch(barometricTrendProvider);
  final now = DateTime.now();

  // Determine current season based on date and typical crappie patterns
  final season = _determineSeason(now);

  return weatherAsync.when(
    data: (weather) {
      // Estimate water temp from air temp (simplified model)
      final airTemp = weather.current.temperatureF;
      final estimatedWaterTemp = CurrentConditions.estimateWaterTemp(airTemp);

      return CurrentConditions(
        season: season,
        waterTempF: estimatedWaterTemp,
        waterLevelTrend: 'stable', // Would come from USGS data
        pressureTrend: _normalizeTrend(baroTrend),
        hourOfDay: now.hour,
        windSpeedMph: weather.current.windSpeedMph,
        windDirectionDeg: weather.current.windDirectionDeg,
        pressureMb: weather.current.pressureMb,
        cloudCover: null, // Not available in current weather model
      );
    },
    loading: () => CurrentConditions(
      season: season,
      hourOfDay: now.hour,
    ),
    error: (_, __) => CurrentConditions(
      season: season,
      hourOfDay: now.hour,
    ),
  );
});

/// Hotspots scored and ranked by current conditions.
final rankedHotspotsProvider =
    FutureProvider<List<HotspotRating>>((ref) async {
  final hotspotsAsync = await ref.watch(filteredHotspotsProvider.future);
  final conditions = ref.watch(currentConditionsProvider);
  final service = ref.watch(hotspotServiceProvider);

  return service.scoreHotspots(hotspotsAsync, conditions);
});

/// The top-rated hotspot for current conditions.
final topHotspotProvider = FutureProvider<HotspotRating?>((ref) async {
  final ranked = await ref.watch(rankedHotspotsProvider.future);
  return ranked.isNotEmpty ? ranked.first : null;
});

/// The currently selected hotspot for the bottom sheet.
final selectedHotspotProvider = StateProvider<HotspotRating?>((ref) => null);

/// Determines the crappie fishing season based on date.
/// This is a simplified model based on typical Southern US patterns.
/// In reality, season is more dependent on water temperature.
String _determineSeason(DateTime date) {
  final month = date.month;
  final day = date.day;

  // Pre-spawn: Late February - March
  if ((month == 2 && day >= 20) || month == 3) {
    return 'pre_spawn';
  }

  // Spawn: April - Early May
  if (month == 4 || (month == 5 && day <= 15)) {
    return 'spawn';
  }

  // Post-spawn: Mid-May - June
  if ((month == 5 && day > 15) || month == 6) {
    return 'post_spawn';
  }

  // Summer: July - September
  if (month >= 7 && month <= 9) {
    return 'summer';
  }

  // Fall: October - November
  if (month == 10 || month == 11) {
    return 'fall';
  }

  // Winter: December - Mid-February
  return 'winter';
}

/// Normalizes barometric trend string to match hotspot conditions.
String? _normalizeTrend(String trend) {
  switch (trend.toLowerCase()) {
    case 'rising':
      return 'rising';
    case 'falling':
      return 'falling';
    case 'steady':
    case 'stable':
      return 'stable';
    default:
      return null;
  }
}

/// Provider for filtering hotspots by season.
/// Null means show all, otherwise filter to hotspots matching the season.
final hotspotSeasonFilterProvider = StateProvider<String?>((ref) => null);

/// Filtered ranked hotspots by season (when filter is active).
final seasonFilteredHotspotsProvider =
    FutureProvider<List<HotspotRating>>((ref) async {
  final ranked = await ref.watch(rankedHotspotsProvider.future);
  final seasonFilter = ref.watch(hotspotSeasonFilterProvider);

  if (seasonFilter == null) return ranked;

  return ranked
      .where((r) => r.hotspot.bestSeasons.contains(seasonFilter))
      .toList();
});
