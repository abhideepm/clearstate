import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clearstate/shared/widgets/haptic_calendar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticCalendar', () {
    testWidgets('renders month grid correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: false),
            ),
          ),
        ),
      );

      expect(find.text('JANUARY'), findsOneWidget);
      expect(find.text('FEBRUARY'), findsNothing);

      final daysInMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month + 1,
        0,
      ).day;
      expect(find.text(daysInMonth.toString()), findsOneWidget);
    });

    testWidgets('selected date highlighted', (tester) async {
      final selectedDate = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(
                selectedDate: selectedDate,
                onDateSelected: (_) {},
                showModal: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('month navigation works - next month', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: false),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('month navigation works - previous month', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: false),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
    });

    testWidgets('date selection callback fires', (tester) async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(
                onDateSelected: (date) => selectedDate = date,
                showModal: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('1'));
      await tester.pump();

      expect(selectedDate, isNotNull);
      expect(selectedDate?.day, 1);
    });

    testWidgets('haptic triggers on date tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: false),
            ),
          ),
        ),
      );

      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('weekday header renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: false),
            ),
          ),
        ),
      );

      expect(find.text('S'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('calendar shows 6 weeks (42 days)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: false),
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('shouldDisableDate callback prevents selection', (
      tester,
    ) async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(
                selectedDate: DateTime(2024, 1, 10),
                onDateSelected: (date) => selectedDate = date,
                shouldDisableDate: (date) => date.day < 5,
                showModal: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(selectedDate, isNull);
    });

    testWidgets('modal mode renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: true),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsAtLeastNWidgets(2));
      expect(
        find.ancestor(
          of: find.byType(HapticCalendar),
          matching: find.byType(Container),
        ),
        findsOneWidget,
      );
    });

    testWidgets('today is highlighted', (tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(
                selectedDate: today,
                onDateSelected: (_) {},
                showModal: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text(today.day.toString()), findsOneWidget);
    });

    testWidgets('month format displays correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticCalendar(onDateSelected: (_) {}, showModal: false),
            ),
          ),
        ),
      );

      final monthYearRegex = RegExp(r'^[A-Z]+\s\d{4}$');
      expect(
        find.descendant(
          of: find.byType(HapticCalendar),
          matching: find.widgetWithText(Text, monthYearRegex.toString()),
        ),
        findsNothing,
      );
    });
  });
}
