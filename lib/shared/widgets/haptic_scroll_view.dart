import 'package:flutter/gestures.dart';
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
    HapticService.selection();
  }
}

class HapticCustomScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollBehavior? scrollBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? semanticChildCount;
  final double? cacheExtent;
  final double? anchor;
  final Key? center;

  const HapticCustomScrollView({
    super.key,
    required this.slivers,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.scrollBehavior,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.semanticChildCount,
    this.cacheExtent,
    this.anchor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: CustomScrollView(
        slivers: slivers,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        shrinkWrap: shrinkWrap,
        physics: physics,
        scrollBehavior: scrollBehavior,
        restorationId: restorationId,
        clipBehavior: clipBehavior,
        dragStartBehavior: dragStartBehavior,
        keyboardDismissBehavior: keyboardDismissBehavior,
        semanticChildCount: semanticChildCount == null
            ? null
            : int.tryParse(semanticChildCount!) ?? 0,
        cacheExtent: cacheExtent,
        anchor: anchor ?? 0.0,
        center: center,
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
