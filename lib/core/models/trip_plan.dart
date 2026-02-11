/// Smart Trip Plan — AI-generated fishing strategy
///
/// Combines weather, solunar, thermocline, and bait data into
/// a single actionable plan with confidence scoring.

enum TripRating { excellent, good, fair, poor }

enum FeedingWindow { major, minor, none }

class TripPlan {
  final DateTime generatedAt;
  final String lakeName;
  final double overallScore;
  final TripRating rating;
  final String summary;
  final List<TimeWindow> bestWindows;
  final DepthStrategy depthStrategy;
  final List<String> topBaits;
  final List<String> tactics;
  final List<String> warnings;
  final ConditionsBreakdown conditions;

  const TripPlan({
    required this.generatedAt,
    required this.lakeName,
    required this.overallScore,
    required this.rating,
    required this.summary,
    required this.bestWindows,
    required this.depthStrategy,
    required this.topBaits,
    required this.tactics,
    required this.warnings,
    required this.conditions,
  });

  bool get isGoDay => rating == TripRating.excellent || rating == TripRating.good;
  String get ratingLabel => switch (rating) {
    TripRating.excellent => 'Excellent',
    TripRating.good => 'Good',
    TripRating.fair => 'Fair',
    TripRating.poor => 'Poor',
  };
  String get ratingEmoji => switch (rating) {
    TripRating.excellent => '🔥',
    TripRating.good => '👍',
    TripRating.fair => '😐',
    TripRating.poor => '⛔',
  };
}

class TimeWindow {
  final DateTime start;
  final DateTime end;
  final FeedingWindow feedingType;
  final double activityScore;
  final String reason;

  const TimeWindow({
    required this.start,
    required this.end,
    required this.feedingType,
    required this.activityScore,
    required this.reason,
  });

  String get label => '${_fmt(start)} – ${_fmt(end)}';
  String _fmt(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : t.hour;
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }
}

class DepthStrategy {
  final double primaryDepthFt;
  final double? secondaryDepthFt;
  final String zone;
  final String reasoning;

  const DepthStrategy({
    required this.primaryDepthFt,
    this.secondaryDepthFt,
    required this.zone,
    required this.reasoning,
  });

  String get depthRange => secondaryDepthFt != null
      ? '${primaryDepthFt.round()}–${secondaryDepthFt!.round()} ft'
      : '${primaryDepthFt.round()} ft';
}

class ConditionsBreakdown {
  final double tempScore;
  final double pressureScore;
  final double windScore;
  final double solunarScore;
  final double clarityScore;
  final double waterTempF;
  final double pressureMb;
  final double windSpeedMph;
  final String pressureTrend;
  final String season;

  const ConditionsBreakdown({
    required this.tempScore,
    required this.pressureScore,
    required this.windScore,
    required this.solunarScore,
    required this.clarityScore,
    required this.waterTempF,
    required this.pressureMb,
    required this.windSpeedMph,
    required this.pressureTrend,
    required this.season,
  });

  double get average =>
      (tempScore + pressureScore + windScore + solunarScore + clarityScore) / 5;
}
