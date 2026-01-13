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
    tempDir = await Directory.systemTemp.createTemp('clearstate_test');
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
      expect(repository.getActiveSession(), isNull);
    });

    test('saveUserProfile saves profile and starts session', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 1));
      await repository.saveUserProfile(
        lastDrinkDate: startDate,
        avgDrinksPerWeek: 7,
        avgCostPerDrink: 10.0,
        defaultDrinkType: 'Beer',
      );

      final profile = repository.getUserProfile();
      expect(profile, isNotNull);
      expect(profile!.avgDrinksPerWeek, 7);
      expect(profile.onboardingComplete, isTrue);

      final session = repository.getActiveSession();
      expect(session, isNotNull);
      expect(session!.startDate, startDate);
      expect(session.isActive, isTrue);
    });

    test('logRelapse ends current session and starts new one', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 5));
      await repository.saveUserProfile(
        lastDrinkDate: startDate,
        avgDrinksPerWeek: 7,
        avgCostPerDrink: 10.0,
        defaultDrinkType: 'Beer',
      );

      final oldSession = repository.getActiveSession();

      await repository.logRelapse(
        drinksConsumed: 5,
        costIncurred: 50.0,
        caloriesConsumed: 1000,
        drinkType: 'Beer',
      );

      final currentSession = repository.getActiveSession();
      expect(currentSession!.id, isNot(oldSession!.id));
      expect(currentSession.isActive, isTrue);
      expect(repository.getTotalRelapses(), 1);
    });

    test('nukeAllData clears all boxes', () async {
      await repository.saveUserProfile(
        lastDrinkDate: DateTime.now(),
        avgDrinksPerWeek: 7,
        avgCostPerDrink: 10.0,
        defaultDrinkType: 'Beer',
      );

      expect(repository.getUserProfile(), isNotNull);

      await repository.nukeAllData();

      expect(repository.getUserProfile(), isNull);
      expect(repository.getActiveSession(), isNull);
      expect(repository.getTotalRelapses(), 0);
    });
  });
}
