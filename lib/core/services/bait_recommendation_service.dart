import '../models/bait_recommendation.dart';
import '../models/weather_data.dart';

/// Crappie Bait Recommendation Engine
/// 
/// Science-backed bait selection algorithm that weighs multiple factors:
/// 
/// **Temperature (25% weight):** Primary driver of crappie metabolism and activity.
/// Cold water = slow presentations, small baits. Warm water = larger, faster.
/// 
/// **Water Clarity (20% weight):** Determines color visibility and contrast needs.
/// Clear = natural, subtle. Stained = chartreuse combinations. Muddy = bright.
/// 
/// **Depth (15% weight):** Affects bait sink rate, jig weight, and presentation.
/// Shallow = light jigs, finesse. Deep = heavier heads, compact profiles.
/// 
/// **Season (15% weight):** Behavioral patterns drive bait choice.
/// Pre-spawn = staging baits. Spawn = bed defense triggers. Fall = shad profiles.
/// 
/// **Time of Day (10% weight):** Feeding windows affect aggression level.
/// Dawn/dusk = more aggressive presentations. Midday = finesse.
/// 
/// **Weather/Pressure (10% weight):** Barometric pressure affects feeding activity.
/// Falling = pre-front frenzy. Post-front = lockjaw, ultra-finesse.
/// 
/// **Structure (5% weight):** Specific cover types favor certain presentations.
/// Docks = shooting jigs. Brush = vertical. Open = trolling profiles.
class BaitRecommendationService {
  
  // ---------------------------------------------------------------------------
  // Bait Database - Comprehensive crappie bait profiles
  // ---------------------------------------------------------------------------
  
  static const List<BaitProfile> _baitDatabase = [
    // Tube Jigs - #1 Overall
    BaitProfile(
      name: 'Tube Jig',
      category: BaitCategory.tubeJig,
      sizes: ['1.5"', '2"', '2.5"', '3"'],
      colorsByClarity: {
        WaterClarity.clear: [
          'Ghost/Pearl',
          'Smoke/Silver Flake',
          'Natural Shad',
          'Watermelon',
          'Blue Ice',
        ],
        WaterClarity.lightStain: [
          'Monkey Milk',
          'Pearl/Chartreuse',
          'Blue/Pearl',
          'Junebug',
          'Threadfin Shad',
        ],
        WaterClarity.stained: [
          'Chartreuse/White',
          'Electric Chicken',
          'Black/Chartreuse',
          'Orange/Chartreuse',
          'Hot Pink',
        ],
        WaterClarity.muddy: [
          'Chartreuse',
          'White',
          'Glow White',
          'Fluorescent Orange',
          'Black',
        ],
      },
      minDepthFt: 1,
      maxDepthFt: 35,
      minTempF: 35,
      maxTempF: 90,
      bestStructures: [
        StructureType.brushPile,
        StructureType.stakeBed,
        StructureType.standingTimber,
        StructureType.creekChannel,
        StructureType.point,
      ],
      techniques: [
        'Vertical jigging',
        'Spider rigging',
        'Casting to brush',
        'Slip bobber',
        'Swimming retrieve',
      ],
      presentations: [
        'Slow hop on bottom',
        'Pendulum fall into brush',
        'Steady swim with occasional pause',
        'Dead-stick under float',
        'Tight-line vertical',
      ],
      description: 'The most versatile crappie bait. Hollow body creates subtle '
          'water displacement that triggers strikes. Works in all conditions '
          'and all seasons. The go-to choice when nothing else is working.',
      baseEffectiveness: 0.92,
      peakSeasons: [
        CrappieSeason.preSpawn,
        CrappieSeason.spawn,
        CrappieSeason.fall,
      ],
    ),
    
    // Soft Plastic Minnow - #1 Dock Shooting
    BaitProfile(
      name: 'Soft Plastic Minnow',
      category: BaitCategory.softPlasticMinnow,
      sizes: ['1"', '1.5"', '2"', '2.5"'],
      colorsByClarity: {
        WaterClarity.clear: [
          'Translucent Shad',
          'Smoke/Silver',
          'Ghost Minnow',
          'Alewife',
          'Clear/Blue Back',
        ],
        WaterClarity.lightStain: [
          'Pearl/Blue',
          'Silver/Black Back',
          'Chartreuse Shad',
          'Blue Ice',
          'Threadfin',
        ],
        WaterClarity.stained: [
          'Chartreuse/White',
          'Blue/Chartreuse',
          'Bubblegum',
          'Red/Chartreuse',
          'Electric Blue',
        ],
        WaterClarity.muddy: [
          'Chartreuse',
          'White',
          'Pink',
          'Glow',
          'Fluorescent Yellow',
        ],
      },
      minDepthFt: 1,
      maxDepthFt: 25,
      minTempF: 45,
      maxTempF: 90,
      bestStructures: [
        StructureType.dock,
        StructureType.bridge,
        StructureType.openWater,
        StructureType.point,
        StructureType.riprap,
      ],
      techniques: [
        'Dock shooting',
        'Long-line trolling',
        'Casting and retrieving',
        'Slow-roll swim',
        'Count-down retrieve',
      ],
      presentations: [
        'Skip under docks, let pendulum fall',
        'Steady slow retrieve 0.5-1 mph',
        'Twitch-twitch-pause cadence',
        'Yo-yo retrieve through suspended fish',
        'Burn and kill - fast then dead-stop',
      ],
      description: 'Matches the primary crappie forage - threadfin and gizzard shad. '
          'Best in clear to moderately stained water where fish are sight-feeding. '
          'Unmatched for dock shooting due to its skip-ability.',
      baseEffectiveness: 0.88,
      peakSeasons: [
        CrappieSeason.summer,
        CrappieSeason.postSpawn,
        CrappieSeason.fall,
      ],
    ),
    
    // Curly Tail Grub - Most Durable
    BaitProfile(
      name: 'Curly Tail Grub',
      category: BaitCategory.curlyTailGrub,
      sizes: ['1.5"', '2"', '2.5"', '3"'],
      colorsByClarity: {
        WaterClarity.clear: [
          'Smoke/Silver',
          'Watermelon',
          'Pumpkin Seed',
          'Natural Shad',
          'Green Pumpkin',
        ],
        WaterClarity.lightStain: [
          'Chartreuse',
          'White',
          'Pink/White',
          'Motor Oil',
          'Pumpkin/Chartreuse',
        ],
        WaterClarity.stained: [
          'Chartreuse/White',
          'Red/Chartreuse',
          'Electric Chicken',
          'Hot Pink',
          'Orange/Chartreuse',
        ],
        WaterClarity.muddy: [
          'Chartreuse',
          'White',
          'Glow Chartreuse',
          'Black/Chartreuse',
          'Fluorescent Orange',
        ],
      },
      minDepthFt: 1,
      maxDepthFt: 30,
      minTempF: 40,
      maxTempF: 85,
      bestStructures: [
        StructureType.brushPile,
        StructureType.openWater,
        StructureType.creekChannel,
        StructureType.hump,
        StructureType.point,
      ],
      techniques: [
        'Spider rigging',
        'Long-line trolling',
        'Casting and swimming',
        'Vertical jigging',
        'Slip bobber',
      ],
      presentations: [
        'Steady slow swim - let tail work',
        'Lift-drop with tail flutter on fall',
        'Slow troll at 0.6-0.9 mph',
        'Cast, count down, slow retrieve',
        'Hover in brush with subtle twitches',
      ],
      description: 'The curly tail generates vibration and visual attraction that '
          'triggers strikes even in low visibility. Most durable soft plastic - '
          'one grub can catch dozens of fish. Great all-around choice.',
      baseEffectiveness: 0.85,
      peakSeasons: [
        CrappieSeason.preSpawn,
        CrappieSeason.fall,
        CrappieSeason.summer,
      ],
    ),
    
    // Hair Jig - Best Finesse
    BaitProfile(
      name: 'Hair Jig (Marabou/Chenille)',
      category: BaitCategory.hairJig,
      sizes: ['1/32 oz', '1/16 oz', '1/8 oz', '3/16 oz'],
      colorsByClarity: {
        WaterClarity.clear: [
          'White',
          'Olive/White',
          'Gray/White',
          'Natural Brown',
          'Tan/Orange',
        ],
        WaterClarity.lightStain: [
          'White',
          'Chartreuse',
          'Pink',
          'Brown/Orange',
          'Black/Chartreuse',
        ],
        WaterClarity.stained: [
          'Chartreuse',
          'White',
          'Pink',
          'Orange',
          'Black',
        ],
        WaterClarity.muddy: [
          'White',
          'Chartreuse',
          'Glow',
          'Orange',
          'Black',
        ],
      },
      minDepthFt: 1,
      maxDepthFt: 20,
      minTempF: 35,
      maxTempF: 75,
      bestStructures: [
        StructureType.brushPile,
        StructureType.stakeBed,
        StructureType.standingTimber,
        StructureType.laydown,
        StructureType.vegetation,
      ],
      techniques: [
        'Single pole jigging',
        'Slip float/bobber',
        'Tight-line vertical',
        'Slow swimming',
        'Push-pole shallow cover',
      ],
      presentations: [
        'Barely hop - let marabou breathe',
        'Dead-stick under float - let current work it',
        'Super slow fall into cover',
        'Hold still, twitch, hold still',
        'Ultra-slow vertical drop',
      ],
      description: 'The finesse king. Marabou fibers undulate naturally with '
          'minimal angler input, triggering strikes from pressured or '
          'cold-water crappie. Essential for tough bites and clear water.',
      baseEffectiveness: 0.80,
      peakSeasons: [
        CrappieSeason.winter,
        CrappieSeason.spawn,
        CrappieSeason.preSpawn,
      ],
    ),
    
    // Live Minnow
    BaitProfile(
      name: 'Live Minnow',
      category: BaitCategory.liveMinnow,
      sizes: ['1-1.5" (spawn)', '1.5-2" (standard)', '2-3" (trophy)', '3-4" (magnum)'],
      colorsByClarity: {
        WaterClarity.clear: ['Fathead', 'Golden Shiner', 'Small Shad'],
        WaterClarity.lightStain: ['Fathead', 'Golden Shiner', 'Rosy Red'],
        WaterClarity.stained: ['Fathead', 'Rosy Red', 'Any Lively'],
        WaterClarity.muddy: ['Any Lively Minnow', 'Rosy Red (visible)'],
      },
      minDepthFt: 1,
      maxDepthFt: 40,
      minTempF: 32,
      maxTempF: 95,
      bestStructures: [
        StructureType.brushPile,
        StructureType.stakeBed,
        StructureType.standingTimber,
        StructureType.creekChannel,
        StructureType.bridge,
      ],
      techniques: [
        'Slip float/bobber',
        'Tight-line with split shot',
        'Tipped on jig',
        'Free-line drift',
        'Spider rigging (tipped)',
      ],
      presentations: [
        'Under slip float, 6-12" above cover',
        'Hooked through lips, free to swim',
        'Hooked behind dorsal for liveliness',
        'Tipped on jig nose for scent trail',
        'Drift along brush edges',
      ],
      description: 'Nothing beats live bait when crappie are reluctant to bite '
          'artificials. Especially deadly during cold water (winter) and '
          'when fish are staging pre-spawn. The "can\'t lose" option.',
      baseEffectiveness: 0.95,
      peakSeasons: [
        CrappieSeason.winter,
        CrappieSeason.preSpawn,
        CrappieSeason.fall,
      ],
    ),
    
    // Crankbait
    BaitProfile(
      name: 'Crappie Crankbait',
      category: BaitCategory.crankbait,
      sizes: ['1.5"', '2"', '2.5"'],
      colorsByClarity: {
        WaterClarity.clear: [
          'Natural Shad',
          'Chrome/Blue',
          'Ghost Minnow',
          'Clear/Silver',
          'Perch',
        ],
        WaterClarity.lightStain: [
          'Shad',
          'Chartreuse Shad',
          'Blue/Chrome',
          'Fire Tiger',
          'Bluegill',
        ],
        WaterClarity.stained: [
          'Chartreuse/Black',
          'Fire Tiger',
          'Orange/Chartreuse',
          'Hot Pink',
          'Red Crawfish',
        ],
        WaterClarity.muddy: [
          'Chartreuse',
          'Fire Tiger',
          'Fluorescent Orange',
          'White',
          'Black/Chartreuse',
        ],
      },
      minDepthFt: 3,
      maxDepthFt: 18,
      minTempF: 55,
      maxTempF: 85,
      bestStructures: [
        StructureType.openWater,
        StructureType.creekChannel,
        StructureType.point,
        StructureType.hump,
        StructureType.riprap,
      ],
      techniques: [
        'Trolling (long line)',
        'Casting and retrieving',
        'Paralleling structure',
        'Count-down to depth',
        'Ripping through suspended fish',
      ],
      presentations: [
        'Troll 1.0-1.5 mph, let lip dig depth',
        'Cast, count to target depth, steady retrieve',
        'Parallel riprap walls slowly',
        'Twitch-pause over submerged humps',
        'Speed up through fish schools to trigger reaction',
      ],
      description: 'Excellent for covering water quickly and triggering reaction '
          'strikes from aggressive, feeding crappie. Best when fish are '
          'actively chasing baitfish in open water or along structure.',
      baseEffectiveness: 0.75,
      peakSeasons: [
        CrappieSeason.fall,
        CrappieSeason.summer,
        CrappieSeason.postSpawn,
      ],
    ),
    
    // Blade Bait
    BaitProfile(
      name: 'Blade Bait (Spoon)',
      category: BaitCategory.bladeBait,
      sizes: ['1/8 oz', '1/4 oz', '3/8 oz', '1/2 oz'],
      colorsByClarity: {
        WaterClarity.clear: [
          'Silver',
          'Chrome',
          'Gold',
          'Natural Shad',
          'Holographic',
        ],
        WaterClarity.lightStain: [
          'Silver/Chartreuse',
          'Gold',
          'Chrome/Blue',
          'Firetiger',
          'White/Silver',
        ],
        WaterClarity.stained: [
          'Gold',
          'Chartreuse',
          'Orange',
          'White',
          'Hammered Gold',
        ],
        WaterClarity.muddy: [
          'Gold',
          'Hammered Brass',
          'Fluorescent',
          'Glow',
          'Painted Chartreuse',
        ],
      },
      minDepthFt: 8,
      maxDepthFt: 40,
      minTempF: 35,
      maxTempF: 60,
      bestStructures: [
        StructureType.creekChannel,
        StructureType.standingTimber,
        StructureType.hump,
        StructureType.point,
        StructureType.openWater,
      ],
      techniques: [
        'Vertical jigging',
        'Ripping/stroking',
        'Drop-shot style',
        'Slow trolling deep',
        'Cast and yo-yo',
      ],
      presentations: [
        'Lift-drop cadence (6" hops)',
        'Snap-drop to trigger reaction',
        'Slow flutter fall, watch line',
        'Dead-stick over fish on LiveScope',
        'Rip through schools, pause for strike',
      ],
      description: 'Cold water specialist. The tight vibration and flash of a '
          'blade bait draws winter crappie out of lethargy. Excellent for '
          'vertical fishing deep structure when fish are sluggish.',
      baseEffectiveness: 0.78,
      peakSeasons: [
        CrappieSeason.winter,
        CrappieSeason.fall,
      ],
    ),
  ];
  
  // ---------------------------------------------------------------------------
  // Jig Head Weight Database
  // ---------------------------------------------------------------------------
  
  static const List<JigHeadWeight> _jigHeadWeights = [
    JigHeadWeight(
      weightOz: 0.03125, // 1/32
      label: '1/32 oz',
      minDepthFt: 1,
      maxDepthFt: 8,
      useCase: 'Ultra-finesse shallow. Spawn beds, clear water sight-fishing.',
    ),
    JigHeadWeight(
      weightOz: 0.0625, // 1/16
      label: '1/16 oz',
      minDepthFt: 1,
      maxDepthFt: 12,
      useCase: 'Shallow to mid-depth. Dock shooting, light slip float.',
    ),
    JigHeadWeight(
      weightOz: 0.09375, // 3/32
      label: '3/32 oz',
      minDepthFt: 3,
      maxDepthFt: 15,
      useCase: 'All-around shallow jigging and casting.',
    ),
    JigHeadWeight(
      weightOz: 0.125, // 1/8
      label: '1/8 oz',
      minDepthFt: 5,
      maxDepthFt: 18,
      useCase: 'The workhorse. Single pole, spider rigging, vertical.',
    ),
    JigHeadWeight(
      weightOz: 0.1875, // 3/16
      label: '3/16 oz',
      minDepthFt: 8,
      maxDepthFt: 22,
      useCase: 'Mid-depth trolling and jigging. Moderate current.',
    ),
    JigHeadWeight(
      weightOz: 0.25, // 1/4
      label: '1/4 oz',
      minDepthFt: 12,
      maxDepthFt: 30,
      useCase: 'Deep water, windy conditions, faster sink rate.',
    ),
    JigHeadWeight(
      weightOz: 0.375, // 3/8
      label: '3/8 oz',
      minDepthFt: 18,
      maxDepthFt: 40,
      useCase: 'Deep structure, heavy current, winter vertical.',
    ),
  ];
  
  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------
  
  /// Generate bait recommendations based on current conditions
  /// 
  /// Returns a [BaitRecommendationResult] with ranked bait choices,
  /// color/size recommendations, techniques, and presentation tips.
  BaitRecommendationResult getRecommendations({
    required double waterTempF,
    required WaterClarity clarity,
    required double targetDepthFt,
    StructureType? structureType,
    double? pressureMb,
    double? windSpeedMph,
    DateTime? currentTime,
    DateTime? sunrise,
    DateTime? sunset,
    double? solunarRating,
    bool? isFallingPressure,
    bool? isRisingPressure,
    int? month,
    String? tempTrend,
  }) {
    // Determine season from water temperature + trend disambiguation
    final season = _determineSeason(
      waterTempF,
      tempTrend: tempTrend ?? 'stable',
      month: month,
    );
    
    // Determine time of day
    final timeOfDay = _determineTimeOfDay(
      currentTime ?? DateTime.now(),
      sunrise,
      sunset,
    );
    
    // Determine pressure trend
    final pressureTrend = _determinePressureTrend(
      pressureMb,
      isFallingPressure: isFallingPressure ?? false,
      isRisingPressure: isRisingPressure ?? false,
    );
    
    // Build conditions snapshot
    final conditions = ConditionsSnapshot(
      waterTempF: waterTempF,
      clarity: clarity,
      targetDepthFt: targetDepthFt,
      season: season,
      timeOfDay: timeOfDay,
      pressureTrend: pressureTrend,
      pressureMb: pressureMb ?? 1013,
      structureType: structureType,
      windSpeedMph: windSpeedMph,
      isPreFront: isFallingPressure ?? false,
      isPostFront: pressureTrend == PressureTrend.rising && 
          (pressureMb ?? 1013) > 1020,
      solunarRating: solunarRating,
      isNightFishing: timeOfDay == TimeOfDay.night,
    );
    
    // Score all baits
    final scoredBaits = <_ScoredBait>[];
    for (final bait in _baitDatabase) {
      final score = _scoreBait(bait, conditions);
      scoredBaits.add(_ScoredBait(bait: bait, score: score));
    }
    
    // Sort by score descending
    scoredBaits.sort((a, b) => b.score.compareTo(a.score));
    
    // Build recommendations
    final recommendations = <BaitRecommendation>[];
    for (var i = 0; i < scoredBaits.length && i < 5; i++) {
      final scored = scoredBaits[i];
      final rec = _buildRecommendation(
        scored.bait,
        scored.score,
        conditions,
        rank: i + 1,
      );
      recommendations.add(rec);
    }
    
    // Generate general tips
    final generalTips = _generateGeneralTips(conditions);
    
    // Generate summary
    final summary = _generateSummary(conditions, recommendations.first);
    
    return BaitRecommendationResult(
      recommendations: recommendations,
      conditions: conditions,
      generalTips: generalTips,
      summary: summary,
      generatedAt: DateTime.now(),
    );
  }
  
  /// Convenience method using WeatherData
  BaitRecommendationResult getRecommendationsFromWeather({
    required WeatherData weather,
    required double waterTempF,
    required WaterClarity clarity,
    required double targetDepthFt,
    StructureType? structureType,
    double? solunarRating,
  }) {
    // Determine pressure trend from hourly data
    bool isFalling = false;
    bool isRising = false;

    if (weather.hourly.length >= 6) {
      final currentPressure = weather.current.pressureMb;
      final recentPressure = weather.hourly[5].pressureMb;
      final diff = currentPressure - recentPressure;

      if (diff < -3) {
        isFalling = true;
      } else if (diff > 3) {
        isRising = true;
      }
    }

    // Compute temperature trend from hourly air temps for season
    // disambiguation (spring vs fall in the 55-68 F range)
    final tempTrend = _computeTempTrend(weather.hourly);

    return getRecommendations(
      waterTempF: waterTempF,
      clarity: clarity,
      targetDepthFt: targetDepthFt,
      structureType: structureType,
      pressureMb: weather.current.pressureMb,
      windSpeedMph: weather.current.windSpeedMph,
      currentTime: DateTime.now(),
      sunrise: weather.daily.isNotEmpty ? weather.daily.first.sunrise : null,
      sunset: weather.daily.isNotEmpty ? weather.daily.first.sunset : null,
      solunarRating: solunarRating,
      isFallingPressure: isFalling,
      isRisingPressure: isRising,
      tempTrend: tempTrend,
      month: DateTime.now().month,
    );
  }
  
  /// Get recommended jig head weight for depth and conditions
  JigHeadWeight getJigHeadWeight({
    required double depthFt,
    double? windSpeedMph,
    double? currentSpeed,
  }) {
    // Adjust for wind and current
    double adjustedDepth = depthFt;
    if (windSpeedMph != null && windSpeedMph > 10) {
      adjustedDepth += windSpeedMph / 5; // Need heavier in wind
    }
    
    for (final weight in _jigHeadWeights) {
      if (adjustedDepth >= weight.minDepthFt && 
          adjustedDepth <= weight.maxDepthFt) {
        return weight;
      }
    }
    
    // Default to 1/8 oz if no match
    return _jigHeadWeights[3];
  }
  
  /// Get all available bait profiles
  List<BaitProfile> getAllBaits() => List.unmodifiable(_baitDatabase);
  
  /// Get all jig head weights
  List<JigHeadWeight> getAllJigHeadWeights() => 
      List.unmodifiable(_jigHeadWeights);
  
  // ---------------------------------------------------------------------------
  // Scoring Algorithm
  // ---------------------------------------------------------------------------
  
  double _scoreBait(BaitProfile bait, ConditionsSnapshot conditions) {
    double score = bait.baseEffectiveness * 100;
    
    // Temperature fit (25% weight)
    final tempScore = _scoreTemperatureFit(bait, conditions.waterTempF);
    score += tempScore * 25;
    
    // Depth fit (15% weight)
    final depthScore = _scoreDepthFit(bait, conditions.targetDepthFt);
    score += depthScore * 15;
    
    // Season fit (15% weight)
    final seasonScore = _scoreSeasonFit(bait, conditions.season);
    score += seasonScore * 15;
    
    // Structure fit (5% weight)
    if (conditions.structureType != null) {
      final structureScore = _scoreStructureFit(bait, conditions.structureType!);
      score += structureScore * 5;
    }
    
    // Time of day modifier (10% weight)
    final timeModifier = conditions.timeOfDay.activityMultiplier;
    score *= (0.9 + (timeModifier - 1.0) * 0.1);
    
    // Pressure modifier (10% weight)
    score *= (0.9 + (conditions.pressureTrend.activityModifier - 1.0) * 0.1);
    
    // Special condition bonuses/penalties
    score = _applySpecialConditions(bait, conditions, score);
    
    return score.clamp(0, 100);
  }
  
  double _scoreTemperatureFit(BaitProfile bait, double waterTempF) {
    if (waterTempF < bait.minTempF || waterTempF > bait.maxTempF) {
      return -0.5; // Penalty for out of range
    }
    
    // Perfect score in middle of range
    final range = bait.maxTempF - bait.minTempF;
    final midpoint = bait.minTempF + range / 2;
    final distance = (waterTempF - midpoint).abs();
    
    return 1.0 - (distance / (range / 2)) * 0.5;
  }
  
  double _scoreDepthFit(BaitProfile bait, double depthFt) {
    if (depthFt < bait.minDepthFt - 2 || depthFt > bait.maxDepthFt + 5) {
      return -0.3;
    }
    
    // Sweet spot scoring
    final range = bait.maxDepthFt - bait.minDepthFt;
    final midpoint = bait.minDepthFt + range / 2;
    final distance = (depthFt - midpoint).abs();
    
    return 1.0 - (distance / (range / 2)) * 0.3;
  }
  
  double _scoreSeasonFit(BaitProfile bait, CrappieSeason season) {
    if (bait.peakSeasons.contains(season)) {
      return 1.0;
    }
    return 0.5;
  }
  
  double _scoreStructureFit(BaitProfile bait, StructureType structure) {
    if (bait.bestStructures.contains(structure)) {
      return 1.0;
    }
    return 0.4;
  }
  
  double _applySpecialConditions(
    BaitProfile bait,
    ConditionsSnapshot conditions,
    double score,
  ) {
    // Cold water bonus for finesse baits
    if (conditions.waterTempF < 50 && 
        (bait.category == BaitCategory.hairJig ||
         bait.category == BaitCategory.liveMinnow ||
         bait.category == BaitCategory.bladeBait)) {
      score *= 1.15;
    }
    
    // Dock structure bonus for soft plastic minnows
    if (conditions.structureType == StructureType.dock &&
        bait.category == BaitCategory.softPlasticMinnow) {
      score *= 1.25;
    }
    
    // Night fishing - live bait bonus, visual bait penalty
    if (conditions.isNightFishing) {
      if (bait.category == BaitCategory.liveMinnow) {
        score *= 1.2;
      } else if (bait.category == BaitCategory.crankbait) {
        score *= 0.8;
      }
    }
    
    // Pre-front feeding frenzy - faster presentations shine
    if (conditions.isPreFront) {
      if (bait.category == BaitCategory.crankbait ||
          bait.category == BaitCategory.curlyTailGrub) {
        score *= 1.15;
      }
    }
    
    // Post-front lockjaw - finesse only
    if (conditions.isPostFront) {
      if (bait.category == BaitCategory.hairJig ||
          bait.category == BaitCategory.liveMinnow) {
        score *= 1.2;
      } else {
        score *= 0.85;
      }
    }
    
    // High solunar activity - aggressive presentations
    if (conditions.solunarRating != null && conditions.solunarRating! > 0.8) {
      if (bait.category == BaitCategory.crankbait ||
          bait.category == BaitCategory.curlyTailGrub) {
        score *= 1.1;
      }
    }
    
    // Windy conditions - need larger profiles
    if (conditions.windSpeedMph != null && conditions.windSpeedMph! > 15) {
      if (bait.category == BaitCategory.hairJig) {
        score *= 0.85; // Hard to feel bites
      } else if (bait.category == BaitCategory.bladeBait) {
        score *= 1.1; // Can feel vibration in wind
      }
    }
    
    return score;
  }
  
  // ---------------------------------------------------------------------------
  // Recommendation Building
  // ---------------------------------------------------------------------------
  
  BaitRecommendation _buildRecommendation(
    BaitProfile bait,
    double score,
    ConditionsSnapshot conditions,
    {required int rank}
  ) {
    // Get colors for clarity
    final colors = bait.getColorsForClarity(conditions.clarity);
    
    // Get size recommendation
    final size = bait.getSizeRecommendation(
      conditions.waterTempF,
      conditions.season,
    );
    
    // Get jig head weight if applicable
    JigHeadWeight? weight;
    if (bait.category != BaitCategory.liveMinnow &&
        bait.category != BaitCategory.crankbait) {
      weight = getJigHeadWeight(
        depthFt: conditions.targetDepthFt,
        windSpeedMph: conditions.windSpeedMph,
      );
    }
    
    // Select techniques based on conditions
    final techniques = _selectTechniques(bait, conditions);
    
    // Select presentation tips
    final presentations = _selectPresentations(bait, conditions);
    
    // Build reasoning
    final reasons = _buildReasons(bait, conditions, score);
    
    // Determine confidence
    final confidence = _determineConfidence(score);
    
    return BaitRecommendation(
      bait: bait,
      score: score,
      confidenceLevel: confidence,
      recommendedColors: colors.take(3).toList(),
      recommendedSize: size,
      recommendedWeight: weight,
      techniques: techniques,
      presentationTips: presentations,
      reasons: reasons,
      rank: rank,
    );
  }
  
  List<String> _selectTechniques(
    BaitProfile bait,
    ConditionsSnapshot conditions,
  ) {
    final selected = <String>[];
    
    // Structure-specific techniques
    if (conditions.structureType == StructureType.dock &&
        bait.techniques.any((t) => t.toLowerCase().contains('dock'))) {
      selected.add(bait.techniques.firstWhere(
        (t) => t.toLowerCase().contains('dock'),
      ));
    }
    
    if (conditions.structureType == StructureType.brushPile &&
        bait.techniques.any((t) => t.toLowerCase().contains('vertical'))) {
      selected.add(bait.techniques.firstWhere(
        (t) => t.toLowerCase().contains('vertical'),
      ));
    }
    
    // Depth-specific techniques
    if (conditions.targetDepthFt > 15 &&
        bait.techniques.any((t) => t.toLowerCase().contains('vertical'))) {
      if (!selected.any((t) => t.toLowerCase().contains('vertical'))) {
        selected.add(bait.techniques.firstWhere(
          (t) => t.toLowerCase().contains('vertical'),
        ));
      }
    }
    
    if (conditions.targetDepthFt < 8 &&
        bait.techniques.any((t) => t.toLowerCase().contains('bobber') ||
            t.toLowerCase().contains('float'))) {
      selected.add(bait.techniques.firstWhere(
        (t) => t.toLowerCase().contains('bobber') ||
            t.toLowerCase().contains('float'),
      ));
    }
    
    // Fill remaining with top techniques
    for (final tech in bait.techniques) {
      if (selected.length >= 2) break;
      if (!selected.contains(tech)) {
        selected.add(tech);
      }
    }
    
    return selected.take(3).toList();
  }
  
  List<String> _selectPresentations(
    BaitProfile bait,
    ConditionsSnapshot conditions,
  ) {
    final tips = <String>[];
    
    // Temperature-based presentation
    if (conditions.waterTempF < 50) {
      tips.add('Slow down! Cold water = slow metabolism. '
          'Give fish time to commit.');
    } else if (conditions.waterTempF > 70) {
      tips.add('Fish are active - try faster retrieves to trigger '
          'reaction strikes.');
    }
    
    // Clarity-based tips
    if (conditions.clarity == WaterClarity.muddy) {
      tips.add('Use scent (Gulp, minnow tip) and vibration to help '
          'fish locate your bait.');
    } else if (conditions.clarity == WaterClarity.clear) {
      tips.add('Light line (4-6 lb fluoro), subtle movements. '
          'Fish can see everything.');
    }
    
    // Add bait-specific presentations
    for (final pres in bait.presentations.take(2)) {
      tips.add(pres);
    }
    
    return tips.take(4).toList();
  }
  
  List<String> _buildReasons(
    BaitProfile bait,
    ConditionsSnapshot conditions,
    double score,
  ) {
    final reasons = <String>[];
    
    // Season match
    if (bait.peakSeasons.contains(conditions.season)) {
      reasons.add('Peak effectiveness during ${conditions.season.displayName}');
    }
    
    // Temperature match
    if (conditions.waterTempF >= bait.minTempF &&
        conditions.waterTempF <= bait.maxTempF) {
      reasons.add('Ideal for ${conditions.waterTempF.round()}°F water');
    }
    
    // Structure match
    if (conditions.structureType != null &&
        bait.bestStructures.contains(conditions.structureType)) {
      reasons.add('Excellent for ${conditions.structureType!.displayName}');
    }
    
    // Special conditions
    if (conditions.isPreFront && 
        (bait.category == BaitCategory.crankbait ||
         bait.category == BaitCategory.curlyTailGrub)) {
      reasons.add('Great for pre-front aggressive feeding');
    }
    
    if (conditions.isPostFront && bait.category == BaitCategory.hairJig) {
      reasons.add('Finesse presentation for post-front lockjaw');
    }
    
    if (conditions.waterTempF < 50 && bait.category == BaitCategory.bladeBait) {
      reasons.add('Vibration draws lethargic cold-water fish');
    }
    
    return reasons.take(3).toList();
  }
  
  String _determineConfidence(double score) {
    if (score >= 85) return 'High';
    if (score >= 70) return 'Medium';
    return 'Low';
  }
  
  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------
  
  /// Compute temperature trend from hourly forecast data.
  ///
  /// Compares the average air temperature of the most recent 12 hours to the
  /// preceding 12-24 hour window. Returns 'warming', 'cooling', or 'stable'.
  /// When fewer than 12 hours of data are available, falls back to a 6-hour
  /// delta. With fewer than 6 hours, returns 'stable'.
  String _computeTempTrend(List<HourlyForecast> hourly) {
    if (hourly.length >= 24) {
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
  CrappieSeason _determineSeason(
    double waterTempF, {
    String tempTrend = 'stable',
    int? month,
  }) {
    if (waterTempF < 50) return CrappieSeason.winter;

    // Ambiguous range: 55-68 F could be spring (warming) or fall (cooling)
    if (waterTempF >= 55 && waterTempF < 68) {
      if (tempTrend == 'warming') {
        // Spring progression: warming into spawn range
        return waterTempF < 60 ? CrappieSeason.preSpawn : CrappieSeason.spawn;
      }
      if (tempTrend == 'cooling') {
        // Fall transition: cooling out of summer
        return CrappieSeason.fall;
      }
      // Trend is stable/unknown — use calendar month as tiebreaker
      final m = month ?? DateTime.now().month;
      if (m >= 8 && m <= 12) return CrappieSeason.fall;
      // Jan-Jul with stable trend: assume spring progression
      return waterTempF < 60 ? CrappieSeason.preSpawn : CrappieSeason.spawn;
    }

    // Below the ambiguous band but above winter
    if (waterTempF >= 50 && waterTempF < 55) {
      // 50-55 F: could be late winter warming or late fall cooling
      if (tempTrend == 'cooling') return CrappieSeason.fall;
      return CrappieSeason.preSpawn;
    }

    if (waterTempF < 75) return CrappieSeason.postSpawn;

    // 75 F+: summer or fall depending on trend and calendar
    if (tempTrend == 'cooling') return CrappieSeason.fall;
    final m = month ?? DateTime.now().month;
    if (m >= 9 && m <= 11) return CrappieSeason.fall;
    return CrappieSeason.summer;
  }
  
  TimeOfDay _determineTimeOfDay(
    DateTime now,
    DateTime? sunrise,
    DateTime? sunset,
  ) {
    final hour = now.hour;
    
    if (sunrise != null && sunset != null) {
      final sunriseHour = sunrise.hour;
      final sunsetHour = sunset.hour;
      
      // Dawn: 30min before to 2hr after sunrise
      if (hour >= sunriseHour - 1 && hour <= sunriseHour + 2) {
        return TimeOfDay.dawn;
      }
      
      // Dusk: 2hr before to 30min after sunset
      if (hour >= sunsetHour - 2 && hour <= sunsetHour + 1) {
        return TimeOfDay.dusk;
      }
      
      // Night
      if (hour > sunsetHour + 1 || hour < sunriseHour - 1) {
        return TimeOfDay.night;
      }
    }
    
    // Fallback to simple hour-based
    if (hour >= 5 && hour < 8) return TimeOfDay.dawn;
    if (hour >= 8 && hour < 10) return TimeOfDay.morning;
    if (hour >= 10 && hour < 15) return TimeOfDay.midday;
    if (hour >= 15 && hour < 18) return TimeOfDay.afternoon;
    if (hour >= 18 && hour < 21) return TimeOfDay.dusk;
    return TimeOfDay.night;
  }
  
  PressureTrend _determinePressureTrend(
    double? pressureMb,
    {required bool isFallingPressure,
     required bool isRisingPressure}
  ) {
    if (isFallingPressure) {
      // Check rate of fall
      return PressureTrend.falling;
    }
    
    if (isRisingPressure) {
      return PressureTrend.rising;
    }
    
    final pressure = pressureMb ?? 1013;
    if (pressure > 1020) return PressureTrend.stableHigh;
    if (pressure < 1005) return PressureTrend.stableLow;
    
    return PressureTrend.stableHigh; // Default
  }
  
  List<String> _generateGeneralTips(ConditionsSnapshot conditions) {
    final tips = <String>[];
    
    // Season-specific tips
    switch (conditions.season) {
      case CrappieSeason.winter:
        tips.add('💡 Winter tip: Use electronics to find schools '
            'suspended near channels. Fish are tight together.');
        break;
      case CrappieSeason.preSpawn:
        tips.add('💡 Pre-spawn tip: Fish are staging on migration routes. '
            'Focus on points and brush along creek channels.');
        break;
      case CrappieSeason.spawn:
        tips.add('💡 Spawn tip: Males guard beds aggressively. '
            'Females stage just off beds in slightly deeper water.');
        break;
      case CrappieSeason.postSpawn:
        tips.add('💡 Post-spawn tip: Fish scatter and become harder to pattern. '
            'Cover water with trolling or try dock shooting.');
        break;
      case CrappieSeason.summer:
        tips.add('💡 Summer tip: Key on the thermocline. Fish suspend '
            'where temperature and oxygen align.');
        break;
      case CrappieSeason.fall:
        tips.add('💡 Fall tip: Follow the shad! Crappie chase baitfish '
            'into creek arms as water cools.');
        break;
    }
    
    // Pressure-based tip
    if (conditions.isPreFront) {
      tips.add('⚡ Pre-front feeding frenzy! Fish aggressively '
          'before the front arrives.');
    } else if (conditions.isPostFront) {
      tips.add('🐢 Post-front conditions. Slow down and downsize. '
          'Fish are reluctant.');
    }
    
    // Time-based tip
    if (conditions.timeOfDay == TimeOfDay.midday &&
        conditions.season == CrappieSeason.summer) {
      tips.add('☀️ Midday summer: Try dock shooting or go deep. '
          'Fish seek shade and cooler water.');
    }
    
    // Solunar tip
    if (conditions.solunarRating != null && conditions.solunarRating! > 0.85) {
      tips.add('🌙 Major solunar period! Expect increased fish activity.');
    }
    
    return tips;
  }
  
  String _generateSummary(
    ConditionsSnapshot conditions,
    BaitRecommendation topPick,
  ) {
    final buffer = StringBuffer();
    
    buffer.write('${conditions.season.displayName} pattern at ');
    buffer.write('${conditions.waterTempF.round()}°F. ');
    
    if (conditions.pressureTrend == PressureTrend.falling) {
      buffer.write('Falling pressure suggests active feeding. ');
    } else if (conditions.pressureTrend == PressureTrend.rising) {
      buffer.write('Rising pressure - fish recovering from front. ');
    }
    
    buffer.write('Top pick: ${topPick.bait.name} in ');
    buffer.write('${topPick.recommendedColors.first}. ');
    
    if (conditions.structureType != null) {
      buffer.write('Target ${conditions.structureType!.displayName} ');
      buffer.write('at ${conditions.targetDepthFt.round()} ft.');
    }
    
    return buffer.toString();
  }
}

// Internal scoring helper
class _ScoredBait {
  final BaitProfile bait;
  final double score;
  
  const _ScoredBait({required this.bait, required this.score});
}
