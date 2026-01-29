import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the sobriety start date (loaded from storage)
final sobrietyStartDateProvider = StateProvider<DateTime?>((ref) => null);

// Provider that streams elapsed duration, updating every second
final elapsedDurationProvider = StreamProvider<Duration>((ref) async* {
  final startDate = ref.watch(sobrietyStartDateProvider);

  if (startDate == null) {
    yield Duration.zero;
    return;
  }

  // Yield initial value immediately
  yield DateTime.now().difference(startDate);

  // Then yield update every second
  yield* Stream.periodic(const Duration(seconds: 1), (_) {
    return DateTime.now().difference(startDate);
  });
});

// Helper class to break down duration into components
class TimerComponents {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  TimerComponents({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  factory TimerComponents.fromDuration(Duration duration) {
    final totalDays = duration.inDays;
    final years = totalDays ~/ 365;
    final remainingAfterYears = totalDays % 365;
    final months = remainingAfterYears ~/ 30;
    final days = remainingAfterYears % 30;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return TimerComponents(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
}

// Provider for timer components
final timerComponentsProvider = Provider<TimerComponents>((ref) {
  final durationAsync = ref.watch(elapsedDurationProvider);
  
  return durationAsync.when(
    data: (duration) => TimerComponents.fromDuration(duration),
    loading: () {
      // Calculate synchronously from start date to avoid flickering "000"
      final startDate = ref.read(sobrietyStartDateProvider);
      if (startDate == null) return TimerComponents.fromDuration(Duration.zero);
      return TimerComponents.fromDuration(DateTime.now().difference(startDate));
    },
    error: (_, _) => TimerComponents.fromDuration(Duration.zero),
  );
});
