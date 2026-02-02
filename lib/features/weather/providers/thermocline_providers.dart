import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/lake.dart';
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
  final conditions = await ref.watch(lakeConditionsProvider.future);
  final coords = ref.watch(selectedWeatherLakeProvider);
  
  // Convert WeatherLakeCoords to Lake for thermocline service
  final lake = Lake(
    id: coords.name.toLowerCase().replaceAll(' ', '_'),
    name: coords.name,
    state: '', // Not needed for thermocline calculation
    centerLat: coords.lat,
    centerLon: coords.lon,
    maxDepthFt: coords.maxDepthFt,
    areaAcres: coords.areaAcres,
  );
  
  final service = ref.read(thermoclineServiceProvider);
  
  return service.predictThermocline(
    lake: lake,
    weather: weather,
    conditions: conditions,
  );
});
