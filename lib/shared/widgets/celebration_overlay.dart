import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';

class CelebrationOverlay extends StatefulWidget {
  final String milestoneTitle;
  final VoidCallback onComplete;
  final Duration duration;

  const CelebrationOverlay({
    super.key,
    required this.milestoneTitle,
    required this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _toastController;
  late AnimationController _confettiController;
  late Animation<Offset> _toastSlideAnimation;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _toastController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _toastSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _toastController, curve: Curves.easeOutCubic),
        );

    _particles = List.generate(50, (index) {
      return ConfettiParticle(
        color: _getRandomColor(),
        startDelay: math.Random().nextInt(500),
        size: 6 + math.Random().nextDouble() * 8,
      );
    });

    _initCelebration();
  }

  void _initCelebration() async {
    HapticService.milestone();

    await Future.delayed(const Duration(milliseconds: 100));
    _toastController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _confettiController.forward();

    await Future.delayed(widget.duration);
    if (mounted) {
      _dismiss();
    }
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

  void _dismiss() {
    _toastController.reverse().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _toastController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _dismiss,
        child: Stack(children: [_buildConfetti(), _buildToastBanner()]),
      ),
    );
  }

  Widget _buildConfetti() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ConfettiPainter(
              animation: _confettiController.value,
              particles: _particles,
            ),
          );
        },
      ),
    );
  }

  Widget _buildToastBanner() {
    return SlideTransition(
      position: _toastSlideAnimation,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: ClearStateColors.charcoal,
              border: Border.all(color: ClearStateColors.ash, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MILESTONE REACHED',
                  style: ClearStateTypography.caption.copyWith(
                    color: ClearStateColors.sober,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.milestoneTitle,
                  style: ClearStateTypography.h2.copyWith(
                    color: ClearStateColors.bone,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap anywhere to continue',
                  style: ClearStateTypography.caption.copyWith(
                    color: ClearStateColors.smoke,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfettiParticle {
  final Color color;
  final int startDelay;
  final double size;

  ConfettiParticle({
    required this.color,
    required this.startDelay,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final double animation;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.animation, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final progress = (animation * 3000 - particle.startDelay) / 2000;
      if (progress <= 0 || progress >= 1) continue;

      final progressCurve = 1 - (1 - progress) * (1 - progress);
      final x =
          size.width *
          (0.1 +
              progress * 0.8 +
              (math.Random().nextDouble() - 0.5) * 0.1 * progress);
      final y =
          size.height * progressCurve +
          math.sin(progress * math.pi * 4) * 20 * progress;
      final rotation =
          progress * math.pi * 2 * (math.Random().nextBool() ? 1 : -1);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      paint.color = particle.color.withValues(alpha: 1 - progressCurve);
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

class CelebrationOverlayWrapper extends StatelessWidget {
  final Widget child;
  final String? pendingMilestone;
  final VoidCallback onMilestoneDismissed;

  const CelebrationOverlayWrapper({
    super.key,
    required this.child,
    this.pendingMilestone,
    required this.onMilestoneDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (pendingMilestone != null && pendingMilestone!.isNotEmpty)
          Positioned.fill(
            child: CelebrationOverlay(
              milestoneTitle: pendingMilestone!,
              onComplete: onMilestoneDismissed,
            ),
          ),
      ],
    );
  }
}
