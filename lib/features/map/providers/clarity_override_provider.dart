import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/water_clarity.dart';
import 'package:slabhaul/features/map/providers/clarity_providers.dart';

/// Manual clarity override. When non-null, bypasses the computed clarity.
final manualClarityOverrideProvider = StateProvider<ClarityLevel?>((ref) => null);

/// Returns the manual override if set, otherwise delegates to the
/// weather-computed [clarityForBaitEngineProvider].
final effectiveClarityProvider = FutureProvider<ClarityLevel>((ref) async {
  final override = ref.watch(manualClarityOverrideProvider);
  if (override != null) return override;
  return ref.watch(clarityForBaitEngineProvider.future);
});
