class CalculatorInput {
  final double sinkerWeightOz;
  final double lineOutFt;
  final double boatSpeedMph;
  final double lineDragFactor;
  final String lineType;

  const CalculatorInput({
    this.sinkerWeightOz = 0.5,
    this.lineOutFt = 50.0,
    this.boatSpeedMph = 0.6,
    this.lineDragFactor = 1.0,
    this.lineType = 'Mono',
  });

  CalculatorInput copyWith({
    double? sinkerWeightOz,
    double? lineOutFt,
    double? boatSpeedMph,
    double? lineDragFactor,
    String? lineType,
  }) {
    return CalculatorInput(
      sinkerWeightOz: sinkerWeightOz ?? this.sinkerWeightOz,
      lineOutFt: lineOutFt ?? this.lineOutFt,
      boatSpeedMph: boatSpeedMph ?? this.boatSpeedMph,
      lineDragFactor: lineDragFactor ?? this.lineDragFactor,
      lineType: lineType ?? this.lineType,
    );
  }

  String get weightLabel {
    if (sinkerWeightOz == 0.0625) return '1/16 oz';
    if (sinkerWeightOz == 0.125) return '1/8 oz';
    if (sinkerWeightOz == 0.1875) return '3/16 oz';
    if (sinkerWeightOz == 0.25) return '1/4 oz';
    if (sinkerWeightOz == 0.375) return '3/8 oz';
    if (sinkerWeightOz == 0.5) return '1/2 oz';
    if (sinkerWeightOz == 0.75) return '3/4 oz';
    if (sinkerWeightOz == 1.0) return '1 oz';
    if (sinkerWeightOz == 1.5) return '1-1/2 oz';
    if (sinkerWeightOz == 2.0) return '2 oz';
    return '${sinkerWeightOz.toStringAsFixed(2)} oz';
  }
}

class CalculatorResult {
  final double depthFt;
  final double depthRatio;
  final double lineAngleDeg;
  final CalculatorInput input;

  const CalculatorResult({
    required this.depthFt,
    required this.depthRatio,
    required this.lineAngleDeg,
    required this.input,
  });

  String get depthZone {
    if (depthFt <= 6) return 'Spawn Zone (1-6 ft)';
    if (depthFt <= 15) return 'Pre-Spawn Zone (8-15 ft)';
    if (depthFt <= 25) return 'Summer Zone (15-25 ft)';
    return 'Deep Structure (25+ ft)';
  }

  String get depthZoneColor {
    if (depthFt <= 6) return 'green';
    if (depthFt <= 15) return 'teal';
    if (depthFt <= 25) return 'blue';
    return 'purple';
  }
}
