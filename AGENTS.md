# AGENTS.md - ClearState

This document provides context for AI coding agents working in this codebase.

## Project Overview

**ClearState** is a minimalist sobriety tracker mobile app built with Flutter.
- Framework: Flutter (Dart SDK ^3.10.7)
- State Management: flutter_riverpod (^2.4.0)
- Local Storage: Hive (^2.2.3) + hive_flutter
- UI: Material 3 with custom dark theme

## Project Structure

```
clearstate_app/
├── lib/
│   ├── main.dart         # App entry point, Hive setup
│   ├── app.dart          # Root widget, navigation
│   ├── core/
│   │   ├── constants/    # Milestones, drink presets
│   │   ├── services/     # Haptic feedback service
│   │   └── theme/        # Colors, typography, app theme
│   ├── data/
│   │   ├── models/       # Hive models (*.dart + *.g.dart)
│   │   └── repositories/ # Data access layer
│   ├── features/
│   │   ├── timer/        # Main sobriety timer
│   │   ├── timeline/     # Recovery milestones
│   │   ├── analytics/    # Stats & heatmap
│   │   ├── onboarding/   # Initial setup flow
│   │   ├── relapse/      # Relapse tracking
│   │   └── settings/     # Settings & data management
│   └── shared/widgets/   # Shared UI components
└── test/                 # Test files
```

## Build/Lint/Test Commands

Run from `clearstate_app/` directory:

```bash
flutter pub get                    # Install dependencies
flutter run                        # Run app (debug)
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run single test file
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
- Use `dart format` (2-space indent, 80 char lines)
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
- Use `ClearStateTypography` for text styles
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

- `lib/main.dart` - App initialization, Hive setup
- `lib/app.dart` - Root widget, navigation with 4-tab bottom nav
- `lib/data/repositories/sobriety_repository.dart` - Main data layer (includes `nukeAllData()`)
- `lib/core/theme/colors.dart` - Color constants
- `lib/core/constants/milestones.dart` - Recovery milestones
- `lib/features/settings/settings_screen.dart` - Settings with privacy & data management
- `lib/features/settings/widgets/wipe_confirmation_dialog.dart` - Nuclear wipe confirmation
- `pubspec.yaml` - Dependencies
- `analysis_options.yaml` - Lint config
