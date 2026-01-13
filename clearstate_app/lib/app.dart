import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'features/timer/timer_screen.dart';
import 'features/timeline/timeline_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'data/repositories/sobriety_repository.dart';
import 'features/timer/timer_provider.dart';

class ClearStateApp extends ConsumerStatefulWidget {
  const ClearStateApp({super.key});

  @override
  ConsumerState<ClearStateApp> createState() => _ClearStateAppState();
}

class _ClearStateAppState extends ConsumerState<ClearStateApp> {
  bool _showOnboarding = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Defer provider access until after the first frame to avoid !_dirty assertion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingStatus();
    });
  }

  void _checkOnboardingStatus() {
    final repository = ref.read(sobrietyRepositoryProvider);
    final profile = repository.getUserProfile();
    
    if (profile != null && profile.onboardingComplete) {
      setState(() => _showOnboarding = false);
      // Set the start date from profile
      ref.read(sobrietyStartDateProvider.notifier).state = profile.lastDrinkDate;
    }
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
    ref.read(sobrietyStartDateProvider.notifier).state = onboardingState.lastDrinkDate;
    
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearState',
      debugShowCheckedModeBanner: false,
      theme: ClearStateTheme.darkTheme,
      home: _showOnboarding
          ? OnboardingScreen(onComplete: _completeOnboarding)
          : _MainShell(
              currentIndex: _currentIndex,
              onIndexChanged: (index) => setState(() => _currentIndex = index),
            ),
    );
  }
}

class _MainShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const _MainShell({
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClearStateColors.void_,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          TimerScreen(),
          TimelineScreen(),
          AnalyticsScreen(),
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
          ],
        ),
      ),
    );
  }
}
