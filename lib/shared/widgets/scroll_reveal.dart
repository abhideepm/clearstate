import 'package:flutter/material.dart';

class ScrollRevealItem extends StatefulWidget {
  final Widget child;
  final double offset;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const ScrollRevealItem({
    super.key,
    required this.child,
    this.offset = 20,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<ScrollRevealItem> createState() => _ScrollRevealItemState();
}

class _ScrollRevealItemState extends State<ScrollRevealItem> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      curve: widget.curve,
      opacity: _isVisible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: widget.duration,
        curve: widget.curve,
        offset: _isVisible ? Offset.zero : Offset(0, widget.offset / 100),
        child: widget.child,
      ),
    );
  }
}

class StaggeredRevealList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDelay;
  final Duration duration;
  final Curve curve;

  const StaggeredRevealList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDelay = const Duration(milliseconds: 400),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(children.length, (index) {
        return ScrollRevealItem(
          delay: Duration(
            milliseconds:
                (index * staggerDelay.inMilliseconds) +
                itemDelay.inMilliseconds,
          ),
          duration: duration,
          curve: curve,
          child: children[index],
        );
      }),
    );
  }
}

class RevealOnScroll extends StatefulWidget {
  final Widget child;
  final double revealThreshold;
  final VoidCallback? onReveal;
  final double offset;
  final Duration duration;
  final Curve curve;

  const RevealOnScroll({
    super.key,
    required this.child,
    this.revealThreshold = 0.5,
    this.onReveal,
    this.offset = 20,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  bool _hasRevealed = false;
  final GlobalKey _childKey = GlobalKey();

  bool _checkVisibility() {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    final viewportOffset = Scrollable.of(context).position;
    final viewportSize = viewportOffset.viewportDimension;
    final objectTop = renderBox.localToGlobal(Offset.zero).dy;
    final objectHeight = renderBox.size.height;

    final objectTopInViewport = objectTop - viewportOffset.pixels;
    final objectBottomInViewport = objectTopInViewport + objectHeight;

    final revealPoint = viewportSize * widget.revealThreshold;

    return objectTopInViewport < revealPoint && objectBottomInViewport > 0;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && !_hasRevealed) {
          if (_checkVisibility()) {
            setState(() => _hasRevealed = true);
            widget.onReveal?.call();
          }
        }
        return false;
      },
      child: ScrollRevealItem(
        offset: widget.offset,
        duration: widget.duration,
        curve: widget.curve,
        child: KeyedSubtree(key: _childKey, child: widget.child),
      ),
    );
  }
}
