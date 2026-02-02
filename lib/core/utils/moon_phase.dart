import 'dart:math';

/// Calculates moon phase for a given date using the synodic period algorithm.
///
/// Returns a value 0.0–1.0 representing the phase:
///   0.00 = New Moon
///   0.25 = First Quarter
///   0.50 = Full Moon
///   0.75 = Last Quarter
double moonPhase(DateTime date) {
  // Known new moon reference: Jan 11, 2024 11:57 UTC
  final reference = DateTime.utc(2024, 1, 11, 11, 57);
  const synodicPeriod = 29.53058770576;

  final daysSinceRef = date.difference(reference).inHours / 24.0;
  final phase = (daysSinceRef % synodicPeriod) / synodicPeriod;
  return phase < 0 ? phase + 1.0 : phase;
}

/// Returns the moon phase name for the given phase value (0.0–1.0).
String moonPhaseName(double phase) {
  if (phase < 0.03 || phase > 0.97) return 'New Moon';
  if (phase < 0.22) return 'Waxing Crescent';
  if (phase < 0.28) return 'First Quarter';
  if (phase < 0.47) return 'Waxing Gibbous';
  if (phase < 0.53) return 'Full Moon';
  if (phase < 0.72) return 'Waning Gibbous';
  if (phase < 0.78) return 'Last Quarter';
  return 'Waning Crescent';
}

/// Returns a Unicode moon emoji for the given phase.
String moonPhaseEmoji(double phase) {
  if (phase < 0.03 || phase > 0.97) return '\u{1F311}'; // New Moon
  if (phase < 0.22) return '\u{1F312}'; // Waxing Crescent
  if (phase < 0.28) return '\u{1F313}'; // First Quarter
  if (phase < 0.47) return '\u{1F314}'; // Waxing Gibbous
  if (phase < 0.53) return '\u{1F315}'; // Full Moon
  if (phase < 0.72) return '\u{1F316}'; // Waning Gibbous
  if (phase < 0.78) return '\u{1F317}'; // Last Quarter
  return '\u{1F318}'; // Waning Crescent
}

/// Moon illumination percentage (approximate).
double moonIllumination(double phase) {
  return (1.0 - cos(phase * 2 * pi)) / 2.0 * 100.0;
}
