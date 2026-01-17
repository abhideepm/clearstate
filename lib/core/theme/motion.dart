import 'package:flutter/material.dart';

class ClearStateMotion {
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration dramatic = Duration(milliseconds: 1000);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;

  static bool get reduceMotion {
    return WidgetsBinding.instance.disableAnimations ||
        MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first,
        ).disableAnimations;
  }

  static Duration duration(Duration normal) {
    return reduceMotion ? Duration.zero : normal;
  }
}
