import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'features/timer/timer_screen.dart';
import 'features/timeline/timeline_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/security/security_provider.dart';
import 'features/security/biometric_lock_screen.dart';
import 'data/repositories/sobriety_repository.dart';
import 'features/timer/timer_provider.dart';

class ClearStateApp extends ConsumerStatefulWidget {
  const ClearStateApp({super.key});

  @override
  ConsumerState<ClearStateApp> createState() => _ClearStateAppState();
}

class _ClearStateAppState extends ConsumerState<ClearStateApp>
    with WidgetsBindingObserver {
  bool _showOnboarding = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer provider access until after the first frame to avoid !_dirty assertion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingStatus();
      _checkLockStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Lock the app when it goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final securityState = ref.read(securityProvider);
      if (securityState.biometricEnabled) {
        ref.read(securityProvider.notifier).lock();
      }
    }
  }

  void _checkOnboardingStatus() {
    final repository = ref.read(sobrietyRepositoryProvider);
    final profile = repository.getUserProfile();

    if (profile != null && profile.onboardingComplete) {
      setState(() => _showOnboarding = false);
      // Set the start date from profile
      ref.read(sobrietyStartDateProvider.notifier).state =
          profile.lastDrinkDate;
    }
  }

  void _checkLockStatus() {
    // Lock status is now managed by securityProvider, no local state needed
  }

  void _completeOnboarding() async {
    final repository = ref.read(sobrietyRepositoryProvider);
    final onboardingState = ref.read(onboardingProvider);

    // Save user profile
    await repository.saveUserProfile(
      lastDrinkDate: onboardingState.lastDrinkDate ?? DateTime.now(),
      avgDrinksPerWeek: onboardingState.drinksPerWeek,
      avgCostPerDrink: onboardingState.costPerDrink,
      defaultDrinkType: onboardingState.drinkType,
    );

    // Set the start date for timer
    ref.read(sobrietyStartDateProvider.notifier).state =
        onboardingState.lastDrinkDate;

    setState(() => _showOnboarding = false);
  }

  void _handleDataWiped() {
    // Reset to onboarding after data wipe
    setState(() {
      _showOnboarding = true;
      _currentIndex = 0;
    });
  }

  void _handleUnlock() {
    // State is managed by securityProvider, just trigger a rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Watch security state for changes
    final securityState = ref.watch(securityProvider);

    // Determine if we need to show lock screen
    final shouldShowLock =
        securityState.biometricEnabled && !securityState.isUnlocked;

    return MaterialApp(
      title: 'ClearState',
      debugShowCheckedModeBanner: false,
      theme: ClearStateTheme.darkTheme,
      home: _buildHome(shouldShowLock),
    );
  }

  Widget _buildHome(bool shouldShowLock) {
    // Show lock screen if biometric is enabled and not unlocked
    if (shouldShowLock && !_showOnboarding) {
      return BiometricLockScreen(onUnlocked: _handleUnlock);
    }

    // Show onboarding if needed
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    // Show main app
    return _MainShell(
      currentIndex: _currentIndex,
      onIndexChanged: (index) => setState(() => _currentIndex = index),
      onDataWiped: _handleDataWiped,
    );
  }
}

class _MainShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onDataWiped;

  const _MainShell({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onDataWiped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClearStateColors.void_,
      body: IndexedStack(
        index: currentIndex,
        children: [
          const TimerScreen(),
          const TimelineScreen(),
          const AnalyticsScreen(),
          SettingsScreen(onDataWiped: onDataWiped),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ClearStateColors.ash, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onIndexChanged,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'TIMER',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: 'TIMELINE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'STATS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined),
              activeIcon: Icon(Icons.tune),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}
