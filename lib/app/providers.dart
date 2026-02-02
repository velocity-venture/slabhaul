import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/attractor_service.dart';
import '../core/services/weather_service.dart';
import '../core/services/lake_service.dart';
import '../core/services/generation_service.dart';
import '../core/services/wind_service.dart';
import '../core/services/hotspot_service.dart';
import '../core/services/streamflow_service.dart';
import '../core/services/water_clarity_service.dart';

final attractorServiceProvider = Provider<AttractorService>((ref) {
  return AttractorService();
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final lakeServiceProvider = Provider<LakeService>((ref) {
  return LakeService();
});

final generationServiceProvider = Provider<GenerationService>((ref) {
  return GenerationService();
});

final windServiceProviderImpl = Provider<WindService>((ref) {
  return WindService();
});

final hotspotServiceProviderImpl = Provider<HotspotService>((ref) {
  return HotspotService();
});

final streamflowServiceProviderImpl = Provider<StreamflowService>((ref) {
  return StreamflowService();
});

final waterClarityServiceProviderImpl = Provider<WaterClarityService>((ref) {
  return WaterClarityService();
});
