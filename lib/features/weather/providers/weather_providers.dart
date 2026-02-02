import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/weather_data.dart';
import 'package:slabhaul/core/utils/weather_utils.dart';

/// Coordinates record for a selected weather lake.
class WeatherLakeCoords {
  final String? id;
  final double lat;
  final double lon;
  final String name;
  final double? maxDepthFt;
  final double? areaAcres;

  const WeatherLakeCoords({
    this.id,
    required this.lat,
    required this.lon,
    required this.name,
    this.maxDepthFt,
    this.areaAcres,
  });
}

/// The currently selected lake for weather data.
/// Defaults to Reelfoot Lake, TN.
final selectedWeatherLakeProvider = StateProvider<WeatherLakeCoords>((ref) {
  return const WeatherLakeCoords(
    lat: 36.387,
    lon: -89.387,
    name: 'Reelfoot Lake',
    maxDepthFt: 18, // Reelfoot is shallow - avg 5ft, max ~18ft
    areaAcres: 15000,
  );
});

/// Fetches full weather data for the selected lake coordinates.
final weatherDataProvider = FutureProvider<WeatherData>((ref) async {
  final coords = ref.watch(selectedWeatherLakeProvider);
  final weatherService = ref.read(weatherServiceProvider);
  return weatherService.getWeather(coords.lat, coords.lon);
});

/// Derives the barometric trend from the most recent hourly pressure readings.
/// Looks at the last 6 hours of hourly data to determine the trend direction.
final barometricTrendProvider = Provider<String>((ref) {
  final weatherAsync = ref.watch(weatherDataProvider);
  return weatherAsync.when(
    data: (weather) {
      final now = DateTime.now();
      // Collect pressure readings from the past ~6 hours of hourly data.
      final recentPressures = weather.hourly
          .where((h) =>
              h.time.isBefore(now) &&
              h.time.isAfter(now.subtract(const Duration(hours: 6))))
          .map((h) => h.pressureMb)
          .toList();
      if (recentPressures.length < 2) {
        // Fall back to using first several hourly entries if no past data yet.
        final fallback =
            weather.hourly.take(6).map((h) => h.pressureMb).toList();
        return barometricTrend(fallback);
      }
      return barometricTrend(recentPressures);
    },
    loading: () => 'Steady',
    error: (_, __) => 'Steady',
  );
});
