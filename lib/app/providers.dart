import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/attractor_service.dart';
import '../core/services/weather_service.dart';
import '../core/services/lake_service.dart';
import '../core/services/generation_service.dart';

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
