/// Crappie Bait Recommendation Data Models
/// 
/// Science-backed bait selection models that account for:
/// - Water temperature (seasonal patterns)
/// - Water clarity (color visibility)
/// - Depth/thermocline positioning
/// - Time of day / solunar periods
/// - Weather conditions (pressure, fronts)
/// - Structure type
/// - Regional forage variations

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Primary bait categories for crappie fishing
enum BaitCategory {
  tubeJig,
  softPlasticMinnow,
  curlyTailGrub,
  hairJig,
  liveMinnow,
  crankbait,
  bladeBait,
}

extension BaitCategoryX on BaitCategory {
  String get displayName {
    switch (this) {
      case BaitCategory.tubeJig:
        return 'Tube Jig';
      case BaitCategory.softPlasticMinnow:
        return 'Soft Plastic Minnow';
      case BaitCategory.curlyTailGrub:
        return 'Curly Tail Grub';
      case BaitCategory.hairJig:
        return 'Hair Jig';
      case BaitCategory.liveMinnow:
        return 'Live Minnow';
      case BaitCategory.crankbait:
        return 'Crankbait';
      case BaitCategory.bladeBait:
        return 'Blade Bait';
    }
  }
  
  String get icon {
    switch (this) {
      case BaitCategory.tubeJig:
        return '🎯';
      case BaitCategory.softPlasticMinnow:
        return '🐟';
      case BaitCategory.curlyTailGrub:
        return '🌀';
      case BaitCategory.hairJig:
        return '🪶';
      case BaitCategory.liveMinnow:
        return '🐠';
      case BaitCategory.crankbait:
        return '🎣';
      case BaitCategory.bladeBait:
        return '⚡';
    }
  }
}

/// Water clarity classifications
enum WaterClarity {
  clear,      // >5ft visibility
  lightStain, // 3-5ft visibility  
  stained,    // 1-3ft visibility
  muddy,      // <1ft visibility
}

extension WaterClarityX on WaterClarity {
  String get displayName {
    switch (this) {
      case WaterClarity.clear:
        return 'Clear (>5ft)';
      case WaterClarity.lightStain:
        return 'Light Stain (3-5ft)';
      case WaterClarity.stained:
        return 'Stained (1-3ft)';
      case WaterClarity.muddy:
        return 'Muddy (<1ft)';
    }
  }
  
  double get visibilityFt {
    switch (this) {
      case WaterClarity.clear:
        return 6.0;
      case WaterClarity.lightStain:
        return 4.0;
      case WaterClarity.stained:
        return 2.0;
      case WaterClarity.muddy:
        return 0.5;
    }
  }
}

/// Structure types where crappie hold
enum StructureType {
  brushPile,
  stakeBed,
  standingTimber,
  laydown,
  dock,
  bridge,
  riprap,
  openWater,
  creekChannel,
  hump,
  point,
  vegetation,
}

extension StructureTypeX on StructureType {
  String get displayName {
    switch (this) {
      case StructureType.brushPile:
        return 'Brush Pile';
      case StructureType.stakeBed:
        return 'Stake Bed';
      case StructureType.standingTimber:
        return 'Standing Timber';
      case StructureType.laydown:
        return 'Laydown/Blowdown';
      case StructureType.dock:
        return 'Boat Dock';
      case StructureType.bridge:
        return 'Bridge Piling';
      case StructureType.riprap:
        return 'Riprap/Seawall';
      case StructureType.openWater:
        return 'Open Water/Suspended';
      case StructureType.creekChannel:
        return 'Creek Channel';
      case StructureType.hump:
        return 'Submerged Hump';
      case StructureType.point:
        return 'Point';
      case StructureType.vegetation:
        return 'Vegetation Edge';
    }
  }
}

/// Seasonal crappie patterns
enum CrappieSeason {
  winter,     // <50°F - Deep, lethargic
  preSpawn,   // 50-60°F - Staging, transitioning
  spawn,      // 61-68°F - Shallow, aggressive
  postSpawn,  // 69-75°F - Scattered, recovering
  summer,     // >75°F - Thermocline, dawn/dusk
  fall,       // 70→55°F - Following shad, aggressive
}

extension CrappieSeasonX on CrappieSeason {
  String get displayName {
    switch (this) {
      case CrappieSeason.winter:
        return 'Winter';
      case CrappieSeason.preSpawn:
        return 'Pre-Spawn';
      case CrappieSeason.spawn:
        return 'Spawn';
      case CrappieSeason.postSpawn:
        return 'Post-Spawn';
      case CrappieSeason.summer:
        return 'Summer';
      case CrappieSeason.fall:
        return 'Fall';
    }
  }
  
  String get tempRange {
    switch (this) {
      case CrappieSeason.winter:
        return '<50°F';
      case CrappieSeason.preSpawn:
        return '50-60°F';
      case CrappieSeason.spawn:
        return '61-68°F';
      case CrappieSeason.postSpawn:
        return '69-75°F';
      case CrappieSeason.summer:
        return '>75°F';
      case CrappieSeason.fall:
        return '70→55°F';
    }
  }
}

/// Barometric pressure trend
enum PressureTrend {
  rising,       // Fish becoming more active
  stableHigh,   // Good, consistent feeding
  stableLow,    // Sluggish, finesse needed
  falling,      // Pre-front feeding frenzy
  rapidFall,    // Fish shutting down
}

extension PressureTrendX on PressureTrend {
  String get displayName {
    switch (this) {
      case PressureTrend.rising:
        return 'Rising';
      case PressureTrend.stableHigh:
        return 'Stable High';
      case PressureTrend.stableLow:
        return 'Stable Low';
      case PressureTrend.falling:
        return 'Falling';
      case PressureTrend.rapidFall:
        return 'Rapid Fall';
    }
  }
  
  double get activityModifier {
    switch (this) {
      case PressureTrend.rising:
        return 1.15;
      case PressureTrend.stableHigh:
        return 1.0;
      case PressureTrend.stableLow:
        return 0.85;
      case PressureTrend.falling:
        return 1.25; // Pre-front feeding frenzy
      case PressureTrend.rapidFall:
        return 0.6;
    }
  }
}

/// Time of day fishing windows
enum TimeOfDay {
  dawn,        // 30min before to 2hr after sunrise
  morning,     // 2hr after sunrise to 10am
  midday,      // 10am to 3pm
  afternoon,   // 3pm to 2hr before sunset
  dusk,        // 2hr before to 30min after sunset
  night,       // After dark
}

extension TimeOfDayX on TimeOfDay {
  String get displayName {
    switch (this) {
      case TimeOfDay.dawn:
        return 'Dawn';
      case TimeOfDay.morning:
        return 'Morning';
      case TimeOfDay.midday:
        return 'Midday';
      case TimeOfDay.afternoon:
        return 'Afternoon';
      case TimeOfDay.dusk:
        return 'Dusk';
      case TimeOfDay.night:
        return 'Night';
    }
  }
  
  double get activityMultiplier {
    switch (this) {
      case TimeOfDay.dawn:
        return 1.3;
      case TimeOfDay.morning:
        return 1.1;
      case TimeOfDay.midday:
        return 0.7;
      case TimeOfDay.afternoon:
        return 0.9;
      case TimeOfDay.dusk:
        return 1.35;
      case TimeOfDay.night:
        return 0.9;
    }
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// Individual bait profile with all selection criteria
class BaitProfile {
  final String name;
  final BaitCategory category;
  final List<String> sizes;
  final Map<WaterClarity, List<String>> colorsByClarity;
  final double minDepthFt;
  final double maxDepthFt;
  final double minTempF;
  final double maxTempF;
  final List<StructureType> bestStructures;
  final List<String> techniques;
  final List<String> presentations;
  final String description;
  final double baseEffectiveness; // 0.0 - 1.0
  final List<CrappieSeason> peakSeasons;
  
  const BaitProfile({
    required this.name,
    required this.category,
    required this.sizes,
    required this.colorsByClarity,
    required this.minDepthFt,
    required this.maxDepthFt,
    required this.minTempF,
    required this.maxTempF,
    required this.bestStructures,
    required this.techniques,
    required this.presentations,
    required this.description,
    required this.baseEffectiveness,
    required this.peakSeasons,
  });
  
  /// Get recommended colors for given water clarity
  List<String> getColorsForClarity(WaterClarity clarity) {
    return colorsByClarity[clarity] ?? colorsByClarity.values.first;
  }
  
  /// Get recommended size for current conditions
  String getSizeRecommendation(double waterTempF, CrappieSeason season) {
    if (sizes.isEmpty) return 'Standard';
    
    // Cold water = smaller, finesse presentations
    // Spawn = smaller to match fry
    // Summer = larger to trigger reaction
    if (waterTempF < 50 || season == CrappieSeason.spawn) {
      return sizes.first; // Smallest
    } else if (waterTempF > 70 || season == CrappieSeason.fall) {
      return sizes.length > 2 ? sizes[sizes.length - 2] : sizes.last;
    }
    return sizes.length > 1 ? sizes[1] : sizes.first; // Middle size
  }
}

/// Jig head weight recommendation
class JigHeadWeight {
  final double weightOz;
  final String label;
  final double minDepthFt;
  final double maxDepthFt;
  final String useCase;
  
  const JigHeadWeight({
    required this.weightOz,
    required this.label,
    required this.minDepthFt,
    required this.maxDepthFt,
    required this.useCase,
  });
}

/// A scored bait recommendation with reasoning
class BaitRecommendation {
  final BaitProfile bait;
  final double score;            // 0.0 - 100.0
  final String confidenceLevel;  // High, Medium, Low
  final List<String> recommendedColors;
  final String recommendedSize;
  final JigHeadWeight? recommendedWeight;
  final List<String> techniques;
  final List<String> presentationTips;
  final List<String> reasons;    // Why this bait was recommended
  final int rank;                // 1st, 2nd, 3rd choice
  
  const BaitRecommendation({
    required this.bait,
    required this.score,
    required this.confidenceLevel,
    required this.recommendedColors,
    required this.recommendedSize,
    this.recommendedWeight,
    required this.techniques,
    required this.presentationTips,
    required this.reasons,
    required this.rank,
  });
}

/// Complete recommendation result with all context
class BaitRecommendationResult {
  final List<BaitRecommendation> recommendations;
  final ConditionsSnapshot conditions;
  final List<String> generalTips;
  final String summary;
  final DateTime generatedAt;
  
  const BaitRecommendationResult({
    required this.recommendations,
    required this.conditions,
    required this.generalTips,
    required this.summary,
    required this.generatedAt,
  });
  
  /// Get the top recommendation
  BaitRecommendation? get topPick => 
      recommendations.isNotEmpty ? recommendations.first : null;
  
  /// Get top N recommendations
  List<BaitRecommendation> getTopN(int n) => 
      recommendations.take(n).toList();
}

/// Snapshot of current fishing conditions used for recommendations
class ConditionsSnapshot {
  final double waterTempF;
  final WaterClarity clarity;
  final double targetDepthFt;
  final CrappieSeason season;
  final TimeOfDay timeOfDay;
  final PressureTrend pressureTrend;
  final double pressureMb;
  final StructureType? structureType;
  final double? windSpeedMph;
  final bool isPreFront;
  final bool isPostFront;
  final double? solunarRating; // 0.0 - 1.0
  final bool isNightFishing;
  
  const ConditionsSnapshot({
    required this.waterTempF,
    required this.clarity,
    required this.targetDepthFt,
    required this.season,
    required this.timeOfDay,
    required this.pressureTrend,
    required this.pressureMb,
    this.structureType,
    this.windSpeedMph,
    this.isPreFront = false,
    this.isPostFront = false,
    this.solunarRating,
    this.isNightFishing = false,
  });
}

/// Regional forage profile - what crappie eat varies by region
class RegionalForageProfile {
  final String region;
  final List<String> primaryForage;
  final List<String> secondaryForage;
  final Map<CrappieSeason, String> seasonalForage;
  final List<String> matchTheHatchColors;
  
  const RegionalForageProfile({
    required this.region,
    required this.primaryForage,
    required this.secondaryForage,
    required this.seasonalForage,
    required this.matchTheHatchColors,
  });
}
