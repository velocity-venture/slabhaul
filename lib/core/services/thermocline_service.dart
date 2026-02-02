import '../models/thermocline_data.dart';
import '../models/weather_data.dart';
import '../models/lake_conditions.dart';
import '../utils/thermocline_calculator.dart';

/// Service for generating thermocline predictions
/// 
/// Combines weather data, lake conditions, and lake characteristics
/// to predict thermocline depth and fishing recommendations.
class ThermoclineService {
  
  /// Generate thermocline prediction for a lake
  /// 
  /// [weather] - Current weather conditions
  /// [lakeConditions] - Current lake data (water level, temp if available)
  /// [maxLakeDepthFt] - Maximum depth of the lake
  /// [lakeAreaAcres] - Optional lake surface area
  ThermoclineData predict({
    required WeatherData weather,
    required LakeConditions lakeConditions,
    required double maxLakeDepthFt,
    double? lakeAreaAcres,
  }) {
    // Get surface water temperature
    // Prefer actual lake temp from USGS if available, else estimate from air temp
    final surfaceTempF = lakeConditions.waterTempF ?? 
        _estimateSurfaceTempFromAir(weather.current.temperatureF);
    
    return ThermoclineCalculator.calculate(
      surfaceTempF: surfaceTempF,
      airTempF: weather.current.temperatureF,
      windSpeedMph: weather.current.windSpeedMph,
      date: DateTime.now(),
      maxLakeDepthFt: maxLakeDepthFt,
      lakeAreaAcres: lakeAreaAcres,
    );
  }
  
  /// Estimate surface water temperature from air temperature
  /// 
  /// Water temp lags air temp by several days and is moderated.
  /// This is a rough approximation when actual water temp isn't available.
  double _estimateSurfaceTempFromAir(double airTempF) {
    // Water temp is typically 5-15°F cooler than peak air temp in summer
    // and warmer than air temp in fall/winter due to thermal mass
    // Using a simplified model: water ≈ air * 0.85 + offset
    if (airTempF > 80) {
      return airTempF - 10; // Hot days - water cooler than air
    } else if (airTempF > 60) {
      return airTempF - 5; // Moderate - slight lag
    } else if (airTempF > 40) {
      return airTempF; // Cool - similar temps
    } else {
      return airTempF + 5; // Cold - water holds warmth
    }
  }
  
  /// Get mock thermocline data for testing/demo
  static ThermoclineData getMockData() {
    return ThermoclineCalculator.calculate(
      surfaceTempF: 78,
      airTempF: 85,
      windSpeedMph: 8,
      date: DateTime.now(),
      maxLakeDepthFt: 35,
    );
  }
}
