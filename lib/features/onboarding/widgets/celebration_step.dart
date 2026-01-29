import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/services/haptic_service.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/breathing_wrapper.dart';
import '../onboarding_provider.dart';

class CelebrationStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const CelebrationStep({super.key, required this.onComplete});

  @override
  ConsumerState<CelebrationStep> createState() => _CelebrationStepState();
}

class _CelebrationStepState extends ConsumerState<CelebrationStep>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _contentController;
  late AnimationController _glowController;
  late DateTime _earliestStartDate;
  Duration _elapsedDuration = Duration.zero;

  late List<_OrganicParticle> _particles;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: TrueStateMotion.dramatic,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: TrueStateMotion.breathCycle,
      vsync: this,
    );

    _particles = List.generate(40, (index) {
      return _OrganicParticle(
        color: _getOrganicColor(),
        startX: math.Random().nextDouble(),
        startY: 0.3 + math.Random().nextDouble() * 0.4,
        size: 4 + math.Random().nextDouble() * 8,
        delay: math.Random().nextDouble() * 0.5,
        type: index % 3 == 0 ? ParticleType.leaf : ParticleType.glow,
      );
    });

    _startCelebration();
  }

  void _startCelebration() async {
    HapticService.milestone();

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
    if (!TrueStateMotion.reduceMotion) {
      _particleController.repeat();
      _glowController.repeat(reverse: true);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();

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

  Color _getOrganicColor() {
    final colors = [
      TrueStateColors.dawnCoral.withValues(alpha: 0.6),
      TrueStateColors.sunriseGold.withValues(alpha: 0.5),
      TrueStateColors.moss.withValues(alpha: 0.4),
      TrueStateColors.morningMist.withValues(alpha: 0.3),
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
    _particleController.dispose();
    _contentController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final habitCount = state.selectedHabits.length;
    final habitNames = state.habitNamesDisplay;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TrueStateColors.deepForest,
            TrueStateColors.darkSurface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Organic particles layer
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _OrganicParticlePainter(
                    animation: _particleController.value,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _contentController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _contentController,
                    curve: TrueStateMotion.organic,
                  )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      // Warm, hopeful messaging
                      Text(
                        'Your healing\nhas begun',
                        style: TrueStateTypography.h1.copyWith(
                          fontSize: 38,
                          height: 1.15,
                          color: TrueStateColors.warmIvory,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Glass card timer display with breathing animation
                      BreathingWrapper(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 28,
                          ),
                          borderRadius: 24,
                          showGlow: true,
                          child: Column(
                            children: [
                              Text(
                                'Already sober for',
                                style: TrueStateTypography.bodySmall.copyWith(
                                  color: TrueStateColors.dawnCoral,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatTime(_elapsedDuration),
                                style: TrueStateTypography.timerDisplay.copyWith(
                                  fontSize: 52,
                                  color: TrueStateColors.warmIvory,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'and counting...',
                                style: TrueStateTypography.caption.copyWith(
                                  color: TrueStateColors.morningMist,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Habit info
                      Text(
                        habitCount == 1
                            ? 'Tracking: $habitNames'
                            : 'Tracking $habitCount habits',
                        style: TrueStateTypography.body.copyWith(
                          color: TrueStateColors.morningMist,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Consistency rate teaser
                      Text(
                        "You're already at 100% today ✨",
                        style: TrueStateTypography.quote.copyWith(
                          color: TrueStateColors.sunriseGold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(flex: 3),
                      ModernButton(
                        label: "Let's begin",
                        onPressed: () {
                          HapticService.success();
                          widget.onComplete();
                        },
                        type: ModernButtonType.primary,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ParticleType { leaf, glow }

class _OrganicParticle {
  final Color color;
  final double startX;
  final double startY;
  final double size;
  final double delay;
  final ParticleType type;

  _OrganicParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.size,
    required this.delay,
    required this.type,
  });
}

class _OrganicParticlePainter extends CustomPainter {
  final double animation;
  final List<_OrganicParticle> particles;

  _OrganicParticlePainter({required this.animation, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final adjustedAnim = (animation + particle.delay) % 1.0;
      
      // Gentle floating motion
      final floatY = math.sin(adjustedAnim * math.pi * 2) * 30;
      final floatX = math.cos(adjustedAnim * math.pi * 3) * 15;
      
      final x = size.width * particle.startX + floatX;
      final y = size.height * particle.startY + floatY;
      
      // Pulsing opacity
      final opacity = 0.3 + math.sin(adjustedAnim * math.pi * 2) * 0.3;
      
      paint.color = particle.color.withValues(alpha: opacity.clamp(0.1, 0.6));
      
      if (particle.type == ParticleType.glow) {
        // Soft glow circles
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(x, y), particle.size, paint);
        paint.maskFilter = null;
      } else {
        // Leaf-like shapes
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(adjustedAnim * math.pi);
        
        final path = Path()
          ..moveTo(0, -particle.size)
          ..quadraticBezierTo(particle.size * 0.6, 0, 0, particle.size)
          ..quadraticBezierTo(-particle.size * 0.6, 0, 0, -particle.size);
        
        canvas.drawPath(path, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrganicParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
