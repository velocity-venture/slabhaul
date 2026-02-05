import 'package:flutter_test/flutter_test.dart';
import 'package:slabhaul/core/utils/spider_rigging_calculator.dart';

void main() {
  group('calculateDepth', () {
    test('dead drift returns ~95% of line out', () {
      final depth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 20.0,
        boatSpeedMph: 0.0,
      );
      expect(depth, closeTo(19.0, 0.1)); // 20 * 0.95
    });

    test('very slow speed treated as dead drift', () {
      final depth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 20.0,
        boatSpeedMph: 0.04, // below 0.05 threshold
      );
      expect(depth, closeTo(19.0, 0.1));
    });

    test('heavier sinker = deeper at same speed', () {
      final lightDepth = calculateDepth(
        sinkerWeightOz: 0.25,
        lineOutFt: 30.0,
        boatSpeedMph: 1.0,
      );
      final heavyDepth = calculateDepth(
        sinkerWeightOz: 1.0,
        lineOutFt: 30.0,
        boatSpeedMph: 1.0,
      );
      expect(heavyDepth, greaterThan(lightDepth));
    });

    test('faster speed = shallower depth', () {
      final slowDepth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 0.5,
      );
      final fastDepth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 2.0,
      );
      expect(slowDepth, greaterThan(fastDepth));
    });

    test('more line out = deeper absolute depth', () {
      final shortDepth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 15.0,
        boatSpeedMph: 1.0,
      );
      final longDepth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 40.0,
        boatSpeedMph: 1.0,
      );
      expect(longDepth, greaterThan(shortDepth));
    });

    test('braid (low drag) goes deeper than mono', () {
      final monoDepth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 1.0,
        lineDragFactor: 1.0, // mono
      );
      final braidDepth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 1.0,
        lineDragFactor: 0.7, // braid
      );
      expect(braidDepth, greaterThan(monoDepth));
    });

    test('depth never exceeds 95% of line out', () {
      final depth = calculateDepth(
        sinkerWeightOz: 4.0, // max weight
        lineOutFt: 100.0,
        boatSpeedMph: 0.1, // very slow
      );
      expect(depth, lessThanOrEqualTo(95.0));
    });

    test('depth is always non-negative', () {
      final depth = calculateDepth(
        sinkerWeightOz: 0.0625,
        lineOutFt: 5.0,
        boatSpeedMph: 3.0,
      );
      expect(depth, greaterThanOrEqualTo(0.0));
    });

    test('typical tournament setup returns reasonable depth', () {
      // 3/8 oz sinker, 25ft line, 0.8 mph — should be ~15-22ft
      final depth = calculateDepth(
        sinkerWeightOz: 0.375,
        lineOutFt: 25.0,
        boatSpeedMph: 0.8,
      );
      expect(depth, greaterThan(10.0));
      expect(depth, lessThan(25.0));
    });
  });

  group('calculateLineAngle', () {
    test('dead drift returns 0 degrees (vertical)', () {
      final angle = calculateLineAngle(
        sinkerWeightOz: 0.5,
        lineOutFt: 20.0,
        boatSpeedMph: 0.0,
      );
      expect(angle, equals(0.0));
    });

    test('angle increases with speed', () {
      final slowAngle = calculateLineAngle(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 0.5,
      );
      final fastAngle = calculateLineAngle(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 2.5,
      );
      expect(fastAngle, greaterThan(slowAngle));
    });

    test('heavier sinker reduces angle', () {
      final lightAngle = calculateLineAngle(
        sinkerWeightOz: 0.25,
        lineOutFt: 30.0,
        boatSpeedMph: 1.0,
      );
      final heavyAngle = calculateLineAngle(
        sinkerWeightOz: 1.0,
        lineOutFt: 30.0,
        boatSpeedMph: 1.0,
      );
      expect(heavyAngle, lessThan(lightAngle));
    });

    test('angle is clamped between 0 and 90', () {
      final angle = calculateLineAngle(
        sinkerWeightOz: 0.0625,
        lineOutFt: 200.0,
        boatSpeedMph: 3.0,
      );
      expect(angle, greaterThanOrEqualTo(0.0));
      expect(angle, lessThanOrEqualTo(90.0));
    });
  });

  group('calculateDepthRatio', () {
    test('dead drift ratio is ~0.95', () {
      final ratio = calculateDepthRatio(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 0.0,
      );
      expect(ratio, closeTo(0.95, 0.01));
    });

    test('ratio decreases with speed', () {
      final slowRatio = calculateDepthRatio(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 0.5,
      );
      final fastRatio = calculateDepthRatio(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 2.0,
      );
      expect(slowRatio, greaterThan(fastRatio));
    });

    test('ratio is always between 0 and 1', () {
      final ratio = calculateDepthRatio(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 1.5,
      );
      expect(ratio, greaterThanOrEqualTo(0.0));
      expect(ratio, lessThanOrEqualTo(1.0));
    });
  });

  group('estimateLineOutForDepth', () {
    test('converges to correct line out for known depth', () {
      // First calculate the depth for a known config
      final knownDepth = calculateDepth(
        sinkerWeightOz: 0.5,
        lineOutFt: 30.0,
        boatSpeedMph: 1.0,
      );

      // Now estimate what line out would achieve that depth
      final estimatedLine = estimateLineOutForDepth(
        targetDepthFt: knownDepth,
        sinkerWeightOz: 0.5,
        boatSpeedMph: 1.0,
      );
      expect(estimatedLine, closeTo(30.0, 1.0));
    });

    test('deeper target needs more line', () {
      final shallowLine = estimateLineOutForDepth(
        targetDepthFt: 10.0,
        sinkerWeightOz: 0.5,
        boatSpeedMph: 1.0,
      );
      final deepLine = estimateLineOutForDepth(
        targetDepthFt: 20.0,
        sinkerWeightOz: 0.5,
        boatSpeedMph: 1.0,
      );
      expect(deepLine, greaterThan(shallowLine));
    });

    test('throws on non-positive target depth', () {
      expect(
        () => estimateLineOutForDepth(
          targetDepthFt: 0.0,
          sinkerWeightOz: 0.5,
          boatSpeedMph: 1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('result is within valid line out range', () {
      final lineOut = estimateLineOutForDepth(
        targetDepthFt: 15.0,
        sinkerWeightOz: 0.5,
        boatSpeedMph: 1.0,
      );
      expect(lineOut, greaterThanOrEqualTo(5.0));
      expect(lineOut, lessThanOrEqualTo(200.0));
    });
  });

  group('input validation', () {
    test('throws on NaN sinker weight', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: double.nan,
          lineOutFt: 20.0,
          boatSpeedMph: 1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on infinite line out', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.5,
          lineOutFt: double.infinity,
          boatSpeedMph: 1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on sinker weight below minimum', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.01,
          lineOutFt: 20.0,
          boatSpeedMph: 1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on sinker weight above maximum', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 5.0,
          lineOutFt: 20.0,
          boatSpeedMph: 1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on line out below minimum', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.5,
          lineOutFt: 3.0,
          boatSpeedMph: 1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on line out above maximum', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.5,
          lineOutFt: 250.0,
          boatSpeedMph: 1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on negative boat speed', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.5,
          lineOutFt: 20.0,
          boatSpeedMph: -1.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on boat speed above maximum', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.5,
          lineOutFt: 20.0,
          boatSpeedMph: 5.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on drag factor below minimum', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.5,
          lineOutFt: 20.0,
          boatSpeedMph: 1.0,
          lineDragFactor: 0.1,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('throws on drag factor above maximum', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.5,
          lineOutFt: 20.0,
          boatSpeedMph: 1.0,
          lineDragFactor: 3.0,
        ),
        throwsA(isA<SpiderRiggingInputException>()),
      );
    });

    test('exception includes parameter name and value', () {
      try {
        calculateDepth(
          sinkerWeightOz: -1.0,
          lineOutFt: 20.0,
          boatSpeedMph: 1.0,
        );
        fail('Should have thrown');
      } on SpiderRiggingInputException catch (e) {
        expect(e.parameterName, equals('sinkerWeightOz'));
        expect(e.invalidValue, equals(-1.0));
        expect(e.toString(), contains('sinkerWeightOz'));
      }
    });
  });

  group('boundary values', () {
    test('minimum valid inputs do not throw', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 0.0625,
          lineOutFt: 5.0,
          boatSpeedMph: 0.0,
          lineDragFactor: 0.5,
        ),
        returnsNormally,
      );
    });

    test('maximum valid inputs do not throw', () {
      expect(
        () => calculateDepth(
          sinkerWeightOz: 4.0,
          lineOutFt: 200.0,
          boatSpeedMph: 3.0,
          lineDragFactor: 2.0,
        ),
        returnsNormally,
      );
    });

    test('common preset weights all work', () {
      final weights = [0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5, 2.0];
      for (final w in weights) {
        final depth = calculateDepth(
          sinkerWeightOz: w,
          lineOutFt: 25.0,
          boatSpeedMph: 1.0,
        );
        expect(depth, greaterThan(0.0), reason: 'Weight $w should give positive depth');
        expect(depth, lessThanOrEqualTo(25.0), reason: 'Weight $w depth exceeds line out');
      }
    });
  });
}
