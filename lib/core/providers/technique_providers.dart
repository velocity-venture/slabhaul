import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/services/technique_recommendation_service.dart';
import 'package:slabhaul/features/weather/providers/weather_providers.dart';

/// Provider for the technique recommendation service singleton
final techniqueRecommendationServiceProvider =
    Provider<TechniqueRecommendationService>((ref) {
  return TechniqueRecommendationService();
});

/// Computes technique recommendations from live weather + lake data.
///
/// Reads [weatherDataProvider] for current conditions and
/// [selectedWeatherLakeProvider] for lake-specific depth info, then runs
/// the scoring engine to return the top 3 techniques.
final techniqueRecommendationsProvider =
    FutureProvider<List<TechniqueRecommendation>>((ref) async {
  final weather = await ref.watch(weatherDataProvider.future);
  final lake = ref.watch(selectedWeatherLakeProvider);
  final service = ref.read(techniqueRecommendationServiceProvider);

  // Derive water temp estimate (air temp - offset)
  final waterTempF = weather.current.temperatureF - 5;

  // Derive barometric trend from recent hourly readings
  final now = DateTime.now();
  final recentPressures = weather.hourly
      .where((h) =>
          h.time.isBefore(now) &&
          h.time.isAfter(now.subtract(const Duration(hours: 6))))
      .map((h) => h.pressureMb)
      .toList();
  String baroTrend = 'Steady';
  if (recentPressures.length >= 2) {
    final diff = recentPressures.last - recentPressures.first;
    if (diff > 1.5) {
      baroTrend = 'Rising';
    } else if (diff < -1.5) {
      baroTrend = 'Falling';
    }
  }

  // Derive time of day from the current hour
  final hour = now.hour;
  String timeOfDay;
  if (hour >= 5 && hour < 8) {
    timeOfDay = 'dawn';
  } else if (hour >= 8 && hour < 10) {
    timeOfDay = 'morning';
  } else if (hour >= 10 && hour < 15) {
    timeOfDay = 'midday';
  } else if (hour >= 15 && hour < 18) {
    timeOfDay = 'afternoon';
  } else if (hour >= 18 && hour < 21) {
    timeOfDay = 'dusk';
  } else {
    timeOfDay = 'night';
  }

  // Derive season from water temperature
  String season;
  if (waterTempF < 50) {
    season = 'winter';
  } else if (waterTempF < 60) {
    season = 'pre-spawn';
  } else if (waterTempF < 68) {
    season = 'spring';
  } else if (waterTempF < 75) {
    season = 'post-spawn';
  } else {
    final month = now.month;
    season = (month >= 9 && month <= 11) ? 'fall' : 'summer';
  }

  // Derive water clarity from weather code (rough heuristic)
  // Heavy rain codes indicate runoff -> muddy; clear skies -> stained default
  final code = weather.current.weatherCode;
  String clarity;
  if (code >= 63 || code >= 80) {
    clarity = 'muddy';
  } else if (code >= 51) {
    clarity = 'stained';
  } else {
    clarity = 'stained'; // Default assumption for most lakes
  }

  // Estimate cloud cover from weather code
  int cloudCover;
  if (code == 0 || code == 1) {
    cloudCover = 10;
  } else if (code == 2) {
    cloudCover = 50;
  } else if (code == 3) {
    cloudCover = 90;
  } else {
    cloudCover = 75; // Precipitation implies heavy cloud cover
  }

  // Use lake max depth as a proxy for target depth, or fall back to 12 ft
  final depthFt = (lake.maxDepthFt ?? 12) * 0.6; // Fish at ~60% of max depth

  return service.recommend(
    waterTempF: waterTempF,
    windSpeedMph: weather.current.windSpeedMph,
    waterClarity: clarity,
    depthFt: depthFt,
    barometricTrend: baroTrend,
    timeOfDay: timeOfDay,
    season: season,
    cloudCoverPercent: cloudCover,
  );
});
