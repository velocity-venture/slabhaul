import '../models/bait_recommendation.dart';
import '../models/hatch_recommendation.dart';

/// Match the Hatch — Crappie Bait Selector Engine
///
/// Pure Dart rules engine encoding expert crappie fishing knowledge from
/// research. No external AI API — works offline with zero latency.
///
/// Data tables are derived from matching-the-hatch-research.md covering:
/// - Regional forage profiles by season
/// - Color matrix (clarity × season × time-of-day)
/// - Presentation speed by water temperature
/// - Jig weight by depth and wind
/// - Bait size by forage lifecycle
/// - Product suggestions from tournament pros
/// - Pro tips keyed by condition triggers
class MatchTheHatchEngine {
  /// Generate a complete Match the Hatch recommendation.
  HatchRecommendation recommend({
    required double waterTempF,
    required WaterClarity clarity,
    required CrappieSeason season,
    required TimeOfDay timeOfDay,
    required FishingRegion region,
    double? airTempF,
    double? pressureMb,
    String? pressureTrend,
    double? windSpeedMph,
    int? windDirectionDeg,
    double? solunarRating,
    double? targetDepthFt,
    FishingPressure? fishingPressure,
  }) {
    final conditions = HatchConditions(
      waterTempF: waterTempF,
      clarity: clarity,
      season: season,
      timeOfDay: timeOfDay,
      region: region,
      airTempF: airTempF,
      pressureMb: pressureMb,
      pressureTrend: pressureTrend,
      windSpeedMph: windSpeedMph,
      windDirectionDeg: windDirectionDeg,
      solunarRating: solunarRating,
      targetDepthFt: targetDepthFt,
      fishingPressure: fishingPressure,
    );

    // 1. Forage profile
    final forage = _getForageContext(region, season, waterTempF);

    // 2. Score bait types
    final scored = <_ScoredType>[];
    for (final entry in _baitTypes.entries) {
      final score = _scoreBaitType(
        entry.key,
        entry.value,
        conditions,
        forage,
      );
      scored.add(_ScoredType(entry.key, entry.value, score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));

    // 3. Build picks for top 3
    final depth = targetDepthFt ?? _defaultDepth(season, waterTempF);
    final picks = <HatchBaitPick>[];
    for (var i = 0; i < 3 && i < scored.length; i++) {
      picks.add(_buildPick(
        scored[i],
        conditions,
        forage,
        depth,
        isAlternative: i > 0,
      ));
    }

    // 4. Products
    final products = _getProducts(picks.first.baitCategory, season);

    // 5. Pro tip
    final proTip = _selectProTip(conditions, forage);

    // 6. Reasoning
    final reasoning = _buildReasoning(conditions, forage, picks.first);

    return HatchRecommendation(
      primary: picks.first,
      alternatives: picks.skip(1).toList(),
      reasoning: reasoning,
      forage: forage,
      proTip: proTip,
      products: products,
      conditions: conditions,
      generatedAt: DateTime.now(),
    );
  }

  // -------------------------------------------------------------------------
  // Forage Table (Research Section 1-2)
  // -------------------------------------------------------------------------

  ForageContext _getForageContext(
    FishingRegion region,
    CrappieSeason season,
    double waterTempF,
  ) {
    final regional = _forageTable[region] ?? _forageTable[FishingRegion.midSouth]!;
    final seasonal = regional[season] ?? regional[CrappieSeason.summer]!;

    // Adjust forage size by temperature within season
    String size = seasonal.size;
    if (season == CrappieSeason.postSpawn && waterTempF > 72) {
      size = '0.5-1"'; // Shad fry just hatched
    } else if (season == CrappieSeason.summer && waterTempF > 80) {
      size = '1.5-2.5"'; // Juvenile shad growing
    } else if (season == CrappieSeason.fall && waterTempF < 60) {
      size = '2.5-3.5"'; // Mature shad
    }

    return ForageContext(
      species: seasonal.species,
      size: size,
      seasonalNote: seasonal.note,
    );
  }

  static final Map<FishingRegion, Map<CrappieSeason, _ForageEntry>> _forageTable = {
    FishingRegion.south: {
      CrappieSeason.winter: const _ForageEntry('Threadfin shad (suspended deep)', '2-3"', 'Shad holding deep near channels; minimal movement'),
      CrappieSeason.preSpawn: const _ForageEntry('Threadfin shad + minnows', '2-2.5"', 'Shad moving up creek channels; minnows active near staging areas'),
      CrappieSeason.spawn: const _ForageEntry('Minnows + insects', '1-2"', 'Males on beds; small minnows, insects, fry present nearby'),
      CrappieSeason.postSpawn: const _ForageEntry('Shad fry', '0.5-1"', 'Newly hatched shad fry; mayfly hatches; crappie transitioning deeper'),
      CrappieSeason.summer: const _ForageEntry('Juvenile threadfin shad', '1.5-2.5"', 'Shad concentrated at thermocline; brief feeding windows'),
      CrappieSeason.fall: const _ForageEntry('Maturing shad', '2.5-4"', 'Shad migrating along creek channels; crappie following aggressively'),
    },
    FishingRegion.midSouth: {
      CrappieSeason.winter: const _ForageEntry('Threadfin shad (deep)', '2-3"', 'Shad suspended deep; crappie metabolism at seasonal low'),
      CrappieSeason.preSpawn: const _ForageEntry('Threadfin shad + minnows', '2-2.5"', 'Shad moving shallow; minnows active in creek arms'),
      CrappieSeason.spawn: const _ForageEntry('Small minnows + insects', '1-1.5"', 'Nest defense triggers; insects and larvae near beds'),
      CrappieSeason.postSpawn: const _ForageEntry('Shad fry + mayflies', '0.5-1.5"', 'Shad fry hatch; mayfly activity peaks; micro forage abundant'),
      CrappieSeason.summer: const _ForageEntry('Juvenile shad', '1.5-2.5"', 'Shad at thermocline; focus dawn/dusk feeding windows'),
      CrappieSeason.fall: const _ForageEntry('Maturing threadfin shad', '2.5-3.5"', 'Fall shad migration into creek arms; aggressive feeding'),
    },
    FishingRegion.midwest: {
      CrappieSeason.winter: const _ForageEntry('Gizzard shad + minnows', '2-3"', 'Shad deep and lethargic; minnows near structure'),
      CrappieSeason.preSpawn: const _ForageEntry('Minnows + shad', '1.5-2.5"', 'Mixed forage becoming active; crappie staging on points'),
      CrappieSeason.spawn: const _ForageEntry('Minnows + insect larvae', '1-1.5"', 'Small forage near spawning flats; bed defense behavior'),
      CrappieSeason.postSpawn: const _ForageEntry('Shad fry + insects', '0.5-1.5"', 'Young-of-year forage emerging; mayfly hatches in river systems'),
      CrappieSeason.summer: const _ForageEntry('Juvenile gizzard shad', '2-3"', 'Larger shad profile than south; crappie at thermocline'),
      CrappieSeason.fall: const _ForageEntry('Shad + crawfish', '2-3"', 'Fall turnover disrupts shad; crawfish become secondary forage'),
    },
    FishingRegion.north: {
      CrappieSeason.winter: const _ForageEntry('Minnows + insect larvae', '1-2"', 'Ice belt; minimal forage movement; ultra-slow metabolism'),
      CrappieSeason.preSpawn: const _ForageEntry('Minnows', '1.5-2"', 'Fathead minnows and shiners moving shallow'),
      CrappieSeason.spawn: const _ForageEntry('Small minnows + insects', '1-1.5"', 'Shorter spawn window; insects increasingly important'),
      CrappieSeason.postSpawn: const _ForageEntry('Insect larvae + minnow fry', '0.5-1"', 'Insect hatches drive feeding; micro forage dominant'),
      CrappieSeason.summer: const _ForageEntry('Minnows + perch fry', '1.5-2.5"', 'Mixed forage base; shorter summer window'),
      CrappieSeason.fall: const _ForageEntry('Minnows + shad', '2-3"', 'Aggressive fall feeding before ice; larger profiles effective'),
    },
    FishingRegion.northeast: {
      CrappieSeason.winter: const _ForageEntry('Minnows', '1.5-2"', 'Cold deep water; minnows near structure; slow presentations'),
      CrappieSeason.preSpawn: const _ForageEntry('Shiners + minnows', '1.5-2.5"', 'Golden shiners active in pre-spawn staging areas'),
      CrappieSeason.spawn: const _ForageEntry('Small minnows + insects', '1-1.5"', 'Spawn on structure in ponds and reservoirs'),
      CrappieSeason.postSpawn: const _ForageEntry('Insect larvae + fry', '0.5-1.5"', 'Insect hatches peak; crappie scatter to deeper water'),
      CrappieSeason.summer: const _ForageEntry('Minnows + alewives', '1.5-2.5"', 'Alewife forage in northeastern reservoirs'),
      CrappieSeason.fall: const _ForageEntry('Minnows + shad', '2-3"', 'Fall migration; crappie follow bait along channels'),
    },
  };

  // -------------------------------------------------------------------------
  // Color Matrix (Research Appendix + Section 4)
  // -------------------------------------------------------------------------

  static String _selectColor(
    WaterClarity clarity,
    CrappieSeason season,
    TimeOfDay time,
    FishingPressure? pressure,
  ) {
    // Base color from matrix
    final matrix = _colorMatrix[clarity] ?? _colorMatrix[WaterClarity.stained]!;
    final colors = matrix[season] ?? matrix[CrappieSeason.summer]!;

    // Time-of-day adjustment
    String color = colors.first;
    if (time == TimeOfDay.night || time == TimeOfDay.dusk) {
      // Prefer glow or dark silhouette at night/dusk
      color = colors.firstWhere(
        (c) => c.toLowerCase().contains('glow') ||
            c.toLowerCase().contains('black') ||
            c.toLowerCase().contains('dark'),
        orElse: () => colors.first,
      );
    } else if (time == TimeOfDay.dawn) {
      // Subtle natural or white at dawn
      color = colors.firstWhere(
        (c) => c.toLowerCase().contains('white') ||
            c.toLowerCase().contains('natural') ||
            c.toLowerCase().contains('ghost'),
        orElse: () => colors.first,
      );
    }

    // Fishing pressure: shift toward natural/subtle under heavy pressure
    if (pressure == FishingPressure.heavy || pressure == FishingPressure.tournament) {
      color = colors.firstWhere(
        (c) => c.toLowerCase().contains('natural') ||
            c.toLowerCase().contains('ghost') ||
            c.toLowerCase().contains('smoke') ||
            c.toLowerCase().contains('subtle'),
        orElse: () => color,
      );
    }

    return color;
  }

  static ColorCategory _classifyColor(String color) {
    final lc = color.toLowerCase();
    if (lc.contains('glow')) return ColorCategory.glow;
    if (lc.contains('black') || lc.contains('dark') || lc.contains('purple')) {
      return ColorCategory.darkSilhouette;
    }
    if (lc.contains('chartreuse') || lc.contains('electric') ||
        lc.contains('laminate') || lc.contains('bluegrass')) {
      return ColorCategory.brightLaminate;
    }
    if (lc.contains('hot') || lc.contains('fluorescent') || lc.contains('pink')) {
      return ColorCategory.reaction;
    }
    return ColorCategory.natural;
  }

  static final Map<WaterClarity, Map<CrappieSeason, List<String>>> _colorMatrix = {
    WaterClarity.crystalClear: {
      CrappieSeason.winter: ['Ghost/glow', 'Subtle natural', 'White/silver'],
      CrappieSeason.preSpawn: ['Natural shad', 'Silver/blue', 'Ghost minnow'],
      CrappieSeason.spawn: ['Chartreuse/white', 'Pink/white', 'Natural shad'],
      CrappieSeason.postSpawn: ['Natural shad', 'Subtle flash', 'Ghost/pearl'],
      CrappieSeason.summer: ['Natural shad', 'Subtle flash', 'Translucent smoke'],
      CrappieSeason.fall: ['Natural shad', 'Threadfin shad pattern', 'Silver/blue'],
    },
    WaterClarity.clear: {
      CrappieSeason.winter: ['Ghost/glow', 'Subtle natural', 'White/silver'],
      CrappieSeason.preSpawn: ['Natural shad', 'Silver/blue', 'Ghost minnow'],
      CrappieSeason.spawn: ['Chartreuse/white', 'Pink/white', 'Natural shad'],
      CrappieSeason.postSpawn: ['Natural shad', 'Subtle flash', 'Ghost/pearl'],
      CrappieSeason.summer: ['Natural shad', 'Subtle flash', 'Smoke/silver'],
      CrappieSeason.fall: ['Natural shad', 'Threadfin Shad pattern', 'Silver/blue'],
    },
    WaterClarity.lightStain: {
      CrappieSeason.winter: ['Black/chartreuse', 'Dark purple/chartreuse', 'Glow accents'],
      CrappieSeason.preSpawn: ['Chartreuse/white', 'Blue Ice', 'Monkey Milk'],
      CrappieSeason.spawn: ['Electric Chicken', 'Bluegrass', 'Chartreuse/white'],
      CrappieSeason.postSpawn: ['Pearl/chartreuse', 'Monkey Milk', 'Blue/pearl'],
      CrappieSeason.summer: ['Bright laminates', 'Chartreuse/orange', 'Bluegrass'],
      CrappieSeason.fall: ['Chartreuse/orange', 'Bright laminates', 'Blue Ice'],
    },
    WaterClarity.stained: {
      CrappieSeason.winter: ['Black/chartreuse', 'Dark purple', 'Glow accents'],
      CrappieSeason.preSpawn: ['Chartreuse/white', 'Blue Ice', 'Orange/chartreuse'],
      CrappieSeason.spawn: ['Electric Chicken', 'Bluegrass', 'Hot pink'],
      CrappieSeason.postSpawn: ['Chartreuse/white', 'Electric Chicken', 'Orange/chartreuse'],
      CrappieSeason.summer: ['Bright laminates', 'Chartreuse/orange', 'Electric Chicken'],
      CrappieSeason.fall: ['Chartreuse/orange', 'Bright laminates', 'Orange/chartreuse'],
    },
    WaterClarity.muddy: {
      CrappieSeason.winter: ['Black', 'Dark purple', 'Glow'],
      CrappieSeason.preSpawn: ['Black/chartreuse', 'Dark bodies', 'Chartreuse/white'],
      CrappieSeason.spawn: ['Dark silhouettes + rattle', 'Black/chartreuse', 'Glow'],
      CrappieSeason.postSpawn: ['Dark bodies', 'Chartreuse/white', 'Glow'],
      CrappieSeason.summer: ['Dark bodies', 'Chartreuse/white', 'Fluorescent orange'],
      CrappieSeason.fall: ['Black/pearl', 'Chartreuse/white', 'Glow'],
    },
  };

  // -------------------------------------------------------------------------
  // Bait Type Scoring (Research Section 5-6)
  // -------------------------------------------------------------------------

  double _scoreBaitType(
    BaitCategory cat,
    _BaitTypeData data,
    HatchConditions cond,
    ForageContext forage,
  ) {
    double score = data.baseScore;

    // Temperature fit
    if (cond.waterTempF >= data.minTemp && cond.waterTempF <= data.maxTemp) {
      final range = data.maxTemp - data.minTemp;
      final mid = data.minTemp + range / 2;
      final dist = (cond.waterTempF - mid).abs();
      score += (1.0 - dist / (range / 2)) * 20;
    } else {
      score -= 15;
    }

    // Season match
    if (data.peakSeasons.contains(cond.season)) score += 15;

    // Forage size matching
    final forageMax = _parseMaxSize(forage.size);
    final baitMax = _parseMaxSize(data.sizeRange);
    final sizeDiff = (forageMax - baitMax).abs();
    if (sizeDiff < 0.5) {
      score += 10; // Excellent match
    } else if (sizeDiff < 1.0) {
      score += 5;
    } else {
      score -= 5;
    }

    // Depth fit
    final depth = cond.targetDepthFt ?? _defaultDepth(cond.season, cond.waterTempF);
    if (depth >= data.minDepth && depth <= data.maxDepth) {
      score += 8;
    } else {
      score -= 8;
    }

    // Pressure modifier
    if (cond.pressureTrend == 'Falling') {
      // Pre-front frenzy: aggressive baits shine
      if (cat == BaitCategory.crankbait || cat == BaitCategory.curlyTailGrub) {
        score += 8;
      }
    } else if (cond.pressureTrend == 'Rising') {
      // Post-front lockjaw: finesse
      if (cat == BaitCategory.hairJig || cat == BaitCategory.liveMinnow ||
          cat == BaitCategory.microJig) {
        score += 8;
      }
    }

    // Fishing pressure modifier
    if (cond.fishingPressure == FishingPressure.heavy ||
        cond.fishingPressure == FishingPressure.tournament) {
      if (cat == BaitCategory.microJig || cat == BaitCategory.hairJig ||
          cat == BaitCategory.liveMinnow) {
        score += 10;
      } else if (cat == BaitCategory.crankbait) {
        score -= 5;
      }
    }

    // Time-of-day modifier
    if (cond.timeOfDay == TimeOfDay.night) {
      if (cat == BaitCategory.liveMinnow) score += 8;
      if (cat == BaitCategory.crankbait) score -= 10;
    }

    // Cold water finesse bonus
    if (cond.waterTempF < 50) {
      if (cat == BaitCategory.hairJig || cat == BaitCategory.liveMinnow ||
          cat == BaitCategory.bladeBait) {
        score += 10;
      }
    }

    // Hot water + live minnow bonus (Whitey Outlaw tip)
    if (cond.waterTempF > 80 && cat == BaitCategory.liveMinnow) {
      score += 12;
    }

    // Wind: hard to feel bites on hair jig, blade bait advantage
    if ((cond.windSpeedMph ?? 0) > 15) {
      if (cat == BaitCategory.hairJig) score -= 6;
      if (cat == BaitCategory.bladeBait) score += 6;
    }

    return score.clamp(0, 100);
  }

  static final Map<BaitCategory, _BaitTypeData> _baitTypes = {
    BaitCategory.tubeJig: const _BaitTypeData(
      baseScore: 50, minTemp: 35, maxTemp: 90, minDepth: 1, maxDepth: 35,
      sizeRange: '1.5-3"',
      peakSeasons: [CrappieSeason.preSpawn, CrappieSeason.spawn, CrappieSeason.fall],
      technique: 'Vertical jigging into brush',
    ),
    BaitCategory.softPlasticMinnow: const _BaitTypeData(
      baseScore: 48, minTemp: 45, maxTemp: 90, minDepth: 1, maxDepth: 25,
      sizeRange: '1-2.5"',
      peakSeasons: [CrappieSeason.summer, CrappieSeason.postSpawn, CrappieSeason.fall],
      technique: 'Dock shooting / casting',
    ),
    BaitCategory.curlyTailGrub: const _BaitTypeData(
      baseScore: 46, minTemp: 40, maxTemp: 85, minDepth: 1, maxDepth: 30,
      sizeRange: '1.5-3"',
      peakSeasons: [CrappieSeason.preSpawn, CrappieSeason.fall, CrappieSeason.summer],
      technique: 'Slow swimming / spider rigging',
    ),
    BaitCategory.hairJig: const _BaitTypeData(
      baseScore: 44, minTemp: 35, maxTemp: 75, minDepth: 1, maxDepth: 20,
      sizeRange: '1-2"',
      peakSeasons: [CrappieSeason.winter, CrappieSeason.spawn, CrappieSeason.preSpawn],
      technique: 'Barely hop, let marabou breathe',
    ),
    BaitCategory.liveMinnow: const _BaitTypeData(
      baseScore: 52, minTemp: 32, maxTemp: 95, minDepth: 1, maxDepth: 40,
      sizeRange: '1-3"',
      peakSeasons: [CrappieSeason.winter, CrappieSeason.preSpawn, CrappieSeason.fall],
      technique: 'Slip float over cover',
    ),
    BaitCategory.crankbait: const _BaitTypeData(
      baseScore: 40, minTemp: 55, maxTemp: 85, minDepth: 3, maxDepth: 18,
      sizeRange: '1.5-2.5"',
      peakSeasons: [CrappieSeason.fall, CrappieSeason.summer, CrappieSeason.postSpawn],
      technique: 'Trolling 1.0-1.5 mph along structure',
    ),
    BaitCategory.bladeBait: const _BaitTypeData(
      baseScore: 42, minTemp: 35, maxTemp: 60, minDepth: 8, maxDepth: 40,
      sizeRange: '1.5-2"',
      peakSeasons: [CrappieSeason.winter, CrappieSeason.fall],
      technique: 'Vertical jigging with 6" hops',
    ),
    BaitCategory.microJig: const _BaitTypeData(
      baseScore: 38, minTemp: 55, maxTemp: 85, minDepth: 1, maxDepth: 15,
      sizeRange: '1-1.25"',
      peakSeasons: [CrappieSeason.postSpawn, CrappieSeason.summer, CrappieSeason.spawn],
      technique: 'Tandem rig or slow fall under float',
    ),
  };

  // -------------------------------------------------------------------------
  // Presentation Speed (Research Section 5)
  // -------------------------------------------------------------------------

  static PresentationSpeed _getSpeed(double waterTempF) {
    if (waterTempF < 45) return PresentationSpeed.deadSlow;
    if (waterTempF < 55) return PresentationSpeed.slow;
    if (waterTempF < 65) return PresentationSpeed.moderate;
    if (waterTempF < 75) return PresentationSpeed.moderateFast;
    return PresentationSpeed.moderate; // Back to moderate in heat; early/late focus
  }

  // -------------------------------------------------------------------------
  // Jig Weight (Research Section 5)
  // -------------------------------------------------------------------------

  static String _getJigWeight(double depthFt, double windMph) {
    final windy = windMph > 10;
    if (depthFt <= 5) return windy ? '1/32-1/16 oz' : '1/64-1/32 oz';
    if (depthFt <= 10) return windy ? '1/16 oz' : '1/32-1/16 oz';
    if (depthFt <= 15) return windy ? '1/16-1/8 oz' : '1/16 oz';
    if (depthFt <= 25) return windy ? '1/8-3/16 oz' : '1/8 oz';
    return windy ? '1/4 oz' : '1/8-1/4 oz';
  }

  // -------------------------------------------------------------------------
  // Bait Size by Forage (Research Section 5)
  // -------------------------------------------------------------------------

  static String _matchBaitSize(BaitCategory cat, String forageSize) {
    final maxForage = _parseMaxSize(forageSize);

    if (cat == BaitCategory.microJig) {
      return maxForage <= 1.0 ? '1"' : '1.25"';
    }
    if (cat == BaitCategory.liveMinnow) {
      if (maxForage <= 1.5) return '1-1.5" (spawn)';
      if (maxForage <= 2.5) return '1.5-2" (standard)';
      return '2-3" (trophy)';
    }

    // Standard soft plastics and tubes
    if (maxForage <= 1.0) return '1.5"';
    if (maxForage <= 2.0) return '2"';
    if (maxForage <= 3.0) return '2.5"';
    return '3"';
  }

  // -------------------------------------------------------------------------
  // Default Depth (when not provided)
  // -------------------------------------------------------------------------

  static double _defaultDepth(CrappieSeason season, double waterTempF) {
    switch (season) {
      case CrappieSeason.winter:
        return waterTempF < 40 ? 30 : 20;
      case CrappieSeason.preSpawn:
        return 10;
      case CrappieSeason.spawn:
        return 4;
      case CrappieSeason.postSpawn:
        return 12;
      case CrappieSeason.summer:
        return 18;
      case CrappieSeason.fall:
        return 12;
    }
  }

  // -------------------------------------------------------------------------
  // Build Pick
  // -------------------------------------------------------------------------

  HatchBaitPick _buildPick(
    _ScoredType scored,
    HatchConditions cond,
    ForageContext forage,
    double depth, {
    required bool isAlternative,
  }) {
    final color = _selectColor(
      cond.clarity,
      cond.season,
      cond.timeOfDay,
      cond.fishingPressure,
    );
    final speed = _getSpeed(cond.waterTempF);
    final weight = _getJigWeight(depth, cond.windSpeedMph ?? 0);
    final size = _matchBaitSize(scored.cat, forage.size);

    // Depth range
    double depthMin, depthMax;
    switch (cond.season) {
      case CrappieSeason.spawn:
        depthMin = 2;
        depthMax = 6;
      case CrappieSeason.preSpawn:
        depthMin = 6;
        depthMax = 12;
      case CrappieSeason.postSpawn:
        depthMin = 8;
        depthMax = 15;
      case CrappieSeason.summer:
        depthMin = 15;
        depthMax = 22;
      case CrappieSeason.fall:
        depthMin = 8;
        depthMax = 15;
      case CrappieSeason.winter:
        depthMin = 20;
        depthMax = 35;
    }
    if (cond.targetDepthFt != null) {
      depthMin = (cond.targetDepthFt! - 3).clamp(1, 40);
      depthMax = (cond.targetDepthFt! + 3).clamp(2, 40);
    }

    final reasons = <String>[];
    if (scored.data.peakSeasons.contains(cond.season)) {
      reasons.add('Peak effectiveness during ${cond.season.displayName}');
    }
    reasons.add('Matches ${forage.species} forage (${forage.size})');
    if (cond.fishingPressure == FishingPressure.heavy ||
        cond.fishingPressure == FishingPressure.tournament) {
      reasons.add('Finesse approach for pressured fish');
    }
    if (cond.waterTempF < 50) {
      reasons.add('Cold water finesse presentation');
    }

    return HatchBaitPick(
      baitType: scored.data.technique.split('/').first.trim(),
      baitCategory: scored.cat,
      baitSize: size,
      jigWeight: weight,
      colorName: color,
      colorCategory: _classifyColor(color),
      technique: scored.data.technique,
      speed: speed,
      depthMin: depthMin,
      depthMax: depthMax,
      confidence: (scored.score / 100).clamp(0.0, 1.0),
      reasons: reasons.take(3).toList(),
    );
  }

  // -------------------------------------------------------------------------
  // Products (Research throughout)
  // -------------------------------------------------------------------------

  static List<ProductSuggestion> _getProducts(BaitCategory cat, CrappieSeason season) {
    final all = _productTable[cat] ?? [];
    if (all.isEmpty) return all;
    // Return up to 4 products
    return all.take(4).toList();
  }

  static final Map<BaitCategory, List<ProductSuggestion>> _productTable = {
    BaitCategory.tubeJig: const [
      ProductSuggestion(name: 'Baby Shad', brand: 'Bobby Garland', color: 'Threadfin Shad', size: '2"'),
      ProductSuggestion(name: 'Slab Slay\'R', brand: 'Bobby Garland', color: 'Monkey Milk', size: '2"'),
      ProductSuggestion(name: 'Stroll\'R', brand: 'Bobby Garland', color: 'Electric Chicken', size: '2.5"'),
      ProductSuggestion(name: 'Split Tail', brand: 'Bobby Garland', color: 'Blue Ice', size: '2"'),
    ],
    BaitCategory.softPlasticMinnow: const [
      ProductSuggestion(name: 'Baby Shad Swim\'R', brand: 'Bobby Garland', color: 'Threadfin Shad', size: '2"'),
      ProductSuggestion(name: 'Minnow Mind\'R', brand: 'Bobby Garland', color: 'Shad', size: '2"'),
      ProductSuggestion(name: 'Slab Daddy', brand: 'Mr. Crappie', color: 'Chartreuse/White', size: '2"'),
      ProductSuggestion(name: 'Mayfly', brand: 'Bobby Garland', color: 'Natural', size: '2.25"'),
    ],
    BaitCategory.curlyTailGrub: const [
      ProductSuggestion(name: 'Crappie Grub', brand: 'Strike King', color: 'Chartreuse/White', size: '2"'),
      ProductSuggestion(name: 'Curly Tail', brand: 'Bobby Garland', color: 'Electric Chicken', size: '2"'),
      ProductSuggestion(name: 'Slab Slanger', brand: 'Mr. Crappie', color: 'Hot Pink', size: '2"'),
    ],
    BaitCategory.hairJig: const [
      ProductSuggestion(name: 'Slab Daddy', brand: 'Mr. Crappie', color: 'White', size: '1/16 oz'),
      ProductSuggestion(name: 'Marabou Jig', brand: 'Eagle Claw', color: 'Black/Chartreuse', size: '1/32 oz'),
      ProductSuggestion(name: 'Hand-Tied Hair Jig', brand: 'Southern Pro', color: 'Olive/White', size: '1/16 oz'),
    ],
    BaitCategory.liveMinnow: const [
      ProductSuggestion(name: 'Fathead Minnow', brand: 'Local Bait Shop', color: 'Natural', size: '1.5-2"'),
      ProductSuggestion(name: 'Golden Shiner', brand: 'Local Bait Shop', color: 'Natural Gold', size: '2-3"'),
    ],
    BaitCategory.crankbait: const [
      ProductSuggestion(name: 'Wally Marshall Crappie Crankbait', brand: 'Strike King', color: 'Shad', size: '1.5"'),
      ProductSuggestion(name: 'Tiny Trap', brand: 'Bill Lewis', color: 'Chrome/Blue', size: '1.5"'),
      ProductSuggestion(name: 'Crappie Crankbait', brand: 'Bandit', color: 'Chartreuse Shad', size: '2"'),
    ],
    BaitCategory.bladeBait: const [
      ProductSuggestion(name: 'Road Runner', brand: 'Blakemore', color: 'Chartreuse/White', size: '1/8 oz'),
      ProductSuggestion(name: 'Crappie Spoon', brand: 'Johnson', color: 'Silver', size: '1/4 oz'),
    ],
    BaitCategory.microJig: const [
      ProductSuggestion(name: 'Itty Bit Slab Hunt\'R', brand: 'Bobby Garland', color: 'Threadfin Shad', size: '1"'),
      ProductSuggestion(name: 'Trout Magnet', brand: 'Leland Lures', color: 'White', size: '1"'),
      ProductSuggestion(name: 'Eyehole Jig', brand: 'Leland Lures', color: 'Chartreuse', size: '1/64 oz'),
    ],
  };

  // -------------------------------------------------------------------------
  // Pro Tips (Research Section 7)
  // -------------------------------------------------------------------------

  static ProTip _selectProTip(HatchConditions cond, ForageContext forage) {
    // Cold water
    if (cond.waterTempF < 50) {
      return const ProTip(
        text: 'Tick the end of your rod tip — minimal movement. Do not overwork '
            'the lure. In cold water, crappie will inspect the bait for extended '
            'periods before committing.',
        source: 'Wally Marshall (Mr. Crappie)',
      );
    }

    // Hot water
    if (cond.waterTempF > 80) {
      return const ProTip(
        text: 'When summer water temps spike above 80F, switch from artificials '
            'to live minnows. Crappie become reluctant to chase artificial action '
            'in extreme heat.',
        source: 'Whitey Outlaw',
      );
    }

    // Spawn
    if (cond.season == CrappieSeason.spawn) {
      return const ProTip(
        text: 'Tie your knot at the BACK of the hook eye so the lure hangs '
            'horizontal, not nose-down. Shoot jigs under docks and minimize '
            'movement once in the zone.',
        source: 'Wally Marshall (Mr. Crappie)',
      );
    }

    // Pre-spawn / finicky
    if (cond.season == CrappieSeason.preSpawn) {
      return const ProTip(
        text: 'When pre-spawn crappie follow baits but won\'t commit, downsize '
            'to 1" micro jigs on 1/64 oz heads with 2-lb mono. Two jigs tied '
            '20" apart with loop knots.',
        source: 'Kent Driscoll',
      );
    }

    // Fall
    if (cond.season == CrappieSeason.fall) {
      return const ProTip(
        text: 'Follow the bait! The best way to know where the fish are is to '
            'follow the baitfish. Look for shad on your graph before putting '
            'lines out.',
        source: 'Kent Driscoll',
      );
    }

    // Heavy pressure
    if (cond.fishingPressure == FishingPressure.heavy ||
        cond.fishingPressure == FishingPressure.tournament) {
      return const ProTip(
        text: 'Crappie are extremely sensitive to sound. Distance yourself from '
            'other boats and minimize electronics/trolling motor noise — the '
            'most underrated factor in crappie fishing.',
        source: 'Whitey Outlaw',
      );
    }

    // Post-spawn
    if (cond.season == CrappieSeason.postSpawn) {
      return const ProTip(
        text: 'Shad fry are tiny right now. Try a tandem rig: heavier jig on '
            'top (1/16 oz), trailing a 1" micro jig 12-18" below. The pendulum '
            'effect mimics drifting fry.',
        source: 'Tournament Pro Consensus',
      );
    }

    // Default / summer
    return const ProTip(
      text: 'Watch the line! If the bow stops or jumps, you have a fish. Once '
          'you catch one, immediately re-present a jig — schools scatter if '
          'you delay.',
      source: 'Wally Marshall (Mr. Crappie)',
    );
  }

  // -------------------------------------------------------------------------
  // Reasoning Builder
  // -------------------------------------------------------------------------

  static String _buildReasoning(
    HatchConditions cond,
    ForageContext forage,
    HatchBaitPick primary,
  ) {
    final buf = StringBuffer();
    buf.write('Water at ${cond.waterTempF.round()}°F in ${cond.clarity.displayName.split(' ').first.toLowerCase()} '
        'conditions during ${cond.season.displayName}. ');

    if (cond.pressureTrend == 'Falling') {
      buf.write('Falling pressure suggests active feeding — go aggressive. ');
    } else if (cond.pressureTrend == 'Rising') {
      buf.write('Rising pressure (post-front) calls for finesse. ');
    }

    buf.write('Regional forage is ${forage.species} at ${forage.size}. ');
    buf.write('${primary.baitCategory.displayName} in ${primary.colorName} '
        'matches the hatch with a ${primary.speed.displayName.toLowerCase()} '
        'presentation at ${primary.depthRange}.');

    return buf.toString();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static double _parseMaxSize(String sizeStr) {
    // Extract the largest number from strings like "1.5-2.5"" or "2""
    final nums = RegExp(r'[\d.]+').allMatches(sizeStr);
    double max = 2.0;
    for (final m in nums) {
      final v = double.tryParse(m.group(0)!) ?? 0;
      if (v > max) max = v;
    }
    return max;
  }
}

// ---------------------------------------------------------------------------
// Internal data classes
// ---------------------------------------------------------------------------

class _ForageEntry {
  final String species;
  final String size;
  final String note;
  const _ForageEntry(this.species, this.size, this.note);
}

class _BaitTypeData {
  final double baseScore;
  final double minTemp;
  final double maxTemp;
  final double minDepth;
  final double maxDepth;
  final String sizeRange;
  final List<CrappieSeason> peakSeasons;
  final String technique;

  const _BaitTypeData({
    required this.baseScore,
    required this.minTemp,
    required this.maxTemp,
    required this.minDepth,
    required this.maxDepth,
    required this.sizeRange,
    required this.peakSeasons,
    required this.technique,
  });
}

class _ScoredType {
  final BaitCategory cat;
  final _BaitTypeData data;
  final double score;
  const _ScoredType(this.cat, this.data, this.score);
}
