import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/calculator_result.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/spider_rigging_calculator.dart';

// ---------------------------------------------------------------------------
// Calculator Input Notifier
// ---------------------------------------------------------------------------

class CalculatorInputNotifier extends StateNotifier<CalculatorInput> {
  CalculatorInputNotifier() : super(const CalculatorInput());

  void setSinkerWeight(double oz) {
    state = state.copyWith(sinkerWeightOz: oz);
  }

  void setLineOut(double ft) {
    state = state.copyWith(lineOutFt: ft);
  }

  void setBoatSpeed(double mph) {
    state = state.copyWith(boatSpeedMph: mph);
  }

  void setLineType(String type) {
    final dragFactor = LineTypes.dragFactors[type] ?? 1.0;
    state = state.copyWith(lineType: type, lineDragFactor: dragFactor);
  }

  void applyPreset({
    required double sinkerWeightOz,
    required double lineOutFt,
    required double boatSpeedMph,
  }) {
    state = state.copyWith(
      sinkerWeightOz: sinkerWeightOz,
      lineOutFt: lineOutFt,
      boatSpeedMph: boatSpeedMph,
    );
  }

  void reset() {
    state = const CalculatorInput();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final calculatorInputProvider =
    StateNotifierProvider<CalculatorInputNotifier, CalculatorInput>((ref) {
  return CalculatorInputNotifier();
});

final calculatorResultProvider = Provider<CalculatorResult>((ref) {
  final input = ref.watch(calculatorInputProvider);

  final depthFt = calculateDepth(
    sinkerWeightOz: input.sinkerWeightOz,
    lineOutFt: input.lineOutFt,
    boatSpeedMph: input.boatSpeedMph,
    lineDragFactor: input.lineDragFactor,
  );

  final lineAngleDeg = calculateLineAngle(
    sinkerWeightOz: input.sinkerWeightOz,
    lineOutFt: input.lineOutFt,
    boatSpeedMph: input.boatSpeedMph,
    lineDragFactor: input.lineDragFactor,
  );

  final depthRatio = calculateDepthRatio(
    sinkerWeightOz: input.sinkerWeightOz,
    lineOutFt: input.lineOutFt,
    boatSpeedMph: input.boatSpeedMph,
    lineDragFactor: input.lineDragFactor,
  );

  return CalculatorResult(
    depthFt: depthFt,
    depthRatio: depthRatio,
    lineAngleDeg: lineAngleDeg,
    input: input,
  );
});
