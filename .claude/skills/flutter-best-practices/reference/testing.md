# Flutter Testing Deep Dive

## Test Pyramid

```
        ╱╲
       ╱  ╲
      ╱ E2E╲        Few: Critical user flows
     ╱──────╲
    ╱ Widget ╲      More: Component behavior
   ╱──────────╲
  ╱    Unit    ╲    Many: Business logic
 ╱──────────────╲
```

| Type | What | Speed | Coverage Target |
|------|------|-------|-----------------|
| Unit | Logic, models, utilities | ~1ms | 70-80% |
| Widget | UI components | ~100ms | 15-25% |
| Integration | Full flows | ~10s | 5-10% |

---

## Unit Testing

### Basic Structure

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calculator', () {
    late Calculator calculator;
    
    setUp(() {
      calculator = Calculator();
    });
    
    test('adds two numbers', () {
      expect(calculator.add(2, 3), equals(5));
    });
    
    test('throws on division by zero', () {
      expect(() => calculator.divide(1, 0), throwsArgumentError);
    });
  });
}
```

### Testing with Mocks (mocktail)

```dart
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepo;
  late GetUserUseCase useCase;
  
  setUp(() {
    mockRepo = MockUserRepository();
    useCase = GetUserUseCase(mockRepo);
  });
  
  test('returns user from repository', () async {
    final user = User(id: '1', name: 'Test');
    when(() => mockRepo.getById('1')).thenAnswer((_) async => user);
    
    final result = await useCase('1');
    
    expect(result, equals(user));
    verify(() => mockRepo.getById('1')).called(1);
  });
  
  test('propagates repository errors', () async {
    when(() => mockRepo.getById(any())).thenThrow(NetworkException());
    
    expect(() => useCase('1'), throwsA(isA<NetworkException>()));
  });
}
```

### Async Testing

```dart
test('completes after delay', () async {
  final future = delayedOperation();
  
  await expectLater(future, completes);
});

test('stream emits values', () async {
  final stream = counterStream();
  
  await expectLater(stream, emitsInOrder([1, 2, 3]));
});

test('stream emits error', () async {
  final stream = failingStream();
  
  await expectLater(stream, emitsError(isA<Exception>()));
});
```

---

## Widget Testing

### Basic Widget Test

```dart
testWidgets('displays greeting', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: GreetingWidget(name: 'Flutter'),
    ),
  );
  
  expect(find.text('Hello, Flutter!'), findsOneWidget);
});
```

### User Interaction

```dart
testWidgets('increments counter on tap', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: CounterPage()));
  
  expect(find.text('0'), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();  // Rebuild after state change
  
  expect(find.text('1'), findsOneWidget);
});

testWidgets('submits form', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: LoginPage()));
  
  await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('password')), 'password123');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  expect(find.text('Welcome!'), findsOneWidget);
});
```

### Testing with Riverpod

```dart
testWidgets('shows loading then data', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userProvider.overrideWith((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return User(id: '1', name: 'Test User');
        }),
      ],
      child: const MaterialApp(home: UserScreen()),
    ),
  );
  
  // Initially loading
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  
  // Wait for async operation
  await tester.pumpAndSettle();
  
  // Now shows data
  expect(find.text('Test User'), findsOneWidget);
});
```

### Testing with BLoC

```dart
testWidgets('shows user after login', (tester) async {
  final authBloc = MockAuthBloc();
  
  whenListen(
    authBloc,
    Stream.fromIterable([AuthLoading(), AuthSuccess(mockUser)]),
    initialState: AuthInitial(),
  );
  
  await tester.pumpWidget(
    BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.text(mockUser.name), findsOneWidget);
});
```

---

## Time-Based Testing

### Using pump()

```dart
testWidgets('animates over 500ms', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: AnimatedWidget()));
  
  // Check initial state
  expect(find.byType(AnimatedWidget), findsOneWidget);
  
  // Advance 250ms
  await tester.pump(const Duration(milliseconds: 250));
  
  // Check mid-animation state
  final widget = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
  expect(widget.opacity, closeTo(0.5, 0.1));
  
  // Complete animation
  await tester.pumpAndSettle();
});
```

### pump() vs pumpAndSettle()

| Method | Use When |
|--------|----------|
| `pump()` | Need to check intermediate states |
| `pump(duration)` | Advance specific time |
| `pumpAndSettle()` | Wait for all animations to complete |

**Important**: `pumpAndSettle()` only waits for the render pipeline, NOT network calls.

```dart
// ❌ Wrong - pumpAndSettle won't wait for HTTP
testWidgets('loads data', (tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();  // Times out if real HTTP
  expect(find.text('Data'), findsOneWidget);
});

// ✅ Correct - mock the HTTP
testWidgets('loads data', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dataProvider.overrideWith((_) => mockData)],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('Data'), findsOneWidget);
});
```

---

## Mocking Platform Plugins

### Wrap in Service Class

```dart
// Don't test plugin directly - wrap it
abstract class ConnectivityService {
  Stream<bool> get onConnectivityChanged;
  Future<bool> get isConnected;
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  
  ConnectivityServiceImpl(this._connectivity);
  
  @override
  Stream<bool> get onConnectivityChanged => 
    _connectivity.onConnectivityChanged.map((r) => r != ConnectivityResult.none);
  
  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

// Test with mock
class MockConnectivityService extends Mock implements ConnectivityService {}

testWidgets('shows offline banner', (tester) async {
  final mockService = MockConnectivityService();
  when(() => mockService.isConnected).thenAnswer((_) async => false);
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [connectivityProvider.overrideWithValue(mockService)],
      child: const MyApp(),
    ),
  );
  
  await tester.pumpAndSettle();
  expect(find.text('You are offline'), findsOneWidget);
});
```

---

## Integration Testing

### Setup

```yaml
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### Test Structure

```dart
// integration_test/app_test.dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete login flow', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    // Navigate to login
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    
    // Fill form
    await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'password123');
    
    // Submit
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Verify navigation to home
    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
```

### Run Integration Tests

```bash
# Run on device/emulator
flutter test integration_test/app_test.dart

# Run on specific device
flutter test integration_test/app_test.dart -d <device_id>
```

---

## CI Configuration

### GitHub Actions

```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## Testing Checklist

- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Mock external dependencies
- [ ] Test error states
- [ ] Test loading states
- [ ] Integration tests for critical flows
- [ ] CI runs tests on every PR
