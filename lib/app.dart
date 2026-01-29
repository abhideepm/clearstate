import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'core/theme/typography.dart';
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
import 'data/models/habit_template.dart';

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
    final repository = ref.read(sobrietyRepositoryProvider);

    // Request notification permissions during onboarding completion
    await NotificationService.instance.requestPermissions();

    // Get selected habits and their start dates
    final selectedHabits = onboardingState.selectedHabits;
    final habitStartDates = onboardingState.habitStartDates;
    final motivation = onboardingState.motivation;

    // Create actual Habit objects from the selected templates
    for (final template in selectedHabits) {
      final habitStartDate = habitStartDates[template.id] ?? DateTime.now();
      final habit = template.toHabit(
        startDate: habitStartDate,
        motivation: motivation,
      );
      await repository.saveHabit(habit);
      
      // Start a session for each habit
      await orchestrator.startNewSession(
        habit.id,
        habitStartDate,
        scheduleNotifications: template == selectedHabits.first,
      );
    }

    // Use the earliest start date for the main timer, or today if none set
    final startDate = habitStartDates.isNotEmpty
        ? habitStartDates.values.reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();

    // Save user profile
    await orchestrator.saveUserProfile(
      selectedHabitIds: selectedHabits.map((h) => h.id).toList(),
      lastDrinkDate: startDate,
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
      theme: ClearStateTheme.getThemeFromState(themeState),
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
      backgroundColor: themeState.background,
      body: _AnimatedTabContent(
        currentIndex: currentIndex,
        onDataWiped: onDataWiped,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onIndexChanged: onIndexChanged,
        accentColor: themeState.accent.value,
        backgroundColor: themeState.background,
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
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.timer_outlined,
                activeIcon: Icons.timer,
                label: 'Timer',
                isActive: currentIndex == 0,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.timeline_outlined,
                activeIcon: Icons.timeline,
                label: 'Timeline',
                isActive: currentIndex == 1,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Stats',
                isActive: currentIndex == 2,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                isActive: currentIndex == 3,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        onIndexChanged(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? accentColor : ClearStateColors.textMutedDark,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: ClearStateTypography.navLabel.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
