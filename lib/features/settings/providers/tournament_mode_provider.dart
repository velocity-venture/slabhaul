import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing tournament mode preference.
const _kTournamentModeKey = 'tournament_mode_enabled';

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Notifier that manages tournament mode state and persists it to local storage.
/// 
/// Tournament mode disables AI-assisted features like:
/// - Thermocline Predictor
/// - Best Spots recommendations
/// - Any real-time AI assistance
/// 
/// This is intended for crappie tournaments (like Crappie Masters) that may
/// ban the use of real-time AI assistance during competition.
class TournamentModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  TournamentModeNotifier(this._prefs)
      : super(_prefs.getBool(_kTournamentModeKey) ?? false);

  /// Toggle tournament mode on/off.
  void toggle() {
    state = !state;
    _prefs.setBool(_kTournamentModeKey, state);
  }

  /// Explicitly set tournament mode.
  void setEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_kTournamentModeKey, enabled);
  }
}

/// Provider for tournament mode state.
/// 
/// Usage:
/// ```dart
/// final isTournamentMode = ref.watch(tournamentModeProvider);
/// ref.read(tournamentModeProvider.notifier).toggle();
/// ```
final tournamentModeProvider =
    StateNotifierProvider<TournamentModeNotifier, bool>((ref) {
  // This will throw if SharedPreferences isn't ready yet.
  // In practice, we initialize this after the app starts.
  throw UnimplementedError(
    'tournamentModeProvider must be overridden with a valid SharedPreferences instance',
  );
});

/// Async provider that properly waits for SharedPreferences.
/// Use this in widgets that can handle the async state.
final tournamentModeAsyncProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getBool(_kTournamentModeKey) ?? false;
});
