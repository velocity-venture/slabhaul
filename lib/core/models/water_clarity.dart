/// Water Clarity Estimation Models
///
/// Science-based clarity estimation algorithm that considers:
/// - Recent precipitation (rain stirs up sediment)
/// - Wind speed/direction (wind mixing affects clarity)
/// - Inflow rates (high runoff = murky)
/// - Season (spring runoff vs summer clarity)
/// - Lake-specific baseline characteristics
/// - Days since last significant rain event
///
/// Visibility ranges (based on Secchi disk measurements):
/// - Crystal: 8+ ft (rare - only after extended dry/calm periods)
/// - Clear: 5-8 ft (typical summer, low rainfall)
/// - Light Stain: 3-5 ft (normal TVA reservoir conditions)
/// - Stained: 1-3 ft (after rain, spring runoff, windy periods)
/// - Muddy: <1 ft (heavy rain, flood conditions, major inflow)
library;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Water clarity levels with visibility ranges
enum ClarityLevel {
  crystal,     // 8+ ft visibility - exceptional, rare
  clear,       // 5-8 ft visibility - great conditions
  lightStain,  // 3-5 ft visibility - typical/good
  stained,     // 1-3 ft visibility - reduced but fishable
  muddy,       // <1 ft visibility - challenging conditions
}

extension ClarityLevelX on ClarityLevel {
  String get displayName {
    switch (this) {
      case ClarityLevel.crystal:
        return 'Crystal Clear';
      case ClarityLevel.clear:
        return 'Clear';
      case ClarityLevel.lightStain:
        return 'Light Stain';
      case ClarityLevel.stained:
        return 'Stained';
      case ClarityLevel.muddy:
        return 'Muddy';
    }
  }
  
  String get icon {
    switch (this) {
      case ClarityLevel.crystal:
        return '💎';
      case ClarityLevel.clear:
        return '🔵';
      case ClarityLevel.lightStain:
        return '🟢';
      case ClarityLevel.stained:
        return '🟤';
      case ClarityLevel.muddy:
        return '🟫';
    }
  }
  
  String get visibilityRange {
    switch (this) {
      case ClarityLevel.crystal:
        return '8+ ft';
      case ClarityLevel.clear:
        return '5-8 ft';
      case ClarityLevel.lightStain:
        return '3-5 ft';
      case ClarityLevel.stained:
        return '1-3 ft';
      case ClarityLevel.muddy:
        return '<1 ft';
    }
  }
  
  /// Approximate visibility in feet for calculations
  double get visibilityFt {
    switch (this) {
      case ClarityLevel.crystal:
        return 10.0;
      case ClarityLevel.clear:
        return 6.5;
      case ClarityLevel.lightStain:
        return 4.0;
      case ClarityLevel.stained:
        return 2.0;
      case ClarityLevel.muddy:
        return 0.5;
    }
  }
  
  /// Map display color (hex RGB)
  int get mapColor {
    switch (this) {
      case ClarityLevel.crystal:
        return 0xFF38BDF8; // Sky blue
      case ClarityLevel.clear:
        return 0xFF3B82F6; // Blue
      case ClarityLevel.lightStain:
        return 0xFF22C55E; // Green
      case ClarityLevel.stained:
        return 0xFF84CC16; // Yellow-green
      case ClarityLevel.muddy:
        return 0xFFA16207; // Brown
    }
  }
  
  /// Fishing description for this clarity level
  String get fishingDescription {
    switch (this) {
      case ClarityLevel.crystal:
        return 'Ultra-finesse required. Use light line, natural colors, and subtle presentations. Fish can see everything.';
      case ClarityLevel.clear:
        return 'Natural colors work well. Fish can be line-shy. Dawn/dusk produce best. Translucent shad patterns excel.';
      case ClarityLevel.lightStain:
        return 'Ideal conditions for most techniques. Chartreuse combos and pearl work well. Fish are less wary.';
      case ClarityLevel.stained:
        return 'Use brighter colors and vibration. Chartreuse, white, and orange stand out. Rattling baits help.';
      case ClarityLevel.muddy:
        return 'Go bold! Bright chartreuse, white, or black. Use scent and vibration. Fish locate by feel, not sight.';
    }
  }
  
  /// Recommended bait colors for this clarity
  List<String> get recommendedColors {
    switch (this) {
      case ClarityLevel.crystal:
        return ['Ghost/Pearl', 'Smoke/Silver', 'Translucent Shad', 'Watermelon'];
      case ClarityLevel.clear:
        return ['Natural Shad', 'Pearl', 'Blue Ice', 'Smoke/Pepper'];
      case ClarityLevel.lightStain:
        return ['Monkey Milk', 'Pearl/Chartreuse', 'Threadfin', 'Junebug'];
      case ClarityLevel.stained:
        return ['Chartreuse/White', 'Electric Chicken', 'Orange/Chartreuse', 'Hot Pink'];
      case ClarityLevel.muddy:
        return ['Chartreuse', 'White', 'Black', 'Fluorescent Orange'];
    }
  }
}

/// Lake zones that typically have different clarity characteristics
enum LakeZoneType {
  mainChannel,    // Deepest, often clearest
  openBay,        // Mid-clarity
  creekArm,       // Variable, often stained after rain
  upperReservoir, // Near inflows, often murkiest
  lowerDam,       // Near dam, typically clearest
  cove,           // Sheltered, can be stained
  shallow,        // Wind-affected, variable
}

extension LakeZoneTypeX on LakeZoneType {
  String get displayName {
    switch (this) {
      case LakeZoneType.mainChannel:
        return 'Main Channel';
      case LakeZoneType.openBay:
        return 'Open Bay';
      case LakeZoneType.creekArm:
        return 'Creek Arm';
      case LakeZoneType.upperReservoir:
        return 'Upper Reservoir';
      case LakeZoneType.lowerDam:
        return 'Lower (Dam)';
      case LakeZoneType.cove:
        return 'Cove';
      case LakeZoneType.shallow:
        return 'Shallow Flat';
    }
  }
  
  /// Baseline clarity modifier (1.0 = average lake clarity)
  /// >1.0 = typically clearer than average
  /// <1.0 = typically more stained than average
  double get baselineClarityModifier {
    switch (this) {
      case LakeZoneType.mainChannel:
        return 1.15;
      case LakeZoneType.openBay:
        return 1.05;
      case LakeZoneType.creekArm:
        return 0.80;
      case LakeZoneType.upperReservoir:
        return 0.70;
      case LakeZoneType.lowerDam:
        return 1.20;
      case LakeZoneType.cove:
        return 0.90;
      case LakeZoneType.shallow:
        return 0.85;
    }
  }
  
  /// How much rain affects this zone (higher = more impact)
  double get rainSensitivity {
    switch (this) {
      case LakeZoneType.mainChannel:
        return 0.6;
      case LakeZoneType.openBay:
        return 0.7;
      case LakeZoneType.creekArm:
        return 1.4;
      case LakeZoneType.upperReservoir:
        return 1.5;
      case LakeZoneType.lowerDam:
        return 0.5;
      case LakeZoneType.cove:
        return 0.9;
      case LakeZoneType.shallow:
        return 1.2;
    }
  }
  
  /// How much wind affects this zone (higher = more mixing)
  double get windSensitivity {
    switch (this) {
      case LakeZoneType.mainChannel:
        return 0.5;
      case LakeZoneType.openBay:
        return 1.2;
      case LakeZoneType.creekArm:
        return 0.8;
      case LakeZoneType.upperReservoir:
        return 1.0;
      case LakeZoneType.lowerDam:
        return 0.6;
      case LakeZoneType.cove:
        return 0.4;
      case LakeZoneType.shallow:
        return 1.5;
    }
  }
}

/// Confidence level for clarity estimates
enum ClarityConfidence {
  high,    // Recent weather data, typical conditions
  medium,  // Some uncertainty, transitioning conditions
  low,     // Limited data or unusual conditions
}

extension ClarityConfidenceX on ClarityConfidence {
  String get displayName {
    switch (this) {
      case ClarityConfidence.high:
        return 'High';
      case ClarityConfidence.medium:
        return 'Medium';
      case ClarityConfidence.low:
        return 'Low';
    }
  }
  
  String get explanation {
    switch (this) {
      case ClarityConfidence.high:
        return 'Recent weather patterns are well understood; estimate is reliable.';
      case ClarityConfidence.medium:
        return 'Weather is transitional; actual clarity may vary from estimate.';
      case ClarityConfidence.low:
        return 'Limited data or unusual conditions; use estimate as general guidance.';
    }
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// Factors that affect water clarity estimation
class ClarityFactors {
  /// Total precipitation in last 24 hours (mm)
  final double precipitation24h;
  
  /// Total precipitation in last 72 hours (mm)
  final double precipitation72h;
  
  /// Days since significant rain (>10mm)
  final int daysSinceRain;
  
  /// Current wind speed (mph)
  final double windSpeedMph;
  
  /// Average wind speed over last 24h (mph)
  final double windSpeed24hAvg;
  
  /// Current season (affects runoff and base clarity)
  final int month;
  
  /// Lake-specific baseline clarity (visibility in ft)
  final double lakeBaselineClarity;
  
  /// Zone type within the lake
  final LakeZoneType? zoneType;
  
  /// Lake depth (shallow lakes mix more easily)
  final double? averageDepthFt;
  
  const ClarityFactors({
    required this.precipitation24h,
    required this.precipitation72h,
    required this.daysSinceRain,
    required this.windSpeedMph,
    required this.windSpeed24hAvg,
    required this.month,
    required this.lakeBaselineClarity,
    this.zoneType,
    this.averageDepthFt,
  });
  
  /// Create factors with defaults for when data is unavailable
  factory ClarityFactors.defaults({
    double? lakeBaselineClarity,
    int? month,
  }) {
    return ClarityFactors(
      precipitation24h: 0,
      precipitation72h: 0,
      daysSinceRain: 7,
      windSpeedMph: 5,
      windSpeed24hAvg: 5,
      month: month ?? DateTime.now().month,
      lakeBaselineClarity: lakeBaselineClarity ?? 4.0,
    );
  }
  
  /// Check if conditions suggest recent weather impact
  bool get hasRecentRain => precipitation24h > 5 || daysSinceRain < 3;
  
  bool get hasSignificantRain => precipitation24h > 15 || precipitation72h > 30;
  
  bool get isWindy => windSpeedMph > 15;
  
  bool get isVeryWindy => windSpeedMph > 25;
  
  /// Spring runoff period (typically March-May)
  bool get isSpringRunoff => month >= 3 && month <= 5;
  
  /// Dry summer period (typically July-September)
  bool get isDrySeason => month >= 7 && month <= 9;
}

/// A water clarity estimate with confidence and explanation
class ClarityEstimate {
  /// The estimated clarity level
  final ClarityLevel level;
  
  /// Approximate visibility in feet
  final double visibilityFt;
  
  /// Confidence in the estimate
  final ClarityConfidence confidence;
  
  /// Human-readable explanation of why this clarity was estimated
  final List<String> reasons;
  
  /// Factors used to calculate this estimate
  final ClarityFactors factors;
  
  /// When this estimate was generated
  final DateTime estimatedAt;
  
  /// Trend: is clarity expected to improve or worsen?
  final ClarityTrend trend;
  
  const ClarityEstimate({
    required this.level,
    required this.visibilityFt,
    required this.confidence,
    required this.reasons,
    required this.factors,
    required this.estimatedAt,
    required this.trend,
  });
  
  /// Get fishing recommendations based on clarity
  String get fishingAdvice => level.fishingDescription;
  
  /// Get recommended colors for this clarity
  List<String> get recommendedColors => level.recommendedColors;
}

/// Clarity trend direction
enum ClarityTrend {
  improving,  // Clearing up (days since rain increasing, wind calming)
  stable,     // No significant change expected
  worsening,  // Getting muddier (rain incoming, wind increasing)
}

extension ClarityTrendX on ClarityTrend {
  String get displayName {
    switch (this) {
      case ClarityTrend.improving:
        return 'Improving';
      case ClarityTrend.stable:
        return 'Stable';
      case ClarityTrend.worsening:
        return 'Worsening';
    }
  }
  
  String get icon {
    switch (this) {
      case ClarityTrend.improving:
        return '📈';
      case ClarityTrend.stable:
        return '➡️';
      case ClarityTrend.worsening:
        return '📉';
    }
  }
  
  String get description {
    switch (this) {
      case ClarityTrend.improving:
        return 'Water should clear up over the next few days';
      case ClarityTrend.stable:
        return 'Clarity expected to remain similar';
      case ClarityTrend.worsening:
        return 'Expect reduced visibility in coming days';
    }
  }
}

/// A zone within a lake with its own clarity characteristics
class ClarityZone {
  /// Unique identifier
  final String id;
  
  /// Display name
  final String name;
  
  /// Lake this zone belongs to
  final String lakeId;
  
  /// Zone type (affects baseline and sensitivity)
  final LakeZoneType type;
  
  /// Center coordinates
  final double centerLat;
  final double centerLon;
  
  /// Polygon points defining the zone boundary (lat/lon pairs)
  final List<List<double>> boundary;
  
  /// Baseline clarity for this zone (visibility in ft under normal conditions)
  final double baselineClarity;
  
  /// Average depth of this zone
  final double? avgDepthFt;
  
  /// Notes about this zone's clarity behavior
  final String? notes;
  
  /// Current estimated clarity (populated by service)
  final ClarityEstimate? currentClarity;
  
  const ClarityZone({
    required this.id,
    required this.name,
    required this.lakeId,
    required this.type,
    required this.centerLat,
    required this.centerLon,
    required this.boundary,
    required this.baselineClarity,
    this.avgDepthFt,
    this.notes,
    this.currentClarity,
  });
  
  factory ClarityZone.fromJson(Map<String, dynamic> json) {
    return ClarityZone(
      id: json['id'] as String,
      name: json['name'] as String,
      lakeId: json['lake_id'] as String,
      type: _parseZoneType(json['type'] as String? ?? 'open_bay'),
      centerLat: (json['center_lat'] as num).toDouble(),
      centerLon: (json['center_lon'] as num).toDouble(),
      boundary: (json['boundary'] as List<dynamic>)
          .map((p) => (p as List<dynamic>).map((c) => (c as num).toDouble()).toList())
          .toList(),
      baselineClarity: (json['baseline_clarity'] as num?)?.toDouble() ?? 4.0,
      avgDepthFt: (json['avg_depth_ft'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lake_id': lakeId,
    'type': type.name,
    'center_lat': centerLat,
    'center_lon': centerLon,
    'boundary': boundary,
    'baseline_clarity': baselineClarity,
    'avg_depth_ft': avgDepthFt,
    'notes': notes,
  };
  
  /// Create a copy with updated clarity
  ClarityZone withClarity(ClarityEstimate clarity) {
    return ClarityZone(
      id: id,
      name: name,
      lakeId: lakeId,
      type: type,
      centerLat: centerLat,
      centerLon: centerLon,
      boundary: boundary,
      baselineClarity: baselineClarity,
      avgDepthFt: avgDepthFt,
      notes: notes,
      currentClarity: clarity,
    );
  }
  
  static LakeZoneType _parseZoneType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'main_channel':
        return LakeZoneType.mainChannel;
      case 'creek_arm':
        return LakeZoneType.creekArm;
      case 'upper_reservoir':
      case 'upper':
        return LakeZoneType.upperReservoir;
      case 'lower_dam':
      case 'dam':
        return LakeZoneType.lowerDam;
      case 'cove':
        return LakeZoneType.cove;
      case 'shallow':
        return LakeZoneType.shallow;
      case 'open_bay':
      default:
        return LakeZoneType.openBay;
    }
  }
}

/// Lake-level clarity profile with baseline characteristics
class LakeClarityProfile {
  final String lakeId;
  final String lakeName;
  
  /// Typical baseline clarity under normal conditions (visibility in ft)
  final double baselineClarity;
  
  /// Lake classification for clarity behavior
  final LakeClarityClass clarityClass;
  
  /// Average depth affects wind mixing susceptibility
  final double? avgDepthFt;
  
  /// Major inflows that bring sediment
  final List<String> majorInflows;
  
  /// How quickly this lake clears after rain (days)
  final int typicalClearingDays;
  
  /// Whether generation affects clarity (TVA dams)
  final bool affectedByGeneration;
  
  /// Clarity zones within this lake
  final List<ClarityZone> zones;
  
  const LakeClarityProfile({
    required this.lakeId,
    required this.lakeName,
    required this.baselineClarity,
    required this.clarityClass,
    this.avgDepthFt,
    this.majorInflows = const [],
    this.typicalClearingDays = 5,
    this.affectedByGeneration = false,
    this.zones = const [],
  });
  
  factory LakeClarityProfile.fromJson(Map<String, dynamic> json) {
    return LakeClarityProfile(
      lakeId: json['lake_id'] as String,
      lakeName: json['lake_name'] as String,
      baselineClarity: (json['baseline_clarity'] as num?)?.toDouble() ?? 4.0,
      clarityClass: _parseClarityClass(json['clarity_class'] as String? ?? 'typical'),
      avgDepthFt: (json['avg_depth_ft'] as num?)?.toDouble(),
      majorInflows: (json['major_inflows'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
      typicalClearingDays: json['typical_clearing_days'] as int? ?? 5,
      affectedByGeneration: json['affected_by_generation'] as bool? ?? false,
      zones: (json['zones'] as List<dynamic>?)
          ?.map((z) => ClarityZone.fromJson(z as Map<String, dynamic>)).toList() ?? [],
    );
  }
  
  static LakeClarityClass _parseClarityClass(String classStr) {
    switch (classStr.toLowerCase()) {
      case 'clear':
        return LakeClarityClass.clear;
      case 'stained':
        return LakeClarityClass.stained;
      case 'variable':
        return LakeClarityClass.variable;
      case 'typical':
      default:
        return LakeClarityClass.typical;
    }
  }
}

/// Classification of lake's typical clarity behavior
enum LakeClarityClass {
  clear,     // Generally clear (deep, minimal inflow) e.g., Dale Hollow
  typical,   // Normal TVA reservoir behavior
  stained,   // Typically stained (shallow, lots of inflow)
  variable,  // Highly variable by location/season
}

extension LakeClarityClassX on LakeClarityClass {
  String get displayName {
    switch (this) {
      case LakeClarityClass.clear:
        return 'Generally Clear';
      case LakeClarityClass.typical:
        return 'Typical';
      case LakeClarityClass.stained:
        return 'Often Stained';
      case LakeClarityClass.variable:
        return 'Highly Variable';
    }
  }
  
  double get baselineModifier {
    switch (this) {
      case LakeClarityClass.clear:
        return 1.3;
      case LakeClarityClass.typical:
        return 1.0;
      case LakeClarityClass.stained:
        return 0.7;
      case LakeClarityClass.variable:
        return 0.9;
    }
  }
}
