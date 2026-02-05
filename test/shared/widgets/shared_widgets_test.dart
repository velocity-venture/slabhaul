import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slabhaul/shared/widgets/error_card.dart';
import 'package:slabhaul/shared/widgets/teal_button.dart';
import 'package:slabhaul/shared/widgets/info_chip.dart';
import 'package:slabhaul/shared/widgets/section_header.dart';
import 'package:slabhaul/shared/widgets/skeleton_loader.dart';

Widget wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('ErrorCard', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const ErrorCard(message: 'Something went wrong'),
      ));

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        ErrorCard(message: 'Error', onRetry: () {}),
      ));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const ErrorCard(message: 'Error'),
      ));

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('retry button triggers callback', (tester) async {
      int retryCount = 0;
      await tester.pumpWidget(wrapInApp(
        ErrorCard(
          message: 'Error',
          onRetry: () => retryCount++,
        ),
      ));

      await tester.tap(find.text('Retry'));
      expect(retryCount, equals(1));
    });
  });

  group('TealButton', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(wrapInApp(
        TealButton(label: 'Save', onPressed: () {}),
      ));

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('triggers onPressed callback', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(wrapInApp(
        TealButton(label: 'Tap Me', onPressed: () => tapCount++),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapCount, equals(1));
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        TealButton(label: 'Add', icon: Icons.add, onPressed: () {}),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('renders without icon when not provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        TealButton(label: 'Plain', onPressed: () {}),
      ));

      expect(find.text('Plain'), findsOneWidget);
      // Should be a regular ElevatedButton, not ElevatedButton.icon
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('expanded fills width', (tester) async {
      await tester.pumpWidget(wrapInApp(
        TealButton(label: 'Wide', expanded: true, onPressed: () {}),
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(double.infinity));
    });

    testWidgets('button is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const TealButton(label: 'Disabled'),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });

  group('InfoChip', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const InfoChip(label: 'Active'),
      ));

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const InfoChip(label: 'Status', icon: Icons.check_circle),
      ));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('renders without icon when not provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const InfoChip(label: 'Plain'),
      ));

      expect(find.text('Plain'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const SectionHeader(title: 'Weather'),
      ));

      expect(find.text('Weather'), findsOneWidget);
    });

    testWidgets('shows trailing widget when provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        SectionHeader(
          title: 'Section',
          trailing: TextButton(onPressed: () {}, child: const Text('See All')),
        ),
      ));

      expect(find.text('Section'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
    });

    testWidgets('renders without trailing when not provided', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const SectionHeader(title: 'Solo'),
      ));

      expect(find.text('Solo'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });
  });

  group('SkeletonCard', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const SkeletonCard(),
      ));

      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const SkeletonCard(height: 200),
      ));

      expect(find.byType(SkeletonCard), findsOneWidget);
    });
  });

  group('SkeletonLine', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const SkeletonLine(),
      ));

      expect(find.byType(SkeletonLine), findsOneWidget);
    });

    testWidgets('renders with custom width and height', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const SkeletonLine(width: 100, height: 20),
      ));

      expect(find.byType(SkeletonLine), findsOneWidget);
    });
  });

  group('WeatherCardSkeleton', () {
    testWidgets('renders composite skeleton layout', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const WeatherCardSkeleton(),
      ));

      expect(find.byType(WeatherCardSkeleton), findsOneWidget);
      expect(find.byType(SkeletonLine), findsNWidgets(4));
    });
  });
}
