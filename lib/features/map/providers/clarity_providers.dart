import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/water_clarity.dart';
import 'package:slabhaul/core/services/water_clarity_service.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// Service provider for water clarity estimation
final waterClarityServiceProvider = Provider<WaterClarityService>((ref) {
  return WaterClarityService();
});

/// Whether clarity layer is enabled on the map
final clarityLayerEnabledProvider = StateProvider<bool>((ref) => false);

/// Currently selected lake profile for clarity display
final clarityLakeProfileProvider = FutureProvider<LakeClarityProfile?>((ref) async {
  final service = ref.watch(waterClarityServiceProvider);
  final selectedLakeId = ref.watch(selectedLakeProvider);
  
  if (selectedLakeId == null) return null;
  
  return service.getLakeProfile(selectedLakeId);
});

/// All lake clarity profiles
final allClarityProfilesProvider = FutureProvider<List<LakeClarityProfile>>((ref) async {
  final service = ref.watch(waterClarityServiceProvider);
  return service.loadLakeProfiles();
});

/// Weather data for the selected lake's location
final clarityWeatherProvider = FutureProvider<dynamic>((ref) async {
  final lakes = await ref.watch(lakesProvider.future);
  final selectedLakeId = ref.watch(selectedLakeProvider);
  
  if (selectedLakeId == null && lakes.isNotEmpty) {
    // Default to first lake
    final lake = lakes.first;
    final weatherService = ref.watch(weatherServiceProvider);
    return weatherService.getWeather(lake.centerLat, lake.centerLon);
  }
  
  final selectedLake = lakes.where((l) => l.id == selectedLakeId).firstOrNull;
  if (selectedLake == null) return null;
  
  final weatherService = ref.watch(weatherServiceProvider);
  return weatherService.getWeather(selectedLake.centerLat, selectedLake.centerLon);
});

/// Overall lake clarity estimate for the selected lake
final lakeClarityProvider = FutureProvider<ClarityEstimate?>((ref) async {
  final profile = await ref.watch(clarityLakeProfileProvider.future);
  final weather = await ref.watch(clarityWeatherProvider.future);
  
  if (weather == null) return null;
  
  final service = ref.watch(waterClarityServiceProvider);
  
  // Use lake profile if available, otherwise use defaults
  final baselineClarity = profile?.baselineClarity ?? 4.0;
  
  // Check for rain in forecast for trend calculation
  double? forecastPrecip;
  if (weather.daily.length > 1) {
    forecastPrecip = weather.daily[1].precipitationMm;
  }
  
  return service.estimateClarity(
    weather: weather,
    lakeBaselineClarity: baselineClarity,
    forecastPrecipitation24h: forecastPrecip,
  );
});

/// Clarity zones with estimates for the selected lake
final clarityZonesProvider = FutureProvider<List<ClarityZone>>((ref) async {
  final profile = await ref.watch(clarityLakeProfileProvider.future);
  final weather = await ref.watch(clarityWeatherProvider.future);
  
  if (profile == null || weather == null) return [];
  
  final service = ref.watch(waterClarityServiceProvider);
  
  // Check for rain in forecast
  double? forecastPrecip;
  if (weather.daily.length > 1) {
    forecastPrecip = weather.daily[1].precipitationMm;
  }
  
  return service.estimateClarityForLake(
    profile: profile,
    weather: weather,
    forecastPrecipitation24h: forecastPrecip,
  );
});

/// The factors affecting current clarity (for info display)
final clarityFactorsProvider = FutureProvider<ClarityFactors?>((ref) async {
  final estimate = await ref.watch(lakeClarityProvider.future);
  return estimate?.factors;
});

/// Selected zone for detailed view
final selectedClarityZoneProvider = StateProvider<ClarityZone?>((ref) => null);

/// Quick clarity estimate for bait engine integration
/// Returns the ClarityLevel for use with bait recommendations
final clarityForBaitEngineProvider = FutureProvider<ClarityLevel>((ref) async {
  final estimate = await ref.watch(lakeClarityProvider.future);
  return estimate?.level ?? ClarityLevel.lightStain; // Default to typical
});

/// Recent precipitation summary for display
final recentPrecipitationProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final factors = await ref.watch(clarityFactorsProvider.future);
  if (factors == null) {
    return {
      'last24h': 0.0,
      'last72h': 0.0,
      'daysSinceRain': 7,
    };
  }
  
  return {
    'last24h': factors.precipitation24h,
    'last72h': factors.precipitation72h,
    'daysSinceRain': factors.daysSinceRain,
  };
});

/// Check if clarity data is available for a specific lake
final hasClarityDataProvider = FutureProvider.family<bool, String>((ref, lakeId) async {
  final profiles = await ref.watch(allClarityProfilesProvider.future);
  return profiles.any((p) => p.lakeId == lakeId);
});

/// Extension to get appropriate WaterClarity for bait engine from ClarityLevel
extension ClarityLevelBaitEngineX on ClarityLevel {
  /// Convert to the bait engine's WaterClarity enum index
  /// WaterClarity: clear=0, lightStain=1, stained=2, muddy=3
  int get baitEngineIndex {
    switch (this) {
      case ClarityLevel.crystal:
      case ClarityLevel.clear:
        return 0;
      case ClarityLevel.lightStain:
        return 1;
      case ClarityLevel.stained:
        return 2;
      case ClarityLevel.muddy:
        return 3;
    }
  }
}
