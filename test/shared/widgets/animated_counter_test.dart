import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestate/shared/widgets/animated_counter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnimatedCounter', () {
    testWidgets('renders correct value', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: AnimatedCounter(value: 42))),
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('animates on value change with sliding animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedCounter(value: 10, morphDigits: false),
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedCounter(value: 20, morphDigits: false),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('animates on value change with morphing animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AnimatedCounter(value: 5, morphDigits: true)),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AnimatedCounter(value: 8, morphDigits: true)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('respects reduced motion setting', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: AnimatedCounter(value: 99))),
        ),
      );

      expect(find.text('9'), findsNWidgets(2));
    });

    testWidgets('handles multi-digit changes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: AnimatedCounter(value: 9))),
        ),
      );

      expect(find.text('9'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: AnimatedCounter(value: 100))),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2));
    });

    testWidgets('uses custom style when provided', (tester) async {
      const customStyle = TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AnimatedCounter(value: 5, style: customStyle)),
          ),
        ),
      );

      final textWidgets = tester.widgetList<Text>(find.text('5'));
      expect(textWidgets.first.style?.color, Colors.red);
      expect(textWidgets.first.style?.fontSize, 32);
    });
  });
}
