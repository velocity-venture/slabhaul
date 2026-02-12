import 'dart:math';
import '../models/trip_plan.dart';
import '../models/weather_data.dart';
import '../utils/solunar_calculator.dart';

/// Smart Trip Planner — AI Fishing Intelligence Engine
///
/// Synthesizes weather, solunar astronomy, thermocline physics, and seasonal
/// crappie behavior into a Go/No-Go assessment with optimized strategy.
///
/// Scoring weights (research-backed):
///   Temperature fit   25%  — crappie metabolism / seasonal pattern driver
///   Pressure trend    25%  — #1 feeding behavior predictor (multi-hour analysis)
///   Solunar period    20%  — lunar transit feeding windows (calculated, not estimated)
///   Wind conditions   15%  — fishability + oxygen + bait positioning
///   Water clarity     15%  — presentation / color selection
class SmartTripPlanner {
  TripPlan generatePlan({
    required WeatherData weather,
    required String lakeName,
    required double waterTempF,
    required double latitude,
    required double longitude,
    double? thermoclineDepthFt,
    double? lakeMaxDepthFt,
    double? waterClarityFt,
    DateTime? sunrise,
    DateTime? sunset,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final current = weather.current;

    // Calculate real solunar forecast from astronomy
    final solunarForecast = SolunarCalculator.calculate(
      date: now,
      latitude: latitude,
      longitude: longitude,
    );

    // Multi-hour barometric analysis
    final baroAnalysis = _analyzeBarometricTrend(current.pressureMb, weather.hourly);

    // Score each factor (0.0 - 1.0)
    final tempScore = _scoreTemperature(waterTempF);
    final pressureScore = _scorePressureAdvanced(baroAnalysis);
    final solunarScore = _scoreSolunar(solunarForecast, now);
    final windScore = _scoreWind(current.windSpeedMph, current.windDirectionDeg);
    final clarityScore = _scoreClarity(waterClarityFt);

    // Weighted overall score
    final overall = (tempScore * 0.25 +
            pressureScore * 0.25 +
            solunarScore * 0.20 +
            windScore * 0.15 +
            clarityScore * 0.15) *
        100;

    final rating = _toRating(overall);
    final tempTrend = _computeTempTrend(weather.hourly);
    final season = _determineSeason(
      waterTempF,
      tempTrend: tempTrend,
      month: now.month,
    );

    final effectiveSunrise = sunrise ?? _defaultSunrise(now);
    final effectiveSunset = sunset ?? _defaultSunset(now);

    // Build feeding windows from real solunar periods + dawn/dusk
    final windows = _buildTimeWindows(
      now: now,
      sunrise: effectiveSunrise,
      sunset: effectiveSunset,
      solunarForecast: solunarForecast,
      baroAnalysis: baroAnalysis,
    );

    // Depth strategy with thermocline physics
    final depth = _buildDepthStrategy(
      waterTempF: waterTempF,
      thermoclineDepthFt: thermoclineDepthFt,
      lakeMaxDepthFt: lakeMaxDepthFt,
      season: season,
      baroAnalysis: baroAnalysis,
    );

    final tactics = _buildTactics(
      waterTempF: waterTempF,
      windSpeedMph: current.windSpeedMph,
      baroAnalysis: baroAnalysis,
      season: season,
      clarity: waterClarityFt,
      solunarForecast: solunarForecast,
      now: now,
    );

    final topBaits = _quickBaitPicks(waterTempF, season, waterClarityFt);

    final warnings = _buildWarnings(
      windSpeedMph: current.windSpeedMph,
      baroAnalysis: baroAnalysis,
      waterTempF: waterTempF,
      solunarForecast: solunarForecast,
    );

    final summary = _buildSummary(
      rating: rating,
      waterTempF: waterTempF,
      season: season,
      baroAnalysis: baroAnalysis,
      windSpeedMph: current.windSpeedMph,
      solunarForecast: solunarForecast,
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
        pressureTrend: baroAnalysis.trend,
        season: season,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Barometric Pressure Analysis
  // ---------------------------------------------------------------------------

  BarometricAnalysis _analyzeBarometricTrend(
      double currentMb, List<HourlyForecast> hourly) {
    double? delta6h;
    double? delta12h;
    double? delta24h;
    double volatility = 0;

    if (hourly.length >= 6) {
      delta6h = currentMb - hourly[5].pressureMb;
    }
    if (hourly.length >= 12) {
      delta12h = currentMb - hourly[11].pressureMb;
    }
    if (hourly.length >= 24) {
      delta24h = currentMb - hourly[23].pressureMb;
    }

    // Pressure volatility: std deviation of hour-to-hour changes
    if (hourly.length >= 6) {
      final changes = <double>[];
      for (int i = 1; i < min(24, hourly.length); i++) {
        changes.add(hourly[i].pressureMb - hourly[i - 1].pressureMb);
      }
      if (changes.isNotEmpty) {
        final mean = changes.reduce((a, b) => a + b) / changes.length;
        final variance =
            changes.map((c) => (c - mean) * (c - mean)).reduce((a, b) => a + b) /
                changes.length;
        volatility = sqrt(variance);
      }
    }

    // Classify trend using multi-hour analysis
    String trend;
    if (delta6h != null && delta6h < -3) {
      trend = delta12h != null && delta12h < -6 ? 'crashing' : 'falling';
    } else if (delta6h != null && delta6h > 3) {
      trend = delta12h != null && delta12h > 6 ? 'surging' : 'rising';
    } else if (currentMb > 1020) {
      trend = 'stable_high';
    } else if (currentMb < 1005) {
      trend = 'stable_low';
    } else {
      trend = 'stable';
    }

    return BarometricAnalysis(
      currentMb: currentMb,
      delta6h: delta6h,
      delta12h: delta12h,
      delta24h: delta24h,
      volatility: volatility,
      trend: trend,
    );
  }

  // ---------------------------------------------------------------------------
  // Scoring Functions
  // ---------------------------------------------------------------------------

  double _scoreTemperature(double tempF) {
    // Crappie metabolic sweet spots by phase:
    // Pre-spawn staging: 48-55°F (fish grouping, catchable in numbers)
    // Pre-spawn to spawn: 55-68°F (peak activity, aggressive feeding)
    // Post-spawn: 68-75°F (recovery feeding, still active)
    if (tempF >= 58 && tempF <= 65) return 1.0; // Dead center spawn — peak
    if (tempF >= 55 && tempF <= 72) return 0.9; // Prime range
    if (tempF >= 48 && tempF < 55) return 0.7; // Late winter staging
    if (tempF > 72 && tempF <= 78) return 0.65; // Early summer — still good
    if (tempF >= 42 && tempF < 48) return 0.5; // Cold — vertical jigging
    if (tempF > 78 && tempF <= 85) return 0.4; // Hot — dawn/dusk only
    if (tempF >= 38 && tempF < 42) return 0.3; // Near lethargy
    if (tempF > 85) return 0.2; // Stress zone
    return 0.15; // Below 38°F — lock-jaw
  }

  double _scorePressureAdvanced(BarometricAnalysis baro) {
    // Multi-hour barometric trend scoring
    // Falling pressure = fish sense the front coming, feed aggressively
    // Crashing pressure = feeding frenzy, best bite of the year
    // Rising = post-front lockjaw, worst conditions
    // Stable high = consistent, good baseline
    return switch (baro.trend) {
      'crashing' => 1.0, // Rapid pressure drop — all-day feeding frenzy
      'falling' => 0.85, // Pre-front feeding response
      'stable' => 0.65, // Neutral conditions
      'stable_high' => 0.7, // Consistent high — fish on schedule
      'stable_low' => 0.6, // Overcast, subtle bite
      'rising' => 0.35, // Post-front — fish are shut down
      'surging' => 0.2, // Rapid rise — worst conditions for feeding
      _ => 0.5,
    };
  }

  double _scoreSolunar(SolunarForecast forecast, DateTime now) {
    // Check if we're currently in or near a solunar period
    double periodBonus = 0;
    for (final period in forecast.allPeriods) {
      final minutesToPeriod = period.start.difference(now).inMinutes.abs();
      if (period.isActive(now)) {
        // Currently in a feeding window
        periodBonus = period.type == SolunarPeriodType.major ? 0.3 : 0.15;
        break;
      } else if (minutesToPeriod < 60) {
        // Within an hour of a period — fish start positioning
        periodBonus = period.type == SolunarPeriodType.major ? 0.15 : 0.08;
      }
    }

    // Base score from moon phase (0.4-1.0 from calculator)
    // New moon and full moon = best (1.0), quarters = worst (0.4)
    final phaseScore = forecast.overallRating;

    return min(1.0, phaseScore * 0.7 + periodBonus + 0.1);
  }

  double _scoreWind(double windMph, int windDirectionDeg) {
    // Speed scoring — light chop (5-10 mph) is ideal:
    // - Breaks surface glare (less spooky)
    // - Oxygenates water
    // - Positions bait along windblown banks
    // - Provides current for spider rigging
    double speedScore;
    if (windMph >= 5 && windMph <= 10) {
      speedScore = 1.0;
    } else if (windMph > 10 && windMph <= 15) {
      speedScore = 0.75;
    } else if (windMph > 0 && windMph < 5) {
      speedScore = 0.7;
    } else if (windMph > 15 && windMph <= 20) {
      speedScore = 0.4;
    } else if (windMph == 0) {
      speedScore = 0.6;
    } else {
      speedScore = 0.15;
    }

    final dirModifier = _windDirectionModifier(windDirectionDeg);
    return (speedScore * 0.75 + dirModifier * 0.25).clamp(0.0, 1.0);
  }

  /// Wind direction modifier for crappie fishing intelligence.
  /// S/SW winds = warm air, stable conditions, best feeding.
  /// N/NW winds = cold front passage, worst feeding.
  double _windDirectionModifier(int deg) {
    if (deg >= 180 && deg < 250) return 0.95; // S to SW — best
    if (deg >= 250 && deg < 300) return 0.80; // W to WNW — good
    if (deg >= 135 && deg < 180) return 0.75; // SE — fair
    if (deg >= 90 && deg < 135) return 0.55; // E to ESE — pre-frontal
    if (deg >= 45 && deg < 90) return 0.45; // NE — cold/unstable
    if (deg >= 300 || deg < 45) return 0.35; // NW to N — cold front
    return 0.60;
  }

  double _scoreClarity(double? clarityFt) {
    if (clarityFt == null) return 0.5;
    // Ideal: 2-4 ft visibility (stained water)
    // Crappie are ambush predators — they use cover + limited visibility
    if (clarityFt >= 2 && clarityFt <= 4) return 1.0;
    if (clarityFt > 4 && clarityFt <= 6) return 0.8; // Slightly clear — finesse
    if (clarityFt >= 1.5 && clarityFt < 2) return 0.75; // Stained — use chartreuse
    if (clarityFt > 6 && clarityFt <= 8) return 0.6; // Clear — long casts, light line
    if (clarityFt >= 1 && clarityFt < 1.5) return 0.5; // Muddy — need noise/scent
    if (clarityFt > 8) return 0.45; // Gin clear — toughest conditions
    return 0.3; // <1 ft — nearly unfishable
  }

  // ---------------------------------------------------------------------------
  // Time Windows — Real Solunar Integration
  // ---------------------------------------------------------------------------

  List<TimeWindow> _buildTimeWindows({
    required DateTime now,
    required DateTime sunrise,
    required DateTime sunset,
    required SolunarForecast solunarForecast,
    required BarometricAnalysis baroAnalysis,
  }) {
    final windows = <TimeWindow>[];

    // Dawn window: 30 min before sunrise to 90 min after
    // Dawn + solunar overlap = absolute peak
    final dawnStart = sunrise.subtract(const Duration(minutes: 30));
    final dawnEnd = sunrise.add(const Duration(minutes: 90));
    final dawnSolunarOverlap = _hasOverlap(
        dawnStart, dawnEnd, solunarForecast.allPeriods);
    windows.add(TimeWindow(
      start: dawnStart,
      end: dawnEnd,
      feedingType: FeedingWindow.major,
      activityScore: dawnSolunarOverlap ? 0.98 : 0.88,
      reason: dawnSolunarOverlap
          ? 'Dawn + solunar overlap — best bite of the day'
          : 'Dawn feed — low light triggers crappie movement',
    ));

    // Dusk window: 90 min before sunset to 30 min after
    final duskStart = sunset.subtract(const Duration(minutes: 90));
    final duskEnd = sunset.add(const Duration(minutes: 30));
    final duskSolunarOverlap = _hasOverlap(
        duskStart, duskEnd, solunarForecast.allPeriods);
    windows.add(TimeWindow(
      start: duskStart,
      end: duskEnd,
      feedingType: FeedingWindow.major,
      activityScore: duskSolunarOverlap ? 0.95 : 0.82,
      reason: duskSolunarOverlap
          ? 'Dusk + solunar overlap — second-best window'
          : 'Dusk feed — evening transition bite',
    ));

    // Real solunar major periods (moon overhead / underfoot)
    for (final period in solunarForecast.majorPeriods) {
      // Skip if already covered by dawn/dusk
      if (_isWithinWindow(period.start, dawnStart, dawnEnd) ||
          _isWithinWindow(period.start, duskStart, duskEnd)) {
        continue;
      }
      windows.add(TimeWindow(
        start: period.start,
        end: period.end,
        feedingType: FeedingWindow.major,
        activityScore: 0.7 + (period.intensity * 0.25),
        reason: '${period.label} — moon transit triggers deep feeding instinct',
      ));
    }

    // Real solunar minor periods (moonrise / moonset)
    for (final period in solunarForecast.minorPeriods) {
      if (_isWithinWindow(period.start, dawnStart, dawnEnd) ||
          _isWithinWindow(period.start, duskStart, duskEnd)) {
        continue;
      }
      windows.add(TimeWindow(
        start: period.start,
        end: period.end,
        feedingType: FeedingWindow.minor,
        activityScore: 0.5 + (period.intensity * 0.2),
        reason: '${period.label} — lunar position change activates feeding',
      ));
    }

    // Pre-front bonus: falling/crashing pressure = all-day bite
    if (baroAnalysis.trend == 'falling' || baroAnalysis.trend == 'crashing') {
      windows.insert(
        0,
        TimeWindow(
          start: sunrise,
          end: sunset,
          feedingType: FeedingWindow.major,
          activityScore: baroAnalysis.trend == 'crashing' ? 1.0 : 0.92,
          reason: baroAnalysis.trend == 'crashing'
              ? 'Pressure crashing — all-day feeding frenzy, fish gorging before front'
              : 'Falling pressure — extended feeding windows throughout the day',
        ),
      );
    }

    windows.sort((a, b) => b.activityScore.compareTo(a.activityScore));
    return windows;
  }

  bool _hasOverlap(
      DateTime start, DateTime end, List<SolunarPeriod> periods) {
    for (final p in periods) {
      if (p.start.isBefore(end) && p.end.isAfter(start)) return true;
    }
    return false;
  }

  bool _isWithinWindow(DateTime time, DateTime winStart, DateTime winEnd) {
    return time.isAfter(winStart) && time.isBefore(winEnd);
  }

  // ---------------------------------------------------------------------------
  // Depth Strategy — Thermocline Physics
  // ---------------------------------------------------------------------------

  DepthStrategy _buildDepthStrategy({
    required double waterTempF,
    double? thermoclineDepthFt,
    double? lakeMaxDepthFt,
    required String season,
    required BarometricAnalysis baroAnalysis,
  }) {
    // Thermocline-aware depth targeting
    if (thermoclineDepthFt != null) {
      // Crappie suspend just above the thermocline where oxygen and
      // temperature create an ideal zone. During stable pressure they
      // hold tight; during falling pressure they push shallower.
      final pressureAdjust = switch (baroAnalysis.trend) {
        'crashing' || 'falling' => -3.0, // Fish move up aggressively
        'rising' || 'surging' => 2.0, // Fish drop deeper, tighter to structure
        _ => 0.0,
      };

      final primary = max(2.0, thermoclineDepthFt - 2 + pressureAdjust);
      final secondary = thermoclineDepthFt + 3;

      final pressureNote = switch (baroAnalysis.trend) {
        'falling' || 'crashing' =>
          ' Falling pressure pushing fish ${pressureAdjust.abs().round()} ft shallower.',
        'rising' || 'surging' =>
          ' Rising pressure pushing fish deeper and tighter to cover.',
        _ => '',
      };

      return DepthStrategy(
        primaryDepthFt: primary,
        secondaryDepthFt: secondary,
        zone: 'Thermocline',
        reasoning:
            'Thermocline at ${thermoclineDepthFt.round()} ft — oxygen and '
            'temperature converge here. Target ${primary.round()}-'
            '${secondary.round()} ft.$pressureNote',
      );
    }

    // No thermocline data — use season + pressure adjustment
    final baseStrategy = _seasonalDepthStrategy(season);

    // Pressure-based depth adjustment
    if (baroAnalysis.trend == 'falling' || baroAnalysis.trend == 'crashing') {
      return DepthStrategy(
        primaryDepthFt: max(2.0, baseStrategy.primaryDepthFt - 3),
        secondaryDepthFt: baseStrategy.secondaryDepthFt,
        zone: baseStrategy.zone,
        reasoning:
            '${baseStrategy.reasoning} Falling pressure — fish pushing '
            '${(baseStrategy.primaryDepthFt - max(2.0, baseStrategy.primaryDepthFt - 3)).round()} ft shallower than normal.',
      );
    }
    if (baroAnalysis.trend == 'rising' || baroAnalysis.trend == 'surging') {
      return DepthStrategy(
        primaryDepthFt: baseStrategy.primaryDepthFt + 2,
        secondaryDepthFt: baseStrategy.secondaryDepthFt != null
            ? baseStrategy.secondaryDepthFt! + 3
            : null,
        zone: baseStrategy.zone,
        reasoning:
            '${baseStrategy.reasoning} Post-front — fish retreating deeper '
            'and hugging cover.',
      );
    }

    return baseStrategy;
  }

  DepthStrategy _seasonalDepthStrategy(String season) {
    return switch (season) {
      'Winter' => const DepthStrategy(
          primaryDepthFt: 18,
          secondaryDepthFt: 30,
          zone: 'Deep channels',
          reasoning:
              'Cold water pushes crappie to deep structure along creek channels. '
              'Vertical jig over brush piles and channel ledges.',
        ),
      'Pre-Spawn' => const DepthStrategy(
          primaryDepthFt: 8,
          secondaryDepthFt: 15,
          zone: 'Staging areas',
          reasoning:
              'Fish migrating shallow along creek channels and points. '
              'Target brush piles and stake beds on migration routes.',
        ),
      'Spawn' => const DepthStrategy(
          primaryDepthFt: 3,
          secondaryDepthFt: 8,
          zone: 'Shallow cover',
          reasoning:
              'Males guarding beds in 3-6 ft near wood cover. '
              'Females staging just deeper at 6-8 ft, moving in waves.',
        ),
      'Post-Spawn' => const DepthStrategy(
          primaryDepthFt: 8,
          secondaryDepthFt: 15,
          zone: 'Transitional',
          reasoning:
              'Fish scattering from beds toward summer pattern. '
              'Target docks, deep brush, and transition points.',
        ),
      'Summer' => const DepthStrategy(
          primaryDepthFt: 15,
          secondaryDepthFt: 25,
          zone: 'Suspended / deep brush',
          reasoning:
              'Fish suspend over deep structure or along the thermocline. '
              'Use electronics to find suspended schools.',
        ),
      'Fall' => const DepthStrategy(
          primaryDepthFt: 6,
          secondaryDepthFt: 15,
          zone: 'Creek arms',
          reasoning:
              'Follow the shad migration into creek arms. Fish push shallow '
              'chasing baitfish — match the shad profile.',
        ),
      _ => const DepthStrategy(
          primaryDepthFt: 10,
          secondaryDepthFt: 20,
          zone: 'General',
          reasoning:
              'Start mid-depth and adjust based on electronics feedback.',
        ),
    };
  }

  // ---------------------------------------------------------------------------
  // Tactics
  // ---------------------------------------------------------------------------

  List<String> _buildTactics({
    required double waterTempF,
    required double windSpeedMph,
    required BarometricAnalysis baroAnalysis,
    required String season,
    double? clarity,
    required SolunarForecast solunarForecast,
    required DateTime now,
  }) {
    final tactics = <String>[];

    // Presentation speed based on metabolism
    if (waterTempF < 45) {
      tactics.add(
          'Dead-slow vertical jigging — 3-5 second pause between lifts. '
          'Fish barely moving.');
    } else if (waterTempF < 55) {
      tactics.add('Slow vertical jigging or tight-line minnows — '
          '2-3 second pause, subtle lifts only.');
    } else if (waterTempF >= 55 && waterTempF <= 68) {
      tactics.add(
          'Spider rigging at 0.5-0.8 mph — cover water along migration '
          'routes and brush lines.');
    } else if (waterTempF > 68 && waterTempF <= 80) {
      tactics.add(
          'Aggressive trolling or casting — fish are active and willing '
          'to chase. Match their energy.');
    } else {
      tactics.add(
          'Early morning only — ultra-slow in the deepest available shade. '
          'Fish are heat-stressed.');
    }

    // Wind-driven positioning
    if (windSpeedMph > 12) {
      tactics.add(
          'Drift the windblown bank — bait and oxygen concentrate on the '
          'wind-facing shoreline. Use drift sock for speed control.');
    } else if (windSpeedMph < 3) {
      tactics.add(
          'Stealth mode — dead-calm water amplifies boat noise and shadow. '
          'Long casts, light line, minimal movement.');
    }

    // Barometric pressure tactics
    if (baroAnalysis.trend == 'crashing') {
      tactics.add(
          'Fish fast and cover water — pre-front crash triggers aggressive '
          'feeding. Upsize baits, increase speed.');
    } else if (baroAnalysis.trend == 'falling') {
      tactics.add(
          'Fish with confidence — falling barometer means active fish. '
          'Try more aggressive presentations.');
    } else if (baroAnalysis.trend == 'rising' || baroAnalysis.trend == 'surging') {
      tactics.add(
          'Downsize everything — post-front fish have lockjaw. '
          'Lighter jigs, smaller profiles, slower retrieves.');
    }

    // Solunar-aware timing
    final nextPeriod = solunarForecast.getNextPeriod(now);
    if (nextPeriod != null) {
      final minutesUntil = nextPeriod.start.difference(now).inMinutes;
      if (minutesUntil > 0 && minutesUntil < 90) {
        tactics.add(
            '${nextPeriod.label} in $minutesUntil min — be positioned '
            'on your best spot before it starts.');
      }
    }

    // Season-specific
    if (season == 'Spawn') {
      tactics.add(
          'Slow-drag jigs across beds — trigger defensive strikes from '
          'nest-guarding males.');
    } else if (season == 'Fall') {
      tactics.add(
          'Match the hatch — shad-profile baits in silver/white. '
          'Follow the baitfish migration.');
    }

    // Clarity adaptation
    if (clarity != null && clarity < 1.5) {
      tactics.add(
          'Muddy water — add scent (garlic/shad), use rattles, and pick '
          'bright colors (chartreuse, orange).');
    } else if (clarity != null && clarity > 8) {
      tactics.add(
          'Gin-clear water — fluorocarbon only, natural colors, and keep '
          'your shadow off the strike zone.');
    }

    return tactics.take(5).toList();
  }

  List<String> _quickBaitPicks(
      double waterTempF, String season, double? clarity) {
    if (waterTempF < 45) {
      return [
        'Hair jig (1/32 oz, white/chartreuse)',
        'Blade bait — slow lift-and-drop',
        'Live minnow on tight-line — barely moving',
      ];
    }
    if (waterTempF < 55) {
      return [
        'Hair jig (1/16 oz)',
        'Tube jig — slow vertical presentation',
        'Live minnow under slip-float',
      ];
    }
    if (season == 'Pre-Spawn' || season == 'Spawn') {
      final color = (clarity != null && clarity < 2)
          ? 'chartreuse/white'
          : 'monkey milk';
      return [
        'Tube jig ($color, 1/16 oz)',
        'Bobby Garland Baby Shad',
        'Curly tail grub (pearl/chartreuse)',
      ];
    }
    if (season == 'Summer') {
      return [
        'Live minnow under slip-float (set at thermocline)',
        'Deep-diving crankbait (shad pattern)',
        'Tube jig (1/8 oz, smoke/glitter)',
      ];
    }
    if (season == 'Fall') {
      return [
        'Shad-profile swimbait (2-3")',
        'Tube jig (threadfin shad pattern)',
        'Crankbait (silver/black back)',
      ];
    }
    return ['Tube jig (1/8 oz)', 'Curly tail grub', 'Live minnow'];
  }

  // ---------------------------------------------------------------------------
  // Warnings
  // ---------------------------------------------------------------------------

  List<String> _buildWarnings({
    required double windSpeedMph,
    required BarometricAnalysis baroAnalysis,
    required double waterTempF,
    required SolunarForecast solunarForecast,
  }) {
    final warnings = <String>[];

    if (windSpeedMph > 20) {
      warnings.add(
          'High winds (${windSpeedMph.round()} mph) — dangerous boating. '
          'Consider postponing or fishing protected coves only.');
    } else if (windSpeedMph > 15) {
      warnings.add(
          'Strong winds (${windSpeedMph.round()} mph) — use a drift sock, '
          'stay in protected water, watch for whitecaps.');
    }

    if (baroAnalysis.trend == 'surging' && waterTempF < 50) {
      warnings.add(
          'Rapid pressure rise + cold water = the toughest bite possible. '
          'Expect very slow action. Consider postponing.');
    } else if (baroAnalysis.trend == 'rising' && waterTempF < 50) {
      warnings.add(
          'Post-front + cold water = extremely tough bite. '
          'Downsize everything, manage expectations.');
    }

    if (waterTempF > 85) {
      warnings.add(
          'Water temps above 85°F — fish are stressed. Fish early morning '
          'only, use gentle handling, and release quickly.');
    }

    if (baroAnalysis.volatility > 2.0) {
      warnings.add(
          'Highly unstable barometer — pressure swinging wildly. '
          'Feeding will be erratic and unpredictable.');
    }

    // Full moon + clear skies = fish fed all night
    if (solunarForecast.moonPhase > 0.45 && solunarForecast.moonPhase < 0.55) {
      warnings.add(
          'Full moon — fish likely fed heavily overnight. '
          'Morning bite may start slow. Focus on solunar major periods.');
    }

    return warnings;
  }

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  String _buildSummary({
    required TripRating rating,
    required double waterTempF,
    required String season,
    required BarometricAnalysis baroAnalysis,
    required double windSpeedMph,
    required SolunarForecast solunarForecast,
  }) {
    final ratingText = switch (rating) {
      TripRating.excellent =>
        'GO! Conditions are stacked in your favor.',
      TripRating.good =>
        'Solid day to fish. Conditions are favorable.',
      TripRating.fair =>
        'Fishable but challenging. Adjust techniques and expectations.',
      TripRating.poor =>
        'Tough conditions. Consider postponing or going ultra-finesse.',
    };

    final pressureText = switch (baroAnalysis.trend) {
      'crashing' => 'Pressure crashing — feeding frenzy likely.',
      'falling' => 'Falling pressure triggering feeding response.',
      'rising' => 'Post-front rising pressure — cautious fish.',
      'surging' => 'Rapid pressure surge — fish shut down.',
      'stable_high' => 'Stable high pressure — fish on schedule.',
      'stable_low' => 'Low pressure overcast — subtle but steady bite.',
      _ => 'Stable barometer.',
    };

    final moonText = '${solunarForecast.moonEmoji} '
        '${solunarForecast.ratingLabel} solunar '
        '(${(solunarForecast.overallRating * 100).round()}%).';

    return '$ratingText $season pattern at ${waterTempF.round()}°F. '
        '$pressureText Wind ${windSpeedMph.round()} mph. $moonText';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Compute temperature trend from hourly forecast data.
  ///
  /// Compares the average air temperature of the most recent 12 hours to the
  /// preceding 12-24 hour window. Returns 'warming', 'cooling', or 'stable'.
  /// When fewer than 12 hours of data are available, falls back to a 6-hour
  /// delta. With fewer than 6 hours, returns 'stable'.
  String _computeTempTrend(List<HourlyForecast> hourly) {
    if (hourly.length >= 24) {
      // Compare average of hours 0-11 (recent) vs 12-23 (older)
      double recentSum = 0;
      double olderSum = 0;
      for (int i = 0; i < 12; i++) {
        recentSum += hourly[i].temperatureF;
        olderSum += hourly[i + 12].temperatureF;
      }
      final delta = (recentSum / 12) - (olderSum / 12);
      if (delta > 2.0) return 'warming';
      if (delta < -2.0) return 'cooling';
      return 'stable';
    }
    if (hourly.length >= 6) {
      final delta = hourly[0].temperatureF - hourly[5].temperatureF;
      if (delta > 3.0) return 'warming';
      if (delta < -3.0) return 'cooling';
      return 'stable';
    }
    return 'stable';
  }

  /// Determine the crappie behavioral season from water temperature, with
  /// temperature trend disambiguation for the ambiguous 55-68 F range.
  ///
  /// The 55-68 F range maps to both spring (pre-spawn / spawn) and fall
  /// transition depending on whether temperatures are warming or cooling.
  /// [tempTrend] should be 'warming', 'cooling', or 'stable'.
  /// [month] is used as a calendar tiebreaker when trend is neutral.
  String _determineSeason(
    double waterTempF, {
    String tempTrend = 'stable',
    int? month,
  }) {
    if (waterTempF < 50) return 'Winter';

    // Ambiguous range: 55-68 F could be spring (warming) or fall (cooling)
    if (waterTempF >= 55 && waterTempF < 68) {
      if (tempTrend == 'warming') {
        // Spring progression: warming into spawn range
        return waterTempF < 60 ? 'Pre-Spawn' : 'Spawn';
      }
      if (tempTrend == 'cooling') {
        // Fall transition: cooling out of summer
        return 'Fall';
      }
      // Trend is stable/unknown — use calendar month as tiebreaker
      final m = month ?? DateTime.now().month;
      if (m >= 8 && m <= 12) return 'Fall';
      // Jan-Jul with stable trend: assume spring progression
      return waterTempF < 60 ? 'Pre-Spawn' : 'Spawn';
    }

    // Below the ambiguous band but above winter
    if (waterTempF >= 50 && waterTempF < 55) {
      // 50-55 F: could be late winter warming or late fall cooling
      if (tempTrend == 'cooling') return 'Fall';
      return 'Pre-Spawn';
    }

    if (waterTempF < 75) return 'Post-Spawn';

    // 75 F+: summer or fall depending on trend and calendar
    if (tempTrend == 'cooling') return 'Fall';
    final m = month ?? DateTime.now().month;
    if (m >= 9 && m <= 11) return 'Fall';
    return 'Summer';
  }

  TripRating _toRating(double score) {
    if (score >= 75) return TripRating.excellent;
    if (score >= 55) return TripRating.good;
    if (score >= 35) return TripRating.fair;
    return TripRating.poor;
  }

  DateTime _defaultSunrise(DateTime date) =>
      DateTime(date.year, date.month, date.day, 6, 30);

  DateTime _defaultSunset(DateTime date) =>
      DateTime(date.year, date.month, date.day, 17, 30);
}

/// Multi-hour barometric pressure analysis
class BarometricAnalysis {
  final double currentMb;
  final double? delta6h;
  final double? delta12h;
  final double? delta24h;
  final double volatility;
  final String trend;

  const BarometricAnalysis({
    required this.currentMb,
    this.delta6h,
    this.delta12h,
    this.delta24h,
    required this.volatility,
    required this.trend,
  });

  bool get isFrontApproaching => trend == 'falling' || trend == 'crashing';
  bool get isPostFront => trend == 'rising' || trend == 'surging';
}
