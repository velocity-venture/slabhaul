import '../models/trip_plan.dart';
import '../models/weather_data.dart';

/// Smart Trip Planner — AI fishing intelligence
///
/// Synthesizes weather, solunar, thermocline, and seasonal data into
/// a Go/No-Go assessment with optimized fishing strategy.
///
/// Scoring weights:
///   Temperature fit   30%  — crappie metabolism driver
///   Pressure trend    25%  — feeding behavior predictor
///   Wind conditions   15%  — fishability + bite detection
///   Solunar period    15%  — lunar feeding windows
///   Water clarity     15%  — presentation selection
class SmartTripPlanner {
  /// Generate a trip plan from current weather data and lake info.
  TripPlan generatePlan({
    required WeatherData weather,
    required String lakeName,
    required double waterTempF,
    double? thermoclineDepthFt,
    double? lakeMaxDepthFt,
    double? waterClarityFt,
    double? solunarRating,
    DateTime? sunrise,
    DateTime? sunset,
  }) {
    final now = DateTime.now();
    final current = weather.current;

    // Score each factor (0.0 - 1.0)
    final tempScore = _scoreTemperature(waterTempF);
    final pressureScore = _scorePressure(current.pressureMb, weather.hourly);
    final windScore = _scoreWind(current.windSpeedMph);
    final solunarScore = solunarRating ?? 0.5;
    final clarityScore = _scoreClarity(waterClarityFt);

    // Weighted overall score
    final overall = (tempScore * 0.30 +
            pressureScore * 0.25 +
            windScore * 0.15 +
            solunarScore * 0.15 +
            clarityScore * 0.15) *
        100;

    final rating = _toRating(overall);
    final pressureTrend = _getPressureTrend(current.pressureMb, weather.hourly);
    final season = _determineSeason(waterTempF);

    // Build feeding windows
    final windows = _buildTimeWindows(
      now: now,
      sunrise: sunrise ?? DateTime(now.year, now.month, now.day, 6, 30),
      sunset: sunset ?? DateTime(now.year, now.month, now.day, 17, 30),
      solunarRating: solunarScore,
      pressureTrend: pressureTrend,
    );

    // Depth strategy
    final depth = _buildDepthStrategy(
      waterTempF: waterTempF,
      thermoclineDepthFt: thermoclineDepthFt,
      lakeMaxDepthFt: lakeMaxDepthFt,
      season: season,
    );

    // Tactics based on conditions
    final tactics = _buildTactics(
      waterTempF: waterTempF,
      windSpeedMph: current.windSpeedMph,
      pressureTrend: pressureTrend,
      season: season,
      clarity: waterClarityFt,
    );

    // Top baits (quick picks, not full recommendation engine)
    final topBaits = _quickBaitPicks(waterTempF, season, waterClarityFt);

    // Warnings
    final warnings = _buildWarnings(
      windSpeedMph: current.windSpeedMph,
      pressureTrend: pressureTrend,
      waterTempF: waterTempF,
    );

    // Summary
    final summary = _buildSummary(
      rating: rating,
      waterTempF: waterTempF,
      season: season,
      pressureTrend: pressureTrend,
      windSpeedMph: current.windSpeedMph,
    );

    return TripPlan(
      generatedAt: now,
      lakeName: lakeName,
      overallScore: overall,
      rating: rating,
      summary: summary,
      bestWindows: windows,
      depthStrategy: depth,
      topBaits: topBaits,
      tactics: tactics,
      warnings: warnings,
      conditions: ConditionsBreakdown(
        tempScore: tempScore,
        pressureScore: pressureScore,
        windScore: windScore,
        solunarScore: solunarScore,
        clarityScore: clarityScore,
        waterTempF: waterTempF,
        pressureMb: current.pressureMb,
        windSpeedMph: current.windSpeedMph,
        pressureTrend: pressureTrend,
        season: season,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Scoring Functions
  // ---------------------------------------------------------------------------

  double _scoreTemperature(double tempF) {
    // Crappie sweet spot: 55-72°F (pre-spawn through post-spawn)
    if (tempF >= 55 && tempF <= 72) return 1.0;
    if (tempF >= 48 && tempF < 55) return 0.7; // Late winter staging
    if (tempF > 72 && tempF <= 80) return 0.6; // Summer — still catchable
    if (tempF >= 40 && tempF < 48) return 0.5; // Cold but vertical jigging works
    if (tempF > 80 && tempF <= 88) return 0.4; // Hot — early/late only
    if (tempF < 40) return 0.2; // Near lethargy
    return 0.2; // Extreme heat
  }

  double _scorePressure(double pressureMb, List<HourlyForecast> hourly) {
    final trend = _getPressureTrend(pressureMb, hourly);
    return switch (trend) {
      'falling' => 0.9, // Pre-front feeding frenzy
      'stable_high' => 0.7, // Consistent conditions
      'rising' => 0.4, // Post-front recovery
      'stable_low' => 0.5, // Overcast, decent
      _ => 0.5,
    };
  }

  double _scoreWind(double windMph) {
    if (windMph <= 5) return 0.8; // Calm — good for finesse
    if (windMph <= 10) return 1.0; // Light chop — ideal (breaks surface, oxygenates)
    if (windMph <= 15) return 0.7; // Moderate — still fishable
    if (windMph <= 20) return 0.4; // Tough boat control
    return 0.2; // Dangerous
  }

  double _scoreClarity(double? clarityFt) {
    if (clarityFt == null) return 0.5; // Unknown
    if (clarityFt >= 2 && clarityFt <= 5) return 1.0; // Ideal stain
    if (clarityFt > 5 && clarityFt <= 8) return 0.7; // Clear — finesse needed
    if (clarityFt >= 1 && clarityFt < 2) return 0.6; // Stained — use color
    if (clarityFt > 8) return 0.5; // Gin clear — tough
    return 0.3; // Muddy
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _getPressureTrend(double currentMb, List<HourlyForecast> hourly) {
    if (hourly.length >= 6) {
      final diff = currentMb - hourly[5].pressureMb;
      if (diff < -3) return 'falling';
      if (diff > 3) return 'rising';
    }
    if (currentMb > 1020) return 'stable_high';
    if (currentMb < 1005) return 'stable_low';
    return 'stable_high';
  }

  String _determineSeason(double waterTempF) {
    if (waterTempF < 50) return 'Winter';
    if (waterTempF < 60) return 'Pre-Spawn';
    if (waterTempF < 68) return 'Spawn';
    if (waterTempF < 75) return 'Post-Spawn';
    final month = DateTime.now().month;
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Summer';
  }

  TripRating _toRating(double score) {
    if (score >= 75) return TripRating.excellent;
    if (score >= 55) return TripRating.good;
    if (score >= 35) return TripRating.fair;
    return TripRating.poor;
  }

  List<TimeWindow> _buildTimeWindows({
    required DateTime now,
    required DateTime sunrise,
    required DateTime sunset,
    required double solunarRating,
    required String pressureTrend,
  }) {
    final windows = <TimeWindow>[];

    // Dawn window: 30 min before sunrise to 2 hrs after
    windows.add(TimeWindow(
      start: sunrise.subtract(const Duration(minutes: 30)),
      end: sunrise.add(const Duration(hours: 2)),
      feedingType: FeedingWindow.major,
      activityScore: 0.9,
      reason: 'Dawn feed — peak bite window',
    ));

    // Dusk window: 2 hrs before sunset to 30 min after
    windows.add(TimeWindow(
      start: sunset.subtract(const Duration(hours: 2)),
      end: sunset.add(const Duration(minutes: 30)),
      feedingType: FeedingWindow.major,
      activityScore: 0.85,
      reason: 'Dusk feed — second-best window',
    ));

    // Solunar minor period (midday)
    if (solunarRating > 0.6) {
      final midday = DateTime(now.year, now.month, now.day, 11, 30);
      windows.add(TimeWindow(
        start: midday,
        end: midday.add(const Duration(hours: 2)),
        feedingType: FeedingWindow.minor,
        activityScore: solunarRating * 0.7,
        reason: 'Solunar minor period — opportunistic feeding',
      ));
    }

    // Pre-front bonus: all-day bite
    if (pressureTrend == 'falling') {
      windows.insert(
        0,
        TimeWindow(
          start: sunrise,
          end: sunset,
          feedingType: FeedingWindow.major,
          activityScore: 0.95,
          reason: 'Falling pressure — all-day feeding frenzy',
        ),
      );
    }

    windows.sort((a, b) => b.activityScore.compareTo(a.activityScore));
    return windows;
  }

  DepthStrategy _buildDepthStrategy({
    required double waterTempF,
    double? thermoclineDepthFt,
    double? lakeMaxDepthFt,
    required String season,
  }) {
    if (thermoclineDepthFt != null) {
      return DepthStrategy(
        primaryDepthFt: thermoclineDepthFt - 2,
        secondaryDepthFt: thermoclineDepthFt + 3,
        zone: 'Thermocline',
        reasoning:
            'Fish suspend near the thermocline at ${thermoclineDepthFt.round()} ft '
            'where temperature and oxygen converge.',
      );
    }

    return switch (season) {
      'Winter' => DepthStrategy(
          primaryDepthFt: 18,
          secondaryDepthFt: 30,
          zone: 'Deep channels',
          reasoning:
              'Cold water pushes crappie to deep structure along creek channels.',
        ),
      'Pre-Spawn' => DepthStrategy(
          primaryDepthFt: 8,
          secondaryDepthFt: 15,
          zone: 'Staging areas',
          reasoning:
              'Fish migrate from deep to shallow — target points and brush on migration routes.',
        ),
      'Spawn' => DepthStrategy(
          primaryDepthFt: 3,
          secondaryDepthFt: 8,
          zone: 'Shallow cover',
          reasoning:
              'Males on beds in 3-6 ft. Females staging just deeper at 6-8 ft.',
        ),
      'Post-Spawn' => DepthStrategy(
          primaryDepthFt: 8,
          secondaryDepthFt: 15,
          zone: 'Transitional',
          reasoning: 'Fish scattering from beds. Try docks, brush, and '
              'deeper points as they transition to summer patterns.',
        ),
      'Summer' => DepthStrategy(
          primaryDepthFt: 15,
          secondaryDepthFt: 25,
          zone: 'Suspended / deep brush',
          reasoning:
              'Look for fish suspended over deep structure or along the thermocline.',
        ),
      'Fall' => DepthStrategy(
          primaryDepthFt: 6,
          secondaryDepthFt: 15,
          zone: 'Creek arms',
          reasoning:
              'Follow the shad into creek arms. Fish push shallow chasing baitfish.',
        ),
      _ => DepthStrategy(
          primaryDepthFt: 10,
          secondaryDepthFt: 20,
          zone: 'General',
          reasoning: 'Start mid-depth and adjust based on your electronics.',
        ),
    };
  }

  List<String> _buildTactics({
    required double waterTempF,
    required double windSpeedMph,
    required String pressureTrend,
    required String season,
    double? clarity,
  }) {
    final tactics = <String>[];

    // Speed-based tactic
    if (waterTempF < 50) {
      tactics.add('Ultra-slow vertical jigging — 2-3 second pause between lifts');
    } else if (waterTempF >= 55 && waterTempF <= 68) {
      tactics.add(
          'Spider rigging at 0.5-0.8 mph — cover water along migration routes');
    } else if (waterTempF > 68) {
      tactics.add(
          'Trolling or casting — fish are active, match their aggression');
    }

    // Wind adaptation
    if (windSpeedMph > 12) {
      tactics.add('Drift-fish the windblown bank — bait concentrates there');
    } else if (windSpeedMph < 5) {
      tactics.add('Stealth approach — calm water means spooky fish. Long casts.');
    }

    // Pressure adaptation
    if (pressureTrend == 'falling') {
      tactics.add('Fish fast and aggressive — pre-front fish are feeding up');
    } else if (pressureTrend == 'rising') {
      tactics.add('Downsize everything — post-front fish are tight-lipped');
    }

    // Season tactic
    if (season == 'Spawn') {
      tactics.add('Slow-drag jigs across beds — trigger defensive strikes');
    } else if (season == 'Fall') {
      tactics.add('Match the hatch — shad-profile baits in silver/white');
    }

    // Clarity tactic
    if (clarity != null && clarity < 1.5) {
      tactics.add('Add scent and use rattles — fish are hunting by feel');
    }

    return tactics.take(4).toList();
  }

  List<String> _quickBaitPicks(
      double waterTempF, String season, double? clarity) {
    if (waterTempF < 50) {
      return ['Hair jig (1/16 oz)', 'Blade bait', 'Live minnow on tight-line'];
    }
    if (season == 'Pre-Spawn' || season == 'Spawn') {
      final color = (clarity != null && clarity < 2)
          ? 'chartreuse/white'
          : 'monkey milk';
      return ['Tube jig ($color)', 'Bobby Garland Baby Shad', 'Curly tail grub'];
    }
    if (season == 'Summer') {
      return [
        'Minnow under slip-float',
        'Deep-diving crankbait',
        'Tube jig (1/8 oz)',
      ];
    }
    if (season == 'Fall') {
      return [
        'Shad-profile swimbait',
        'Tube jig (threadfin shad)',
        'Crankbait (silver/black)',
      ];
    }
    return ['Tube jig (1/8 oz)', 'Curly tail grub', 'Live minnow'];
  }

  List<String> _buildWarnings({
    required double windSpeedMph,
    required String pressureTrend,
    required double waterTempF,
  }) {
    final warnings = <String>[];

    if (windSpeedMph > 20) {
      warnings.add('⚠️ High winds (${windSpeedMph.round()} mph) — '
          'dangerous boating conditions. Consider postponing.');
    } else if (windSpeedMph > 15) {
      warnings.add('⚠️ Moderate-strong winds — use a drift sock and '
          'stay aware of wave conditions.');
    }

    if (pressureTrend == 'rising' && waterTempF < 50) {
      warnings.add('⚠️ Post-front + cold water = extremely tough bite. '
          'Manage expectations.');
    }

    if (waterTempF > 85) {
      warnings.add('⚠️ Water temps above 85°F — fish are stressed. '
          'Early morning only, handle fish carefully.');
    }

    return warnings;
  }

  String _buildSummary({
    required TripRating rating,
    required double waterTempF,
    required String season,
    required String pressureTrend,
    required double windSpeedMph,
  }) {
    final ratingText = switch (rating) {
      TripRating.excellent => "Today is a GO! Conditions are stacked in your favor.",
      TripRating.good => "Solid day to fish. Conditions are favorable.",
      TripRating.fair =>
        "Fishable but challenging. Adjust expectations and techniques.",
      TripRating.poor =>
        "Tough conditions today. Consider postponing or going ultra-finesse.",
    };

    final pressureText = switch (pressureTrend) {
      'falling' => 'Falling pressure is triggering a feeding response.',
      'rising' => 'Rising pressure post-front — fish will be cautious.',
      'stable_high' => 'Stable high pressure — consistent conditions.',
      'stable_low' => 'Low pressure system — overcast skies help.',
      _ => '',
    };

    return '$ratingText $season pattern at ${waterTempF.round()}°F. '
        '$pressureText Wind ${windSpeedMph.round()} mph.';
  }
}
