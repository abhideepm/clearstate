import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/sunrise_logo.dart';
import 'onboarding_provider.dart';
import 'widgets/habit_stack_step.dart';
import 'widgets/last_drink_step.dart' show StartDateStep;
import 'widgets/motivation_step.dart';
import 'widgets/celebration_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticService.light();
    final state = ref.read(onboardingProvider);
    if (state.currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      ref.read(onboardingProvider.notifier).nextStep();
    } else {
      // Show celebration screen instead of completing immediately
      setState(() {
        _showCelebration = true;
      });
    }
  }

  void _previousPage() {
    HapticService.light();
    if (ref.read(onboardingProvider).currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      ref.read(onboardingProvider.notifier).previousStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    // Show celebration screen
    if (_showCelebration) {
      return Scaffold(
        backgroundColor: themeState.background.value,
        body: NoiseBackground(
          opacity: 0.025,
          child: CelebrationStep(onComplete: widget.onComplete),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeState.background.value,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              SunriseLogo(size: 48, accentColor: accentColor, showLabel: false),
              const SizedBox(height: 16),
              _OnboardingProgress(accentColor: accentColor),
              const SizedBox(height: 8),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    HabitStackStep(onNext: _nextPage),
                    StartDateStep(onNext: _nextPage, onBack: _previousPage),
                    MotivationStep(onNext: _nextPage, onBack: _previousPage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingProgress extends ConsumerWidget {
  final Color accentColor;

  const _OnboardingProgress({required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: index <= state.currentStep
                      ? accentColor
                      : ClearStateColors.ash,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'STEP ${state.currentStep + 1} OF 3',
          style: ClearStateTypography.timerLabel.copyWith(
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
