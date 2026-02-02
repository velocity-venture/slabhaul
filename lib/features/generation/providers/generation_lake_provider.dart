import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/generation_data.dart';
import 'package:slabhaul/features/weather/providers/weather_providers.dart';

/// Watches the selected weather lake and provides generation data
/// if the lake has a dam with generation tracking.
final selectedLakeDamProvider = Provider<DamConfig?>((ref) {
  final lake = ref.watch(selectedWeatherLakeProvider);
  return TvaDams.forLake(lake.name);
});

/// Fetches generation data for the currently selected weather lake.
/// Returns null if the lake doesn't have dam generation tracking.
final lakeGenerationProvider = FutureProvider<GenerationData?>((ref) async {
  final dam = ref.watch(selectedLakeDamProvider);
  if (dam == null) return null;

  final service = ref.read(generationServiceProvider);
  return service.getGenerationData(dam);
});

/// Quick check if the current lake has generation tracking
final hasGenerationTrackingProvider = Provider<bool>((ref) {
  return ref.watch(selectedLakeDamProvider) != null;
});
