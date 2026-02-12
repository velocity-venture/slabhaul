import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/livewell.dart';
import 'package:slabhaul/core/services/livewell_service.dart';

/// Provider for the [LivewellService] singleton.
final livewellServiceProvider = Provider<LivewellService>((ref) {
  return LivewellService();
});

/// Current livewell conditions being tracked.
///
/// Set to `null` when the user is not actively monitoring a livewell.
/// Update via `ref.read(livewellConditionsProvider.notifier).state = ...`
/// whenever the user changes fish count, equipment toggles, or new
/// temperature data arrives.
final livewellConditionsProvider = StateProvider<LivewellConditions?>((ref) {
  return null;
});

/// Computed livewell alert derived from the current [livewellConditionsProvider].
///
/// Returns `null` when no conditions are being tracked. Automatically
/// re-evaluates whenever conditions change.
final livewellAlertProvider = Provider<LivewellAlert?>((ref) {
  final conditions = ref.watch(livewellConditionsProvider);
  if (conditions == null) return null;

  final service = ref.read(livewellServiceProvider);
  return service.evaluate(conditions);
});
