/// Represents a known productive fishing location for crappie.
/// 
/// Hotspots are specific areas that have historically produced fish
/// under certain conditions. Unlike attractors (man-made structures),
/// hotspots represent natural features or areas with proven track records.
class FishingHotspot {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String lakeId;
  final String lakeName;
  final String structureType; // brush_pile, bridge_piling, dock, creek_channel, point, timber, flat, etc.
  final String description;
  final double minDepthFt;
  final double maxDepthFt;
  final List<String> bestSeasons; // spawn, post_spawn, summer, fall, winter
  final List<String> techniques; // spider_rigging, vertical_jigging, casting, slip_float, tight_lining
  final HotspotConditions idealConditions;
  final String? notes;
  final int? confidenceScore; // 1-100 based on data quality
  
  const FishingHotspot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.lakeId,
    required this.lakeName,
    required this.structureType,
    required this.description,
    required this.minDepthFt,
    required this.maxDepthFt,
    required this.bestSeasons,
    required this.techniques,
    required this.idealConditions,
    this.notes,
    this.confidenceScore,
  });

  factory FishingHotspot.fromJson(Map<String, dynamic> json) {
    return FishingHotspot(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      lakeId: json['lake_id'] as String,
      lakeName: json['lake_name'] as String,
      structureType: json['structure_type'] as String,
      description: json['description'] as String,
      minDepthFt: (json['min_depth_ft'] as num).toDouble(),
      maxDepthFt: (json['max_depth_ft'] as num).toDouble(),
      bestSeasons: (json['best_seasons'] as List).cast<String>(),
      techniques: (json['techniques'] as List).cast<String>(),
      idealConditions: HotspotConditions.fromJson(
        json['ideal_conditions'] as Map<String, dynamic>,
      ),
      notes: json['notes'] as String?,
      confidenceScore: json['confidence_score'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'lake_id': lakeId,
    'lake_name': lakeName,
    'structure_type': structureType,
    'description': description,
    'min_depth_ft': minDepthFt,
    'max_depth_ft': maxDepthFt,
    'best_seasons': bestSeasons,
    'techniques': techniques,
    'ideal_conditions': idealConditions.toJson(),
    'notes': notes,
    'confidence_score': confidenceScore,
  };

  String get structureLabel {
    switch (structureType) {
      case 'brush_pile':
        return 'Brush Pile Complex';
      case 'bridge_piling':
        return 'Bridge Pilings';
      case 'dock':
        return 'Dock/Marina';
      case 'creek_channel':
        return 'Creek Channel';
      case 'point':
        return 'Main Lake Point';
      case 'timber':
        return 'Standing Timber';
      case 'flat':
        return 'Spawning Flat';
      case 'ledge':
        return 'Channel Ledge';
      case 'hump':
        return 'Submerged Hump';
      case 'riprap':
        return 'Riprap Bank';
      default:
        return structureType;
    }
  }

  String get depthRangeString => '${minDepthFt.toInt()}-${maxDepthFt.toInt()} ft';

  String get coordinateString =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get seasonString => bestSeasons.map(_seasonLabel).join(', ');

  static String _seasonLabel(String season) {
    switch (season) {
      case 'spawn':
        return 'Spawn';
      case 'pre_spawn':
        return 'Pre-Spawn';
      case 'post_spawn':
        return 'Post-Spawn';
      case 'summer':
        return 'Summer';
      case 'fall':
        return 'Fall';
      case 'winter':
        return 'Winter';
      default:
        return season;
    }
  }

  String get techniqueString => techniques.map(techniqueLabel).join(', ');

  static String techniqueLabel(String technique) {
    switch (technique) {
      case 'spider_rigging':
        return 'Spider Rigging';
      case 'vertical_jigging':
        return 'Vertical Jigging';
      case 'casting':
        return 'Casting';
      case 'slip_float':
        return 'Slip Float';
      case 'tight_lining':
        return 'Tight-Lining';
      case 'shooting_docks':
        return 'Shooting Docks';
      case 'trolling':
        return 'Trolling';
      case 'long_lining':
        return 'Long-Lining';
      default:
        return technique;
    }
  }
}

/// Ideal conditions for when a hotspot is most productive.
class HotspotConditions {
  final double? minWaterTempF;
  final double? maxWaterTempF;
  final String? waterLevelTrend; // rising, falling, stable
  final String? pressureTrend; // rising, falling, stable
  final String? timeOfDay; // early_morning, midday, evening, night
  final int? minCloudCover; // 0-100%
  final int? maxCloudCover; // 0-100%
  final double? maxWindMph;
  final String? preferredWindDirection; // N, S, E, W, NE, NW, SE, SW

  const HotspotConditions({
    this.minWaterTempF,
    this.maxWaterTempF,
    this.waterLevelTrend,
    this.pressureTrend,
    this.timeOfDay,
    this.minCloudCover,
    this.maxCloudCover,
    this.maxWindMph,
    this.preferredWindDirection,
  });

  factory HotspotConditions.fromJson(Map<String, dynamic> json) {
    return HotspotConditions(
      minWaterTempF: (json['min_water_temp_f'] as num?)?.toDouble(),
      maxWaterTempF: (json['max_water_temp_f'] as num?)?.toDouble(),
      waterLevelTrend: json['water_level_trend'] as String?,
      pressureTrend: json['pressure_trend'] as String?,
      timeOfDay: json['time_of_day'] as String?,
      minCloudCover: json['min_cloud_cover'] as int?,
      maxCloudCover: json['max_cloud_cover'] as int?,
      maxWindMph: (json['max_wind_mph'] as num?)?.toDouble(),
      preferredWindDirection: json['preferred_wind_direction'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'min_water_temp_f': minWaterTempF,
    'max_water_temp_f': maxWaterTempF,
    'water_level_trend': waterLevelTrend,
    'pressure_trend': pressureTrend,
    'time_of_day': timeOfDay,
    'min_cloud_cover': minCloudCover,
    'max_cloud_cover': maxCloudCover,
    'max_wind_mph': maxWindMph,
    'preferred_wind_direction': preferredWindDirection,
  };
}

/// Result of scoring a hotspot against current conditions.
class HotspotRating {
  final FishingHotspot hotspot;
  final double overallScore; // 0.0 - 1.0
  final double seasonScore;
  final double temperatureScore;
  final double waterLevelScore;
  final double timeOfDayScore;
  final double weatherScore;
  final String ratingLabel; // Excellent, Good, Fair, Poor, Off-Season
  final List<String> whyGoodNow; // Reasons this spot is performing well
  final List<String> concerns; // Potential negatives
  final List<String> suggestedTechniques; // Best techniques for current conditions

  const HotspotRating({
    required this.hotspot,
    required this.overallScore,
    required this.seasonScore,
    required this.temperatureScore,
    required this.waterLevelScore,
    required this.timeOfDayScore,
    required this.weatherScore,
    required this.ratingLabel,
    required this.whyGoodNow,
    required this.concerns,
    required this.suggestedTechniques,
  });

  int get matchPercentage => (overallScore * 100).round();

  bool get isExcellent => overallScore >= 0.8;
  bool get isGood => overallScore >= 0.6 && overallScore < 0.8;
  bool get isFair => overallScore >= 0.4 && overallScore < 0.6;
  bool get isPoor => overallScore < 0.4;
}

/// Represents the current conditions used for scoring.
class CurrentConditions {
  final String season; // spawn, post_spawn, summer, fall, winter
  final double? waterTempF;
  final String? waterLevelTrend; // rising, falling, stable
  final String? pressureTrend; // rising, falling, stable
  final int hourOfDay; // 0-23
  final double? windSpeedMph;
  final int? windDirectionDeg;
  final double? pressureMb;
  final int? cloudCover; // 0-100

  const CurrentConditions({
    required this.season,
    this.waterTempF,
    this.waterLevelTrend,
    this.pressureTrend,
    required this.hourOfDay,
    this.windSpeedMph,
    this.windDirectionDeg,
    this.pressureMb,
    this.cloudCover,
  });

  String get timeOfDay {
    if (hourOfDay >= 5 && hourOfDay < 9) return 'early_morning';
    if (hourOfDay >= 9 && hourOfDay < 16) return 'midday';
    if (hourOfDay >= 16 && hourOfDay < 20) return 'evening';
    return 'night';
  }

  String? get windDirection {
    if (windDirectionDeg == null) return null;
    final deg = windDirectionDeg!;
    if (deg >= 337.5 || deg < 22.5) return 'N';
    if (deg >= 22.5 && deg < 67.5) return 'NE';
    if (deg >= 67.5 && deg < 112.5) return 'E';
    if (deg >= 112.5 && deg < 157.5) return 'SE';
    if (deg >= 157.5 && deg < 202.5) return 'S';
    if (deg >= 202.5 && deg < 247.5) return 'SW';
    if (deg >= 247.5 && deg < 292.5) return 'W';
    return 'NW';
  }

  /// Estimates water temperature from air temperature if not provided.
  /// Uses a lagged relationship where water temp follows air temp slowly.
  static double estimateWaterTemp(double airTempF) {
    // Rough estimation - water temp lags and moderates
    // This is a simplified model; real water temp depends on many factors
    if (airTempF < 40) return airTempF + 5; // Water warmer than cold air
    if (airTempF > 85) return airTempF - 10; // Water cooler than hot air
    return airTempF - 3; // Slight lag in moderate temps
  }
}
