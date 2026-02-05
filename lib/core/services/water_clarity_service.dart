import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/water_clarity.dart';
import '../models/weather_data.dart';
import '../utils/app_logger.dart';

/// Water Clarity Estimation Service
/// 
/// Estimates water clarity based on weather conditions since satellite
/// imagery APIs typically require paid subscriptions. This algorithmic
/// approach provides reasonable estimates by analyzing:
/// 
/// **Primary factors:**
/// - Recent precipitation (rain stirs up sediment)
/// - Wind conditions (wind mixing affects clarity)
/// - Days since last significant rain
/// 
/// **Secondary factors:**
/// - Seasonal patterns (spring runoff, summer stability)
/// - Lake-specific characteristics (depth, inflows)
/// - Zone type (creek arms murkier than main channel)
/// 
/// The model is intentionally explainable - users understand why
/// clarity is estimated at a certain level.
class WaterClarityService {
  
  // Cache for lake profiles
  static List<LakeClarityProfile>? _cachedProfiles;
  
  /// Estimate water clarity based on weather data
  /// 
  /// This is the main entry point for clarity estimation.
  ClarityEstimate estimateClarity({
    required WeatherData weather,
    required double lakeBaselineClarity,
    LakeZoneType? zoneType,
    double? avgDepthFt,
    double? forecastPrecipitation24h,
  }) {
    // Extract factors from weather data
    final factors = _extractFactors(
      weather: weather,
      lakeBaselineClarity: lakeBaselineClarity,
      zoneType: zoneType,
      avgDepthFt: avgDepthFt,
    );
    
    // Calculate base visibility
    double visibility = _calculateBaseVisibility(factors);
    
    // Apply modifiers
    visibility = _applyPrecipitationModifier(visibility, factors);
    visibility = _applyWindModifier(visibility, factors);
    visibility = _applySeasonalModifier(visibility, factors);
    visibility = _applyZoneModifier(visibility, factors);
    visibility = _applyDepthModifier(visibility, factors);
    
    // Clamp to reasonable range
    visibility = visibility.clamp(0.3, 12.0);
    
    // Determine clarity level from visibility
    final level = _visibilityToLevel(visibility);
    
    // Calculate confidence
    final confidence = _calculateConfidence(factors, weather);
    
    // Generate human-readable reasons
    final reasons = _generateReasons(factors, level);
    
    // Determine trend
    final trend = _determineTrend(factors, forecastPrecipitation24h);
    
    return ClarityEstimate(
      level: level,
      visibilityFt: visibility,
      confidence: confidence,
      reasons: reasons,
      factors: factors,
      estimatedAt: DateTime.now(),
      trend: trend,
    );
  }
  
  /// Estimate clarity for a specific zone with its own characteristics
  ClarityEstimate estimateClarityForZone({
    required ClarityZone zone,
    required WeatherData weather,
    double? forecastPrecipitation24h,
  }) {
    return estimateClarity(
      weather: weather,
      lakeBaselineClarity: zone.baselineClarity,
      zoneType: zone.type,
      avgDepthFt: zone.avgDepthFt,
      forecastPrecipitation24h: forecastPrecipitation24h,
    );
  }
  
  /// Get clarity estimates for all zones in a lake
  List<ClarityZone> estimateClarityForLake({
    required LakeClarityProfile profile,
    required WeatherData weather,
    double? forecastPrecipitation24h,
  }) {
    if (profile.zones.isEmpty) {
      return [];
    }
    
    return profile.zones.map((zone) {
      final clarity = estimateClarityForZone(
        zone: zone,
        weather: weather,
        forecastPrecipitation24h: forecastPrecipitation24h,
      );
      return zone.withClarity(clarity);
    }).toList();
  }
  
  /// Load lake clarity profiles from assets
  Future<List<LakeClarityProfile>> loadLakeProfiles() async {
    if (_cachedProfiles != null) return _cachedProfiles!;
    
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/clarity_zones.json',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final lakes = data['lakes'] as List<dynamic>;
      
      _cachedProfiles = lakes
          .map((l) => LakeClarityProfile.fromJson(l as Map<String, dynamic>))
          .toList();
      
      return _cachedProfiles!;
    } catch (e, st) {
      AppLogger.error('WaterClarityService', 'loadLakeProfiles', e, st);
      return [];
    }
  }
  
  /// Get lake profile by ID
  Future<LakeClarityProfile?> getLakeProfile(String lakeId) async {
    final profiles = await loadLakeProfiles();
    try {
      return profiles.firstWhere((p) => p.lakeId == lakeId);
    } catch (_) {
      AppLogger.warn('WaterClarityService', 'No profile found for lake: $lakeId');
      return null;
    }
  }
  
  // ---------------------------------------------------------------------------
  // Private calculation methods
  // ---------------------------------------------------------------------------
  
  ClarityFactors _extractFactors({
    required WeatherData weather,
    required double lakeBaselineClarity,
    LakeZoneType? zoneType,
    double? avgDepthFt,
  }) {
    // Calculate 24h precipitation from hourly data
    double precip24h = 0;
    final now = DateTime.now();
    for (final hour in weather.hourly) {
      if (hour.time.isAfter(now.subtract(const Duration(hours: 24))) &&
          hour.time.isBefore(now)) {
        precip24h += hour.precipitationMm;
      }
    }
    
    // Calculate 72h precipitation from daily data
    double precip72h = 0;
    for (int i = 0; i < weather.daily.length && i < 3; i++) {
      precip72h += weather.daily[i].precipitationMm;
    }
    
    // Calculate days since significant rain (>10mm)
    int daysSinceRain = 7; // Default to a week if no recent rain
    for (int i = 0; i < weather.daily.length; i++) {
      if (weather.daily[i].precipitationMm >= 10) {
        daysSinceRain = i;
        break;
      }
    }
    
    // Calculate 24h average wind
    double windSum = 0;
    int windCount = 0;
    for (final hour in weather.hourly) {
      if (hour.time.isAfter(now.subtract(const Duration(hours: 24)))) {
        windSum += hour.windSpeedMph;
        windCount++;
      }
    }
    final wind24hAvg = windCount > 0 ? windSum / windCount : weather.current.windSpeedMph;
    
    return ClarityFactors(
      precipitation24h: precip24h,
      precipitation72h: precip72h,
      daysSinceRain: daysSinceRain,
      windSpeedMph: weather.current.windSpeedMph,
      windSpeed24hAvg: wind24hAvg,
      month: now.month,
      lakeBaselineClarity: lakeBaselineClarity,
      zoneType: zoneType,
      averageDepthFt: avgDepthFt,
    );
  }
  
  double _calculateBaseVisibility(ClarityFactors factors) {
    // Start with lake's baseline clarity
    return factors.lakeBaselineClarity;
  }
  
  double _applyPrecipitationModifier(double visibility, ClarityFactors factors) {
    // Recent rain reduces visibility significantly
    if (factors.precipitation24h > 0) {
      // Heavy rain (>25mm): major impact
      if (factors.precipitation24h > 25) {
        visibility *= 0.40;
      }
      // Moderate rain (10-25mm): significant impact
      else if (factors.precipitation24h > 10) {
        visibility *= 0.55;
      }
      // Light rain (5-10mm): moderate impact
      else if (factors.precipitation24h > 5) {
        visibility *= 0.70;
      }
      // Trace rain (<5mm): minor impact
      else {
        visibility *= 0.85;
      }
    }
    
    // Past 72h rain also matters (sediment takes time to clear)
    if (factors.precipitation72h > 50) {
      visibility *= 0.75;
    } else if (factors.precipitation72h > 25) {
      visibility *= 0.85;
    }
    
    // Clarity improves as days since rain increases
    if (factors.daysSinceRain >= 5) {
      visibility *= 1.15; // Clearing up nicely
    } else if (factors.daysSinceRain >= 3) {
      visibility *= 1.05;
    } else if (factors.daysSinceRain == 0) {
      visibility *= 0.90; // Still settling
    }
    
    return visibility;
  }
  
  double _applyWindModifier(double visibility, ClarityFactors factors) {
    // Apply zone sensitivity if available
    double sensitivity = factors.zoneType?.windSensitivity ?? 1.0;
    
    // Strong wind mixes water, reduces clarity
    if (factors.windSpeedMph > 25) {
      // Very high wind: significant mixing
      visibility *= (1.0 - 0.30 * sensitivity);
    } else if (factors.windSpeedMph > 15) {
      // High wind: moderate mixing
      visibility *= (1.0 - 0.15 * sensitivity);
    } else if (factors.windSpeedMph > 10) {
      // Moderate wind: slight effect
      visibility *= (1.0 - 0.05 * sensitivity);
    }
    // Light wind: no penalty
    
    // Sustained wind matters more than gusts
    if (factors.windSpeed24hAvg > 15) {
      visibility *= 0.90; // Additional penalty for sustained wind
    }
    
    return visibility;
  }
  
  double _applySeasonalModifier(double visibility, ClarityFactors factors) {
    // Spring runoff (March-May): typically murkier
    if (factors.month >= 3 && factors.month <= 5) {
      visibility *= 0.85;
    }
    // Summer (July-September): typically clearest
    else if (factors.month >= 7 && factors.month <= 9) {
      visibility *= 1.10;
    }
    // Fall turnover (October-November): variable
    else if (factors.month >= 10 && factors.month <= 11) {
      visibility *= 0.95;
    }
    
    return visibility;
  }
  
  double _applyZoneModifier(double visibility, ClarityFactors factors) {
    if (factors.zoneType == null) return visibility;
    
    // Apply zone-specific baseline modifier
    visibility *= factors.zoneType!.baselineClarityModifier;
    
    // Apply zone-specific rain sensitivity for recent rain
    if (factors.hasRecentRain) {
      final rainPenalty = 1.0 - (0.1 * factors.zoneType!.rainSensitivity);
      visibility *= rainPenalty.clamp(0.6, 1.0);
    }
    
    return visibility;
  }
  
  double _applyDepthModifier(double visibility, ClarityFactors factors) {
    if (factors.averageDepthFt == null) return visibility;
    
    final depth = factors.averageDepthFt!;
    
    // Shallow areas (<15ft) mix more easily
    if (depth < 15) {
      // More wind impact on shallow areas
      if (factors.isWindy) {
        visibility *= 0.85;
      }
      // But they also clear faster when calm
      if (!factors.isWindy && factors.daysSinceRain > 3) {
        visibility *= 1.05;
      }
    }
    // Deep areas (>40ft) are generally more stable
    else if (depth > 40) {
      visibility *= 1.05;
    }
    
    return visibility;
  }
  
  ClarityLevel _visibilityToLevel(double visibilityFt) {
    if (visibilityFt >= 8.0) return ClarityLevel.crystal;
    if (visibilityFt >= 5.0) return ClarityLevel.clear;
    if (visibilityFt >= 3.0) return ClarityLevel.lightStain;
    if (visibilityFt >= 1.0) return ClarityLevel.stained;
    return ClarityLevel.muddy;
  }
  
  ClarityConfidence _calculateConfidence(
    ClarityFactors factors,
    WeatherData weather,
  ) {
    // Confidence is high when conditions are stable and recent
    
    // Check data freshness
    final dataAge = DateTime.now().difference(weather.fetchedAt);
    if (dataAge.inHours > 6) {
      return ClarityConfidence.low;
    }
    
    // Transitional conditions reduce confidence
    if (factors.hasSignificantRain && factors.daysSinceRain <= 1) {
      return ClarityConfidence.medium; // Still settling
    }
    
    // Very windy conditions are harder to predict
    if (factors.isVeryWindy) {
      return ClarityConfidence.medium;
    }
    
    // Spring conditions are variable
    if (factors.isSpringRunoff) {
      return ClarityConfidence.medium;
    }
    
    return ClarityConfidence.high;
  }
  
  List<String> _generateReasons(ClarityFactors factors, ClarityLevel level) {
    final reasons = <String>[];
    
    // Explain precipitation impact
    if (factors.hasSignificantRain) {
      if (factors.precipitation24h > 25) {
        reasons.add('Heavy rain in the last 24h significantly reduced clarity');
      } else if (factors.precipitation24h > 10) {
        reasons.add('Moderate rain in the last 24h has stained the water');
      } else if (factors.precipitation72h > 25) {
        reasons.add('Rain over the past few days is still affecting clarity');
      }
    } else if (factors.daysSinceRain >= 5) {
      reasons.add('No significant rain in ${factors.daysSinceRain} days - water has had time to clear');
    }
    
    // Explain wind impact
    if (factors.isVeryWindy) {
      reasons.add('Strong winds are mixing the water and reducing visibility');
    } else if (factors.isWindy) {
      reasons.add('Moderate winds are causing some water mixing');
    } else if (!factors.hasRecentRain && factors.windSpeedMph < 10) {
      reasons.add('Calm winds helping maintain clarity');
    }
    
    // Explain seasonal impact
    if (factors.isSpringRunoff) {
      reasons.add('Spring runoff typically brings higher turbidity');
    } else if (factors.isDrySeason) {
      reasons.add('Summer dry season typically means better clarity');
    }
    
    // Explain zone impact
    if (factors.zoneType != null) {
      switch (factors.zoneType!) {
        case LakeZoneType.creekArm:
          reasons.add('Creek arms typically receive more runoff');
          break;
        case LakeZoneType.upperReservoir:
          reasons.add('Upper reservoir areas are closest to inflows');
          break;
        case LakeZoneType.lowerDam:
          reasons.add('Near-dam areas typically have the clearest water');
          break;
        case LakeZoneType.shallow:
          reasons.add('Shallow areas are more susceptible to wind mixing');
          break;
        case LakeZoneType.mainChannel:
          reasons.add('Main channel typically has more stable clarity');
          break;
        default:
          break;
      }
    }
    
    // Add overall summary
    if (reasons.isEmpty) {
      reasons.add('Normal conditions for this lake and time of year');
    }
    
    return reasons;
  }
  
  ClarityTrend _determineTrend(
    ClarityFactors factors,
    double? forecastPrecipitation,
  ) {
    // Check if rain is forecast
    final rainForecast = forecastPrecipitation ?? 0;
    
    if (rainForecast > 15) {
      return ClarityTrend.worsening;
    }
    
    // Check if currently recovering from rain
    if (factors.hasRecentRain && factors.daysSinceRain >= 1) {
      if (rainForecast < 5 && !factors.isWindy) {
        return ClarityTrend.improving;
      }
    }
    
    // Check if winds are calming
    if (factors.isWindy && factors.windSpeed24hAvg > factors.windSpeedMph * 1.2) {
      return ClarityTrend.improving;
    }
    
    // Check if conditions are getting worse
    if (!factors.hasRecentRain && rainForecast > 5) {
      return ClarityTrend.worsening;
    }
    
    return ClarityTrend.stable;
  }
  
  // ---------------------------------------------------------------------------
  // Utility methods for external use
  // ---------------------------------------------------------------------------
  
  /// Get a simple clarity estimate using minimal data
  /// Useful when full weather data isn't available
  ClarityEstimate estimateClaritySimple({
    required double precipitation24hMm,
    required double windSpeedMph,
    required int daysSinceSignificantRain,
    double lakeBaselineClarity = 4.0,
    LakeZoneType? zoneType,
  }) {
    final factors = ClarityFactors(
      precipitation24h: precipitation24hMm,
      precipitation72h: precipitation24hMm * 1.5,
      daysSinceRain: daysSinceSignificantRain,
      windSpeedMph: windSpeedMph,
      windSpeed24hAvg: windSpeedMph,
      month: DateTime.now().month,
      lakeBaselineClarity: lakeBaselineClarity,
      zoneType: zoneType,
    );
    
    double visibility = _calculateBaseVisibility(factors);
    visibility = _applyPrecipitationModifier(visibility, factors);
    visibility = _applyWindModifier(visibility, factors);
    visibility = _applySeasonalModifier(visibility, factors);
    visibility = _applyZoneModifier(visibility, factors);
    visibility = visibility.clamp(0.3, 12.0);
    
    final level = _visibilityToLevel(visibility);
    final reasons = _generateReasons(factors, level);
    
    return ClarityEstimate(
      level: level,
      visibilityFt: visibility,
      confidence: ClarityConfidence.medium, // Lower confidence without full data
      reasons: reasons,
      factors: factors,
      estimatedAt: DateTime.now(),
      trend: ClarityTrend.stable, // Can't determine trend without forecast
    );
  }
  
  /// Convert from the bait engine's WaterClarity enum to ClarityLevel
  /// This allows integration with existing bait recommendation system
  static ClarityLevel fromBaitEngineClarity(int index) {
    // WaterClarity: clear=0, lightStain=1, stained=2, muddy=3
    switch (index) {
      case 0:
        return ClarityLevel.clear; // Treat bait engine "clear" as clear
      case 1:
        return ClarityLevel.lightStain;
      case 2:
        return ClarityLevel.stained;
      case 3:
        return ClarityLevel.muddy;
      default:
        return ClarityLevel.lightStain;
    }
  }
  
  /// Convert ClarityLevel to bait engine WaterClarity index
  static int toBaitEngineClarity(ClarityLevel level) {
    switch (level) {
      case ClarityLevel.crystal:
      case ClarityLevel.clear:
        return 0; // clear
      case ClarityLevel.lightStain:
        return 1; // lightStain
      case ClarityLevel.stained:
        return 2; // stained
      case ClarityLevel.muddy:
        return 3; // muddy
    }
  }
}
