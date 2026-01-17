# AGENTS.md - ClearState

This document provides context for AI coding agents working in this codebase.

## Project Overview

**ClearState** is a minimalist sobriety tracker mobile app built with Flutter.
- Framework: Flutter (Dart SDK ^3.10.7)
- State Management: flutter_riverpod (^2.4.0)
- Local Storage: Hive (^2.2.3) + hive_flutter
- Local Notifications: flutter_local_notifications (^17.2.0)
- UI: Material 3 with custom dark theme

## AI Agent Workflow

To maintain codebase health, agents **must** follow these steps for every modification:
1.  **Write Tests**: For every new feature or bug fix, implement corresponding unit or widget tests in the `test/` directory.
2.  **Auto-Format**: Always run `dart format .` immediately after any code changes.
3.  **Static Analysis**: Run `flutter analyze` to verify that no linting or type errors were introduced.

## Project Structure

```
clearstate/
├── lib/
│   ├── main.dart         # App entry point, Hive setup, widget init
│   ├── app.dart          # Root widget, navigation
│   ├── core/
│   │   ├── constants/    # Milestones, drink presets, bio_states, stoic_quotes
│   │   ├── services/     # Haptic feedback, notifications, widget_update_service
│   │   └── theme/        # Colors, typography, app theme
│   ├── data/
│   │   ├── models/       # Hive models (*.dart + *.g.dart), widget_config
│   │   └── repositories/ # Data access layer
│   ├── features/
│   │   ├── timer/        # Main sobriety timer
│   │   ├── timeline/     # Recovery milestones
│   │   ├── analytics/    # Stats & heatmap
│   │   ├── onboarding/   # Initial setup flow
│   │   ├── relapse/      # Relapse tracking
│   │   ├── settings/     # Settings & data management
│   │   └── widgets/      # Stealth widgets configuration
│   └── shared/widgets/   # Shared UI components
└── test/
    ├── shared/
    │   └── widgets/      # Widget tests for shared UI components
    └── unit/             # Unit tests
```

## Build/Lint/Test Commands

Run from project root:

```bash
flutter pub get                    # Install dependencies
flutter run                        # Run app (debug)
flutter test                       # Run all tests
flutter test test/shared/widgets/  # Run widget tests
flutter test --name "pattern"      # Run tests matching pattern
flutter analyze                    # Static analysis
dart format .                      # Format code
dart format --set-exit-if-changed . # Format check (CI)

# Generate Hive adapters after modifying models
flutter pub run build_runner build --delete-conflicting-outputs

flutter build apk                  # Build Android APK
flutter build ios                  # Build iOS
```

## Code Style Guidelines

### Imports
Order: 1) Dart SDK, 2) Flutter, 3) Third-party packages, 4) Project imports (relative)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
```

### Naming Conventions
- **Classes**: PascalCase (`TimerScreen`, `SobrietyRepository`)
- **Files**: snake_case (`timer_screen.dart`)
- **Variables/Functions**: camelCase (`getUserProfile`)
- **Private members**: underscore prefix (`_isInitialized`)
- **Providers**: camelCase + `Provider` suffix (`sobrietyRepositoryProvider`)

### Types & Formatting
- Always run `dart format .` after any code change (2-space indent, 80 char lines)
- Trailing commas for multi-line structures
- Always specify types for class members and function signatures
- Use `final` for immutable values, `const` constructors where possible
- Prefer `late` for lazy initialization over nullable types

### Riverpod Patterns
```dart
// Simple state
final sobrietyStartDateProvider = StateProvider<DateTime?>((ref) => null);

// Complex state with notifier
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
```
- Use `ConsumerWidget`/`ConsumerStatefulWidget` for widgets reading providers
- Define providers at file scope, not inside classes

### Hive Data Models
```dart
@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  DateTime lastDrinkDate;
}
```
- Unique `typeId` per model, sequential `@HiveField` numbers
- Generated files (`*.g.dart`) are in `.gitignore`
- Run `build_runner` after modifying model fields

### Widget Structure
- Keep widgets small and focused
- Private widgets prefixed with `_` for local helpers
- Use `const` constructors, `required` for non-optional named params
```dart
class _TimerUnit extends StatelessWidget {
  final int value;
  final String label;
  const _TimerUnit({required this.value, required this.label});
}
```

### Theme & Colors
- Use `ClearStateColors` static constants: `void_`, `charcoal`, `bone`, `signal`
- Use `ClearStateTypography` for text styles (JetBrains Mono)
- Use `ClearStateMotion` for animation durations and curves
- Primary accent: Signal Orange (`#FF6B35`)

### Error Handling
- Use null safety; avoid `!` operator unless certain
- Use Riverpod's `AsyncValue.when()` for async state
```dart
durationAsync.when(
  data: (duration) => TimerComponents.fromDuration(duration),
  loading: () => TimerComponents.fromDuration(Duration.zero),
  error: (_, __) => TimerComponents.fromDuration(Duration.zero),
);
```

### Comments
- `//` for single-line, `///` for documentation
- Use `// TODO:` for pending work
- Avoid commented-out code

## Linting

Uses `flutter_lints` package. Run `flutter analyze` to check.

## Key Files

- `lib/main.dart` - App initialization, Hive setup, widget initialization
- `lib/app.dart` - Root widget, navigation with 4-tab bottom nav
- `lib/data/repositories/sobriety_repository.dart` - Main data layer (includes `nukeAllData()`, `triggerWidgetUpdate()`)
- `lib/core/theme/colors.dart` - Color constants
- `lib/core/theme/motion.dart` - Animation constants and accessibility utilities
- `lib/core/theme/theme_provider.dart` - Theme state management with accent colors and background themes
- `lib/core/theme/typography.dart` - JetBrains Mono text styles
- `lib/core/constants/milestones.dart` - Recovery milestones
- `lib/core/constants/bio_states.dart` - Bio-state recovery metrics
- `lib/core/constants/stoic_quotes.dart` - Daily Stoic quotes database
- `lib/core/services/widget_update_service.dart` - Home screen widget sync
- `lib/core/services/widget_data_service.dart` - Widget data preparation
- `lib/data/models/widget_config.dart` - Widget configuration model (typeId: 4)
- `lib/features/widgets/widget_settings_screen.dart` - Stealth widget configuration UI
- `lib/features/widgets/providers/widget_settings_provider.dart` - Widget settings state
- `lib/features/settings/settings_screen.dart` - Settings with privacy & data management
- `lib/features/settings/widgets/wipe_confirmation_dialog.dart` - Nuclear wipe confirmation
- `lib/core/services/notification_service.dart` - Milestone notification scheduling
- `lib/features/settings/notification_provider.dart` - Notification settings state
- `pubspec.yaml` - Dependencies
- `analysis_options.yaml` - Lint config

## Shared Widgets

- `lib/shared/widgets/haptic_calendar.dart` - Modal calendar with haptic feedback
- `lib/shared/widgets/animated_counter.dart` - Animated digit counter (slide/morph modes)
- `lib/shared/widgets/brutalist_button.dart` - Brutalist-style buttons (primary/secondary)
- `lib/shared/widgets/animated_stepper_button.dart` - Animated stepper navigation buttons
- `lib/shared/widgets/celebration_overlay.dart` - Milestone celebration with confetti
- `lib/shared/widgets/haptic_scroll_view.dart` - Scroll views with overscroll haptics
- `lib/shared/widgets/animated_chip.dart` - Animated selection chips
- `lib/shared/widgets/animated_tab_switcher.dart` - Animated tab switching with scale/opacity
- `lib/shared/widgets/animated_nav_icon.dart` - Animated navigation icons (bounce effect)
- `lib/shared/widgets/sunrise_logo.dart` - Sunrise logo widget (accent-adaptive)
- `lib/shared/widgets/scroll_reveal.dart` - Scroll reveal animations (fade + slide up)
- `lib/features/settings/widgets/theme_settings.dart` - Theme/color picker settings

## Widget Tests

Widget tests for shared UI components are located in `test/shared/widgets/`:

- `animated_counter_test.dart` - Tests for AnimatedCounter widget
- `brutalist_button_test.dart` - Tests for BrutalistButton widget
- `haptic_calendar_test.dart` - Tests for HapticCalendar widget
- `animated_chip_test.dart` - Tests for AnimatedChip widget
- `celebration_overlay_test.dart` - Tests for CelebrationOverlay widget

Run with: `flutter test test/shared/widgets/`

## iOS Widget Extension Configuration

The ClearStateWidgetsExtension target is configured in `ios/Runner.xcodeproj/project.pbxproj`. To avoid Xcode build cycle errors when embedding the widget extension:

1. **Do not use Xcode's native "Embed Foundation Extensions" build phase** - it can cause cycle errors
2. **Use a shell script build phase instead** with `alwaysOutOfDate = 1` to copy the extension
3. The shell script should check if the extension exists before copying

The widget extension is embedded to `Runner.app/PlugIns/ClearStateWidgetsExtension.appex` via a custom shell script build phase in the Runner target.
