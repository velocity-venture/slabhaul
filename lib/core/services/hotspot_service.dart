import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/fishing_hotspot.dart';
import '../utils/app_logger.dart';
import 'supabase_service.dart';

/// Service for loading and scoring fishing hotspots based on current conditions.
class HotspotService {
  List<FishingHotspot>? _cachedHotspots;

  /// Loads all hotspots, optionally filtered by lake.
  Future<List<FishingHotspot>> getHotspots({String? lakeId}) async {
    if (_cachedHotspots != null) {
      return lakeId == null
          ? _cachedHotspots!
          : _cachedHotspots!.where((h) => h.lakeId == lakeId).toList();
    }

    // Try Supabase first
    if (SupabaseService.isAvailable) {
      try {
        var query = SupabaseService.client!.from('hotspots').select();
        if (lakeId != null) {
          query = query.eq('lake_id', lakeId);
        }
        final data = await query;
        _cachedHotspots =
            (data as List).map((e) => FishingHotspot.fromJson(e)).toList();
        return _cachedHotspots!;
      } catch (e, st) {
        AppLogger.error('HotspotService', 'getHotspots (Supabase)', e, st);
      }
    }

    // Fall back to local JSON
    return _loadLocalHotspots(lakeId: lakeId);
  }

  Future<List<FishingHotspot>> _loadLocalHotspots({String? lakeId}) async {
    final jsonStr = await rootBundle.loadString('assets/data/hotspots.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final hotspotsJson = data['hotspots'] as List;
    _cachedHotspots =
        hotspotsJson.map((e) => FishingHotspot.fromJson(e)).toList();

    if (lakeId != null) {
      return _cachedHotspots!.where((h) => h.lakeId == lakeId).toList();
    }
    return _cachedHotspots!;
  }

  /// Scores all hotspots against current conditions and returns ranked ratings.
  /// 
  /// Scoring weights:
  /// - Season match: 30%
  /// - Temperature match: 25%
  /// - Water level trend: 15%
  /// - Time of day: 15%
  /// - Weather/pressure: 15%
  List<HotspotRating> scoreHotspots(
    List<FishingHotspot> hotspots,
    CurrentConditions conditions,
  ) {
    final ratings = hotspots.map((hotspot) {
      return _scoreHotspot(hotspot, conditions);
    }).toList();

    // Sort by overall score descending
    ratings.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    return ratings;
  }

  HotspotRating _scoreHotspot(
    FishingHotspot hotspot,
    CurrentConditions conditions,
  ) {
    // Calculate individual scores (0.0 - 1.0)
    final seasonScore = _calculateSeasonScore(hotspot, conditions);
    final temperatureScore = _calculateTemperatureScore(hotspot, conditions);
    final waterLevelScore = _calculateWaterLevelScore(hotspot, conditions);
    final timeOfDayScore = _calculateTimeOfDayScore(hotspot, conditions);
    final weatherScore = _calculateWeatherScore(hotspot, conditions);

    // Weighted average
    final overallScore = (seasonScore * 0.30) +
        (temperatureScore * 0.25) +
        (waterLevelScore * 0.15) +
        (timeOfDayScore * 0.15) +
        (weatherScore * 0.15);

    // Determine rating label
    String ratingLabel;
    if (seasonScore < 0.2) {
      ratingLabel = 'Off-Season';
    } else if (overallScore >= 0.8) {
      ratingLabel = 'Excellent';
    } else if (overallScore >= 0.6) {
      ratingLabel = 'Good';
    } else if (overallScore >= 0.4) {
      ratingLabel = 'Fair';
    } else {
      ratingLabel = 'Poor';
    }

    // Build reasons and concerns
    final whyGoodNow = <String>[];
    final concerns = <String>[];

    // Season reasoning
    if (seasonScore >= 0.8) {
      whyGoodNow.add('Peak season for this structure type');
    } else if (seasonScore >= 0.5) {
      whyGoodNow.add('Good seasonal timing');
    } else if (seasonScore < 0.3) {
      concerns.add('Not ideal season - fish may have moved');
    }

    // Temperature reasoning
    if (temperatureScore >= 0.8) {
      whyGoodNow.add('Water temperature in ideal range');
    } else if (temperatureScore < 0.4) {
      concerns.add('Water temperature outside optimal range');
    }

    // Time of day reasoning
    if (timeOfDayScore >= 0.8) {
      whyGoodNow.add('Prime time of day for this spot');
    }

    // Water level reasoning
    if (waterLevelScore >= 0.8 &&
        hotspot.idealConditions.waterLevelTrend != null) {
      whyGoodNow
          .add('Water level trend (${conditions.waterLevelTrend}) is ideal');
    } else if (waterLevelScore < 0.4 &&
        hotspot.idealConditions.waterLevelTrend != null) {
      concerns.add(
          'Preferred water level is ${hotspot.idealConditions.waterLevelTrend}');
    }

    // Weather reasoning
    if (weatherScore >= 0.8) {
      whyGoodNow.add('Weather conditions are favorable');
    } else if (weatherScore < 0.4) {
      if (conditions.windSpeedMph != null &&
          hotspot.idealConditions.maxWindMph != null &&
          conditions.windSpeedMph! > hotspot.idealConditions.maxWindMph!) {
        concerns.add('Wind exceeds recommended maximum');
      }
    }

    // Suggest techniques based on conditions
    final suggestedTechniques = _suggestTechniques(hotspot, conditions);

    return HotspotRating(
      hotspot: hotspot,
      overallScore: overallScore,
      seasonScore: seasonScore,
      temperatureScore: temperatureScore,
      waterLevelScore: waterLevelScore,
      timeOfDayScore: timeOfDayScore,
      weatherScore: weatherScore,
      ratingLabel: ratingLabel,
      whyGoodNow: whyGoodNow,
      concerns: concerns,
      suggestedTechniques: suggestedTechniques,
    );
  }

  double _calculateSeasonScore(
    FishingHotspot hotspot,
    CurrentConditions conditions,
  ) {
    if (hotspot.bestSeasons.contains(conditions.season)) {
      return 1.0;
    }

    // Give partial credit for adjacent seasons
    const seasonOrder = [
      'winter',
      'pre_spawn',
      'spawn',
      'post_spawn',
      'summer',
      'fall'
    ];
    final currentIdx = seasonOrder.indexOf(conditions.season);
    if (currentIdx == -1) return 0.5; // Unknown season

    for (final season in hotspot.bestSeasons) {
      final seasonIdx = seasonOrder.indexOf(season);
      if (seasonIdx == -1) continue;

      final distance = (currentIdx - seasonIdx).abs();
      // Wrap around for winter/fall adjacency
      final wrappedDistance =
          distance > 3 ? seasonOrder.length - distance : distance;

      if (wrappedDistance == 1) return 0.5;
      if (wrappedDistance == 2) return 0.25;
    }

    return 0.1;
  }

  double _calculateTemperatureScore(
    FishingHotspot hotspot,
    CurrentConditions conditions,
  ) {
    final waterTemp = conditions.waterTempF;
    if (waterTemp == null) return 0.6; // Neutral if no data

    final minTemp = hotspot.idealConditions.minWaterTempF;
    final maxTemp = hotspot.idealConditions.maxWaterTempF;

    if (minTemp == null && maxTemp == null) return 0.6; // No preference

    // Check if in range
    if (minTemp != null && maxTemp != null) {
      if (waterTemp >= minTemp && waterTemp <= maxTemp) {
        // Perfect match - calculate how close to center
        final center = (minTemp + maxTemp) / 2;
        final range = (maxTemp - minTemp) / 2;
        final distanceFromCenter = (waterTemp - center).abs();
        return 1.0 - (distanceFromCenter / range) * 0.2; // 0.8 - 1.0 in range
      }

      // Outside range - penalize based on distance
      if (waterTemp < minTemp) {
        final diff = minTemp - waterTemp;
        return (1.0 - diff / 20).clamp(0.0, 0.6);
      } else {
        final diff = waterTemp - maxTemp;
        return (1.0 - diff / 20).clamp(0.0, 0.6);
      }
    }

    // Single bound
    if (minTemp != null && waterTemp >= minTemp) return 0.8;
    if (maxTemp != null && waterTemp <= maxTemp) return 0.8;

    return 0.4;
  }

  double _calculateWaterLevelScore(
    FishingHotspot hotspot,
    CurrentConditions conditions,
  ) {
    final idealTrend = hotspot.idealConditions.waterLevelTrend;
    if (idealTrend == null) return 0.7; // No preference
    if (conditions.waterLevelTrend == null) return 0.5; // No data

    if (conditions.waterLevelTrend == idealTrend) return 1.0;
    if (conditions.waterLevelTrend == 'stable') return 0.6; // Stable is okay

    return 0.3;
  }

  double _calculateTimeOfDayScore(
    FishingHotspot hotspot,
    CurrentConditions conditions,
  ) {
    final idealTime = hotspot.idealConditions.timeOfDay;
    if (idealTime == null) return 0.7; // No preference

    if (conditions.timeOfDay == idealTime) return 1.0;

    // Adjacent times get partial credit
    const timeOrder = ['night', 'early_morning', 'midday', 'evening'];
    final currentIdx = timeOrder.indexOf(conditions.timeOfDay);
    final idealIdx = timeOrder.indexOf(idealTime);

    if (currentIdx == -1 || idealIdx == -1) return 0.5;

    final distance = (currentIdx - idealIdx).abs();
    final wrappedDistance = distance > 2 ? timeOrder.length - distance : distance;

    if (wrappedDistance == 1) return 0.6;
    return 0.3;
  }

  double _calculateWeatherScore(
    FishingHotspot hotspot,
    CurrentConditions conditions,
  ) {
    var score = 0.7; // Start neutral
    var factors = 0;

    // Wind speed
    final maxWind = hotspot.idealConditions.maxWindMph;
    if (maxWind != null && conditions.windSpeedMph != null) {
      factors++;
      if (conditions.windSpeedMph! <= maxWind) {
        score += 0.3;
      } else {
        final excess = conditions.windSpeedMph! - maxWind;
        score -= (excess / 20).clamp(0.0, 0.5);
      }
    }

    // Pressure trend
    final idealPressure = hotspot.idealConditions.pressureTrend;
    if (idealPressure != null && conditions.pressureTrend != null) {
      factors++;
      if (conditions.pressureTrend == idealPressure) {
        score += 0.3;
      } else if (conditions.pressureTrend == 'stable') {
        score += 0.1;
      }
    }

    // Cloud cover
    final minCloud = hotspot.idealConditions.minCloudCover;
    final maxCloud = hotspot.idealConditions.maxCloudCover;
    if (conditions.cloudCover != null &&
        (minCloud != null || maxCloud != null)) {
      factors++;
      final cloud = conditions.cloudCover!;
      if ((minCloud == null || cloud >= minCloud) &&
          (maxCloud == null || cloud <= maxCloud)) {
        score += 0.2;
      }
    }

    // Wind direction
    final prefWindDir = hotspot.idealConditions.preferredWindDirection;
    if (prefWindDir != null && conditions.windDirection != null) {
      factors++;
      if (conditions.windDirection == prefWindDir) {
        score += 0.2;
      }
    }

    // Normalize based on factors considered
    if (factors > 0) {
      return (score / (0.7 + factors * 0.3)).clamp(0.0, 1.0);
    }
    return score;
  }

  List<String> _suggestTechniques(
    FishingHotspot hotspot,
    CurrentConditions conditions,
  ) {
    final suggestions = <String>[];

    // Filter techniques based on conditions
    for (final technique in hotspot.techniques) {
      // Vertical jigging works better in cold water or low light
      if (technique == 'vertical_jigging') {
        if ((conditions.waterTempF != null && conditions.waterTempF! < 60) ||
            conditions.timeOfDay == 'night' ||
            conditions.timeOfDay == 'early_morning') {
          suggestions.insert(0, FishingHotspot.techniqueLabel(technique));
        } else {
          suggestions.add(FishingHotspot.techniqueLabel(technique));
        }
        continue;
      }

      // Spider rigging best for active fish in moderate temps
      if (technique == 'spider_rigging') {
        if (conditions.waterTempF != null &&
            conditions.waterTempF! >= 55 &&
            conditions.waterTempF! <= 75) {
          suggestions.insert(0, FishingHotspot.techniqueLabel(technique));
        } else {
          suggestions.add(FishingHotspot.techniqueLabel(technique));
        }
        continue;
      }

      // Slip float for shallow/spawn conditions
      if (technique == 'slip_float') {
        if (hotspot.maxDepthFt <= 10 ||
            conditions.season == 'spawn' ||
            conditions.season == 'pre_spawn') {
          suggestions.insert(0, FishingHotspot.techniqueLabel(technique));
        } else {
          suggestions.add(FishingHotspot.techniqueLabel(technique));
        }
        continue;
      }

      // Shooting docks for sunny, hot conditions
      if (technique == 'shooting_docks') {
        if (conditions.timeOfDay == 'midday' &&
            (conditions.cloudCover == null || conditions.cloudCover! < 50)) {
          suggestions.insert(0, FishingHotspot.techniqueLabel(technique));
        } else {
          suggestions.add(FishingHotspot.techniqueLabel(technique));
        }
        continue;
      }

      suggestions.add(FishingHotspot.techniqueLabel(technique));
    }

    return suggestions.take(3).toList();
  }

  void clearCache() {
    _cachedHotspots = null;
  }
}
