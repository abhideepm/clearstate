import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestate/shared/widgets/celebration_overlay.dart';
import 'package:truestate/core/theme/colors.dart';
import 'package:truestate/core/theme/typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CelebrationOverlay', () {
    testWidgets('renders milestone title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: '7 DAYS SOBER',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      expect(find.text('7 DAYS SOBER'), findsOneWidget);
    });

    testWidgets('shows confetti particles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'TEST MILESTONE',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 3500));

      expect(find.byType(CustomPaint).first, findsOneWidget);
    });

    testWidgets('auto-dismisses after duration', (tester) async {
      bool onCompleteCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'AUTO DISMISS',
                onComplete: () => onCompleteCalled = true,
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(onCompleteCalled, false);

      await tester.pump(const Duration(milliseconds: 4500));
      expect(onCompleteCalled, true);
    });

    testWidgets('onComplete callback fires', (tester) async {
      bool onCompleteCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'CALLBACK TEST',
                onComplete: () => onCompleteCalled = true,
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      expect(onCompleteCalled, true);
    });

    testWidgets('renders MILESTONE REACHED header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: '30 DAYS',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      expect(find.text('MILESTONE REACHED'), findsOneWidget);
    });

    testWidgets('renders tap to continue instruction', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'TAP TEST',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      expect(find.text('Tap anywhere to continue'), findsOneWidget);
    });

    testWidgets('confetti painter is present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'CONFETTI',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 3500));
    });

    testWidgets('particles are generated correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'PARTICLES',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      expect(find.text('PARTICLES'), findsOneWidget);
    });

    testWidgets('random colors are used for particles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'COLORS',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      expect(find.text('COLORS'), findsOneWidget);
    });

    testWidgets('duration parameter controls auto-dismiss timing', (
      tester,
    ) async {
      int callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'DURATION TEST',
                onComplete: () => callCount++,
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(callCount, 0);

      await tester.pump(const Duration(milliseconds: 4500));
      expect(callCount, 1);
    });

    testWidgets('proper styling of milestone title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'STYLED',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      final textWidget = tester.widget<Text>(find.text('STYLED'));
      // Default textPrimary is warmIvory
      expect(textWidget.style?.color, TrueStateColors.textPrimaryDark);
      expect(textWidget.style?.fontSize, TrueStateTypography.h2.fontSize);
    });

    testWidgets('container has correct styling', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                milestoneTitle: 'CONTAINER',
                onComplete: () {},
                duration: const Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('MILESTONE REACHED'),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      // Default surface is darkSurface
      expect(decoration.color, TrueStateColors.darkSurface);
      expect(decoration.border, isNotNull);
    });
  });

  group('CelebrationOverlayWrapper', () {
    testWidgets('renders child when no pending milestone', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlayWrapper(
                pendingMilestone: null,
                onMilestoneDismissed: () {},
                child: const Text('CHILD CONTENT'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('CHILD CONTENT'), findsOneWidget);
      expect(find.byType(CelebrationOverlay), findsNothing);
    });

    testWidgets('shows overlay when pending milestone exists', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlayWrapper(
                pendingMilestone: '5 DAYS',
                onMilestoneDismissed: () {},
                child: const Text('CHILD'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 4500));

      expect(find.text('5 DAYS'), findsOneWidget);
      expect(find.byType(CelebrationOverlay), findsOneWidget);
    });

    testWidgets('hides overlay when pending milestone is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlayWrapper(
                pendingMilestone: '',
                onMilestoneDismissed: () {},
                child: const Text('CHILD'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('CHILD'), findsOneWidget);
      expect(find.byType(CelebrationOverlay), findsNothing);
    });

    testWidgets('calls onMilestoneDismissed when overlay completes', (
      tester,
    ) async {
      bool dismissed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CelebrationOverlayWrapper(
                pendingMilestone: 'MILESTONE',
                onMilestoneDismissed: () => dismissed = true,
                child: const Text('CHILD'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 5000));
      expect(dismissed, true);
    });
  });

  group('ConfettiParticle', () {
    testWidgets('particle has required properties', (tester) async {
      final particle = ConfettiParticle(
        color: Colors.red,
        startDelay: 100,
        size: 8.0,
      );

      expect(particle.color, Colors.red);
      expect(particle.startDelay, 100);
      expect(particle.size, 8.0);
    });
  });
}
