/// Thermocline prediction data for a lake
/// 
/// The thermocline is the transition layer in a lake where temperature
/// drops rapidly with depth. Crappie concentrate near this layer in summer
/// because it marks the boundary between warm, oxygenated surface water
/// and cold, oxygen-depleted deep water.
class ThermoclineData {
  /// Predicted depth of thermocline top (feet)
  final double thermoclineTopFt;
  
  /// Predicted depth of thermocline bottom (feet)
  final double thermoclineBottomFt;
  
  /// Recommended fishing depth range - top (feet)
  final double targetDepthMinFt;
  
  /// Recommended fishing depth range - bottom (feet)
  final double targetDepthMaxFt;
  
  /// Surface water temperature (°F)
  final double surfaceTempF;
  
  /// Estimated temperature at thermocline (°F)
  final double thermoclineTempF;
  
  /// Confidence level of prediction (0.0 - 1.0)
  final double confidence;
  
  /// Current stratification status
  final StratificationStatus status;
  
  /// Human-readable recommendation
  final String recommendation;
  
  /// Factors that influenced this prediction
  final List<String> factors;
  
  /// When this prediction was generated
  final DateTime generatedAt;

  const ThermoclineData({
    required this.thermoclineTopFt,
    required this.thermoclineBottomFt,
    required this.targetDepthMinFt,
    required this.targetDepthMaxFt,
    required this.surfaceTempF,
    required this.thermoclineTempF,
    required this.confidence,
    required this.status,
    required this.recommendation,
    required this.factors,
    required this.generatedAt,
  });

  /// The "sweet spot" - middle of recommended depth range
  double get sweetSpotFt => (targetDepthMinFt + targetDepthMaxFt) / 2;
  
  /// Thermocline thickness
  double get thermoclineThicknessFt => thermoclineBottomFt - thermoclineTopFt;
  
  /// Is the lake stratified enough for thermocline fishing?
  bool get isStratified => status == StratificationStatus.stratified;
}

/// Lake stratification status
enum StratificationStatus {
  /// Lake is fully mixed - no thermocline (spring/fall turnover, winter)
  mixed,
  
  /// Thermocline is forming (early summer)
  forming,
  
  /// Lake is stratified with distinct thermocline (summer)
  stratified,
  
  /// Thermocline is breaking down (fall turnover beginning)
  breaking,
}

extension StratificationStatusX on StratificationStatus {
  String get label {
    switch (this) {
      case StratificationStatus.mixed:
        return 'Mixed';
      case StratificationStatus.forming:
        return 'Forming';
      case StratificationStatus.stratified:
        return 'Stratified';
      case StratificationStatus.breaking:
        return 'Breaking Down';
    }
  }
  
  String get description {
    switch (this) {
      case StratificationStatus.mixed:
        return 'Lake is fully mixed. Fish can be at any depth.';
      case StratificationStatus.forming:
        return 'Thermocline is forming. Fish transitioning to summer patterns.';
      case StratificationStatus.stratified:
        return 'Lake is stratified. Target the thermocline zone.';
      case StratificationStatus.breaking:
        return 'Fall turnover beginning. Fish patterns becoming unpredictable.';
    }
  }
}
