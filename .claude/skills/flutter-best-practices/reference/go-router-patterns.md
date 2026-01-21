# go_router Navigation Patterns

## Basic Setup

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/details/:id',
      name: 'details',
      builder: (_, state) => DetailsScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);

// App setup
MaterialApp.router(
  routerConfig: router,
)
```

---

## Navigation Methods

```dart
// Replace current route (no back navigation)
context.go('/details/123');

// Push onto stack (with back navigation)
context.push('/details/123');

// Go back
context.pop();

// Replace top of stack
context.pushReplacement('/home');

// Named routes
context.goNamed('details', pathParameters: {'id': '123'});

// With query parameters
context.go('/search?query=flutter');
context.goNamed('search', queryParameters: {'query': 'flutter'});
```

---

## Nested Routes

```dart
GoRoute(
  path: '/products',
  builder: (_, __) => const ProductsScreen(),
  routes: [
    GoRoute(
      path: ':id',  // /products/:id
      builder: (_, state) => ProductDetailScreen(
        id: state.pathParameters['id']!,
      ),
      routes: [
        GoRoute(
          path: 'reviews',  // /products/:id/reviews
          builder: (_, state) => ReviewsScreen(
            productId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
)
```

---

## Shell Routes (Persistent Navigation)

```dart
ShellRoute(
  builder: (context, state, child) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _calculateIndex(state.uri.path),
      ),
    );
  },
  routes: [
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeTab(),
    ),
    GoRoute(
      path: '/search',
      builder: (_, __) => const SearchTab(),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileTab(),
    ),
  ],
)
```

### Nested Shell Routes (Tab Navigation)

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, __) => const SearchScreen(),
          routes: [
            GoRoute(
              path: 'results',
              builder: (_, __) => const SearchResultsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
)
```

---

## Authentication Redirect

```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';
    
    // Not logged in and not on login page -> redirect to login
    if (!isLoggedIn && !isLoggingIn) {
      return '/login?redirect=${state.uri}';
    }
    
    // Logged in and on login page -> redirect to home
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }
    
    // No redirect needed
    return null;
  },
  routes: [...],
);
```

### Refresh on Auth Change

```dart
final router = GoRouter(
  refreshListenable: authNotifier,  // Notifier that fires on auth changes
  redirect: (context, state) {
    // Redirect logic
  },
  routes: [...],
);
```

---

## Route Guards

```dart
GoRoute(
  path: '/admin',
  redirect: (context, state) {
    final isAdmin = ref.read(userProvider)?.isAdmin ?? false;
    if (!isAdmin) {
      return '/unauthorized';
    }
    return null;
  },
  builder: (_, __) => const AdminScreen(),
)
```

---

## Error Handling

```dart
GoRouter(
  errorBuilder: (context, state) => ErrorScreen(
    error: state.error,
  ),
  routes: [...],
)

// Or with a page
GoRouter(
  errorPageBuilder: (context, state) => MaterialPage(
    child: ErrorScreen(error: state.error),
  ),
  routes: [...],
)
```

---

## Deep Linking

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="myapp.com" />
</intent-filter>
```

### iOS (ios/Runner/Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

---

## Page Transitions

```dart
GoRoute(
  path: '/details/:id',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: DetailsScreen(id: state.pathParameters['id']!),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
)
```

---

## Route Configuration Organization

```dart
// lib/src/core/routing/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: kDebugMode,
  redirect: _globalRedirect,
  routes: [
    ...authRoutes,
    ...mainRoutes,
  ],
);

// lib/src/core/routing/routes/auth_routes.dart
final authRoutes = [
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (_, __) => const LoginScreen(),
  ),
  GoRoute(
    path: '/register',
    name: 'register',
    builder: (_, __) => const RegisterScreen(),
  ),
];

// lib/src/core/routing/routes/main_routes.dart
final mainRoutes = [
  ShellRoute(
    builder: (_, __, child) => MainShell(child: child),
    routes: [
      GoRoute(path: '/home', ...),
      GoRoute(path: '/profile', ...),
    ],
  ),
];
```

---

## Testing Routes

```dart
testWidgets('navigates to details', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
  
  await tester.tap(find.text('View Details'));
  await tester.pumpAndSettle();
  
  expect(find.byType(DetailsScreen), findsOneWidget);
});
```

---

## Common Patterns

### Pass Complex Objects

```dart
// Use extra for complex objects (not recommended for deep links)
context.go('/details', extra: product);

// In route
GoRoute(
  path: '/details',
  builder: (_, state) {
    final product = state.extra as Product;
    return DetailsScreen(product: product);
  },
)

// Better: Use ID and fetch
context.go('/details/${product.id}');
```

### Return Values

```dart
// Push and wait for result
final result = await context.push<bool>('/confirm');
if (result == true) {
  // Confirmed
}

// Pop with value
context.pop(true);
```
