import 'dart:math';
import '../models/thermocline_data.dart';
import '../models/lake.dart';
import '../models/lake_conditions.dart';
import '../models/weather_data.dart';
import '../utils/thermocline_constants.dart';

/// Service for predicting thermocline depth and generating fishing recommendations
/// 
/// The thermocline is the transition layer in a lake where temperature drops
/// rapidly with depth. Crappie concentrate near this layer in summer because
/// it marks the boundary between warm, oxygenated surface water and cold,
/// oxygen-depleted deep water.
class ThermoclineService {
  /// Predict thermocline depth and generate fishing recommendation
  /// 
  /// Uses a combination of:
  /// - Current water temperature (from USGS or estimated)
  /// - Weather history (for degree-day calculations)
  /// - Wind conditions (affects mixing depth)
  /// - Lake characteristics (depth, area, latitude)
  /// - Seasonal timing
  Future<ThermoclineData> predictThermocline({
    required Lake lake,
    required WeatherData weather,
    required LakeConditions conditions,
    DateTime? date,
  }) async {
    final now = date ?? DateTime.now();
    final dayOfYear = now.dayOfYear;
    
    // Step 1: Determine stratification status
    final status = _determineStatus(
      surfaceTemp: conditions.waterTempF,
      latitude: lake.centerLat,
      dayOfYear: dayOfYear,
      lakeDepth: lake.maxDepthFt,
    );
    
    // If lake is mixed, return early
    if (status == StratificationStatus.mixed) {
      return _createMixedResult(conditions);
    }
    
    // Step 2: Calculate cumulative heating (degree days)
    final degreeDays = _calculateDegreeDays(weather);
    
    // Step 3: Base thermocline depth from empirical model
    double baseDepth = _calculateBaseDepth(
      surfaceTemp: conditions.waterTempF ?? 75,
      degreeDays: degreeDays,
      latitude: lake.centerLat,
      maxLakeDepth: lake.maxDepthFt,
    );
    
    // Step 4: Wind mixing adjustment
    final windAdj = _calculateWindAdjustment(weather, lake.surfaceAreaAcres);
    baseDepth += windAdj;
    
    // Ensure depth stays in valid range
    baseDepth = baseDepth.clamp(
      ThermoclineModel.minDepthFt, 
      ThermoclineModel.maxDepthFt,
    );
    
    // Step 5: Calculate confidence
    final confidence = _calculateConfidence(
      hasUsgsTemp: conditions.waterTempF != null,
      dataAge: conditions.lastUpdated,
      hasLakeDepth: lake.maxDepthFt != null,
      degreeDays: degreeDays,
    );
    
    // Step 6: Target depth (crappie hold 0-5ft above thermocline)
    final targetMin = max(
      CrappieBehavior.minTargetDepthFt,
      baseDepth - CrappieBehavior.holdAboveThermoclineFt,
    );
    final targetMax = baseDepth;
    
    // Step 7: Generate recommendation
    final recommendation = _generateRecommendation(
      status: status,
      targetMin: targetMin,
      targetMax: targetMax,
      surfaceTemp: conditions.waterTempF,
    );
    
    return ThermoclineData(
      thermoclineTopFt: baseDepth,
      thermoclineBottomFt: baseDepth + ThermoclineModel.typicalThicknessFt,
      targetDepthMinFt: targetMin,
      targetDepthMaxFt: targetMax,
      surfaceTempF: conditions.waterTempF ?? 75,
      thermoclineTempF: _estimateThermoclineTemp(conditions.waterTempF),
      confidence: confidence,
      status: status,
      recommendation: recommendation,
      factors: _gatherFactors(conditions, weather, lake, now),
      generatedAt: now,
    );
  }
  
  /// Determine the current stratification status of the lake
  StratificationStatus _determineStatus({
    required double? surfaceTemp,
    required double latitude,
    required int dayOfYear,
    required double? lakeDepth,
  }) {
    // Shallow lakes don't form stable thermoclines
    if (lakeDepth != null && lakeDepth < kMinStratificationDepthFt) {
      return StratificationStatus.mixed;
    }
    
    // Too cold = no stratification
    if (surfaceTemp != null && surfaceTemp < WaterTempThresholds.mixedMax) {
      return StratificationStatus.mixed;
    }
    
    // Latitude-adjusted seasonal windows
    final latOffset = ((latitude - SeasonBoundaries.baselineLatitude) * 
        SeasonBoundaries.latitudeShiftPerDegree).round();
    
    final formingStart = SeasonBoundaries.formingStart + latOffset;
    final stratifiedStart = SeasonBoundaries.stratifiedStart + latOffset;
    final breakingStart = SeasonBoundaries.breakingStart + latOffset;
    final mixedStart = SeasonBoundaries.mixedStart + latOffset;
    
    // Winter: clearly mixed
    if (dayOfYear < formingStart || dayOfYear >= mixedStart) {
      return StratificationStatus.mixed;
    }
    
    // Spring: forming phase
    if (dayOfYear < stratifiedStart) {
      return (surfaceTemp ?? 0) >= WaterTempThresholds.formingMin
          ? StratificationStatus.forming
          : StratificationStatus.mixed;
    }
    
    // Summer: stratified phase
    if (dayOfYear < breakingStart) {
      return (surfaceTemp ?? 0) >= WaterTempThresholds.stratifiedMin
          ? StratificationStatus.stratified
          : StratificationStatus.forming;
    }
    
    // Fall: breaking phase
    return StratificationStatus.breaking;
  }
  
  /// Calculate cumulative degree days from weather data
  /// 
  /// Degree days = sum of (daily_avg_temp - base_temp) for days where avg > base
  double _calculateDegreeDays(WeatherData weather) {
    double sum = 0;
    for (final day in weather.daily) {
      final avg = (day.highF + day.lowF) / 2;
      if (avg > kDegreeDayBaseTemp) {
        sum += avg - kDegreeDayBaseTemp;
      }
    }
    // Extrapolate from forecast period to ~90 day estimate
    // This is a rough approximation; could be improved with historical data
    final daysInForecast = weather.daily.length;
    if (daysInForecast > 0) {
      return sum * (90 / daysInForecast);
    }
    return sum * 13; // Fallback multiplier
  }
  
  /// Calculate base thermocline depth from empirical model
  double _calculateBaseDepth({
    required double surfaceTemp,
    required double degreeDays,
    required double latitude,
    required double? maxLakeDepth,
  }) {
    // Empirical model calibrated from EPA lake data
    // Thermocline deepens as summer progresses
    double depth = ThermoclineModel.baseDepthFt + 
        (degreeDays / ThermoclineModel.degreeDaysPerFoot);
    
    // Hot surface = shallower thermocline (steep gradient forms faster)
    if (surfaceTemp > WaterTempThresholds.hotSurface) {
      depth -= (surfaceTemp - WaterTempThresholds.hotSurface) * 
          ThermoclineModel.hotSurfaceAdjustment;
    }
    
    // Northern adjustment (less heating = shallower)
    depth -= (latitude - SeasonBoundaries.baselineLatitude) * 
        ThermoclineModel.latitudeAdjustment;
    
    // Constrain to lake max depth
    if (maxLakeDepth != null) {
      depth = min(depth, maxLakeDepth * ThermoclineModel.maxDepthFraction);
    }
    
    return depth.clamp(
      ThermoclineModel.minDepthFt, 
      ThermoclineModel.maxDepthFt,
    );
  }
  
  /// Calculate wind mixing adjustment
  /// 
  /// Wind deepens the mixed layer (pushes thermocline down)
  double _calculateWindAdjustment(WeatherData weather, double? surfaceArea) {
    // Calculate 48h average and max wind from hourly data
    final last48h = weather.hourly.take(48).toList();
    if (last48h.isEmpty) return 0;
    
    final winds = last48h.map((h) => h.windSpeedMph).toList();
    final avgWind = winds.reduce((a, b) => a + b) / winds.length;
    final maxWind = winds.reduce(max);
    
    double adj = 0;
    
    // Sustained moderate wind deepens thermocline
    if (avgWind > WindMixing.thresholdMph) {
      adj += (avgWind - WindMixing.thresholdMph) * 
          WindMixing.sustainedAdjustmentPerMph;
    }
    
    // Peak winds have additional temporary effect
    if (maxWind > WindMixing.gustThresholdMph) {
      adj += (maxWind - WindMixing.gustThresholdMph) * 
          WindMixing.gustAdjustmentPerMph;
    }
    
    // Larger lakes have more fetch = more wind effect
    if (surfaceArea != null && surfaceArea > WindMixing.largeLakeThresholdAcres) {
      adj *= WindMixing.largeLakeMultiplier;
    }
    
    return adj.clamp(0, WindMixing.maxAdjustmentFt);
  }
  
  /// Calculate prediction confidence based on available data
  double _calculateConfidence({
    required bool hasUsgsTemp,
    required DateTime? dataAge,
    required bool hasLakeDepth,
    required double degreeDays,
  }) {
    double confidence = ConfidenceWeights.base;
    
    // Real water temp data is the most valuable
    if (hasUsgsTemp) confidence += ConfidenceWeights.usgsTemp;
    
    // Fresh data is more reliable
    if (dataAge != null) {
      final age = DateTime.now().difference(dataAge);
      if (age.inHours < 24) {
        confidence += ConfidenceWeights.freshData;
      } else if (age.inHours < 48) {
        confidence += ConfidenceWeights.recentData;
      }
    }
    
    // Known lake depth improves accuracy
    if (hasLakeDepth) confidence += ConfidenceWeights.knownDepth;
    
    // Peak summer is more predictable
    if (degreeDays > 800) confidence += ConfidenceWeights.peakSummer;
    
    return confidence.clamp(
      ConfidenceWeights.minimum, 
      ConfidenceWeights.maximum,
    );
  }
  
  /// Estimate thermocline temperature from surface temperature
  double _estimateThermoclineTemp(double? surfaceTemp) {
    // Thermocline is typically 10-15°F cooler than surface
    return (surfaceTemp ?? 75) - kThermoclineTempOffsetF;
  }
  
  /// Generate human-readable fishing recommendation
  String _generateRecommendation({
    required StratificationStatus status,
    required double targetMin,
    required double targetMax,
    required double? surfaceTemp,
  }) {
    switch (status) {
      case StratificationStatus.mixed:
        return "Lake is mixed — crappie can be at any depth. "
               "Focus on structure and cover.";
      
      case StratificationStatus.forming:
        return "Thermocline forming. Try ${targetMin.round()}-${targetMax.round()}ft, "
               "but check shallower structure too. Fish still transitioning.";
      
      case StratificationStatus.stratified:
        final hot = (surfaceTemp ?? 0) > WaterTempThresholds.hotSurface
            ? " Surface is hot — fish deeper."
            : "";
        return "Target ${targetMin.round()}-${targetMax.round()}ft over deep water.$hot "
               "Suspended crappie will be near the thermocline.";
      
      case StratificationStatus.breaking:
        return "Fall turnover beginning. Patterns unpredictable — "
               "try ${targetMin.round()}-${targetMax.round()}ft but check multiple depths.";
    }
  }
  
  /// Gather factors that influenced the prediction
  List<String> _gatherFactors(
    LakeConditions conditions,
    WeatherData weather,
    Lake lake,
    DateTime date,
  ) {
    return [
      if (conditions.waterTempF != null)
        "Surface: ${conditions.waterTempF!.round()}°F",
      "Wind: ${weather.current.windSpeedMph.round()} mph",
      "Season: ${_seasonLabel(date.dayOfYear)}",
      if (lake.maxDepthFt != null)
        "Max depth: ${lake.maxDepthFt!.round()}ft",
    ];
  }
  
  /// Get season label from day of year
  String _seasonLabel(int dayOfYear) {
    if (dayOfYear < SeasonBoundaries.formingStart) return "Winter";
    if (dayOfYear < SeasonBoundaries.stratifiedStart) return "Spring";
    if (dayOfYear < SeasonBoundaries.breakingStart) return "Summer";
    if (dayOfYear < SeasonBoundaries.mixedStart) return "Fall";
    return "Winter";
  }
  
  /// Create result for a mixed (non-stratified) lake
  ThermoclineData _createMixedResult(LakeConditions conditions) {
    return ThermoclineData(
      thermoclineTopFt: 0,
      thermoclineBottomFt: 0,
      targetDepthMinFt: 5,
      targetDepthMaxFt: 30,
      surfaceTempF: conditions.waterTempF ?? 55,
      thermoclineTempF: conditions.waterTempF ?? 55,
      confidence: 0.9, // High confidence that it's mixed
      status: StratificationStatus.mixed,
      recommendation: "Lake is mixed — crappie can be at any depth. "
                      "Focus on structure and cover.",
      factors: ["No thermocline present"],
      generatedAt: DateTime.now(),
    );
  }
}

/// Extension to get day of year from DateTime
extension DateTimeDayOfYear on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
