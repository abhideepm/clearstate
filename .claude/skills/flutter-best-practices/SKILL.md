---
name: flutter-best-practices
description: Use when creating new Flutter 3.x apps, scaffolding projects, or refactoring early-stage Flutter code. Provides defaults for state management (Riverpod 3.x; BLoC for enterprise), Clean Architecture, go_router navigation, Material 3 theming, performance guardrails, and testing strategy.
---

# Flutter 3.x Best Practices

Checklist-first guide for production Flutter apps.

## Scope

- Target: Flutter **3.x** new projects
- Focus: Maintainability, testability, performance, Material 3

---

## Project Setup

**Default:**
- Flutter stable channel
- Null safety enabled
- `flutter_lints` for analysis

**Do:**
- Run `flutter analyze` and `flutter test` in CI
- Use `dart format` before commits
- Keep `pubspec.yaml` dependencies minimal

**Avoid:**
- Disabling lints without justification
- Using deprecated APIs

---

## Folder Structure

**Default:**
```
lib/
├── main.dart
├── src/
│   ├── app.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── home/
│   ├── core/
│   │   ├── routing/
│   │   ├── theme/
│   │   └── utils/
│   └── shared/widgets/
test/
├── unit/
├── widget/
└── integration_test/
```

**Do:**
- Organize by feature for medium+ apps
- Keep shared code in `core/` or `shared/`

**Avoid:**
- Flat structure with 50+ files in one folder
- Circular dependencies between features

**Reference:** `reference/folder-structure.md`

---

## Architecture

**Default:** Pragmatic Clean Architecture (3 layers)

| Layer | Contains | Depends On |
|-------|----------|------------|
| Presentation | Widgets, BLoC/Providers | Domain |
| Domain | Entities, Use Cases, Repo interfaces | Nothing |
| Data | Repo implementations, DTOs, Data sources | Domain |

**Do:**
- Keep domain layer framework-agnostic
- Use repository interfaces for testability
- Map DTOs to domain entities at data layer boundary

**Avoid:**
- Passing framework types (BuildContext) to domain
- Skipping layers "for simplicity" without thought

**Reference:** `reference/clean-architecture.md`

---

## State Management

**Default:** Riverpod 3.x

**Alternatives:**
| Use Case | Choice |
|----------|--------|
| Most projects | Riverpod 3.x |
| Enterprise/audit needs | BLoC 9.x |
| Legacy maintenance | Provider |
| **Avoid for new projects** | GetX |

**Do:**
- Use `@riverpod` codegen for type safety
- Keep providers close to their features
- Use `AsyncNotifier` for async state

**Avoid:**
- God providers that manage everything
- GetX for new projects (maintenance risk, single maintainer)

**When to choose BLoC:**
- Large teams needing strict event/state separation
- Regulatory requirements for audit trails

**Reference:** `reference/state-management.md`

---

## Navigation

**Default:** go_router

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/details/:id',
      builder: (_, state) => DetailsScreen(id: state.pathParameters['id']!),
    ),
  ],
);
```

**Do:**
- Use `context.go()` for replacement, `context.push()` for stack
- Implement redirect for auth gates
- Use `ShellRoute` for persistent navigation shells

**Avoid:**
- Mixing Navigator 1.0 and go_router
- Deep nesting without clear route naming

**Reference:** `reference/go-router-patterns.md`

---

## UI & Material 3

**Default:** Material 3 with `useMaterial3: true`

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
  ),
)
```

**Do:**
- Use `Theme.of(context).colorScheme` for colors
- Create `ThemeExtension` for custom tokens
- Use `const` widgets where possible

**Avoid:**
- Hardcoded colors outside theme
- Ignoring text scaling for accessibility

**Reference:** `reference/material3-theming.md`

---

## Performance

**Defaults (80% of wins):**

| Do | Avoid |
|----|-------|
| `const` constructors | Non-const where const is possible |
| `ListView.builder` | `ListView(children: [...])` for long lists |
| `ValueKey` on list items | Missing keys on reorderable items |
| Localized `setState` | `setState` high in widget tree |

**Animation Pitfalls:**

| Avoid | Use Instead |
|-------|-------------|
| `Opacity` widget (expensive) | `AnimatedOpacity`, `FadeTransition` |
| Clipping during animation | Pre-clip before animating |
| Heavy `build()` methods | Extract to smaller widgets |

**Do:**
- Profile with DevTools before release
- Use `RepaintBoundary` for isolated animations
- Cache expensive computations outside `build()`

**Reference:** `reference/performance.md`

---

## Testing

**Strategy (Test Pyramid):**

| Type | What to Test | Speed |
|------|--------------|-------|
| Unit | Business logic, utilities, models | Fast |
| Widget | UI components, user interactions | Fast |
| Integration | Full user flows | Slow |

**Do:**
- Mock HTTP clients via dependency injection
- Use `tester.pump()` for time-based tests
- Wrap platform plugins in service classes

**Avoid:**
- Real network calls in tests
- Relying on `pumpAndSettle()` for async operations

**Reference:** `reference/testing.md`

---

## Animations

**Decision Tree:**

| Need | Use |
|------|-----|
| Simple property change | Implicit (`AnimatedContainer`, `AnimatedOpacity`) |
| Custom property animation | `TweenAnimationBuilder` |
| Full control/sequencing | Explicit (`AnimationController`) |
| Physics/spring effects | `SpringSimulation`, `physics_model` |
| Complex graphics | Rive, Lottie |

**Do:**
- Start with implicit animations (simplest)
- Use `AnimatedBuilder` with child parameter for performance
- Apply `RepaintBoundary` to isolate animations
- Dispose `AnimationController` in `dispose()`

**Avoid:**
- `Opacity` widget for animations (use `FadeTransition`)
- Rebuilding static widgets in animation builders
- Clipping during animations

**Reference:** `reference/animations.md`

---

## Error Handling

**Do:**
- Centralize exception mapping
- Show user-friendly error messages
- Log errors without PII
- Set up crash reporting (Firebase Crashlytics, Sentry)

**Avoid:**
- Swallowing exceptions silently
- Exposing stack traces to users

---

## PR Checklist

- [ ] Architecture boundaries respected
- [ ] Tests added/updated
- [ ] No lint warnings
- [ ] Performance: used const, builder patterns
- [ ] Accessibility: proper semantics, contrast
- [ ] Navigation routes follow convention

---

## Essential Packages

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^16.0.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  mocktail: ^1.0.0
  flutter_lints: ^6.0.0
```

---

## Quick Reference Links

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Flutter Testing](https://docs.flutter.dev/testing/overview)
