/// Constants and calibration values for thermocline prediction
/// 
/// These values are derived from limnological research and EPA lake data.
/// They can be tuned based on user feedback and validation data.
library;

/// Minimum lake depth (ft) required for stable thermocline formation
const double kMinStratificationDepthFt = 15.0;

/// Water temperature thresholds (°F)
class WaterTempThresholds {
  /// Below this, lake is definitely not stratified
  static const double mixedMax = 60.0;
  
  /// Above this, thermocline is likely forming
  static const double formingMin = 65.0;
  
  /// Above this, lake is likely fully stratified
  static const double stratifiedMin = 70.0;
  
  /// "Hot" surface water threshold - affects recommendations
  static const double hotSurface = 82.0;
}

/// Crappie preferred temperature range (°F)
class CrappieTemperature {
  static const double optimal = 68.0;
  static const double preferredMin = 65.0;
  static const double preferredMax = 75.0;
  static const double stressedMin = 55.0;
  static const double stressedMax = 85.0;
}

/// Base temperature for degree-day calculations (°F)
const double kDegreeDayBaseTemp = 50.0;

/// Model calibration constants
class ThermoclineModel {
  /// Base thermocline depth at season start (ft)
  static const double baseDepthFt = 8.0;
  
  /// Degree days per 1 foot of thermocline deepening
  static const double degreeDaysPerFoot = 150.0;
  
  /// Surface temp adjustment factor (ft per °F over 82)
  static const double hotSurfaceAdjustment = 0.3;
  
  /// Latitude adjustment factor (ft per degree north of 35°N)
  static const double latitudeAdjustment = 0.2;
  
  /// Maximum thermocline depth as fraction of lake depth
  static const double maxDepthFraction = 0.7;
  
  /// Typical thermocline thickness (ft)
  static const double typicalThicknessFt = 3.0;
  
  /// Minimum and maximum possible thermocline depths (ft)
  static const double minDepthFt = 6.0;
  static const double maxDepthFt = 35.0;
}

/// Wind mixing model constants
class WindMixing {
  /// Wind speed threshold for mixing effect (mph)
  static const double thresholdMph = 10.0;
  
  /// Adjustment per mph of sustained wind over threshold
  static const double sustainedAdjustmentPerMph = 0.3;
  
  /// Gust threshold for additional adjustment (mph)
  static const double gustThresholdMph = 20.0;
  
  /// Adjustment per mph of gust over threshold
  static const double gustAdjustmentPerMph = 0.2;
  
  /// Lake surface area threshold for "large lake" bonus (acres)
  static const double largeLakeThresholdAcres = 5000.0;
  
  /// Multiplier for large lake wind effect
  static const double largeLakeMultiplier = 1.2;
  
  /// Maximum wind adjustment (ft)
  static const double maxAdjustmentFt = 8.0;
}

/// Confidence calculation weights
class ConfidenceWeights {
  /// Base confidence (no data)
  static const double base = 0.50;
  
  /// Bonus for having USGS water temperature
  static const double usgsTemp = 0.20;
  
  /// Bonus for data less than 24 hours old
  static const double freshData = 0.15;
  
  /// Bonus for data less than 48 hours old
  static const double recentData = 0.08;
  
  /// Bonus for knowing lake max depth
  static const double knownDepth = 0.10;
  
  /// Bonus for peak summer (high degree days)
  static const double peakSummer = 0.05;
  
  /// Minimum confidence to display
  static const double minimum = 0.30;
  
  /// Maximum confidence cap
  static const double maximum = 0.95;
}

/// Seasonal boundaries (day of year) at 35°N latitude
/// Adjusted by ~3 days per degree of latitude
class SeasonBoundaries {
  /// Forming phase starts (approx April 1)
  static const int formingStart = 91;
  
  /// Stratified phase starts (approx June 1)
  static const int stratifiedStart = 153;
  
  /// Breaking phase starts (approx September 1)
  static const int breakingStart = 245;
  
  /// Mixed phase starts (approx November 1)
  static const int mixedStart = 306;
  
  /// Days shift per degree of latitude from baseline (35°N)
  static const double latitudeShiftPerDegree = 3.0;
  
  /// Baseline latitude for season calculations
  static const double baselineLatitude = 35.0;
}

/// Crappie behavior relative to thermocline
class CrappieBehavior {
  /// Typical distance above thermocline where crappie hold (ft)
  static const double holdAboveThermoclineFt = 5.0;
  
  /// Minimum target depth to recommend (ft)
  static const double minTargetDepthFt = 5.0;
  
  /// Dissolved oxygen threshold below which crappie avoid (mg/L)
  static const double minDissolvedOxygenMgL = 4.0;
}

/// Estimated thermocline temperature offset from surface
const double kThermoclineTempOffsetF = 12.0;
