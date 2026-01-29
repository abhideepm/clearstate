import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:truestate/data/repositories/sobriety_repository.dart';
import 'package:truestate/data/models/user_profile.dart';
import 'package:truestate/data/models/habit.dart';
import 'package:truestate/data/models/sobriety_session.dart';
import 'package:truestate/data/models/relapse_event.dart';
import 'package:truestate/data/models/daily_log.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel notificationChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationChannel, (
          MethodCall methodCall,
        ) async {
          return null; // Successfully handled
        });
  });

  late SobrietyRepository repository;
  late Directory tempDir;
  const habitId = 'test-habit';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clearstate_test');
    Hive.init(tempDir.path);

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RelapseEventAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DailyLogAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(HabitTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(SobrietySessionAdapter());
    }

    repository = SobrietyRepository();
    await repository.init();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('SobrietyRepository', () {
    test('initially returns null profile and active session', () {
      expect(repository.getUserProfile(), isNull);
      expect(repository.getActiveSession(habitId), isNull);
    });

    test('saveUserProfile saves profile', () async {
      await repository.saveUserProfile(
        selectedHabitIds: [habitId],
        onboardingComplete: true,
      );

      final profile = repository.getUserProfile();
      expect(profile, isNotNull);
      expect(profile!.selectedHabitIds, contains(habitId));
      expect(profile.onboardingComplete, isTrue);
    });

    test('startNewSession creates active session', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 5));
      await repository.saveUserProfile(
        selectedHabitIds: [habitId],
        onboardingComplete: true,
      );

      await repository.startNewSession(habitId, startDate: startDate);

      final session = repository.getActiveSession(habitId);
      expect(session, isNotNull);
      expect(session!.startDate, startDate);
      expect(session.isActive, isTrue);
    });

    test('logRelapse logs event and resets timer', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 5));
      await repository.saveUserProfile(
        selectedHabitIds: [habitId],
        onboardingComplete: true,
      );

      // Create a habit for the test
      await repository.saveHabit(
        Habit(
          id: habitId,
          name: 'Test Habit',
          type: HabitType.substance,
          themeColor: '#FF0000',
          motivation: 'Testing',
          startDate: startDate,
        ),
      );

      await repository.startNewSession(habitId, startDate: startDate);

      await repository.logRelapse(habitId);

      // After relapse, habit startDate is reset
      final habit = repository.getHabit(habitId);
      expect(habit, isNotNull);
      // New start date should be approximately now
      expect(
        habit!.startDate.difference(DateTime.now()).inMinutes.abs(),
        lessThan(1),
      );
    });

    test('nukeAllData clears all boxes', () async {
      await repository.saveUserProfile(
        selectedHabitIds: [habitId],
        onboardingComplete: true,
      );

      expect(repository.getUserProfile(), isNotNull);

      await repository.nukeAllData();

      expect(repository.getUserProfile(), isNull);
      expect(repository.getActiveSession(habitId), isNull);
      expect(repository.getTotalSlips(habitId), 0);
    });
  });
}
