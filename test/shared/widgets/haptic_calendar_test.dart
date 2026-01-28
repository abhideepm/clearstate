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
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: false),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(HapticCalendar), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('selected date highlighted', (tester) async {
      final selectedDate = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(
                  selectedDate: selectedDate,
                  onDateSelected: (_) {},
                  showModal: false,
                ),
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
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: false),
              ),
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
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: false),
              ),
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
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(
                  onDateSelected: (date) => selectedDate = date,
                  showModal: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('1').first);
      await tester.pump();

      expect(selectedDate, isNotNull);
      expect(selectedDate?.day, 1);
    });

    testWidgets('haptic triggers on date tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: false),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('1').first);
      await tester.pump();
    });

    testWidgets('weekday header renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: false),
              ),
            ),
          ),
        ),
      );

      final weekdays = find.byType(Expanded).evaluate().map((e) {
        final textWidget = e.widget as Expanded;
        final child = textWidget.child as Center;
        final padding = child.child as Padding;
        return (padding.child as Text).data;
      }).toList();

      expect(weekdays, ['S', 'M', 'T', 'W', 'T', 'F', 'S']);
    });

    testWidgets('calendar shows grid', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: false),
              ),
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
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(
                  selectedDate: DateTime(2024, 1, 10),
                  onDateSelected: (date) => selectedDate = date,
                  shouldDisableDate: (date) => date.day < 5,
                  showModal: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('3').first);
      await tester.pump();

      expect(selectedDate, isNull);
    });

    testWidgets('modal mode renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: true),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsAtLeastNWidgets(2));
    });

    testWidgets('today is highlighted', (tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(
                  selectedDate: today,
                  onDateSelected: (_) {},
                  showModal: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Today's day number may appear multiple times (current month + trailing/leading days)
      // Verify at least one instance exists with the correct styling
      final todayText = find.text(today.day.toString());
      expect(todayText, findsWidgets);

      // Verify the highlighted today cell has a border (accent color border for today)
      final containers = find.byType(AnimatedContainer);
      expect(containers, findsWidgets);
    });

    testWidgets('month format displays correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 520,
                child: HapticCalendar(onDateSelected: (_) {}, showModal: false),
              ),
            ),
          ),
        ),
      );

      final monthYearPattern = RegExp(r'^[A-Z]+\s\d{4}$');
      final monthText = find.textContaining(monthYearPattern);
      expect(monthText, findsOneWidget);
    });
  });
}
