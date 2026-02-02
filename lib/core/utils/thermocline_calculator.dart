import 'dart:math';
import '../models/thermocline_data.dart';

/// Thermocline depth predictor using empirical modeling
/// 
/// This calculator estimates thermocline depth based on:
/// - Surface water temperature
/// - Air temperature (affects heat input)
/// - Wind speed (affects mixing depth)
/// - Day of year (seasonal stratification patterns)
/// - Lake characteristics (max depth, surface area)
/// 
/// Model is based on limnological research on temperate lakes.
class ThermoclineCalculator {
  
  /// Calculate thermocline prediction for given conditions
  static ThermoclineData calculate({
    required double surfaceTempF,
    required double airTempF,
    required double windSpeedMph,
    required DateTime date,
    required double maxLakeDepthFt,
    double? lakeAreaAcres,
  }) {
    // Convert to metric for calculations
    final surfaceTempC = (surfaceTempF - 32) * 5 / 9;
    final windSpeedMs = windSpeedMph * 0.44704;
    final maxDepthM = maxLakeDepthFt * 0.3048;
    
    // Determine stratification status based on temperature and season
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final status = _determineStatus(surfaceTempC, dayOfYear);
    
    // If not stratified, return mixed-lake response
    if (status == StratificationStatus.mixed) {
      return ThermoclineData(
        thermoclineTopFt: 0,
        thermoclineBottomFt: 0,
        targetDepthMinFt: 5,
        targetDepthMaxFt: min(25.0, maxLakeDepthFt * 0.6),
        surfaceTempF: surfaceTempF,
        thermoclineTempF: surfaceTempF,
        confidence: 0.7,
        status: status,
        recommendation: 'Lake is mixed. Fish the water column from shallow to mid-depths. Focus on structure and cover.',
        factors: ['Water temperature below stratification threshold', 'Seasonal timing'],
        generatedAt: DateTime.now(),
      );
    }
    
    // Calculate thermocline depth using empirical formula
    // Base depth influenced by surface temp and wind mixing
    double thermoclineDepthM = _calculateThermoclineDepth(
      surfaceTempC: surfaceTempC,
      windSpeedMs: windSpeedMs,
      dayOfYear: dayOfYear,
      maxDepthM: maxDepthM,
    );
    
    // Convert back to feet
    double thermoclineTopFt = thermoclineDepthM * 3.28084;
    double thermoclineBottomFt = (thermoclineDepthM + 3) * 3.28084; // ~3m thick thermocline
    
    // Clamp to reasonable values
    thermoclineTopFt = thermoclineTopFt.clamp(8, maxLakeDepthFt * 0.7);
    thermoclineBottomFt = thermoclineBottomFt.clamp(thermoclineTopFt + 3, maxLakeDepthFt * 0.85);
    
    // Target depth is just above thermocline where oxygen is still good
    final targetDepthMinFt = max(thermoclineTopFt - 5, 8.0);
    final targetDepthMaxFt = thermoclineTopFt + 2;
    
    // Estimate thermocline temperature (typically 65-72°F in summer)
    final thermoclineTempF = _estimateThermoclineTemp(surfaceTempF, thermoclineTopFt);
    
    // Calculate confidence based on data quality
    final confidence = _calculateConfidence(
      surfaceTempF: surfaceTempF,
      windSpeedMph: windSpeedMph,
      status: status,
    );
    
    // Generate factors list
    final factors = _generateFactors(
      surfaceTempF: surfaceTempF,
      windSpeedMph: windSpeedMph,
      dayOfYear: dayOfYear,
      thermoclineTopFt: thermoclineTopFt,
    );
    
    // Generate recommendation
    final recommendation = _generateRecommendation(
      status: status,
      targetDepthMinFt: targetDepthMinFt,
      targetDepthMaxFt: targetDepthMaxFt,
      surfaceTempF: surfaceTempF,
      windSpeedMph: windSpeedMph,
    );
    
    return ThermoclineData(
      thermoclineTopFt: thermoclineTopFt,
      thermoclineBottomFt: thermoclineBottomFt,
      targetDepthMinFt: targetDepthMinFt,
      targetDepthMaxFt: targetDepthMaxFt,
      surfaceTempF: surfaceTempF,
      thermoclineTempF: thermoclineTempF,
      confidence: confidence,
      status: status,
      recommendation: recommendation,
      factors: factors,
      generatedAt: DateTime.now(),
    );
  }
  
  /// Determine stratification status based on temperature and season
  static StratificationStatus _determineStatus(double surfaceTempC, int dayOfYear) {
    // Lakes typically stratify when surface temp exceeds ~15-18°C (59-64°F)
    // and destratify in fall when temps drop and wind increases
    
    final isWarmEnough = surfaceTempC >= 15;
    
    // Northern hemisphere seasonal windows (adjust for region)
    final isSpring = dayOfYear >= 60 && dayOfYear <= 150; // Mar-May
    final isSummer = dayOfYear > 150 && dayOfYear <= 270; // Jun-Sep
    final isFall = dayOfYear > 270 && dayOfYear <= 330; // Oct-Nov
    
    if (!isWarmEnough) {
      return StratificationStatus.mixed;
    }
    
    if (isSpring && surfaceTempC >= 15 && surfaceTempC < 20) {
      return StratificationStatus.forming;
    }
    
    if (isSummer && surfaceTempC >= 18) {
      return StratificationStatus.stratified;
    }
    
    if (isFall && surfaceTempC >= 15 && surfaceTempC < 20) {
      return StratificationStatus.breaking;
    }
    
    // Default based on temperature alone
    if (surfaceTempC >= 20) {
      return StratificationStatus.stratified;
    } else if (surfaceTempC >= 15) {
      return StratificationStatus.forming;
    }
    
    return StratificationStatus.mixed;
  }
  
  /// Calculate thermocline depth using empirical model
  /// 
  /// Based on simplified version of models from:
  /// - Hanna (1990) - wind-driven mixing
  /// - Stefan & Preud'homme (1993) - temperature-depth relationships
  static double _calculateThermoclineDepth({
    required double surfaceTempC,
    required double windSpeedMs,
    required int dayOfYear,
    required double maxDepthM,
  }) {
    // Base thermocline depth from surface temperature
    // Warmer surface = shallower thermocline (stronger stratification)
    // Typical range: 3-10m for most lakes
    double baseDepth = 8 - (surfaceTempC - 20) * 0.3;
    
    // Wind mixing factor - stronger wind pushes thermocline deeper
    // Epilimnion depth ≈ 4.4 * sqrt(fetch) * wind^0.5 (simplified Hanna)
    double windFactor = 1 + (windSpeedMs / 5) * 0.3;
    
    // Seasonal adjustment - thermocline deepens as summer progresses
    double seasonalFactor = 1.0;
    if (dayOfYear >= 150 && dayOfYear <= 240) {
      // Early to mid summer - thermocline relatively shallow
      seasonalFactor = 1.0;
    } else if (dayOfYear > 240 && dayOfYear <= 270) {
      // Late summer - thermocline deepens
      seasonalFactor = 1.2;
    }
    
    double thermoclineDepth = baseDepth * windFactor * seasonalFactor;
    
    // Constrain to lake depth
    thermoclineDepth = thermoclineDepth.clamp(3, maxDepthM * 0.6);
    
    return thermoclineDepth;
  }
  
  /// Estimate temperature at thermocline depth
  static double _estimateThermoclineTemp(double surfaceTempF, double thermoclineTopFt) {
    // Temperature drops ~1-2°F per 3-5 feet in the thermocline
    // Thermocline temp is typically 65-72°F regardless of surface
    double estimatedTemp = surfaceTempF - (thermoclineTopFt / 4);
    return estimatedTemp.clamp(62, 74);
  }
  
  /// Calculate prediction confidence
  static double _calculateConfidence({
    required double surfaceTempF,
    required double windSpeedMph,
    required StratificationStatus status,
  }) {
    double confidence = 0.7; // Base confidence
    
    // Higher confidence when clearly stratified
    if (status == StratificationStatus.stratified) {
      confidence += 0.15;
    }
    
    // Lower confidence in transition periods
    if (status == StratificationStatus.forming || 
        status == StratificationStatus.breaking) {
      confidence -= 0.1;
    }
    
    // High winds reduce confidence (more mixing uncertainty)
    if (windSpeedMph > 15) {
      confidence -= 0.1;
    }
    
    // Very warm water = strong stratification = higher confidence
    if (surfaceTempF >= 75) {
      confidence += 0.05;
    }
    
    return confidence.clamp(0.4, 0.95);
  }
  
  /// Generate list of factors influencing prediction
  static List<String> _generateFactors({
    required double surfaceTempF,
    required double windSpeedMph,
    required int dayOfYear,
    required double thermoclineTopFt,
  }) {
    final factors = <String>[];
    
    if (surfaceTempF >= 75) {
      factors.add('Warm surface water (${surfaceTempF.toStringAsFixed(0)}°F) = strong stratification');
    } else if (surfaceTempF >= 65) {
      factors.add('Moderate surface temp (${surfaceTempF.toStringAsFixed(0)}°F)');
    }
    
    if (windSpeedMph > 15) {
      factors.add('Strong wind (${windSpeedMph.toStringAsFixed(0)} mph) pushing thermocline deeper');
    } else if (windSpeedMph < 5) {
      factors.add('Calm conditions allowing stable stratification');
    }
    
    if (dayOfYear >= 180 && dayOfYear <= 240) {
      factors.add('Peak summer - maximum stratification');
    }
    
    factors.add('Predicted thermocline at ${thermoclineTopFt.toStringAsFixed(0)}-${(thermoclineTopFt + 10).toStringAsFixed(0)} ft');
    
    return factors;
  }
  
  /// Generate fishing recommendation
  static String _generateRecommendation({
    required StratificationStatus status,
    required double targetDepthMinFt,
    required double targetDepthMaxFt,
    required double surfaceTempF,
    required double windSpeedMph,
  }) {
    final depthRange = '${targetDepthMinFt.toStringAsFixed(0)}-${targetDepthMaxFt.toStringAsFixed(0)} ft';
    
    switch (status) {
      case StratificationStatus.stratified:
        if (windSpeedMph > 15) {
          return 'Target $depthRange. Wind is mixing the upper layer - fish may be suspended slightly deeper than normal.';
        }
        return 'Target $depthRange. Crappie are stacking in the comfort zone just above the thermocline. Use electronics to verify.';
        
      case StratificationStatus.forming:
        return 'Thermocline is forming. Fish are transitioning - check $depthRange but also try shallower structure. Pattern may change daily.';
        
      case StratificationStatus.breaking:
        return 'Fall turnover beginning. Fish patterns unstable. Try $depthRange but be ready to adjust. Follow the bait.';
        
      case StratificationStatus.mixed:
        return 'Lake is mixed - fish the water column. Focus on structure, cover, and baitfish location rather than specific depths.';
    }
  }
}
