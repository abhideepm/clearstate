import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:clearstate/data/repositories/sobriety_repository.dart';
import 'package:clearstate/data/models/user_profile.dart';
import 'package:clearstate/data/models/sobriety_session.dart';
import 'package:clearstate/data/models/relapse_event.dart';
import 'package:clearstate/data/models/daily_log.dart';

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
    tempDir = await Directory.systemTemp.createTemp('clearstate_backup_test');
    Hive.init(tempDir.path);

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SobrietySessionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RelapseEventAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DailyLogAdapter());
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
      // Setup some data
      await repository.saveUserProfile(
        lastDrinkDate: DateTime(2023, 1, 1),
        avgDrinksPerWeek: 5,
        avgCostPerDrink: 10.0,
        defaultDrinkType: 'Beer',
      );

      await repository.logDay(DateTime(2023, 1, 2), true);

      final data = repository.exportData();

      expect(data['version'], SobrietyRepository.currentSchemaVersion);
      expect(data['profile'], isNotNull);
      expect(data['profile']['avgDrinksPerWeek'], 5);
      expect(data['sessions'], isNotEmpty);
      expect(data['daily_logs'], isNotEmpty);
      expect(data['relapses'], isEmpty);
    });

    test('importData restores state correctly', () async {
      final exportDate = DateTime(2023, 1, 1);
      final testData = {
        'version': 1,
        'profile': {
          'lastDrinkDate': exportDate.toIso8601String(),
          'avgDrinksPerWeek': 14,
          'avgCostPerDrink': 5.5,
          'avgCaloriesPerDrink': 200,
          'defaultDrinkType': 'Wine',
          'onboardingComplete': true,
        },
        'sessions': [
          {
            'id': 'session1',
            'startDate': exportDate.toIso8601String(),
            'endDate': null,
          },
        ],
        'relapses': [],
        'daily_logs': [
          {
            'date': exportDate.toIso8601String(),
            'isSober': true,
            'drinksConsumed': null,
          },
        ],
      };

      await repository.importData(testData);

      final profile = repository.getUserProfile();
      expect(profile, isNotNull);
      expect(profile!.avgDrinksPerWeek, 14);
      expect(profile.defaultDrinkType, 'Wine');

      final activeSession = repository.getActiveSession();
      expect(activeSession, isNotNull);
      expect(activeSession!.id, 'session1');

      final log = repository.getDayLog(exportDate);
      expect(log, isNotNull);
      expect(log!.isSober, true);
    });
  });
}
