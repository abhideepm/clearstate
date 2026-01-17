# ClearState UI/UX Enhancement Specification

> Comprehensive specification for animations, haptics, typography, and theming improvements.

## Table of Contents

1. [Overview](#overview)
2. [Typography](#typography)
3. [Animation System](#animation-system)
4. [Haptic Feedback System](#haptic-feedback-system)
5. [Color Theming](#color-theming)
6. [Component Specifications](#component-specifications)
7. [Screen-by-Screen Changes](#screen-by-screen-changes)
8. [New Dependencies](#new-dependencies)
9. [File Change Summary](#file-change-summary)
10. [Testing Requirements](#testing-requirements)

---

## Overview

### Design Philosophy

- **Aesthetic:** Brutalist with technical/utilitarian feel
- **Typography:** Monospace throughout (JetBrains Mono)
- **Motion:** Natural ease-out curves, context-variable durations
- **Haptics:** Meaningful feedback on key interactions (not excessive)
- **Accessibility:** Full `prefers-reduced-motion` support (disables all animations)

### Key Principles

1. **Timer as Hero** - The sobriety timer is the emotional center; it gets the most dramatic animations
2. **Brutalist Consistency** - Sharp corners (2px radius), visible borders, industrial aesthetic
3. **Tactile Feedback** - Every meaningful interaction has corresponding haptic response
4. **Performance First** - Only animate `transform` and `opacity` (compositor-friendly)

---

## Typography

### Font Family

**JetBrains Mono** - A monospace font that reinforces the "counting" nature of a sobriety tracker.

```yaml
# pubspec.yaml addition
flutter:
  fonts:
    - family: JetBrains Mono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

### Font Weights

| Use Case | Weight | Example |
|----------|--------|---------|
| Body text, labels, captions | Regular (400) | "Tap to authenticate" |
| Headers, timer display, buttons | Bold (700) | "CLEARSTATE", "47 DAYS" |

### Typography Updates

Update `lib/core/theme/typography.dart`:

```dart
class ClearStateTypography {
  static const String _fontFamily = 'JetBrains Mono';

  static TextStyle get timerDisplay => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: ClearStateColors.bone,
    letterSpacing: -2,
    height: 1.0,
    fontVariations: [FontVariation('wght', 700)],
  );

  static TextStyle get h1 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ClearStateColors.bone,
    letterSpacing: 1,
  );

  static TextStyle get body => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.bone,
  );

  // ... update all text styles with fontFamily: _fontFamily
}
```

---

## Animation System

### Core Animation Constants

Create `lib/core/theme/motion.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClearStateMotion {
  // Durations (context-variable)
  static const Duration micro = Duration(milliseconds: 100);      // Button press
  static const Duration fast = Duration(milliseconds: 150);       // Chip selection
  static const Duration normal = Duration(milliseconds: 200);     // Tab fade
  static const Duration slow = Duration(milliseconds: 300);       // Page transitions
  static const Duration dramatic = Duration(milliseconds: 1000);  // Timer count-up

  // Curves (all ease-out based)
  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;

  // Check for reduced motion preference
  static bool get reduceMotion {
    return WidgetsBinding.instance.disableAnimations ||
           MediaQueryData.fromView(
             WidgetsBinding.instance.platformDispatcher.views.first
           ).disableAnimations;
  }

  // Get duration respecting reduced motion
  static Duration duration(Duration normal) {
    return reduceMotion ? Duration.zero : normal;
  }
}
```

### Animation Specifications by Type

#### 1. Counter/Number Animations (SVG Morphing)

**Package:** `animated_digit` or custom implementation

```dart
// Usage in drinks_per_week_step.dart
AnimatedDigitWidget(
  value: _count,
  textStyle: ClearStateTypography.timerDisplay,
  duration: ClearStateMotion.fast,
  curve: ClearStateMotion.standard,
)
```

**Behavior:**
- Digits morph shape from one number to another
- Duration: 150ms
- Triggered on increment/decrement

#### 2. Chip Selection Animation

```dart
class _AnimatedChip extends StatefulWidget {
  final bool isSelected;
  final String label;
  final VoidCallback onTap;
}

// Animation spec:
// - Scale: 1.0 -> 1.05 -> 1.0 (pop effect)
// - Background color: animated over 150ms
// - Border color: animated over 150ms
// - Duration: 150ms total
// - Curve: easeOutCubic
```

#### 3. Button Press Animation

```dart
// All buttons (Continue, Back, Stepper +/-)
// On tap down:
//   - Scale: 1.0 -> 0.95
//   - Background: darken 10%
//   - Border: thicken or intensify
// On tap up/cancel:
//   - Reverse all effects
// Duration: 100ms
// Curve: easeOutCubic
```

#### 4. Tab Transition Animation

```dart
// In app.dart - wrap IndexedStack with custom animation
class _AnimatedTabSwitcher extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;
}

// Animation spec:
// - Outgoing screen: scale 1.0 -> 0.98, opacity 1.0 -> 0.0
// - Incoming screen: scale 0.98 -> 1.0, opacity 0.0 -> 1.0
// - Duration: 200ms
// - Curve: easeOutCubic
// - State preservation: YES (use IndexedStack underneath)
```

#### 5. Timer Count-Up Animation

```dart
// On timer screen load:
// 1. Timer appears immediately at 00:00:00:00
// 2. Rapidly counts up to actual value
// 3. Duration: 1000ms total
// 4. Curve: easeOutCubic (starts fast, slows at end)
// 5. Surrounding elements fade in AFTER count-up completes
```

#### 6. Timer Live Tick Animation

```dart
// Each second, the seconds digit:
// - Slides up and out (old value)
// - Slides up and in (new value)
// - Duration: 150ms
// - Only animate the changing digit, not static ones
```

#### 7. Onboarding Page Transitions

```dart
// PageView with horizontal slide
// Duration: 300ms
// Curve: easeOut (already implemented)
// Add haptic: HapticService.light() on page change
```

#### 8. Navigation Icon Bounce

```dart
// When tab is selected:
// - Icon scales: 1.0 -> 1.2 -> 1.0
// - Duration: 200ms
// - Curve: easeOutBack (slight overshoot)
```

#### 9. Sheet/Modal Transitions

```dart
// Bottom sheets slide up with:
// - Duration: 300ms
// - Curve: easeOutCubic
// - Background dims with animation
```

#### 10. Timeline Scroll Reveal

```dart
// Each timeline item:
// - Fades in from opacity 0 -> 1
// - Slides up from 20px offset -> 0
// - Stagger delay: 50ms between items
// - Only animate items entering viewport
```

#### 11. Analytics Chart Animation

```dart
// When stats tab becomes visible:
// - Charts animate from 0 to actual values
// - Duration: 800ms
// - Curve: easeOutCubic
// - Stagger: 100ms between chart elements
```

#### 12. Settings Toggle Animation

```dart
// Toggle switch:
// - Thumb slides with spring physics
// - Track color fades between states
// - Duration: 200ms
```

---

## Haptic Feedback System

### Haptic Mapping

Update default strength from `light` to `medium` for most interactions:

| Interaction | Haptic Method | Notes |
|-------------|---------------|-------|
| Calendar date tap | `HapticService.selection()` | Each date cell |
| Calendar month navigation | `HapticService.light()` | Arrow buttons |
| Tab switch | `HapticService.light()` | Bottom nav |
| Counter increment/decrement | `HapticService.medium()` | Stronger than before |
| Chip selection | `HapticService.selection()` | Drink type chips |
| Toggle switch | `HapticService.light()` | Settings toggles |
| Button press (primary) | `HapticService.medium()` | Continue, Submit |
| Button press (secondary) | `HapticService.light()` | Back, Cancel |
| Scroll boundary hit | `HapticService.selection()` | Proportional to overscroll |
| Milestone reached | `HapticService.milestone()` | Celebration pattern |
| Authentication success | `HapticService.success()` | Unlock screen |
| Authentication failure | `HapticService.error()` | With shake animation |

### Scroll Boundary Haptics

Create `lib/shared/widgets/haptic_scroll_view.dart`:

```dart
class HapticScrollView extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
}

// Implementation:
// - Wrap ScrollView with NotificationListener<ScrollNotification>
// - On overscroll, calculate intensity based on overscroll pixels
// - Trigger HapticService.selection() with intensity mapping
// - Max overscroll ~50px = full haptic, proportional below
```

---

## Color Theming

### Theme Provider

Create `lib/core/theme/theme_provider.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Accent Colors
enum AccentColor {
  signalOrange(Color(0xFFFF6B35), 'Signal Orange'),
  electricBlue(Color(0xFF0066FF), 'Electric Blue'),
  emerald(Color(0xFF10B981), 'Emerald'),
  lavender(Color(0xFFA78BFA), 'Lavender'),
  rose(Color(0xFFF43F5E), 'Rose'),
  pureWhite(Color(0xFFFFFFFF), 'Pure White'),
  cyan(Color(0xFF06B6D4), 'Cyan'),
  gold(Color(0xFFF59E0B), 'Gold');

  final Color color;
  final String label;
  const AccentColor(this.color, this.label);
}

// Background Themes
enum BackgroundTheme {
  void_(Color(0xFF050505), 'Void', 0.025),           // Current
  oledBlack(Color(0xFF000000), 'OLED Black', 0.0),   // Pure black, no noise
  charcoalDark(Color(0xFF121212), 'Charcoal', 0.02),
  deepNavy(Color(0xFF0a0a14), 'Deep Navy', 0.03),
  texturedDark(Color(0xFF0d0d0d), 'Textured', 0.05); // More visible noise

  final Color color;
  final String label;
  final double noiseOpacity;
  const BackgroundTheme(this.color, this.label, this.noiseOpacity);
}

// Theme State
class ThemeState {
  final AccentColor accent;
  final BackgroundTheme background;

  const ThemeState({
    this.accent = AccentColor.signalOrange,
    this.background = BackgroundTheme.void_,
  });

  ThemeState copyWith({AccentColor? accent, BackgroundTheme? background}) {
    return ThemeState(
      accent: accent ?? this.accent,
      background: background ?? this.background,
    );
  }
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final box = Hive.box('settings');
    final accentIndex = box.get('accentColor', defaultValue: 0);
    final bgIndex = box.get('backgroundTheme', defaultValue: 0);
    state = ThemeState(
      accent: AccentColor.values[accentIndex],
      background: BackgroundTheme.values[bgIndex],
    );
  }

  Future<void> setAccent(AccentColor accent) async {
    final box = Hive.box('settings');
    await box.put('accentColor', accent.index);
    state = state.copyWith(accent: accent);
  }

  Future<void> setBackground(BackgroundTheme bg) async {
    final box = Hive.box('settings');
    await box.put('backgroundTheme', bg.index);
    state = state.copyWith(background: bg);
  }
}
```

### Dynamic Color Usage

Update `ClearStateColors` to be theme-aware:

```dart
// In widgets, access current accent:
final theme = ref.watch(themeProvider);
final accentColor = theme.accent.color;
final bgColor = theme.background.color;
final noiseOpacity = theme.background.noiseOpacity;
```

### Settings UI for Theme

Add to `settings_screen.dart`:

```dart
// New APPEARANCE section with accordion
// - Accent Color: Horizontal row of 8 color circles
// - Background: Horizontal row of 5 theme options
// - Instant apply with 5-second undo snackbar
```

### Widget Sync

Update `lib/core/services/widget_data_service.dart` to pass accent color to iOS widgets.

---

## Component Specifications

### 1. Custom Calendar Widget

Create `lib/shared/widgets/haptic_calendar.dart`:

```dart
class HapticCalendar extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;
}

// Visual spec:
// - Full modal overlay (dark background 80% opacity)
// - Calendar container: charcoal background, ash border
// - Month header: "JANUARY 2026" with < > navigation arrows
// - Grid: 7 columns (S M T W T F S), bordered cells
// - Cell size: ~44px square
// - Selected date: accent color fill, void text
// - Today indicator: accent border (if different from selected)
// - Haptic: selection() on every date tap, light() on arrows
// - Animation: selected cell color transition 150ms
```

### 2. Animated Counter Widget

Create `lib/shared/widgets/animated_counter.dart`:

```dart
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;
  final Duration duration;
  final bool morphDigits; // true = SVG morph, false = slide
}

// Uses animated_digit package or custom SVG morphing
// Respects ClearStateMotion.reduceMotion
```

### 3. Brutalist Button System

Create `lib/shared/widgets/brutalist_button.dart`:

```dart
enum BrutalistButtonType { primary, secondary }

class BrutalistButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final BrutalistButtonType type;
  final bool isLoading;
}

// Primary (Continue, Submit):
// - Background: accent color
// - Text: void color
// - Border: 1px ash
// - Border radius: 2px
// - Padding: 16px vertical, 32px horizontal

// Secondary (Back, Cancel):
// - Background: transparent
// - Text: smoke color
// - Border: 1px ash
// - Border radius: 2px
// - Same padding as primary

// Press state (both):
// - Scale: 0.95
// - Primary bg: darken 10%
// - Secondary bg: charcoal (slight fill)
// - Border: thicken to 2px or intensify color
// - Duration: 100ms
// - Haptic: medium (primary), light (secondary)
```

### 4. Animated Stepper Button

Update stepper buttons in onboarding:

```dart
class AnimatedStepperButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
}

// Press animation:
// - Scale: 1.0 -> 0.92
// - Background: charcoal -> slightly lighter
// - Duration: 100ms
// - Haptic: HapticService.medium()
```

### 5. Milestone Celebration Overlay

Create `lib/shared/widgets/celebration_overlay.dart`:

```dart
class CelebrationOverlay extends StatefulWidget {
  final String milestoneTitle; // "1 WEEK SOBER!"
  final VoidCallback onComplete;
}

// Components:
// 1. Confetti particles (rainbow colors, ~50 particles)
// 2. Toast banner sliding down from top
// 3. Duration: 3-4 seconds total
// 4. Haptic: HapticService.milestone() at start
// 5. Auto-dismiss, tap anywhere to dismiss early
```

---

## Screen-by-Screen Changes

### 1. Unlock Screen (`biometric_lock_screen.dart`)

**Changes:**
- Replace `_buildLogo()` CS box with actual sunrise SVG
- Center all content (remove left alignment)
- Add staggered entrance animation:
  1. Logo fades in (0-300ms)
  2. "CLEARSTATE" text fades in (150-450ms)
  3. "Unlock" text fades in (300-600ms)
  4. Fingerprint button fades in (450-750ms)
- Add shake animation on auth failure
- Logo color adapts to accent

```dart
// Logo implementation
SvgPicture.asset(
  'assets/icons/clearstate_icon.svg',
  width: 80,
  height: 80,
  colorFilter: ColorFilter.mode(
    theme.accent.color,
    BlendMode.srcIn,
  ),
)
```

### 2. Timer Screen (`timer_screen.dart`)

**Changes:**
- Add small logo (24-32px) in top-left corner
- Keep "CLEARSTATE" text centered
- Timer count-up animation on screen load (1 second)
- Timer digits slide-up on each tick
- ROI cards stagger-reveal after timer count-up
- Logo fades in as part of launch sequence
- Logo color matches accent

### 3. Onboarding Screen (`onboarding_screen.dart`)

**Changes:**
- Add sunrise logo to header area (small, centered above progress bar)
- Page transitions already slide (keep as-is)
- Add haptic on page change

### 4. Last Drink Step (`last_drink_step.dart`)

**Changes:**
- Replace `showDatePicker()` with custom `HapticCalendar`
- Add haptic when opening calendar
- Date display animates when changed

### 5. Drinks Per Week Step (`drinks_per_week_step.dart`)

**Changes:**
- Replace `Text('$_count')` with `AnimatedCounter`
- Replace `_StepperButton` with `AnimatedStepperButton`
- Upgrade haptic to `HapticService.medium()`
- Replace `ElevatedButton` with `BrutalistButton.primary`
- Replace `TextButton` with `BrutalistButton.secondary`

### 6. Drink Type Step (`drink_type_step.dart`)

**Changes:**
- Wrap chips in `_AnimatedChip` with scale pop animation
- Use `HapticService.selection()` instead of raw `HapticFeedback`
- Replace buttons with `BrutalistButton` variants

### 7. Cost Per Drink Step (`cost_per_drink_step.dart`)

**Changes:**
- Same as Drinks Per Week Step
- `AnimatedCounter` for cost display
- `AnimatedStepperButton` for +/-
- `BrutalistButton` for Continue/Back

### 8. App Shell (`app.dart`)

**Changes:**
- Wrap `IndexedStack` in custom `_AnimatedTabSwitcher`
- Add `HapticService.light()` on tab tap
- Add bounce animation to nav icons
- Pass theme state to all screens

### 9. Settings Screen (`settings_screen.dart`)

**Changes:**
- Add new "APPEARANCE" section with accordion
- Accent color picker (8 swatches)
- Background theme picker (5 options)
- Undo snackbar on theme change
- Toggle animations improved

### 10. Timeline Screen

**Changes:**
- Add scroll reveal animation to milestone items
- Add haptic scroll boundary feedback

### 11. Analytics Screen

**Changes:**
- Add chart entry animations
- Add stagger delay between chart elements

---

## New Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_svg: ^2.0.9          # SVG logo rendering
  animated_digit: ^3.3.0       # Digit morphing animation (evaluate alternatives)
  confetti_widget: ^0.4.0      # Milestone celebrations

dev_dependencies:
  # Existing...
```

**Font Assets:**
```
assets/fonts/JetBrainsMono-Regular.ttf
assets/fonts/JetBrainsMono-Bold.ttf
```

---

## File Change Summary

### New Files

| File | Purpose |
|------|---------|
| `lib/core/theme/motion.dart` | Animation constants and utilities |
| `lib/core/theme/theme_provider.dart` | Accent/background theme state |
| `lib/shared/widgets/haptic_calendar.dart` | Custom calendar with haptics |
| `lib/shared/widgets/animated_counter.dart` | SVG morphing counter |
| `lib/shared/widgets/brutalist_button.dart` | Unified button component |
| `lib/shared/widgets/animated_stepper_button.dart` | +/- buttons with animation |
| `lib/shared/widgets/celebration_overlay.dart` | Milestone confetti |
| `lib/shared/widgets/haptic_scroll_view.dart` | Scroll with boundary haptics |
| `lib/shared/widgets/animated_chip.dart` | Chip with scale animation |
| `lib/shared/widgets/animated_tab_switcher.dart` | Tab transition wrapper |
| `lib/shared/widgets/animated_nav_icon.dart` | Bouncing nav icons |
| `lib/features/settings/widgets/theme_settings.dart` | Theme picker UI |
| `assets/fonts/JetBrainsMono-Regular.ttf` | Font file |
| `assets/fonts/JetBrainsMono-Bold.ttf` | Font file |

### Modified Files

| File | Changes |
|------|---------|
| `lib/core/theme/typography.dart` | Add JetBrains Mono font family |
| `lib/core/theme/colors.dart` | Make colors theme-aware |
| `lib/core/theme/app_theme.dart` | Use theme provider for dynamic colors |
| `lib/core/services/haptic_service.dart` | No changes (already comprehensive) |
| `lib/app.dart` | Add animated tab switcher, nav bounce, theme |
| `lib/main.dart` | Initialize settings Hive box |
| `lib/features/security/biometric_lock_screen.dart` | SVG logo, centering, shake animation |
| `lib/features/timer/timer_screen.dart` | Logo, count-up, stagger reveal |
| `lib/features/timer/widgets/timer_display.dart` | Slide-up tick animation |
| `lib/features/onboarding/onboarding_screen.dart` | Logo, haptic on page change |
| `lib/features/onboarding/widgets/last_drink_step.dart` | Custom calendar |
| `lib/features/onboarding/widgets/drinks_per_week_step.dart` | Animated counter, buttons |
| `lib/features/onboarding/widgets/drink_type_step.dart` | Animated chips, buttons |
| `lib/features/onboarding/widgets/cost_per_drink_step.dart` | Animated counter, buttons |
| `lib/features/settings/settings_screen.dart` | Appearance section |
| `lib/features/timeline/timeline_screen.dart` | Scroll reveal |
| `lib/features/analytics/analytics_screen.dart` | Chart animations |
| `lib/shared/widgets/noise_background.dart` | Use theme noise opacity |
| `lib/core/services/widget_data_service.dart` | Pass accent to widgets |
| `pubspec.yaml` | New dependencies, fonts |

---

## Testing Requirements

### Widget Tests

Create tests for each new widget:

```
test/shared/widgets/
  animated_counter_test.dart
  brutalist_button_test.dart
  haptic_calendar_test.dart
  animated_chip_test.dart
  celebration_overlay_test.dart
```

### Test Cases

1. **AnimatedCounter**
   - Renders correct value
   - Animates on value change (verify animation controller)
   - Respects reduced motion setting

2. **BrutalistButton**
   - Primary variant renders correctly
   - Secondary variant renders correctly
   - Press state triggers scale animation
   - Haptic feedback fires on tap

3. **HapticCalendar**
   - Renders month grid correctly
   - Selected date highlighted
   - Month navigation works
   - Date selection callback fires
   - Haptic triggers on date tap

4. **Theme System**
   - Accent color persists across app restart
   - Background theme applies to all screens
   - Widgets receive updated accent color

---

## Implementation Order

Execute all changes in a single comprehensive pass:

1. **Setup** - Dependencies, fonts, new file structure
2. **Core** - Motion constants, theme provider
3. **Components** - All shared widgets
4. **Screens** - Apply changes to each screen
5. **Polish** - Verify animations, test haptics
6. **Tests** - Write widget tests
7. **Format & Analyze** - `dart format .` && `flutter analyze`

---

## Accessibility

### Reduced Motion

All animations check `ClearStateMotion.reduceMotion`:

```dart
if (ClearStateMotion.reduceMotion) {
  // Instant transition, no animation
  return child;
} else {
  // Full animation
  return AnimatedWidget(...);
}
```

### Screen Reader

- All interactive elements have semantic labels
- Logo has `Semantics(label: 'ClearState logo')`
- Celebration overlay announces milestone to screen readers

---

*Specification Version: 1.0*
*Last Updated: January 17, 2026*
