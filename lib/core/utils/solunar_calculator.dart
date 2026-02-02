import 'dart:math';
import 'moon_phase.dart';

/// Solunar fishing activity calculator
/// 
/// The Solunar Theory (developed by John Alden Knight in 1926) suggests that
/// fish and game activity correlates with the position of the moon.
/// 
/// Major periods: Moon overhead and underfoot (transit)
/// Minor periods: Moonrise and moonset
class SolunarCalculator {
  
  /// Calculate solunar periods for a given date and location
  static SolunarForecast calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    final moonPhase = MoonPhase.calculate(date);
    
    // Simplified moon transit calculations
    // In production, use astronomical library for accurate times
    final lunarDay = _getLunarDay(date);
    
    // Major periods occur when moon is overhead (~0h) and underfoot (~12h from transit)
    final moonTransit = _estimateMoonTransit(date, longitude);
    final majorPeriod1Start = moonTransit;
    final majorPeriod2Start = moonTransit.add(const Duration(hours: 12, minutes: 25));
    
    // Minor periods at moonrise and moonset (roughly 6h from transit)
    final minorPeriod1Start = moonTransit.subtract(const Duration(hours: 6, minutes: 12));
    final minorPeriod2Start = moonTransit.add(const Duration(hours: 6, minutes: 12));
    
    // Calculate activity rating based on moon phase
    final phaseRating = _getPhaseRating(moonPhase);
    
    return SolunarForecast(
      date: date,
      moonPhase: moonPhase,
      majorPeriods: [
        SolunarPeriod(
          start: majorPeriod1Start,
          duration: const Duration(hours: 2),
          type: SolunarPeriodType.major,
          intensity: phaseRating,
        ),
        SolunarPeriod(
          start: majorPeriod2Start,
          duration: const Duration(hours: 2),
          type: SolunarPeriodType.major,
          intensity: phaseRating,
        ),
      ],
      minorPeriods: [
        SolunarPeriod(
          start: minorPeriod1Start,
          duration: const Duration(hours: 1),
          type: SolunarPeriodType.minor,
          intensity: phaseRating * 0.7,
        ),
        SolunarPeriod(
          start: minorPeriod2Start,
          duration: const Duration(hours: 1),
          type: SolunarPeriodType.minor,
          intensity: phaseRating * 0.7,
        ),
      ],
      overallRating: phaseRating,
      ratingLabel: _getRatingLabel(phaseRating),
    );
  }
  
  /// Get the lunar day (0-29.5)
  static double _getLunarDay(DateTime date) {
    // Synodic month = 29.53 days
    const synodicMonth = 29.530588853;
    
    // Known new moon: January 6, 2000 18:14 UTC
    final knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
    final daysSinceKnown = date.difference(knownNewMoon).inHours / 24.0;
    
    return daysSinceKnown % synodicMonth;
  }
  
  /// Estimate moon transit time (when moon crosses meridian)
  static DateTime _estimateMoonTransit(DateTime date, double longitude) {
    // Moon transits ~50 minutes later each day
    // This is a simplified approximation
    final lunarDay = _getLunarDay(date);
    
    // Base transit for new moon is roughly noon
    // Adjusts by ~50 min per lunar day
    final minutesOffset = (lunarDay * 50).round();
    
    // Adjust for longitude (4 min per degree from prime meridian)
    final longitudeOffset = (longitude * 4).round();
    
    final baseTime = DateTime(date.year, date.month, date.day, 12, 0);
    return baseTime
        .add(Duration(minutes: minutesOffset))
        .subtract(Duration(minutes: longitudeOffset));
  }
  
  /// Get activity rating based on moon phase
  /// New moon and full moon = highest activity
  static double _getPhaseRating(double moonPhase) {
    // moonPhase: 0 = new, 0.5 = full, 1 = new again
    // Peak activity at new (0) and full (0.5)
    
    double rating;
    if (moonPhase <= 0.5) {
      // New to full: peak at 0 and 0.5
      final distFromPeak = min(moonPhase, 0.5 - moonPhase);
      rating = 1.0 - (distFromPeak * 2);
    } else {
      // Full to new: peak at 0.5 and 1.0
      final distFromFull = moonPhase - 0.5;
      final distFromNew = 1.0 - moonPhase;
      final distFromPeak = min(distFromFull, distFromNew);
      rating = 1.0 - (distFromPeak * 2);
    }
    
    // Scale to 0.4 - 1.0 range (never "terrible")
    return 0.4 + (rating * 0.6);
  }
  
  /// Get human-readable rating label
  static String _getRatingLabel(double rating) {
    if (rating >= 0.9) return 'Excellent';
    if (rating >= 0.75) return 'Good';
    if (rating >= 0.6) return 'Fair';
    return 'Poor';
  }
}

/// Solunar forecast for a day
class SolunarForecast {
  final DateTime date;
  final double moonPhase;
  final List<SolunarPeriod> majorPeriods;
  final List<SolunarPeriod> minorPeriods;
  final double overallRating;
  final String ratingLabel;
  
  const SolunarForecast({
    required this.date,
    required this.moonPhase,
    required this.majorPeriods,
    required this.minorPeriods,
    required this.overallRating,
    required this.ratingLabel,
  });
  
  /// All periods sorted by time
  List<SolunarPeriod> get allPeriods {
    final all = [...majorPeriods, ...minorPeriods];
    all.sort((a, b) => a.start.compareTo(b.start));
    return all;
  }
  
  /// Get the next upcoming period
  SolunarPeriod? getNextPeriod(DateTime now) {
    for (final period in allPeriods) {
      if (period.end.isAfter(now)) {
        return period;
      }
    }
    return null;
  }
  
  /// Moon phase as emoji
  String get moonEmoji {
    if (moonPhase < 0.125) return '🌑'; // New
    if (moonPhase < 0.25) return '🌒';  // Waxing crescent
    if (moonPhase < 0.375) return '🌓'; // First quarter
    if (moonPhase < 0.5) return '🌔';   // Waxing gibbous
    if (moonPhase < 0.625) return '🌕'; // Full
    if (moonPhase < 0.75) return '🌖';  // Waning gibbous
    if (moonPhase < 0.875) return '🌗'; // Last quarter
    return '🌘';                         // Waning crescent
  }
}

/// A solunar activity period
class SolunarPeriod {
  final DateTime start;
  final Duration duration;
  final SolunarPeriodType type;
  final double intensity;
  
  const SolunarPeriod({
    required this.start,
    required this.duration,
    required this.type,
    required this.intensity,
  });
  
  DateTime get end => start.add(duration);
  
  bool isActive(DateTime now) {
    return now.isAfter(start) && now.isBefore(end);
  }
  
  String get label => type == SolunarPeriodType.major ? 'Major' : 'Minor';
}

enum SolunarPeriodType { major, minor }
