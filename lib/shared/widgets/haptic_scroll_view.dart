import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';

class HapticScrollView extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const HapticScrollView({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: SingleChildScrollView(
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        physics: physics,
        padding: padding,
        child: child,
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      final overscroll = scrollDirection == Axis.vertical
          ? notification.overscroll
          : notification.overscroll;

      if (overscroll != 0) {
        final intensity = (overscroll.abs() / 50.0).clamp(0.0, 1.0);

        if (intensity > 0) {
          _triggerHaptic(intensity);
        }
      }
    }
    return false;
  }

  void _triggerHaptic(double intensity) {
    if (intensity >= 1.0) {
      HapticService.selection();
    } else if (intensity >= 0.5) {
      HapticService.selection();
    } else {
      HapticService.selection();
    }
  }
}

class HapticListView extends StatelessWidget {
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const HapticListView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        physics: physics,
        padding: padding,
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      final overscroll = scrollDirection == Axis.vertical
          ? notification.overscroll
          : notification.overscroll;

      if (overscroll != 0) {
        final intensity = (overscroll.abs() / 50.0).clamp(0.0, 1.0);
        if (intensity > 0) {
          HapticService.selection();
        }
      }
    }
    return false;
  }
}

class HapticGridView extends StatelessWidget {
  final SliverGridDelegate gridDelegate;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const HapticGridView({
    super.key,
    required this.gridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: GridView.builder(
        gridDelegate: gridDelegate,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        physics: physics,
        padding: padding,
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      final overscroll = scrollDirection == Axis.vertical
          ? notification.overscroll
          : notification.overscroll;

      if (overscroll != 0) {
        final intensity = (overscroll.abs() / 50.0).clamp(0.0, 1.0);
        if (intensity > 0) {
          HapticService.selection();
        }
      }
    }
    return false;
  }
}
