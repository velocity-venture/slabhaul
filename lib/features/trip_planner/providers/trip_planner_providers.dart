import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/trip_plan.dart';
import '../../../core/services/smart_trip_planner.dart';
import '../../weather/providers/weather_providers.dart';

/// Provider for the Smart Trip Planner service
final tripPlannerServiceProvider = Provider<SmartTripPlanner>((ref) {
  return SmartTripPlanner();
});

/// Current lake-specific parameters for trip planning
class TripPlannerParams {
  final String lakeName;
  final double waterTempF;
  final double latitude;
  final double longitude;
  final double? thermoclineDepthFt;
  final double? lakeMaxDepthFt;
  final double? waterClarityFt;
  final DateTime? sunrise;
  final DateTime? sunset;

  const TripPlannerParams({
    required this.lakeName,
    required this.waterTempF,
    required this.latitude,
    required this.longitude,
    this.thermoclineDepthFt,
    this.lakeMaxDepthFt,
    this.waterClarityFt,
    this.sunrise,
    this.sunset,
  });

  TripPlannerParams copyWith({
    String? lakeName,
    double? waterTempF,
    double? latitude,
    double? longitude,
    double? thermoclineDepthFt,
    double? lakeMaxDepthFt,
    double? waterClarityFt,
    DateTime? sunrise,
    DateTime? sunset,
  }) {
    return TripPlannerParams(
      lakeName: lakeName ?? this.lakeName,
      waterTempF: waterTempF ?? this.waterTempF,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      thermoclineDepthFt: thermoclineDepthFt ?? this.thermoclineDepthFt,
      lakeMaxDepthFt: lakeMaxDepthFt ?? this.lakeMaxDepthFt,
      waterClarityFt: waterClarityFt ?? this.waterClarityFt,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
    );
  }
}

/// Provider for current trip planner parameters
final tripPlannerParamsProvider = StateProvider<TripPlannerParams>((ref) {
  final weatherLake = ref.watch(selectedWeatherLakeProvider);
  final now = DateTime.now();

  return TripPlannerParams(
    lakeName: weatherLake.name,
    waterTempF: _estimateWaterTemp(now),
    latitude: weatherLake.lat,
    longitude: weatherLake.lon,
    thermoclineDepthFt: _estimateThermocline(weatherLake.maxDepthFt, now),
    lakeMaxDepthFt: weatherLake.maxDepthFt,
    waterClarityFt: 3.0,
    sunrise: _calculateSunrise(now, weatherLake.lat),
    sunset: _calculateSunset(now, weatherLake.lat),
  );
});

/// Generates a trip plan using current weather and lake parameters
final currentTripPlanProvider = FutureProvider<TripPlan>((ref) async {
  final weather = await ref.watch(weatherDataProvider.future);
  final params = ref.watch(tripPlannerParamsProvider);
  final planner = ref.read(tripPlannerServiceProvider);

  return planner.generatePlan(
    weather: weather,
    lakeName: params.lakeName,
    waterTempF: params.waterTempF,
    latitude: params.latitude,
    longitude: params.longitude,
    thermoclineDepthFt: params.thermoclineDepthFt,
    lakeMaxDepthFt: params.lakeMaxDepthFt,
    waterClarityFt: params.waterClarityFt,
    sunrise: params.sunrise,
    sunset: params.sunset,
  );
});

double _estimateWaterTemp(DateTime date) {
  final month = date.month;
  final dayOfYear = date.day + (month - 1) * 30.4;
  final tempVariation = 25 * math.sin((dayOfYear - 75) * 2 * math.pi / 365);
  return 60 + tempVariation;
}

double? _estimateThermocline(double? maxDepth, DateTime date) {
  if (maxDepth == null || maxDepth < 20) return null;

  final month = date.month;
  if (month >= 5 && month <= 9) {
    return maxDepth * 0.4;
  }

  return null;
}

DateTime _calculateSunrise(DateTime date, double latitude) {
  const baseRiseHour = 6.5;
  final seasonalOffset = 1.5 * math.sin((date.day + (date.month - 1) * 30.4 - 80) * 2 * math.pi / 365);
  final riseHour = baseRiseHour + seasonalOffset;

  final hour = riseHour.floor();
  final minute = ((riseHour - hour) * 60).round();

  return DateTime(date.year, date.month, date.day, hour, minute);
}

DateTime _calculateSunset(DateTime date, double latitude) {
  const baseSetHour = 18.5;
  final seasonalOffset = 1.5 * math.sin((date.day + (date.month - 1) * 30.4 - 80) * 2 * math.pi / 365);
  final setHour = baseSetHour + seasonalOffset;

  final hour = setHour.floor();
  final minute = ((setHour - hour) * 60).round();

  return DateTime(date.year, date.month, date.day, hour, minute);
}
