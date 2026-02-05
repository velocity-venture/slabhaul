import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/features/calculator/screens/calculator_screen.dart';
import 'package:slabhaul/features/calculator/widgets/depth_result_display.dart';
import 'package:slabhaul/features/calculator/widgets/depth_sliders.dart';
import 'package:slabhaul/features/calculator/widgets/preset_chips.dart';
import 'package:slabhaul/features/calculator/widgets/line_angle_diagram.dart';
import 'package:slabhaul/features/calculator/providers/calculator_providers.dart';

Widget buildTestApp({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: CalculatorScreen(),
    ),
  );
}

void main() {
  group('CalculatorScreen', () {
    testWidgets('renders all main sections', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Depth Calculator'), findsOneWidget);
      expect(find.byType(LineAngleDiagram), findsOneWidget);
      expect(find.byType(DepthResultDisplay), findsOneWidget);
      expect(find.byType(DepthSliders), findsOneWidget);
      expect(find.byType(PresetChips), findsOneWidget);
    });

    testWidgets('has reset button in app bar', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byTooltip('Reset'), findsOneWidget);
    });

    testWidgets('reset button restores default input state', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Modify the state via provider directly (avoids scrolling issues)
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalculatorScreen)),
      );
      container.read(calculatorInputProvider.notifier).applyPreset(
            sinkerWeightOz: 1.0,
            lineOutFt: 80.0,
            boatSpeedMph: 2.0,
          );
      await tester.pumpAndSettle();

      // Verify state changed
      var input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(1.0));

      // Tap reset
      await tester.tap(find.byTooltip('Reset'));
      await tester.pumpAndSettle();

      // Verify state restored to defaults
      input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(0.5));
      expect(input.lineOutFt, equals(50.0));
      expect(input.boatSpeedMph, equals(0.6));
    });
  });

  group('DepthResultDisplay', () {
    testWidgets('shows ft unit label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('ft'), findsOneWidget);
    });

    testWidgets('shows depth ratio and line angle stats', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Depth Ratio'), findsOneWidget);
      expect(find.text('Line Angle'), findsOneWidget);
    });

    testWidgets('shows depth zone badge', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Default inputs (0.5oz, 50ft, 0.6mph) should produce a depth zone.
      // Find any text widget containing "Zone" (case sensitive).
      final zoneWidgets = find.byWidgetPredicate((widget) {
        if (widget is Text && widget.data != null) {
          return widget.data!.contains('Zone') ||
              widget.data!.contains('Structure');
        }
        return false;
      });
      expect(zoneWidgets, findsOneWidget);
    });

    testWidgets('result updates when provider state changes', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalculatorScreen)),
      );

      // Set to dead drift for ~95% depth
      container.read(calculatorInputProvider.notifier).setBoatSpeed(0.0);
      container.read(calculatorInputProvider.notifier).setLineOut(10.0);
      await tester.pumpAndSettle();

      // Should show Spawn Zone for ~9.5ft depth
      final result = container.read(calculatorResultProvider);
      expect(result.depthZone, contains('Spawn'));
    });
  });

  group('DepthSliders', () {
    testWidgets('shows all slider labels', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Sinker Weight'), findsOneWidget);
      expect(find.text('Line Out'), findsOneWidget);
      expect(find.text('Boat Speed'), findsOneWidget);
    });

    testWidgets('shows three sliders', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsNWidgets(3));
    });

    testWidgets('shows default sinker weight label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Default sinker weight is 0.5 oz = "1/2 oz"
      expect(find.text('1/2 oz'), findsOneWidget);
    });

    testWidgets('shows default line out label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Default line out is 50.0
      expect(find.text('50 ft'), findsOneWidget);
    });

    testWidgets('shows default boat speed label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Default boat speed is 0.6
      expect(find.text('0.60 mph'), findsOneWidget);
    });

    testWidgets('shows line type choice chips', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to make line type visible
      await tester.scrollUntilVisible(
        find.text('Braid'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Mono'), findsOneWidget);
      expect(find.text('Fluoro'), findsOneWidget);
      expect(find.text('Braid'), findsOneWidget);
    });

    testWidgets('tapping line type chip updates selection', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to Braid chip
      await tester.scrollUntilVisible(
        find.text('Braid'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap Braid
      await tester.tap(find.text('Braid'));
      await tester.pumpAndSettle();

      // ChoiceChip for Braid should now be selected
      final braidChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Braid'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(braidChip.selected, isTrue);
    });

    testWidgets('line type change updates provider state', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalculatorScreen)),
      );

      // Change line type via provider directly
      container.read(calculatorInputProvider.notifier).setLineType('Braid');
      await tester.pumpAndSettle();

      final input = container.read(calculatorInputProvider);
      expect(input.lineType, equals('Braid'));
      expect(input.lineDragFactor, equals(0.7));
    });
  });

  group('PresetChips', () {
    testWidgets('shows all preset labels', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to preset section
      await tester.scrollUntilVisible(
        find.text('Quick Presets'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Quick Presets'), findsOneWidget);
      expect(find.text('Shallow (8-12ft)'), findsOneWidget);
      expect(find.text('Mid (15-20ft)'), findsOneWidget);
      expect(find.text('Deep (25+ft)'), findsOneWidget);
    });

    testWidgets('tapping preset chip updates provider state', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to deep preset
      await tester.scrollUntilVisible(
        find.text('Deep (25+ft)'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap Deep preset
      await tester.tap(find.text('Deep (25+ft)'));
      await tester.pumpAndSettle();

      // Verify state updated via provider
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalculatorScreen)),
      );
      final input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(1.0));
      expect(input.lineOutFt, equals(80.0));
      expect(input.boatSpeedMph, equals(0.8));
    });

    testWidgets('tapping Shallow preset updates provider state',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to shallow preset
      await tester.scrollUntilVisible(
        find.text('Shallow (8-12ft)'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shallow (8-12ft)'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalculatorScreen)),
      );
      final input = container.read(calculatorInputProvider);
      expect(input.sinkerWeightOz, equals(0.25));
      expect(input.lineOutFt, equals(20.0));
      expect(input.boatSpeedMph, equals(0.4));
    });

    testWidgets('active preset shows check icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Apply the Mid preset via provider (avoids scroll issues for tap)
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalculatorScreen)),
      );
      container.read(calculatorInputProvider.notifier).applyPreset(
            sinkerWeightOz: 0.5,
            lineOutFt: 50.0,
            boatSpeedMph: 0.6,
          );
      await tester.pumpAndSettle();

      // Scroll to preset section
      await tester.scrollUntilVisible(
        find.text('Mid (15-20ft)'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Active chip should have a check icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
