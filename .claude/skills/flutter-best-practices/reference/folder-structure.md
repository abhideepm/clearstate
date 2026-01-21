# Flutter Project Structure

## Small App (MVP/Prototype)

```
lib/
├── main.dart
├── app.dart
├── models/
│   ├── user.dart
│   └── product.dart
├── services/
│   ├── api_service.dart
│   └── auth_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── product_screen.dart
├── widgets/
│   ├── product_card.dart
│   └── loading_indicator.dart
└── utils/
    └── constants.dart
```

---

## Medium App (Feature-Based)

```
lib/
├── main.dart
├── src/
│   ├── app.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── models/
│   │   │   │       └── user_dto.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── register_screen.dart
│   │   │       └── widgets/
│   │   │           └── auth_form.dart
│   │   │
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       └── widgets/
│   │   │           └── home_header.dart
│   │   │
│   │   └── products/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── routing/
│   │   │   ├── app_router.dart
│   │   │   └── routes/
│   │   │       ├── auth_routes.dart
│   │   │       └── main_routes.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   └── utils/
│   │       └── extensions.dart
│   │
│   └── shared/
│       ├── providers/
│       │   └── api_client_provider.dart
│       └── widgets/
│           ├── app_button.dart
│           ├── app_text_field.dart
│           └── loading_overlay.dart
│
test/
├── unit/
│   ├── features/
│   │   └── auth/
│   │       └── auth_repository_test.dart
│   └── core/
│       └── utils_test.dart
├── widget/
│   └── features/
│       └── auth/
│           └── login_screen_test.dart
└── integration_test/
    └── auth_flow_test.dart
```

---

## Large App (Enterprise)

```
lib/
├── main.dart
├── main_development.dart
├── main_staging.dart
├── main_production.dart
├── bootstrap.dart
│
├── src/
│   ├── app/
│   │   ├── app.dart
│   │   └── app_providers.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth.dart                 # Barrel export
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_dto.dart
│   │   │   │   │   └── token_dto.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── logout_usecase.dart
│   │   │   │       └── register_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── register_screen.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── social_login_buttons.dart
│   │   │
│   │   └── [other features]/
│   │
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   └── environment.dart
│   │   ├── di/
│   │   │   └── injection_container.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_interceptors.dart
│   │   │   └── network_info.dart
│   │   ├── routing/
│   │   │   ├── app_router.dart
│   │   │   └── route_guards.dart
│   │   ├── storage/
│   │   │   ├── secure_storage.dart
│   │   │   └── local_storage.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   └── utils/
│   │       ├── extensions/
│   │       ├── formatters/
│   │       └── validators/
│   │
│   └── shared/
│       ├── models/
│       │   └── paginated_response.dart
│       └── widgets/
│           ├── buttons/
│           ├── inputs/
│           └── dialogs/
│
├── l10n/
│   ├── app_en.arb
│   └── app_es.arb
│
test/
├── fixtures/
│   └── json/
│       └── user.json
├── helpers/
│   └── test_helpers.dart
├── mocks/
│   └── mock_repositories.dart
├── unit/
├── widget/
└── integration_test/
```

---

## File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Dart files | lowercase_with_underscores | `user_repository.dart` |
| Directories | lowercase_with_underscores | `data_sources/` |
| Classes | UpperCamelCase | `UserRepository` |
| Widgets | UpperCamelCase | `ProductCard` |
| Tests | `*_test.dart` | `user_repository_test.dart` |

---

## Feature Module Rules

1. **Self-contained**: Feature has its own data/domain/presentation
2. **No circular deps**: Features don't import each other directly
3. **Shared via core**: Cross-feature code goes to `core/` or `shared/`
4. **Barrel exports**: Each feature has a single export file

```dart
// lib/src/features/auth/auth.dart (barrel export)
export 'domain/entities/user.dart';
export 'domain/repositories/auth_repository.dart';
export 'presentation/providers/auth_provider.dart';
// Don't export implementation details
```

---

## When to Restructure

| Signs | Action |
|-------|--------|
| 20+ files in one folder | Split into subfolders |
| Circular imports | Extract shared code to core |
| Feature growing large | Split into sub-features |
| Tests hard to organize | Mirror lib structure in test |
