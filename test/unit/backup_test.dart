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

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('truestate_backup_test');
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
    await repository.nukeAllData();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('SobrietyRepository Backup & Restore', () {
    test('exportData returns correct structure', () async {
      const habitId = 'test-habit';
      // Setup some data
      await repository.saveUserProfile(
        selectedHabitIds: [habitId],
        onboardingComplete: true,
      );

      await repository.logDay(
        date: DateTime(2023, 1, 2),
        habitId: habitId,
        isSober: true,
      );

      final data = repository.exportData();

      expect(data['version'], SobrietyRepository.currentSchemaVersion);
      expect(data['profile'], isNotNull);
      expect(data['habits'], isNotNull, reason: 'Export should contain habits');
      expect(data['daily_logs'], isNotEmpty);
      expect(data['relapses'], isEmpty);
    });

    test('importData restores habits correctly', () async {
      final habit = Habit(
        id: 'test-habit-import',
        name: 'Import Habit',
        type: HabitType.substance,
        themeColor: '#4CAF50',
        motivation: 'Motivation',
        startDate: DateTime(2023, 1, 1),
      );
      await repository.saveHabit(habit);

      final data = repository.exportData();
      await repository.nukeAllData();
      expect(repository.getAllHabits(), isEmpty);

      await repository.importData(data);
      final restored = repository.getHabit('test-habit-import');
      expect(restored, isNotNull, reason: 'Habit should be restored');
      expect(restored?.name, 'Import Habit');
    });

    test('restored DailyLog is accessible via composite key', () async {
      const habitId = 'key-test-habit';
      final date = DateTime(2023, 5, 20);

      await repository.logDay(
        date: date,
        habitId: habitId,
        isSober: true,
      );

      final data = repository.exportData();
      await repository.nukeAllData();
      await repository.importData(data);

      final restoredLog = repository.getDailyLog(habitId, date);
      expect(restoredLog, isNotNull, reason: 'DailyLog should be accessible via composite key after restoration');
    });

    test('importData restores state correctly', () async {
      final exportDate = DateTime(2023, 1, 1);
      final testData = {
        'version': 1,
        'profile': {
          'onboardingComplete': true,
          'selectedHabitIds': ['default'],
          'lastDrinkDate': exportDate.toIso8601String(),
        },
        'sessions': [
          {
            'id': 'session1',
            'habitId': 'default',
            'startDate': exportDate.toIso8601String(),
            'endDate': null,
          },
        ],
        'relapses': [],
        'daily_logs': [
          {
            'date': exportDate.toIso8601String(),
            'habitId': 'default',
            'moodScore': 5,
            'symptoms': <String>[],
            'isSlip': false,
            'isRelapse': false,
          },
        ],
      };

      await repository.importData(testData);

      final profile = repository.getUserProfile();
      expect(profile, isNotNull);
      expect(profile!.onboardingComplete, true);

      final activeSession = repository.getActiveSession('default');
      expect(activeSession, isNotNull);
      expect(activeSession!.id, 'session1');
    });
  });
}
