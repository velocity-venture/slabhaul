import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../utils/weather_utils.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';

class WeatherService {
  static const _cacheTtl = Duration(minutes: 15);
  static final Map<String, _CacheEntry<WeatherData>> _cache = {};

  Future<WeatherData> getWeather(double lat, double lon) async {
    final key = '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return cached.data;
    }

    try {
      final url = Uri.parse(
        '${ApiUrls.openMeteoBase}'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
        'wind_speed_10m,wind_direction_10m,surface_pressure,weather_code'
        '&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,'
        'surface_pressure,precipitation'
        '&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,'
        'precipitation_sum,weather_code'
        '&temperature_unit=fahrenheit&wind_speed_unit=mph'
        '&timezone=auto&forecast_days=7',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final result = _parseWeather(json.decode(response.body));
        _cache[key] = _CacheEntry(data: result, timestamp: DateTime.now());
        return result;
      }
    } catch (e, st) {
      AppLogger.error('WeatherService', 'getWeather($lat, $lon)', e, st);
    }

    return _mockWeather();
  }

  WeatherData _parseWeather(Map<String, dynamic> data) {
    final current = data['current'] ?? {};
    final hourly = data['hourly'] ?? {};
    final daily = data['daily'] ?? {};

    final hourlyTimes = (hourly['time'] as List?)?.cast<String>() ?? [];
    final dailyTimes = (daily['time'] as List?)?.cast<String>() ?? [];

    return WeatherData(
      current: CurrentWeather(
        temperatureF: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        feelsLikeF:
            (current['apparent_temperature'] as num?)?.toDouble() ?? 0,
        humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
        windSpeedMph:
            (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        windDirectionDeg:
            (current['wind_direction_10m'] as num?)?.toInt() ?? 0,
        pressureMb:
            (current['surface_pressure'] as num?)?.toDouble() ?? 1013,
        weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
        description: weatherDescription(
            (current['weather_code'] as num?)?.toInt() ?? 0),
      ),
      hourly: List.generate(
        hourlyTimes.length.clamp(0, 48),
        (i) => HourlyForecast(
          time: DateTime.parse(hourlyTimes[i]),
          temperatureF:
              ((hourly['temperature_2m'] as List?)?[i] as num?)
                  ?.toDouble() ??
              0,
          windSpeedMph:
              ((hourly['wind_speed_10m'] as List?)?[i] as num?)
                  ?.toDouble() ??
              0,
          windDirectionDeg:
              ((hourly['wind_direction_10m'] as List?)?[i] as num?)
                  ?.toInt() ??
              0,
          pressureMb:
              ((hourly['surface_pressure'] as List?)?[i] as num?)
                  ?.toDouble() ??
              1013,
          precipitationMm:
              ((hourly['precipitation'] as List?)?[i] as num?)
                  ?.toDouble() ??
              0,
        ),
      ),
      daily: List.generate(
        dailyTimes.length.clamp(0, 7),
        (i) => DailyForecast(
          date: DateTime.parse(dailyTimes[i]),
          highF:
              ((daily['temperature_2m_max'] as List?)?[i] as num?)
                  ?.toDouble() ??
              0,
          lowF:
              ((daily['temperature_2m_min'] as List?)?[i] as num?)
                  ?.toDouble() ??
              0,
          sunrise: DateTime.tryParse(
                  (daily['sunrise'] as List?)?[i]?.toString() ?? '') ??
              DateTime.now(),
          sunset: DateTime.tryParse(
                  (daily['sunset'] as List?)?[i]?.toString() ?? '') ??
              DateTime.now(),
          precipitationMm:
              ((daily['precipitation_sum'] as List?)?[i] as num?)
                  ?.toDouble() ??
              0,
          weatherCode:
              ((daily['weather_code'] as List?)?[i] as num?)?.toInt() ?? 0,
        ),
      ),
      fetchedAt: DateTime.now(),
    );
  }

  void clearCache() => _cache.clear();

  WeatherData _mockWeather() {
    final now = DateTime.now();
    return WeatherData(
      current: const CurrentWeather(
        temperatureF: 58,
        feelsLikeF: 55,
        humidity: 72,
        windSpeedMph: 8.5,
        windDirectionDeg: 210,
        pressureMb: 1018.5,
        weatherCode: 2,
        description: 'Partly cloudy',
      ),
      hourly: List.generate(
        24,
        (i) => HourlyForecast(
          time: now.add(Duration(hours: i)),
          temperatureF: 55 + (i < 12 ? i * 0.8 : (24 - i) * 0.8),
          windSpeedMph: 6.0 + (i % 4) * 1.2,
          windDirectionDeg: 200 + (i * 5) % 40,
          pressureMb: 1018.5 - i * 0.1,
          precipitationMm: 0,
        ),
      ),
      daily: List.generate(
        7,
        (i) => DailyForecast(
          date: now.add(Duration(days: i)),
          highF: 62 + i * 1.5,
          lowF: 42 + i * 0.8,
          sunrise: DateTime(now.year, now.month, now.day + i, 6, 45),
          sunset: DateTime(now.year, now.month, now.day + i, 17, 30),
          precipitationMm: i == 3 ? 4.2 : 0,
          weatherCode: i == 3 ? 61 : (i % 2 == 0 ? 0 : 2),
        ),
      ),
      fetchedAt: now,
    );
  }
}

class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  const _CacheEntry({required this.data, required this.timestamp});
}
