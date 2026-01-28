import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/haptic_service.dart';
import 'core/services/sobriety_orchestrator.dart';
import 'features/timer/timer_screen.dart';
import 'features/timeline/timeline_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/onboarding_provider.dart';
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
      // Trigger initial widget update (safe - checks lock status)
      _updateWidgetsOnResume();
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

    // Toggle Android privacy screen (FLAG_SECURE)
    _updatePrivacyScreen(state);

    // Lock the app when it goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final securityState = ref.read(securityProvider);
      if (securityState.biometricEnabled) {
        ref.read(securityProvider.notifier).lock();
        // Clear widgets for privacy when locking
        try {
          ref.read(sobrietyOrchestratorProvider).clearWidgetsForPrivacy();
        } catch (e) {
          debugPrint('Error clearing widgets on lock: $e');
        }
      }
    }

    // Update widgets when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      _updateWidgetsOnResume();
    }
  }

  /// Updates home screen widgets when the app returns to foreground.
  /// SECURITY: Only updates if biometric lock is NOT active (user authenticated).
  void _updateWidgetsOnResume() {
    try {
      final securityState = ref.read(securityProvider);

      // Security: Don't update widgets if biometric lock is enabled but not unlocked.
      // This prevents exposing sobriety data on home screen when app is locked.
      if (securityState.biometricEnabled && !securityState.isUnlocked) {
        debugPrint('Skipping widget update: biometric lock active');
        return;
      }

      final orchestrator = ref.read(sobrietyOrchestratorProvider);
      orchestrator.triggerWidgetUpdate();
    } catch (e) {
      debugPrint('Error updating widgets on resume: $e');
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
    final orchestrator = ref.read(sobrietyOrchestratorProvider);
    final onboardingState = ref.read(onboardingProvider);

    // Request notification permissions during onboarding completion
    await NotificationService.instance.requestPermissions();

    // Use the same start date for both profile and timer provider
    final startDate = onboardingState.lastDrinkDate ?? DateTime.now();

    // Save user profile (this also starts the session and schedules notifications)
    await orchestrator.saveUserProfile(
      selectedHabitIds: const ['default'],
      lastDrinkDate: startDate,
      avgDailySpend: 0,
    );

    // Set the start date for timer (must match what was saved to profile)
    ref.read(sobrietyStartDateProvider.notifier).state = startDate;

    setState(() => _showOnboarding = false);
  }

  void _handleDataWiped() {
    setState(() {
      _showOnboarding = true;
      _currentIndex = 0;
    });
  }

  void _handleUnlock() {
    setState(() {});
    // Update widgets after successful unlock
    _updateWidgetsOnResume();
    // Refresh privacy screen state
    _updatePrivacyScreen(WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed);
  }

  /// Toggles the Android system-level privacy flag (FLAG_SECURE).
  /// This obscures the app in the task switcher.
  Future<void> _updatePrivacyScreen(AppLifecycleState state) async {
    // Only applies to Android
    if (Theme.of(context).platform != TargetPlatform.android) return;

    try {
      final securityState = ref.read(securityProvider);
      final isBackground = state == AppLifecycleState.paused || state == AppLifecycleState.inactive;
      final shouldSecure = isBackground || (securityState.biometricEnabled && !securityState.isUnlocked);

      if (shouldSecure) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    } catch (e) {
      debugPrint('Error updating privacy screen flag: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final themeState = ref.watch(themeProvider);

    final shouldShowLock =
        securityState.biometricEnabled && !securityState.isUnlocked;

    return MaterialApp(
      title: 'ClearState',
      debugShowCheckedModeBanner: false,
      theme: ClearStateTheme.getTheme(themeState.accent, themeState.background),
      home: _buildHome(shouldShowLock),
    );
  }

  Widget _buildHome(bool shouldShowLock) {
    if (shouldShowLock && !_showOnboarding) {
      return BiometricLockScreen(onUnlocked: _handleUnlock);
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return _MainShell(
      currentIndex: _currentIndex,
      onIndexChanged: (index) {
        setState(() => _currentIndex = index);
      },
      onDataWiped: _handleDataWiped,
    );
  }
}

class _MainShell extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onDataWiped;

  const _MainShell({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onDataWiped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: themeState.background.value,
      body: _AnimatedTabContent(
        currentIndex: currentIndex,
        onDataWiped: onDataWiped,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onIndexChanged: onIndexChanged,
        accentColor: themeState.accent.value,
        backgroundColor: themeState.background.value,
      ),
    );
  }
}

/// Animated content switcher that fades between tabs.
class _AnimatedTabContent extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onDataWiped;

  const _AnimatedTabContent({
    required this.currentIndex,
    required this.onDataWiped,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey<int>(currentIndex),
        child: _getScreen(currentIndex),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const TimerScreen();
      case 1:
        return const TimelineScreen();
      case 2:
        return const AnalyticsScreen();
      case 3:
        return SettingsScreen(onDataWiped: onDataWiped);
      default:
        return const TimerScreen();
    }
  }
}

/// Bottom navigation bar without duplicate tap handlers.
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final Color accentColor;
  final Color backgroundColor;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ClearStateColors.ash, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          HapticService.light();
          onIndexChanged(index);
        },
        items: [
          _buildNavItem(
            icon: Icons.timer_outlined,
            activeIcon: Icons.timer,
            label: 'TIMER',
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.trending_up_outlined,
            activeIcon: Icons.trending_up,
            label: 'TIMELINE',
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            label: 'STATS',
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.tune_outlined,
            activeIcon: Icons.tune,
            label: 'SETTINGS',
            isActive: currentIndex == 3,
          ),
        ],
        selectedItemColor: accentColor,
        unselectedItemColor: ClearStateColors.smoke,
        backgroundColor: backgroundColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
  }) {
    return BottomNavigationBarItem(
      icon: _NavIcon(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        isActive: isActive,
        accentColor: accentColor,
      ),
      label: label,
    );
  }
}

/// Simple nav icon without duplicate tap handler.
/// Uses AnimatedContainer for smooth transitions.
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color accentColor;

  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? accentColor : ClearStateColors.smoke;

    return AnimatedScale(
      scale: isActive ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              letterSpacing: 1,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }
}
