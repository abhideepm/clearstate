import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/sunrise_logo.dart';
import '../relapse/slip_vs_relapse_sheet.dart';
import '../urge_surfing/urge_surfing_screen.dart';
import 'widgets/timer_display.dart';
import 'widgets/status_indicator.dart';
import 'widgets/roi_cards.dart';
import 'widgets/reset_button.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _countUpController;
  late Animation<double> _countUpAnimation;
  late AnimationController _roiRevealController;
  late Animation<double> _roiRevealAnimation;

  @override
  void initState() {
    super.initState();
    _countUpController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _countUpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _countUpController, curve: Curves.easeOutCubic),
    );

    _roiRevealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _roiRevealAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _roiRevealController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLaunchSequence();
    });
  }

  @override
  void dispose() {
    _countUpController.dispose();
    _roiRevealController.dispose();
    super.dispose();
  }

  Future<void> _startLaunchSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _countUpController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _roiRevealController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return Scaffold(
      backgroundColor: themeState.background.value,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _countUpAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _countUpAnimation.value,
                          child: Transform.translate(
                            offset: Offset(
                              -20 * (1 - _countUpAnimation.value),
                              0,
                            ),
                            child: SunriseLogoSmall(
                              size: 28,
                              accentColor: accentColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _countUpAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _countUpAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _countUpAnimation.value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'CLEARSTATE',
                    style: ClearStateTypography.timerLabel.copyWith(
                      fontSize: 14,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _countUpAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.5 + (0.5 * _countUpAnimation.value),
                      child: Opacity(
                        opacity: _countUpAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: const TimerDisplay(),
                ),
                const SizedBox(height: 32),
                const StatusIndicator(),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _roiRevealAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _roiRevealAnimation.value)),
                      child: Opacity(
                        opacity: _roiRevealAnimation.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: const RoiCards(),
                ),
                const Spacer(flex: 3),
                ResetButton(
                  onReset: () {
                    _showSlipVsRelapseSheet(context);
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    HapticService.medium();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UrgeSurfingScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "I'M STRUGGLING",
                    style: ClearStateTypography.caption.copyWith(
                      color: ClearStateColors.smoke,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSlipVsRelapseSheet(BuildContext context) {
    HapticService.heavy();
    showModalBottomSheet(
      context: context,
      backgroundColor: ClearStateColors.charcoal,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) => const SlipVsRelapseSheet(),
    );
  }
}
