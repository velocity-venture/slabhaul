/// SlabHaul Spider Rigging Depth Calculator v1.0
///
/// Physics-based calculator for estimating fishing line depth during
/// spider rigging (slow-trolling) for crappie.
///
/// Author: SlabHaul Development Team
/// License: Proprietary - Velocity Venture Holdings LLC

import 'dart:math';

// ============================================================================
// CONSTANTS
// ============================================================================

const double kWeightOneEighthOz = 0.125;
const double kWeightOneQuarterOz = 0.25;
const double kWeightThreeEighthsOz = 0.375;
const double kWeightOneHalfOz = 0.5;
const double kWeightThreeQuartersOz = 0.75;
const double kWeightOneOz = 1.0;
const double kWeightOneAndHalfOz = 1.5;
const double kWeightTwoOz = 2.0;

// Physics constants — empirically tuned to tournament crappie data
const double _kWeightCoefficient = 26.0;
const double _kDragCoefficient = 0.42;
const double _kMinDragCoefficient = 0.025;
const double _kSpeedExponent = 1.8;
const double _kMaxDepthRatio = 0.95;
const double _kMinSpeedThreshold = 0.05;

// Validation bounds
const double _kMinSinkerWeight = 0.0625;
const double _kMaxSinkerWeight = 4.0;
const double _kMinLineOut = 5.0;
const double _kMaxLineOut = 200.0;
const double _kMaxBoatSpeed = 3.0;
const double _kMinLineDragFactor = 0.5;
const double _kMaxLineDragFactor = 2.0;

// ============================================================================
// EXCEPTION
// ============================================================================

class SpiderRiggingInputException implements Exception {
  final String message;
  final String parameterName;
  final dynamic invalidValue;

  const SpiderRiggingInputException({
    required this.message,
    required this.parameterName,
    required this.invalidValue,
  });

  @override
  String toString() =>
      'SpiderRiggingInputException: $message '
      '(parameter: $parameterName, value: $invalidValue)';
}

// ============================================================================
// MAIN CALCULATION
// ============================================================================

/// Calculates estimated depth of a spider rig.
///
/// [sinkerWeightOz] — sinker weight in ounces (0.0625–4.0)
/// [lineOutFt] — line deployed in feet (5–200)
/// [boatSpeedMph] — trolling speed in mph (0–3.0)
/// [lineDragFactor] — line type adjustment (0.5–2.0, default 1.0)
///
/// Returns estimated depth in feet.
double calculateDepth({
  required double sinkerWeightOz,
  required double lineOutFt,
  required double boatSpeedMph,
  double lineDragFactor = 1.0,
}) {
  _validateSinkerWeight(sinkerWeightOz);
  _validateLineOut(lineOutFt);
  _validateBoatSpeed(boatSpeedMph);
  _validateLineDragFactor(lineDragFactor);

  // Dead drift — rig hangs nearly vertical
  if (boatSpeedMph < _kMinSpeedThreshold) {
    return lineOutFt * _kMaxDepthRatio;
  }

  // Force-balance physics
  final double verticalForce = sinkerWeightOz * _kWeightCoefficient;
  final double speedComponent = pow(boatSpeedMph, _kSpeedExponent).toDouble();
  final double speedDependentDrag =
      speedComponent * _kDragCoefficient * lineDragFactor * lineOutFt;
  final double baselineDrag = _kMinDragCoefficient * lineOutFt;
  final double horizontalForce = speedDependentDrag + baselineDrag;

  final double tanAngle = verticalForce / horizontalForce;
  final double sinAngle = tanAngle / sqrt(1.0 + tanAngle * tanAngle);

  double depth = lineOutFt * sinAngle;

  // Physical limits
  final double maxDepth = lineOutFt * _kMaxDepthRatio;
  if (depth > maxDepth) depth = maxDepth;
  if (depth < 0) depth = 0;

  return depth;
}

/// Returns line angle from vertical in degrees.
double calculateLineAngle({
  required double sinkerWeightOz,
  required double lineOutFt,
  required double boatSpeedMph,
  double lineDragFactor = 1.0,
}) {
  if (boatSpeedMph < _kMinSpeedThreshold) return 0.0;

  final double verticalForce = sinkerWeightOz * _kWeightCoefficient;
  final double speedComponent = pow(boatSpeedMph, _kSpeedExponent).toDouble();
  final double speedDependentDrag =
      speedComponent * _kDragCoefficient * lineDragFactor * lineOutFt;
  final double baselineDrag = _kMinDragCoefficient * lineOutFt;
  final double horizontalForce = speedDependentDrag + baselineDrag;

  final double tanAngle = verticalForce / horizontalForce;
  final double angleDeg = 90.0 - (atan(tanAngle) * 180.0 / pi);
  return angleDeg.clamp(0.0, 90.0);
}

/// Calculates depth ratio (depth / line out).
double calculateDepthRatio({
  required double sinkerWeightOz,
  required double lineOutFt,
  required double boatSpeedMph,
  double lineDragFactor = 1.0,
}) {
  final depth = calculateDepth(
    sinkerWeightOz: sinkerWeightOz,
    lineOutFt: lineOutFt,
    boatSpeedMph: boatSpeedMph,
    lineDragFactor: lineDragFactor,
  );
  return depth / lineOutFt;
}

/// Estimates line out needed to reach a target depth.
double estimateLineOutForDepth({
  required double targetDepthFt,
  required double sinkerWeightOz,
  required double boatSpeedMph,
  double lineDragFactor = 1.0,
}) {
  if (targetDepthFt <= 0) {
    throw SpiderRiggingInputException(
      message: 'Target depth must be positive',
      parameterName: 'targetDepthFt',
      invalidValue: targetDepthFt,
    );
  }

  double estimatedRatio = 0.7;
  double lineOut = targetDepthFt / estimatedRatio;
  lineOut = lineOut.clamp(_kMinLineOut, _kMaxLineOut);

  for (int i = 0; i < 10; i++) {
    final actualDepth = calculateDepth(
      sinkerWeightOz: sinkerWeightOz,
      lineOutFt: lineOut,
      boatSpeedMph: boatSpeedMph,
      lineDragFactor: lineDragFactor,
    );
    final error = targetDepthFt - actualDepth;
    if (error.abs() < 0.1) break;
    final currentRatio = actualDepth / lineOut;
    lineOut = targetDepthFt / currentRatio;
    lineOut = lineOut.clamp(_kMinLineOut, _kMaxLineOut);
  }

  return lineOut;
}

// ============================================================================
// VALIDATION
// ============================================================================

void _validateSinkerWeight(double weight) {
  if (weight.isNaN || weight.isInfinite) {
    throw SpiderRiggingInputException(
      message: 'Sinker weight must be a finite number',
      parameterName: 'sinkerWeightOz',
      invalidValue: weight,
    );
  }
  if (weight < _kMinSinkerWeight) {
    throw SpiderRiggingInputException(
      message: 'Sinker weight too light. Minimum: $_kMinSinkerWeight oz',
      parameterName: 'sinkerWeightOz',
      invalidValue: weight,
    );
  }
  if (weight > _kMaxSinkerWeight) {
    throw SpiderRiggingInputException(
      message: 'Sinker weight too heavy. Maximum: $_kMaxSinkerWeight oz',
      parameterName: 'sinkerWeightOz',
      invalidValue: weight,
    );
  }
}

void _validateLineOut(double lineOut) {
  if (lineOut.isNaN || lineOut.isInfinite) {
    throw SpiderRiggingInputException(
      message: 'Line out must be a finite number',
      parameterName: 'lineOutFt',
      invalidValue: lineOut,
    );
  }
  if (lineOut < _kMinLineOut) {
    throw SpiderRiggingInputException(
      message: 'Line out too short. Minimum: $_kMinLineOut ft',
      parameterName: 'lineOutFt',
      invalidValue: lineOut,
    );
  }
  if (lineOut > _kMaxLineOut) {
    throw SpiderRiggingInputException(
      message: 'Line out too long. Maximum: $_kMaxLineOut ft',
      parameterName: 'lineOutFt',
      invalidValue: lineOut,
    );
  }
}

void _validateBoatSpeed(double speed) {
  if (speed.isNaN || speed.isInfinite) {
    throw SpiderRiggingInputException(
      message: 'Boat speed must be a finite number',
      parameterName: 'boatSpeedMph',
      invalidValue: speed,
    );
  }
  if (speed < 0) {
    throw SpiderRiggingInputException(
      message: 'Boat speed cannot be negative',
      parameterName: 'boatSpeedMph',
      invalidValue: speed,
    );
  }
  if (speed > _kMaxBoatSpeed) {
    throw SpiderRiggingInputException(
      message: 'Boat speed too fast. Maximum: $_kMaxBoatSpeed mph',
      parameterName: 'boatSpeedMph',
      invalidValue: speed,
    );
  }
}

void _validateLineDragFactor(double factor) {
  if (factor.isNaN || factor.isInfinite) {
    throw SpiderRiggingInputException(
      message: 'Line drag factor must be a finite number',
      parameterName: 'lineDragFactor',
      invalidValue: factor,
    );
  }
  if (factor < _kMinLineDragFactor) {
    throw SpiderRiggingInputException(
      message: 'Line drag factor too low. Minimum: $_kMinLineDragFactor',
      parameterName: 'lineDragFactor',
      invalidValue: factor,
    );
  }
  if (factor > _kMaxLineDragFactor) {
    throw SpiderRiggingInputException(
      message: 'Line drag factor too high. Maximum: $_kMaxLineDragFactor',
      parameterName: 'lineDragFactor',
      invalidValue: factor,
    );
  }
}
