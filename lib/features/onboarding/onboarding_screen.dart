import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import 'onboarding_provider.dart';
import 'widgets/last_drink_step.dart';
import 'widgets/drinks_per_week_step.dart';
import 'widgets/drink_type_step.dart';
import 'widgets/cost_per_drink_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  
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
    if (state.currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      ref.read(onboardingProvider.notifier).nextStep();
    } else {
      HapticService.success();
      widget.onComplete();
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
    final state = ref.watch(onboardingProvider);
    
    return Scaffold(
      backgroundColor: ClearStateColors.void_,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: index <= state.currentStep
                            ? ClearStateColors.signal
                            : ClearStateColors.ash,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Step indicator
              Text(
                'STEP ${state.currentStep + 1} OF 4',
                style: ClearStateTypography.timerLabel,
              ),
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    LastDrinkStep(onNext: _nextPage),
                    DrinksPerWeekStep(onNext: _nextPage, onBack: _previousPage),
                    DrinkTypeStep(onNext: _nextPage, onBack: _previousPage),
                    CostPerDrinkStep(onNext: _nextPage, onBack: _previousPage),
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
