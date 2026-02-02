import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/wind_data.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// Controls whether the wind overlay is visible on the map.
final windEnabledProvider = StateProvider<bool>((ref) => false);

/// Controls whether the wind effects layer (bank colors, arrows) is visible.
final windEffectsLayerEnabledProvider = StateProvider<bool>((ref) => true);

/// The currently selected forecast time for the wind slider.
/// Null means "current conditions".
final selectedWindTimeProvider = StateProvider<DateTime?>((ref) => null);

/// The wind service provider.
final windServiceProvider = Provider((ref) => ref.watch(windServiceProviderImpl));

/// Wind forecast for the selected lake.
/// Automatically fetches when a lake is selected.
final windForecastProvider = FutureProvider<WindForecast?>((ref) async {
  final selectedLakeId = ref.watch(selectedLakeProvider);
  if (selectedLakeId == null) return null;

  final lakes = await ref.watch(lakesProvider.future);
  final lake = lakes.where((l) => l.id == selectedLakeId).firstOrNull;
  if (lake == null) return null;

  final windService = ref.watch(windServiceProvider);
  return windService.getWindForecast(lake.centerLat, lake.centerLon);
});

/// Current or selected time wind conditions.
/// Returns the forecast at the selected time, or current conditions if no time selected.
final activeWindConditionsProvider = Provider<AsyncValue<WindConditions?>>((ref) {
  final forecastAsync = ref.watch(windForecastProvider);
  final selectedTime = ref.watch(selectedWindTimeProvider);

  return forecastAsync.whenData((forecast) {
    if (forecast == null) return null;
    
    if (selectedTime == null) {
      return forecast.current;
    }

    final hourly = forecast.getClosestHour(selectedTime);
    return hourly.toConditions();
  });
});

/// Wind analysis for the selected lake with current/selected conditions.
final windAnalysisProvider = FutureProvider<LakeWindAnalysis?>((ref) async {
  final selectedLakeId = ref.watch(selectedLakeProvider);
  if (selectedLakeId == null) return null;

  final lakes = await ref.watch(lakesProvider.future);
  final lake = lakes.where((l) => l.id == selectedLakeId).firstOrNull;
  if (lake == null) return null;

  final windConditions = ref.watch(activeWindConditionsProvider).valueOrNull;
  if (windConditions == null) return null;

  final windService = ref.watch(windServiceProvider);
  
  // Estimate lake radius from area or use default
  final areaAcres = lake.areaAcres ?? 1000;
  final radiusKm = _estimateLakeRadius(areaAcres);

  return windService.analyzeWindEffects(
    wind: windConditions,
    lakeCenterLat: lake.centerLat,
    lakeCenterLon: lake.centerLon,
    lakeRadiusKm: radiusKm,
    lakeAreaAcres: areaAcres,
  );
});

/// Helper to estimate lake radius from area
double _estimateLakeRadius(double areaAcres) {
  // Area in acres -> km^2 -> radius assuming circular
  final areaKm2 = areaAcres * 0.00404686;
  return (areaKm2 / 3.14159).abs().clamp(0.5, 50.0);
}

/// Time range for the wind forecast slider.
/// Returns (earliest, latest) DateTime that can be selected.
final windTimeRangeProvider = Provider<(DateTime, DateTime)?>((ref) {
  final forecast = ref.watch(windForecastProvider).valueOrNull;
  if (forecast == null) return null;
  return (forecast.earliestTime, forecast.latestTime);
});

/// Whether we're showing historical data (past) or forecast (future).
final windTimeDisplayModeProvider = Provider<WindTimeMode>((ref) {
  final selectedTime = ref.watch(selectedWindTimeProvider);
  if (selectedTime == null) return WindTimeMode.current;
  
  final now = DateTime.now();
  if (selectedTime.isBefore(now.subtract(const Duration(hours: 1)))) {
    return WindTimeMode.historical;
  }
  if (selectedTime.isAfter(now.add(const Duration(hours: 1)))) {
    return WindTimeMode.forecast;
  }
  return WindTimeMode.current;
});

enum WindTimeMode {
  historical, // Showing past data
  current,    // Showing current conditions
  forecast,   // Showing future forecast
}

/// Formatted label for the current wind time selection.
final windTimeLabelProvider = Provider<String>((ref) {
  final mode = ref.watch(windTimeDisplayModeProvider);
  final selectedTime = ref.watch(selectedWindTimeProvider);

  switch (mode) {
    case WindTimeMode.current:
      return 'Now';
    case WindTimeMode.historical:
      return _formatTimeLabel(selectedTime!, isHistorical: true);
    case WindTimeMode.forecast:
      return _formatTimeLabel(selectedTime!, isHistorical: false);
  }
});

String _formatTimeLabel(DateTime time, {required bool isHistorical}) {
  final now = DateTime.now();
  final diff = time.difference(now);
  
  if (diff.inDays.abs() >= 1) {
    final days = diff.inDays.abs();
    final dayName = _getDayName(time);
    final timeStr = _formatHour(time);
    if (isHistorical) {
      return '$dayName $timeStr (${days}d ago)';
    }
    return '$dayName $timeStr (+${days}d)';
  }
  
  final hours = diff.inHours.abs();
  final timeStr = _formatHour(time);
  if (isHistorical) {
    return '$timeStr (${hours}h ago)';
  }
  return '$timeStr (+${hours}h)';
}

String _getDayName(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

String _formatHour(DateTime time) {
  final hour = time.hour;
  final ampm = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  return '$displayHour$ampm';
}
