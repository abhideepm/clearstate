import 'package:flutter_test/flutter_test.dart';
import 'package:clearstate/features/timer/timer_provider.dart';

void main() {
  group('TimerComponents', () {
    test('breaks down duration correctly (simple case)', () {
      final duration = Duration(days: 1, hours: 2, minutes: 3, seconds: 4);
      final components = TimerComponents.fromDuration(duration);

      expect(components.years, 0);
      expect(components.months, 0);
      expect(components.days, 1);
      expect(components.hours, 2);
      expect(components.minutes, 3);
      expect(components.seconds, 4);
    });

    test('calculates years and months correctly', () {
      // 400 days = 1 year (365) + 1 month (30) + 5 days
      final duration = Duration(days: 400);
      final components = TimerComponents.fromDuration(duration);

      expect(components.years, 1);
      expect(components.months, 1);
      expect(components.days, 5);
    });

    test('handles zero duration', () {
      final components = TimerComponents.fromDuration(Duration.zero);

      expect(components.years, 0);
      expect(components.months, 0);
      expect(components.days, 0);
      expect(components.hours, 0);
      expect(components.minutes, 0);
      expect(components.seconds, 0);
    });

    test('handles large durations', () {
      // 1000 days = 2 years (730) + 9 months (270) + 0 days
      final duration = Duration(days: 1000);
      final components = TimerComponents.fromDuration(duration);

      expect(components.years, 2);
      expect(components.months, 9);
      expect(components.days, 0);
    });
  });
}
