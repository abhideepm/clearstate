# Flutter Animations Deep Dive

## Animation Types Overview

```
┌─────────────────────────────────────────────────────────┐
│                    ANIMATIONS                           │
├─────────────────────────┬───────────────────────────────┤
│     IMPLICIT            │         EXPLICIT              │
│  (Framework controls)   │    (You control)              │
├─────────────────────────┼───────────────────────────────┤
│ AnimatedContainer       │ AnimationController           │
│ AnimatedOpacity         │ AnimatedBuilder               │
│ AnimatedPositioned      │ AnimatedWidget                │
│ TweenAnimationBuilder   │ Tween + CurvedAnimation       │
└─────────────────────────┴───────────────────────────────┘
```

---

## Implicit Animations (Start Here)

Best for simple, one-off animations triggered by state changes.

### AnimatedContainer

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  color: isExpanded ? Colors.blue : Colors.red,
  child: const FlutterLogo(),
)
```

### AnimatedOpacity

```dart
AnimatedOpacity(
  duration: const Duration(milliseconds: 300),
  opacity: isVisible ? 1.0 : 0.0,
  child: const Text('Fade me'),
)
```

### Common Implicit Widgets

| Widget | Animates |
|--------|----------|
| `AnimatedContainer` | Size, color, padding, decoration |
| `AnimatedOpacity` | Opacity |
| `AnimatedPositioned` | Position in Stack |
| `AnimatedPadding` | Padding |
| `AnimatedAlign` | Alignment |
| `AnimatedDefaultTextStyle` | Text style |
| `AnimatedSwitcher` | Widget transitions |
| `AnimatedCrossFade` | Cross-fade between two widgets |

### TweenAnimationBuilder (Custom Implicit)

For properties not covered by built-in widgets:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: rotationAngle),
  duration: const Duration(milliseconds: 500),
  builder: (context, value, child) {
    return Transform.rotate(
      angle: value,
      child: child,  // Pass static child for performance
    );
  },
  child: const Icon(Icons.refresh),  // Built once
)
```

---

## Explicit Animations (Full Control)

Use when you need:
- Precise timing control
- Animation sequencing
- Looping/reversing
- Physics-based motion

### AnimationController Setup

```dart
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();  // Always dispose!
    super.dispose();
  }

  void _startAnimation() {
    _controller.forward();
  }

  void _reverseAnimation() {
    _controller.reverse();
  }

  void _repeatAnimation() {
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const FlutterLogo(size: 100),
    );
  }
}
```

### AnimatedBuilder (Preferred)

```dart
// ✅ Good - static child passed through
AnimatedBuilder(
  animation: _controller,
  child: const ExpensiveWidget(),  // Built once
  builder: (context, child) {
    return Transform.rotate(
      angle: _controller.value * 2 * pi,
      child: child,  // Reused every frame
    );
  },
)

// ❌ Bad - rebuilds child every frame
AnimatedBuilder(
  animation: _controller,
  builder: (context, _) {
    return Transform.rotate(
      angle: _controller.value * 2 * pi,
      child: ExpensiveWidget(),  // Rebuilt 60x/sec
    );
  },
)
```

### Built-in Transition Widgets

| Widget | Animation |
|--------|-----------|
| `FadeTransition` | Opacity |
| `SlideTransition` | Position offset |
| `ScaleTransition` | Scale |
| `RotationTransition` | Rotation |
| `SizeTransition` | Size |
| `DecoratedBoxTransition` | Decoration |
| `PositionedTransition` | Position in Stack |

```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(-1, 0),
    end: Offset.zero,
  ).animate(_controller),
  child: const MyWidget(),
)
```

---

## Tweens

Define the range of values to animate between.

### Common Tweens

```dart
// Double
Tween<double>(begin: 0.0, end: 1.0)

// Color
ColorTween(begin: Colors.red, end: Colors.blue)

// Offset
Tween<Offset>(begin: Offset.zero, end: const Offset(1, 0))

// Size
Tween<Size>(begin: Size.zero, end: const Size(100, 100))

// BorderRadius
BorderRadiusTween(
  begin: BorderRadius.circular(0),
  end: BorderRadius.circular(20),
)

// Alignment
AlignmentTween(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Chaining Tweens

```dart
final animation = _controller
    .drive(CurveTween(curve: Curves.easeOut))
    .drive(Tween<double>(begin: 0, end: 100));
```

---

## Curves

Control how animation values change over time.

### Common Curves

| Curve | Effect |
|-------|--------|
| `Curves.linear` | Constant speed |
| `Curves.easeIn` | Start slow, end fast |
| `Curves.easeOut` | Start fast, end slow |
| `Curves.easeInOut` | Slow at both ends |
| `Curves.bounceOut` | Bounce effect at end |
| `Curves.elasticOut` | Elastic/spring effect |
| `Curves.fastOutSlowIn` | Material Design standard |

### Apply Curves

```dart
final curvedAnimation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
  reverseCurve: Curves.easeIn,  // Optional different curve for reverse
);
```

---

## Staggered Animations

Multiple animations with different timings.

```dart
class StaggeredAnimationWidget extends StatefulWidget {
  @override
  State<StaggeredAnimationWidget> createState() => _StaggeredAnimationWidgetState();
}

class _StaggeredAnimationWidgetState extends State<StaggeredAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Stagger: opacity 0-30%, scale 30-60%, slide 60-100%
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value.dy * 50),
              child: child,
            ),
          ),
        );
      },
      child: const Card(child: Text('Staggered!')),
    );
  }
}
```

---

## Hero Animations

Smooth transitions between screens.

```dart
// Source screen
Hero(
  tag: 'product-${product.id}',
  child: Image.network(product.imageUrl),
)

// Destination screen
Hero(
  tag: 'product-${product.id}',
  child: Image.network(product.imageUrl),
)
```

### Custom Hero Flight

```dart
Hero(
  tag: 'avatar',
  flightShuttleBuilder: (
    flightContext,
    animation,
    flightDirection,
    fromHeroContext,
    toHeroContext,
  ) {
    return ScaleTransition(
      scale: animation.drive(Tween(begin: 1.0, end: 1.2)
          .chain(CurveTween(curve: Curves.easeInOut))),
      child: fromHeroContext.widget,
    );
  },
  child: const CircleAvatar(child: Icon(Icons.person)),
)
```

---

## Physics-Based Animations

Natural, realistic motion.

### Spring Simulation

```dart
class _SpringWidgetState extends State<SpringWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    const spring = SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 10,
    );

    final simulation = SpringSimulation(spring, 0, 1, 0);
    _controller.animateWith(simulation);

    _animation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: const FlutterLogo(size: 100),
    );
  }
}
```

---

## Performance Optimization

### RepaintBoundary

```dart
// Isolate animated widget from rest of tree
Stack(
  children: [
    const StaticBackground(),
    RepaintBoundary(
      child: AnimatedWidget(),  // Only this repaints
    ),
    const StaticOverlay(),
  ],
)
```

### Avoid Opacity Widget

```dart
// ❌ Bad - creates saveLayer (expensive)
Opacity(
  opacity: value,
  child: child,
)

// ✅ Good - for animations
FadeTransition(
  opacity: _animation,
  child: child,
)

// ✅ Good - for color animations
AnimatedContainer(
  color: Colors.blue.withOpacity(value),
)
```

### Don't Clip During Animations

```dart
// ❌ Bad - clip recalculates every frame
AnimatedBuilder(
  animation: _controller,
  builder: (_, child) => ClipRRect(
    borderRadius: BorderRadius.circular(_animation.value),
    child: child,
  ),
  child: Image.asset('image.png'),
)

// ✅ Good - pre-clip the image
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: AnimatedBuilder(
    animation: _controller,
    builder: (_, child) => Transform.scale(
      scale: _animation.value,
      child: child,
    ),
    child: Image.asset('image.png'),
  ),
)
```

---

## Third-Party Animation Libraries

### Rive

For complex, interactive animations designed in Rive editor.

```yaml
dependencies:
  rive: ^0.14.0
```

```dart
import 'package:rive/rive.dart';

class RiveAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const RiveAnimation.asset(
      'assets/animations/loading.riv',
      fit: BoxFit.cover,
    );
  }
}
```

### Lottie

For After Effects animations exported as JSON.

```yaml
dependencies:
  lottie: ^3.0.0
```

```dart
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/success.json',
      width: 200,
      height: 200,
      fit: BoxFit.contain,
    );
  }
}

// With controller
class ControlledLottie extends StatefulWidget {
  @override
  State<ControlledLottie> createState() => _ControlledLottieState();
}

class _ControlledLottieState extends State<ControlledLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/checkbox.json',
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
      },
    );
  }

  void play() => _controller.forward();
  void reverse() => _controller.reverse();
}
```

---

## Animation Testing

```dart
testWidgets('fades in over 500ms', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: FadeInWidget()));

  // Check initial state
  final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
  expect(opacity.opacity, 0.0);

  // Advance halfway
  await tester.pump(const Duration(milliseconds: 250));
  
  // Advance to completion
  await tester.pumpAndSettle();

  final finalOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
  expect(finalOpacity.opacity, 1.0);
});
```

---

## Quick Reference

### When to Use What

| Scenario | Solution |
|----------|----------|
| Button press feedback | Implicit (`AnimatedScale`) |
| Page transitions | `PageRouteBuilder` or go_router |
| Loading indicators | Lottie or explicit loop |
| Onboarding | Staggered explicit |
| Micro-interactions | Implicit or `TweenAnimationBuilder` |
| Game-like motion | Physics simulations |
| Brand animations | Rive |

### Checklist

- [ ] Dispose all AnimationControllers
- [ ] Use `child` parameter in AnimatedBuilder
- [ ] Apply RepaintBoundary to isolated animations
- [ ] Avoid Opacity widget (use FadeTransition)
- [ ] Don't clip during animations
- [ ] Test animations with `pump()` and `pumpAndSettle()`
