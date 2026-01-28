import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../onboarding_provider.dart';

class CelebrationStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const CelebrationStep({super.key, required this.onComplete});

  @override
  ConsumerState<CelebrationStep> createState() => _CelebrationStepState();
}

class _CelebrationStepState extends ConsumerState<CelebrationStep>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _contentController;
  late DateTime _earliestStartDate;
  Duration _elapsedDuration = Duration.zero;

  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particles = List.generate(60, (index) {
      return _ConfettiParticle(
        color: _getRandomColor(),
        startX: math.Random().nextDouble(),
        startDelay: math.Random().nextInt(800),
        size: 6 + math.Random().nextDouble() * 10,
        rotationSpeed: (math.Random().nextDouble() - 0.5) * 4,
      );
    });

    _startCelebration();
  }

  void _startCelebration() async {
    HapticService.milestone();

    // Calculate elapsed time from earliest start date
    final state = ref.read(onboardingProvider);
    final dates = state.habitStartDates.values.toList();
    if (dates.isNotEmpty) {
      dates.sort();
      _earliestStartDate = dates.first;
    } else {
      _earliestStartDate = DateTime.now();
    }

    _updateElapsedTime();

    await Future.delayed(const Duration(milliseconds: 200));
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();

    // Start periodic timer to update elapsed time
    _startPeriodicUpdate();
  }

  void _startPeriodicUpdate() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      _updateElapsedTime();
      return true;
    });
  }

  void _updateElapsedTime() {
    if (!mounted) return;
    setState(() {
      _elapsedDuration = DateTime.now().difference(_earliestStartDate);
    });
  }

  Color _getRandomColor() {
    final colors = [
      ClearStateColors.signal,
      ClearStateColors.sober,
      ClearStateColors.bone,
      Colors.white,
      const Color(0xFFFF6B35),
      const Color(0xFF00D26A),
      const Color(0xFF6C63FF),
      const Color(0xFFFFD93D),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  String _formatTime(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      return '${days}d ${hours}h';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      return '${hours}h ${mins}m';
    } else {
      final mins = duration.inMinutes;
      final secs = duration.inSeconds % 60;
      return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final habitCount = state.selectedHabits.length;
    final habitNames = state.habitNamesDisplay;

    return Stack(
      children: [
        // Confetti layer
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ConfettiPainter(
                animation: _confettiController.value,
                particles: _particles,
              ),
            );
          },
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _contentController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _contentController,
                  curve: Curves.easeOut,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    Text(
                      'YOUR JOURNEY\nBEGINS NOW',
                      style: ClearStateTypography.h1.copyWith(
                        fontSize: 36,
                        height: 1.1,
                        color: ClearStateColors.bone,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Live timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: ClearStateColors.charcoal,
                        border: Border.all(color: ClearStateColors.sober, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SOBER FOR',
                            style: ClearStateTypography.caption.copyWith(
                              color: ClearStateColors.sober,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(_elapsedDuration),
                            style: ClearStateTypography.timerDisplay.copyWith(
                              fontSize: 56,
                              color: ClearStateColors.bone,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AND COUNTING...',
                            style: ClearStateTypography.caption.copyWith(
                              color: ClearStateColors.smoke,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      habitCount == 1
                          ? 'Tracking: $habitNames'
                          : 'Tracking $habitCount habits',
                      style: ClearStateTypography.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every second counts. You\'ve got this.',
                      style: ClearStateTypography.caption.copyWith(
                        color: ClearStateColors.smoke,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 3),
                    BrutalistButton(
                      label: 'LET\'S GO',
                      onPressed: () {
                        HapticService.success();
                        widget.onComplete();
                      },
                      type: BrutalistButtonType.primary,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double startX;
  final int startDelay;
  final double size;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startDelay,
    required this.size,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double animation;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.animation, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final progress = (animation * 4000 - particle.startDelay) / 3000;
      if (progress <= 0 || progress >= 1) continue;

      final easedProgress = Curves.easeOutCubic.transform(progress);
      final x = size.width * (0.1 + particle.startX * 0.8) +
          math.sin(progress * math.pi * 3) * 40;
      final y = -50 + size.height * easedProgress * 1.2;
      final rotation = progress * math.pi * particle.rotationSpeed;
      final opacity = progress < 0.8 ? 1.0 : (1 - progress) * 5;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      paint.color = particle.color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
