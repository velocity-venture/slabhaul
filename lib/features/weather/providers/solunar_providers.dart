import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/solunar_calculator.dart';
import 'package:slabhaul/features/weather/providers/weather_providers.dart';

/// Provider for today's solunar forecast
final solunarForecastProvider = Provider<SolunarForecast>((ref) {
  final coords = ref.watch(selectedWeatherLakeProvider);
  
  return SolunarCalculator.calculate(
    date: DateTime.now(),
    latitude: coords.lat,
    longitude: coords.lon,
  );
});

/// Provider for multi-day solunar forecast (7 days)
final weekSolunarForecastProvider = Provider<List<SolunarForecast>>((ref) {
  final coords = ref.watch(selectedWeatherLakeProvider);
  final now = DateTime.now();
  
  return List.generate(7, (i) {
    final date = now.add(Duration(days: i));
    return SolunarCalculator.calculate(
      date: date,
      latitude: coords.lat,
      longitude: coords.lon,
    );
  });
});

/// Provider for the next best fishing time
final nextSolunarPeriodProvider = Provider<SolunarPeriod?>((ref) {
  final forecast = ref.watch(solunarForecastProvider);
  return forecast.getNextPeriod(DateTime.now());
});
