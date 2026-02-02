import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/generation_data.dart';
import 'package:slabhaul/features/generation/providers/generation_lake_provider.dart';

/// History range options for the generation chart
enum HistoryRange {
  oneDay(1, '24hr'),
  twoDays(2, '48hr'),
  sevenDays(7, '7 Days');

  final int days;
  final String label;

  const HistoryRange(this.days, this.label);
}

/// Currently selected history range for the chart
final generationHistoryRangeProvider = StateProvider<HistoryRange>((ref) {
  return HistoryRange.sevenDays;
});

/// Fetches detailed generation data with 7-day history
final generationDetailProvider = FutureProvider<GenerationData?>((ref) async {
  final dam = ref.watch(selectedLakeDamProvider);
  if (dam == null) return null;

  final service = ref.read(generationServiceProvider);
  return service.getGenerationDataWithHistory(dam);
});

/// Analysis of generation patterns over the history period
final generationPatternAnalysisProvider = Provider<DetectedPattern?>((ref) {
  final genAsync = ref.watch(generationDetailProvider);
  return genAsync.when(
    data: (data) => data?.detectedPattern,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Get 7-day history stats
final generationHistoryStatsProvider = Provider<GenerationHistory?>((ref) {
  final genAsync = ref.watch(generationDetailProvider);
  return genAsync.when(
    data: (data) => data?.history7Day,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Check if generation is trending up (more frequent) or down
final generationTrendProvider = Provider<String?>((ref) {
  final history = ref.watch(generationHistoryStatsProvider);
  if (history == null) return null;

  final genPct = history.generatingPercent;
  if (genPct >= 40) return 'High activity';
  if (genPct >= 25) return 'Moderate activity';
  if (genPct >= 10) return 'Low activity';
  return 'Minimal activity';
});
