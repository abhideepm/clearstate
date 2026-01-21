# State Management Deep Dive

## Riverpod 3.x (Recommended)

### Provider Types

```dart
// Synchronous provider
@riverpod
String greeting(GreetingRef ref) => 'Hello';

// Async provider
@riverpod
Future<User> currentUser(CurrentUserRef ref) async {
  return ref.watch(apiClientProvider).fetchUser();
}

// Stream provider
@riverpod
Stream<List<Message>> messages(MessagesRef ref) {
  return ref.watch(chatServiceProvider).messageStream;
}

// Notifier (mutable state)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
}

// AsyncNotifier (async mutable state)
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<User?> build() => ref.watch(authRepoProvider).getCurrentUser();
  
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepoProvider).login(email, password),
    );
  }
}
```

### Mutations (Riverpod 3.x)

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() => ref.watch(todoRepoProvider).fetchAll();
  
  @mutation
  Future<void> addTodo(String title) async {
    final newTodo = await ref.read(todoRepoProvider).create(title);
    state = AsyncData([...state.value!, newTodo]);
  }
}

// Widget usage
class AddButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(todoListProvider.addTodo);
    
    return ElevatedButton(
      onPressed: mutation.isLoading ? null : () => ref.read(todoListProvider.notifier).addTodo('New'),
      child: mutation.isLoading ? const CircularProgressIndicator() : const Text('Add'),
    );
  }
}
```

### Provider Placement

```
lib/
├── features/
│   └── auth/
│       ├── providers/
│       │   ├── auth_controller.dart    # Feature-specific providers
│       │   └── auth_state.dart
│       └── presentation/
└── core/
    └── providers/
        └── api_client_provider.dart    # Shared providers
```

### Testing with Riverpod

```dart
testWidgets('shows user data', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((_) => Future.value(mockUser)),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    ),
  );
  
  await tester.pumpAndSettle();
  expect(find.text(mockUser.name), findsOneWidget);
});
```

---

## BLoC 9.x (Enterprise)

### When to Use BLoC

- Large teams (8+) needing strict conventions
- Regulatory/audit requirements
- Complex event-driven flows
- Existing BLoC codebase

### Event/State Pattern

```dart
// Events
sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email, password;
  const LoginRequested(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

// States
sealed class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
  
  @override
  List<Object?> get props => [user];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  
  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
  }
  
  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
```

### Cubit (Simplified BLoC)

```dart
// Use Cubit when you don't need event traceability
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);
  
  void setLight() => emit(ThemeMode.light);
  void setDark() => emit(ThemeMode.dark);
}
```

### BlocSelector for Performance

```dart
BlocSelector<CartBloc, CartState, int>(
  selector: (state) => state is CartLoaded ? state.items.length : 0,
  builder: (_, count) => Badge(label: Text('$count')),
)
```

---

## Why Avoid GetX

1. **Maintenance Crisis**: Extended periods of inactivity, delayed Flutter updates
2. **Single Maintainer Risk**: Bus factor of 1
3. **Architectural Issues**: Global singletons, implicit lifecycle, memory leaks
4. **Navigation Conflicts**: Custom navigation stack conflicts with ecosystem packages

**Migration Path**: Move to Riverpod incrementally using wrapper providers.

---

## Provider (Legacy)

Still valid for:
- Simple apps
- Existing codebases where migration isn't justified
- Learning Flutter basics

```dart
ChangeNotifierProvider(
  create: (_) => CounterModel(),
  child: Consumer<CounterModel>(
    builder: (_, model, __) => Text('${model.count}'),
  ),
)
```

---

## Decision Matrix

| Factor | Riverpod | BLoC | Provider |
|--------|----------|------|----------|
| Learning curve | Medium | High | Low |
| Boilerplate | Low (with codegen) | High | Low |
| Type safety | Excellent | Good | Fair |
| Testability | Excellent | Excellent | Good |
| Performance | Excellent | Excellent | Good |
| Team scalability | Good | Excellent | Fair |
