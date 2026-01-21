# Clean Architecture for Flutter

## Layer Overview

```
┌─────────────────────────────────────────┐
│           PRESENTATION                   │
│  Widgets, Pages, BLoCs/Providers         │
│  Depends on: Domain                      │
├─────────────────────────────────────────┤
│              DOMAIN                      │
│  Entities, Use Cases, Repo Interfaces    │
│  Depends on: Nothing (pure Dart)         │
├─────────────────────────────────────────┤
│               DATA                       │
│  Repo Implementations, DTOs, Sources     │
│  Depends on: Domain                      │
└─────────────────────────────────────────┘
```

## Dependency Rule

Dependencies point **inward** only:
- Presentation → Domain ✅
- Data → Domain ✅
- Domain → Presentation ❌
- Domain → Data ❌

---

## Layer Responsibilities

### Domain Layer

Pure Dart, no Flutter imports.

```dart
// Entity (business object)
class User {
  final String id;
  final String email;
  final String name;
  
  const User({required this.id, required this.email, required this.name});
}

// Repository interface (contract)
abstract class UserRepository {
  Future<User> getById(String id);
  Future<List<User>> getAll();
  Future<void> save(User user);
}

// Use case (optional, for complex logic)
class GetUserUseCase {
  final UserRepository _repository;
  
  GetUserUseCase(this._repository);
  
  Future<User> call(String id) => _repository.getById(id);
}
```

### Data Layer

Implements domain interfaces, handles external systems.

```dart
// DTO (Data Transfer Object)
class UserDto {
  final String id;
  final String email;
  final String name;
  
  UserDto({required this.id, required this.email, required this.name});
  
  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'],
    email: json['email'],
    name: json['name'],
  );
  
  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};
  
  User toEntity() => User(id: id, email: email, name: name);
  
  factory UserDto.fromEntity(User user) => UserDto(
    id: user.id,
    email: user.email,
    name: user.name,
  );
}

// Repository implementation
class UserRepositoryImpl implements UserRepository {
  final ApiClient _client;
  final UserLocalDataSource _local;
  
  UserRepositoryImpl(this._client, this._local);
  
  @override
  Future<User> getById(String id) async {
    try {
      final dto = await _client.getUser(id);
      await _local.cache(dto);
      return dto.toEntity();
    } catch (e) {
      final cached = await _local.get(id);
      if (cached != null) return cached.toEntity();
      rethrow;
    }
  }
  
  @override
  Future<List<User>> getAll() async {
    final dtos = await _client.getUsers();
    return dtos.map((d) => d.toEntity()).toList();
  }
  
  @override
  Future<void> save(User user) async {
    await _client.saveUser(UserDto.fromEntity(user));
  }
}

// Data source
class UserLocalDataSource {
  final SharedPreferences _prefs;
  
  UserLocalDataSource(this._prefs);
  
  Future<void> cache(UserDto dto) async {
    await _prefs.setString('user_${dto.id}', jsonEncode(dto.toJson()));
  }
  
  Future<UserDto?> get(String id) async {
    final json = _prefs.getString('user_$id');
    if (json == null) return null;
    return UserDto.fromJson(jsonDecode(json));
  }
}
```

### Presentation Layer

Widgets and state management.

```dart
// Provider (Riverpod)
@riverpod
Future<User> user(UserRef ref, String id) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getById(id);
}

// Widget
class UserProfileScreen extends ConsumerWidget {
  final String userId;
  
  const UserProfileScreen({super.key, required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));
    
    return userAsync.when(
      data: (user) => UserProfileView(user: user),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString()),
    );
  }
}
```

---

## Folder Structure

```
lib/src/features/user/
├── data/
│   ├── datasources/
│   │   ├── user_local_datasource.dart
│   │   └── user_remote_datasource.dart
│   ├── models/
│   │   └── user_dto.dart
│   └── repositories/
│       └── user_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   └── usecases/
│       └── get_user_usecase.dart
└── presentation/
    ├── providers/
    │   └── user_provider.dart
    ├── screens/
    │   └── user_profile_screen.dart
    └── widgets/
        └── user_avatar.dart
```

---

## When to Add Layers

| App Complexity | Recommended Structure |
|----------------|----------------------|
| Simple/MVP | Presentation + Data (skip Domain) |
| Medium | Full 3-layer |
| Complex/Enterprise | 3-layer + Use Cases |

---

## Common Mistakes

1. **Passing BuildContext to Domain**: Use callbacks or value objects instead
2. **DTOs in Domain**: Keep DTOs in Data layer, map at boundary
3. **Repository in Widget**: Inject via provider/DI
4. **Skipping Entity Mapping**: Always convert DTOs to entities
5. **Circular Feature Dependencies**: Features should only depend on shared/core
