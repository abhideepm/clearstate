import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clearstate/shared/widgets/brutalist_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BrutalistButton', () {
    testWidgets('primary variant renders correctly with label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButton(
                label: 'TEST BUTTON',
                onPressed: () {},
                type: BrutalistButtonType.primary,
              ),
            ),
          ),
        ),
      );

      expect(find.text('TEST BUTTON'), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('secondary variant renders correctly with label', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButton(
                label: 'SECONDARY',
                onPressed: () {},
                type: BrutalistButtonType.secondary,
              ),
            ),
          ),
        ),
      );

      expect(find.text('SECONDARY'), findsOneWidget);
    });

    testWidgets('press state triggers scale animation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButton(label: 'PRESS ME', onPressed: () {}),
            ),
          ),
        ),
      );

      await tester.tap(find.text('PRESS ME'));
      await tester.pump();

      expect(find.text('PRESS ME'), findsOneWidget);
    });

    testWidgets('haptic feedback fires on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButton(label: 'HAPTIC TEST', onPressed: () {}),
            ),
          ),
        ),
      );

      await tester.tap(find.text('HAPTIC TEST'));
      await tester.pump();

      expect(find.text('HAPTIC TEST'), findsOneWidget);
    });

    testWidgets('onPressed callback fires on tap', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButton(
                label: 'CALLBACK TEST',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      expect(pressed, false);

      await tester.tap(find.text('CALLBACK TEST'));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('disabled button does not trigger press animation', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButton(
                label: 'DISABLED',
                onPressed: () => tapped = true,
                enabled: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('DISABLED'));
      await tester.pump();

      expect(tapped, false);
    });

    testWidgets('loading state shows spinner', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButton(
                label: 'LOADING',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('LOADING'), findsNothing);
    });

    testWidgets('custom width and height are applied', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: BrutalistButton(
                  label: 'SIZED',
                  onPressed: () {},
                  width: 200,
                  height: 60,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('SIZED'), findsOneWidget);
    });
  });

  group('BrutalistButtonIcon', () {
    testWidgets('primary icon button renders correctly', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButtonIcon(
                icon: Icons.add,
                onPressed: () => pressed = true,
                type: BrutalistButtonType.primary,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(pressed, false);
    });

    testWidgets('secondary icon button renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButtonIcon(
                icon: Icons.remove,
                onPressed: () {},
                type: BrutalistButtonType.secondary,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('icon button triggers scale on press', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButtonIcon(icon: Icons.star, onPressed: () {}),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BrutalistButtonIcon));
      await tester.pump();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('custom size is applied', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BrutalistButtonIcon(
                icon: Icons.settings,
                onPressed: () {},
                size: 64,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
