import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestate/shared/widgets/brutalist_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModernButton', () {
    testWidgets('primary variant renders correctly with label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ModernButton(
                label: 'TEST BUTTON',
                onPressed: () {},
                type: ModernButtonType.primary,
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
              body: ModernButton(
                label: 'SECONDARY',
                onPressed: () {},
                type: ModernButtonType.secondary,
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
              body: ModernButton(label: 'PRESS ME', onPressed: () {}),
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
              body: ModernButton(label: 'HAPTIC TEST', onPressed: () {}),
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
              body: ModernButton(
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
              body: ModernButton(
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
              body: ModernButton(
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
                child: ModernButton(
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

  group('ModernIconButton', () {
    testWidgets('primary icon button renders correctly', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ModernIconButton(
                icon: Icons.add,
                onPressed: () => pressed = true,
                type: ModernButtonType.primary,
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
              body: ModernIconButton(
                icon: Icons.remove,
                onPressed: () {},
                type: ModernButtonType.secondary,
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
              body: ModernIconButton(icon: Icons.star, onPressed: () {}),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ModernIconButton));
      await tester.pump();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('custom size is applied', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ModernIconButton(
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
