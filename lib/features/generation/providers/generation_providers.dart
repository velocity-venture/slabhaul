import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/generation_data.dart';
import 'package:slabhaul/core/services/generation_service.dart';

/// Service provider for generation data
final generationServiceProvider = Provider<GenerationService>((ref) {
  return GenerationService();
});

/// Currently selected dam for generation tracking
/// Defaults to Kentucky Dam
final selectedDamProvider = StateProvider<DamConfig?>((ref) {
  return TvaDams.kentucky;
});

/// Fetches generation data for the selected dam
final generationDataProvider = FutureProvider<GenerationData?>((ref) async {
  final dam = ref.watch(selectedDamProvider);
  if (dam == null) return null;

  final service = ref.read(generationServiceProvider);
  return service.getGenerationData(dam);
});

/// Fetches generation data for a specific dam (family provider)
final generationDataForDamProvider =
    FutureProvider.family<GenerationData, DamConfig>((ref, dam) async {
  final service = ref.read(generationServiceProvider);
  return service.getGenerationData(dam);
});

/// Quick status check - is generation currently happening?
final isGeneratingProvider = Provider<bool>((ref) {
  final genAsync = ref.watch(generationDataProvider);
  return genAsync.when(
    data: (data) => data?.isGenerating ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Time until next generation (formatted string)
final nextGenerationTimeProvider = Provider<String?>((ref) {
  final genAsync = ref.watch(generationDataProvider);
  return genAsync.when(
    data: (data) {
      if (data == null) return null;
      final duration = data.timeUntilGeneration;
      if (duration == null) return 'Unknown';
      if (duration == Duration.zero) return 'Now';

      if (duration.inHours >= 24) {
        return '${duration.inDays}d ${duration.inHours % 24}h';
      } else if (duration.inHours >= 1) {
        return '${duration.inHours}h ${duration.inMinutes % 60}m';
      } else {
        return '${duration.inMinutes}m';
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Get dam config for a lake name (helper)
DamConfig? getDamForLake(String lakeName) => TvaDams.forLake(lakeName);
