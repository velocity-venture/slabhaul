import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/features/calculator/providers/calculator_providers.dart';
import 'package:slabhaul/core/models/calculator_result.dart';
import 'package:slabhaul/core/utils/constants.dart';

void main() {
  group('CalculatorInputNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default values', () {
      final input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(0.5));
      expect(input.lineOutFt, equals(50.0));
      expect(input.boatSpeedMph, equals(0.6));
      expect(input.lineDragFactor, equals(1.0));
      expect(input.lineType, equals('Mono'));
    });

    test('setSinkerWeight updates only sinker weight', () {
      container.read(calculatorInputProvider.notifier).setSinkerWeight(1.0);
      final input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(1.0));
      expect(input.lineOutFt, equals(50.0)); // unchanged
    });

    test('setLineOut updates only line out', () {
      container.read(calculatorInputProvider.notifier).setLineOut(30.0);
      final input = container.read(calculatorInputProvider);
      expect(input.lineOutFt, equals(30.0));
      expect(input.sinkerWeightOz, equals(0.5)); // unchanged
    });

    test('setBoatSpeed updates only boat speed', () {
      container.read(calculatorInputProvider.notifier).setBoatSpeed(1.5);
      final input = container.read(calculatorInputProvider);
      expect(input.boatSpeedMph, equals(1.5));
    });

    test('setLineType updates type and drag factor for Mono', () {
      container.read(calculatorInputProvider.notifier).setLineType('Mono');
      final input = container.read(calculatorInputProvider);
      expect(input.lineType, equals('Mono'));
      expect(input.lineDragFactor, equals(1.0));
    });

    test('setLineType updates type and drag factor for Fluoro', () {
      container.read(calculatorInputProvider.notifier).setLineType('Fluoro');
      final input = container.read(calculatorInputProvider);
      expect(input.lineType, equals('Fluoro'));
      expect(input.lineDragFactor, equals(0.8));
    });

    test('setLineType updates type and drag factor for Braid', () {
      container.read(calculatorInputProvider.notifier).setLineType('Braid');
      final input = container.read(calculatorInputProvider);
      expect(input.lineType, equals('Braid'));
      expect(input.lineDragFactor, equals(0.7));
    });

    test('setLineType falls back to 1.0 for unknown type', () {
      container.read(calculatorInputProvider.notifier).setLineType('Unknown');
      final input = container.read(calculatorInputProvider);
      expect(input.lineType, equals('Unknown'));
      expect(input.lineDragFactor, equals(1.0));
    });

    test('applyPreset updates weight, line out, and speed', () {
      container.read(calculatorInputProvider.notifier).applyPreset(
            sinkerWeightOz: 0.25,
            lineOutFt: 20,
            boatSpeedMph: 0.4,
          );
      final input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(0.25));
      expect(input.lineOutFt, equals(20.0));
      expect(input.boatSpeedMph, equals(0.4));
      // Line type should remain unchanged
      expect(input.lineType, equals('Mono'));
    });

    test('reset returns to default state', () {
      final notifier = container.read(calculatorInputProvider.notifier);
      notifier.setSinkerWeight(2.0);
      notifier.setLineOut(100.0);
      notifier.setBoatSpeed(2.5);
      notifier.setLineType('Braid');
      notifier.reset();

      final input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(0.5));
      expect(input.lineOutFt, equals(50.0));
      expect(input.boatSpeedMph, equals(0.6));
      expect(input.lineDragFactor, equals(1.0));
      expect(input.lineType, equals('Mono'));
    });
  });

  group('calculatorResultProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('produces CalculatorResult from default input', () {
      final result = container.read(calculatorResultProvider);
      expect(result, isA<CalculatorResult>());
      expect(result.depthFt, greaterThan(0));
      expect(result.depthRatio, greaterThan(0));
      expect(result.depthRatio, lessThanOrEqualTo(1.0));
      expect(result.lineAngleDeg, greaterThanOrEqualTo(0));
      expect(result.input.sinkerWeightOz, equals(0.5));
    });

    test('result updates when input changes', () {
      final initialResult = container.read(calculatorResultProvider);
      container.read(calculatorInputProvider.notifier).setSinkerWeight(2.0);
      final updatedResult = container.read(calculatorResultProvider);

      expect(updatedResult.depthFt, isNot(equals(initialResult.depthFt)));
      expect(updatedResult.input.sinkerWeightOz, equals(2.0));
    });

    test('heavier sinker produces deeper result', () {
      container.read(calculatorInputProvider.notifier).setSinkerWeight(0.25);
      final lightResult = container.read(calculatorResultProvider);

      container.read(calculatorInputProvider.notifier).setSinkerWeight(1.0);
      final heavyResult = container.read(calculatorResultProvider);

      expect(heavyResult.depthFt, greaterThan(lightResult.depthFt));
    });

    test('faster speed produces shallower result', () {
      container.read(calculatorInputProvider.notifier).setBoatSpeed(0.3);
      final slowResult = container.read(calculatorResultProvider);

      container.read(calculatorInputProvider.notifier).setBoatSpeed(2.0);
      final fastResult = container.read(calculatorResultProvider);

      expect(slowResult.depthFt, greaterThan(fastResult.depthFt));
    });

    test('braid produces deeper result than mono', () {
      container.read(calculatorInputProvider.notifier).setLineType('Mono');
      final monoResult = container.read(calculatorResultProvider);

      container.read(calculatorInputProvider.notifier).setLineType('Braid');
      final braidResult = container.read(calculatorResultProvider);

      expect(braidResult.depthFt, greaterThan(monoResult.depthFt));
    });

    test('result includes correct depth zone', () {
      // Set to get shallow depth
      container.read(calculatorInputProvider.notifier).setLineOut(10.0);
      container.read(calculatorInputProvider.notifier).setBoatSpeed(0.0);
      final result = container.read(calculatorResultProvider);

      // 10ft * 0.95 = 9.5ft — should be Pre-Spawn Zone
      expect(result.depthZone, contains('Zone'));
    });
  });

  group('CalculatorInput model', () {
    test('copyWith preserves unchanged fields', () {
      const original = CalculatorInput();
      final copy = original.copyWith(sinkerWeightOz: 1.0);
      expect(copy.sinkerWeightOz, equals(1.0));
      expect(copy.lineOutFt, equals(original.lineOutFt));
      expect(copy.boatSpeedMph, equals(original.boatSpeedMph));
      expect(copy.lineDragFactor, equals(original.lineDragFactor));
      expect(copy.lineType, equals(original.lineType));
    });

    test('weightLabel returns correct fraction strings', () {
      expect(
        const CalculatorInput(sinkerWeightOz: 0.0625).weightLabel,
        equals('1/16 oz'),
      );
      expect(
        const CalculatorInput(sinkerWeightOz: 0.125).weightLabel,
        equals('1/8 oz'),
      );
      expect(
        const CalculatorInput(sinkerWeightOz: 0.25).weightLabel,
        equals('1/4 oz'),
      );
      expect(
        const CalculatorInput(sinkerWeightOz: 0.375).weightLabel,
        equals('3/8 oz'),
      );
      expect(
        const CalculatorInput(sinkerWeightOz: 0.5).weightLabel,
        equals('1/2 oz'),
      );
      expect(
        const CalculatorInput(sinkerWeightOz: 1.0).weightLabel,
        equals('1 oz'),
      );
      expect(
        const CalculatorInput(sinkerWeightOz: 2.0).weightLabel,
        equals('2 oz'),
      );
    });

    test('weightLabel falls back to decimal for non-preset values', () {
      const input = CalculatorInput(sinkerWeightOz: 0.33);
      expect(input.weightLabel, equals('0.33 oz'));
    });
  });

  group('CalculatorResult model', () {
    test('depthZone returns correct zone for shallow depth', () {
      const result = CalculatorResult(
        depthFt: 4.0,
        depthRatio: 0.8,
        lineAngleDeg: 10,
        input: CalculatorInput(),
      );
      expect(result.depthZone, equals('Spawn Zone (1-6 ft)'));
      expect(result.depthZoneColor, equals('green'));
    });

    test('depthZone returns correct zone for pre-spawn depth', () {
      const result = CalculatorResult(
        depthFt: 12.0,
        depthRatio: 0.6,
        lineAngleDeg: 20,
        input: CalculatorInput(),
      );
      expect(result.depthZone, equals('Pre-Spawn Zone (8-15 ft)'));
      expect(result.depthZoneColor, equals('teal'));
    });

    test('depthZone returns correct zone for summer depth', () {
      const result = CalculatorResult(
        depthFt: 20.0,
        depthRatio: 0.5,
        lineAngleDeg: 30,
        input: CalculatorInput(),
      );
      expect(result.depthZone, equals('Summer Zone (15-25 ft)'));
      expect(result.depthZoneColor, equals('blue'));
    });

    test('depthZone returns correct zone for deep structure', () {
      const result = CalculatorResult(
        depthFt: 30.0,
        depthRatio: 0.4,
        lineAngleDeg: 40,
        input: CalculatorInput(),
      );
      expect(result.depthZone, equals('Deep Structure (25+ ft)'));
      expect(result.depthZoneColor, equals('purple'));
    });
  });

  group('Constants', () {
    test('SinkerWeights has expected preset count', () {
      expect(SinkerWeights.values.length, equals(10));
    });

    test('SinkerWeights are in ascending order', () {
      for (int i = 1; i < SinkerWeights.values.length; i++) {
        expect(SinkerWeights.values[i],
            greaterThan(SinkerWeights.values[i - 1]));
      }
    });

    test('SinkerWeights.label matches all presets', () {
      for (final w in SinkerWeights.values) {
        expect(SinkerWeights.label(w), endsWith('oz'));
        expect(SinkerWeights.label(w), isNot(contains('.')));
      }
    });

    test('LineTypes has three types with correct drag factors', () {
      expect(LineTypes.dragFactors.length, equals(3));
      expect(LineTypes.dragFactors['Mono'], equals(1.0));
      expect(LineTypes.dragFactors['Fluoro'], equals(0.8));
      expect(LineTypes.dragFactors['Braid'], equals(0.7));
    });

    test('Braid has lowest drag factor', () {
      final factors = LineTypes.dragFactors.values.toList()..sort();
      expect(factors.first, equals(LineTypes.dragFactors['Braid']));
    });

    test('attractorColor returns expected colors', () {
      expect(attractorColor('brush_pile'), equals(AppColors.brushPile));
      expect(attractorColor('pvc_tree'), equals(AppColors.pvcTree));
      expect(attractorColor('stake_bed'), equals(AppColors.stakeBed));
      expect(attractorColor('pallet'), equals(AppColors.pallet));
      expect(attractorColor('unknown'), equals(AppColors.unknownType));
    });
  });
}
