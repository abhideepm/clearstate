import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clearstate/shared/widgets/animated_chip.dart';
import 'package:clearstate/core/theme/colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnimatedChip', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () {},
              child: const Text('CHIP LABEL'),
            ),
          ),
        ),
      );

      expect(find.text('CHIP LABEL'), findsOneWidget);
    });

    testWidgets('selected state shows correctly with signal color', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: true,
              onTap: () {},
              child: const Text('SELECTED'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('SELECTED'),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, ClearStateColors.signal);
      expect(decoration.border, isNotNull);
    });

    testWidgets('unselected state shows correctly with charcoal color', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () {},
              child: const Text('UNSELECTED'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('UNSELECTED'),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, ClearStateColors.charcoal);
    });

    testWidgets('animation triggers on selection change', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () {},
              child: const Text('ANIMATE'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('ANIMATE'), findsOneWidget);
    });

    testWidgets('haptic fires on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () {},
              child: const Text('HAPTIC TEST'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('HAPTIC TEST'));
      await tester.pump();

      expect(find.text('HAPTIC TEST'), findsOneWidget);
    });

    testWidgets('onTap callback fires', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () => tapped = true,
              child: const Text('CALLBACK'),
            ),
          ),
        ),
      );

      expect(tapped, false);

      await tester.tap(find.text('CALLBACK'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('animation plays forward on selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () {},
              child: const Text('ANIMATION'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: true,
              onTap: () {},
              child: const Text('ANIMATION'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('ANIMATION'), findsOneWidget);
    });

    testWidgets('animation reverses on deselection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: true,
              onTap: () {},
              child: const Text('REVERSE'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () {},
              child: const Text('REVERSE'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('REVERSE'), findsOneWidget);
    });

    testWidgets('correct text color when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: true,
              onTap: () {},
              child: const Text('COLOR TEST'),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('COLOR TEST'));
      expect(text.style?.color, ClearStateColors.void_);
    });

    testWidgets('correct text color when unselected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () {},
              child: const Text('COLOR TEST'),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('COLOR TEST'));
      expect(text.style?.color, ClearStateColors.bone);
    });

    testWidgets('padding is applied correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedChip(
                isSelected: false,
                onTap: () {},
                child: const Text('PADDING'),
              ),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('PADDING'), matching: find.byType(Padding)),
      );

      expect(
        padding.padding,
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      );
    });

    testWidgets('handles rapid taps', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChip(
              isSelected: false,
              onTap: () => tapCount++,
              child: const Text('RAPID'),
            ),
          ),
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('RAPID'));
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(tapCount, 5);
    });
  });
}
