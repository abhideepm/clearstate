import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// ClearState Motion - DAWN Aesthetic
/// Organic animations: breathing, spring physics, natural easing
class ClearStateMotion {
  // Duration constants
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration dramatic = Duration(milliseconds: 800);

  // Breathing animation timing
  static const Duration breathCycle = Duration(milliseconds: 4000);
  static const Duration breathIn = Duration(milliseconds: 1800);
  static const Duration breathHold = Duration(milliseconds: 400);
  static const Duration breathOut = Duration(milliseconds: 1800);

  // Standard curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;

  // Organic curves for DAWN aesthetic
  static const Curve organic = Curves.easeInOutSine;
  static const Curve breathInCurve = Curves.easeInOutSine;
  static const Curve breathOutCurve = Curves.easeInOutSine;
  static const Curve bounce = Curves.elasticOut;
  static const Curve gentle = Curves.easeInOutQuad;

  // Spring configurations for natural feel
  static SpringDescription get gentleSpring => const SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 20.0,
  );

  static SpringDescription get bouncySpring => const SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 15.0,
  );

  static SpringDescription get softSpring => const SpringDescription(
    mass: 1.0,
    stiffness: 100.0,
    damping: 12.0,
  );

  // Breathing animation scale values
  static const double breathMinScale = 0.97;
  static const double breathMaxScale = 1.0;

  // Glow pulse values
  static const double glowMinOpacity = 0.3;
  static const double glowMaxOpacity = 0.6;

  // Check for reduced motion preference
  static bool get reduceMotion {
    return WidgetsBinding.instance.disableAnimations ||
        MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first,
        ).disableAnimations;
  }

  // Get duration respecting reduced motion
  static Duration duration(Duration normalDuration) {
    return reduceMotion ? Duration.zero : normalDuration;
  }

  // Get curve respecting reduced motion
  static Curve curve(Curve normalCurve) {
    return reduceMotion ? Curves.linear : normalCurve;
  }

  // Helper to create spring simulation
  static SpringSimulation createSpring({
    SpringDescription? spring,
    double start = 0.0,
    double end = 1.0,
    double velocity = 0.0,
  }) {
    return SpringSimulation(
      spring ?? gentleSpring,
      start,
      end,
      velocity,
    );
  }
}
