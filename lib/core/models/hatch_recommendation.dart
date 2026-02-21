/// Match the Hatch — AI Bait Selector Data Models
///
/// Richer output models that incorporate forage matching, color science,
/// product suggestions, and expert pro tips from research data.
library;

import 'bait_recommendation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Color category for bait selection logic
enum ColorCategory {
  natural,        // Shad patterns, ghost, translucent
  brightLaminate, // Chartreuse/white, Electric Chicken
  darkSilhouette, // Black, dark purple
  glow,           // Glow-in-dark, phosphorescent
  reaction,       // Bright solid, hot pink, fluorescent
}

extension ColorCategoryX on ColorCategory {
  String get displayName {
    switch (this) {
      case ColorCategory.natural:
        return 'Natural';
      case ColorCategory.brightLaminate:
        return 'Bright Laminate';
      case ColorCategory.darkSilhouette:
        return 'Dark Silhouette';
      case ColorCategory.glow:
        return 'Glow';
      case ColorCategory.reaction:
        return 'Reaction';
    }
  }
}

/// Presentation speed classification
enum PresentationSpeed {
  deadSlow,
  slow,
  moderate,
  moderateFast,
  fast,
}

extension PresentationSpeedX on PresentationSpeed {
  String get displayName {
    switch (this) {
      case PresentationSpeed.deadSlow:
        return 'Dead Slow';
      case PresentationSpeed.slow:
        return 'Slow';
      case PresentationSpeed.moderate:
        return 'Moderate';
      case PresentationSpeed.moderateFast:
        return 'Moderate-Fast';
      case PresentationSpeed.fast:
        return 'Fast';
    }
  }
}

/// Geographic fishing region (determines forage base)
enum FishingRegion {
  south,     // < 34N
  midSouth,  // 34-37N
  midwest,   // 37-43N
  north,     // > 43N (west of -80W)
  northeast, // > 38N and east of -80W
}

extension FishingRegionX on FishingRegion {
  String get displayName {
    switch (this) {
      case FishingRegion.south:
        return 'South';
      case FishingRegion.midSouth:
        return 'Mid-South';
      case FishingRegion.midwest:
        return 'Midwest';
      case FishingRegion.north:
        return 'North';
      case FishingRegion.northeast:
        return 'Northeast';
    }
  }
}

/// Fishing pressure level
enum FishingPressure {
  none,
  light,
  moderate,
  heavy,
  tournament,
}

extension FishingPressureX on FishingPressure {
  String get displayName {
    switch (this) {
      case FishingPressure.none:
        return 'None';
      case FishingPressure.light:
        return 'Light';
      case FishingPressure.moderate:
        return 'Moderate';
      case FishingPressure.heavy:
        return 'Heavy';
      case FishingPressure.tournament:
        return 'Tournament';
    }
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// Complete Match the Hatch recommendation output
class HatchRecommendation {
  final HatchBaitPick primary;
  final List<HatchBaitPick> alternatives;
  final String reasoning;
  final ForageContext forage;
  final ProTip proTip;
  final List<ProductSuggestion> products;
  final HatchConditions conditions;
  final DateTime generatedAt;

  const HatchRecommendation({
    required this.primary,
    required this.alternatives,
    required this.reasoning,
    required this.forage,
    required this.proTip,
    required this.products,
    required this.conditions,
    required this.generatedAt,
  });
}

/// A single bait pick with full detail
class HatchBaitPick {
  final String baitType;
  final BaitCategory baitCategory;
  final String baitSize;
  final String jigWeight;
  final String colorName;
  final ColorCategory colorCategory;
  final String technique;
  final PresentationSpeed speed;
  final double depthMin;
  final double depthMax;
  final double confidence;
  final List<String> reasons;

  const HatchBaitPick({
    required this.baitType,
    required this.baitCategory,
    required this.baitSize,
    required this.jigWeight,
    required this.colorName,
    required this.colorCategory,
    required this.technique,
    required this.speed,
    required this.depthMin,
    required this.depthMax,
    required this.confidence,
    required this.reasons,
  });

  String get depthRange => '${depthMin.round()}-${depthMax.round()} ft';
}

/// What crappie are eating context
class ForageContext {
  final String species;
  final String size;
  final String seasonalNote;

  const ForageContext({
    required this.species,
    required this.size,
    required this.seasonalNote,
  });
}

/// Expert pro tip with attribution
class ProTip {
  final String text;
  final String source;

  const ProTip({
    required this.text,
    required this.source,
  });
}

/// Specific product suggestion
class ProductSuggestion {
  final String name;
  final String brand;
  final String color;
  final String size;

  const ProductSuggestion({
    required this.name,
    required this.brand,
    required this.color,
    required this.size,
  });
}

/// All conditions used to generate the recommendation
class HatchConditions {
  final double waterTempF;
  final WaterClarity clarity;
  final CrappieSeason season;
  final TimeOfDay timeOfDay;
  final FishingRegion region;
  final double? airTempF;
  final double? pressureMb;
  final String? pressureTrend;
  final double? windSpeedMph;
  final int? windDirectionDeg;
  final double? solunarRating;
  final double? targetDepthFt;
  final FishingPressure? fishingPressure;

  const HatchConditions({
    required this.waterTempF,
    required this.clarity,
    required this.season,
    required this.timeOfDay,
    required this.region,
    this.airTempF,
    this.pressureMb,
    this.pressureTrend,
    this.windSpeedMph,
    this.windDirectionDeg,
    this.solunarRating,
    this.targetDepthFt,
    this.fishingPressure,
  });
}
