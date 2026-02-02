import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/thermocline_data.dart';
import 'package:slabhaul/core/services/thermocline_service.dart';
import 'package:slabhaul/features/weather/providers/weather_providers.dart';
import 'package:slabhaul/features/weather/providers/lake_conditions_providers.dart';

/// Service provider for thermocline predictions
final thermoclineServiceProvider = Provider<ThermoclineService>((ref) {
  return ThermoclineService();
});

/// Provider for thermocline prediction data
/// 
/// Combines weather and lake conditions to predict thermocline depth
/// and generate fishing recommendations.
final thermoclineDataProvider = FutureProvider<ThermoclineData>((ref) async {
  final weather = await ref.watch(weatherDataProvider.future);
  final lake = await ref.watch(lakeConditionsProvider.future);
  final selectedLake = ref.watch(selectedWeatherLakeProvider);
  
  final service = ref.read(thermoclineServiceProvider);
  
  return service.predict(
    weather: weather,
    lakeConditions: lake,
    maxLakeDepthFt: selectedLake.maxDepthFt ?? 35.0,
    lakeAreaAcres: selectedLake.areaAcres,
  );
});
