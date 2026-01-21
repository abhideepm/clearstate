# Material 3 Theming

## Basic Setup

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.light,
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.dark,
  ),
  themeMode: ThemeMode.system,
)
```

---

## Custom Color Scheme

```dart
// From seed color (recommended)
final lightScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  brightness: Brightness.light,
);

final darkScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  brightness: Brightness.dark,
);

// Or fully custom
final customScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6750A4),
  onPrimary: Colors.white,
  secondary: Color(0xFF625B71),
  onSecondary: Colors.white,
  error: Color(0xFFB3261E),
  onError: Colors.white,
  surface: Color(0xFFFFFBFE),
  onSurface: Color(0xFF1C1B1F),
);
```

---

## Using Colors in Widgets

```dart
// ✅ Good - use theme colors
Container(
  color: Theme.of(context).colorScheme.primaryContainer,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  ),
)

// ❌ Bad - hardcoded colors
Container(
  color: Color(0xFF6750A4),
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.white),
  ),
)
```

### Color Scheme Roles

| Role | Use For |
|------|---------|
| `primary` | Key actions, active states |
| `onPrimary` | Text/icons on primary |
| `primaryContainer` | Less prominent containers |
| `secondary` | Secondary actions |
| `tertiary` | Accents, highlights |
| `surface` | Backgrounds, cards |
| `surfaceContainerHighest` | Elevated surfaces |
| `error` | Error states |
| `outline` | Borders, dividers |

---

## Typography

```dart
// Material 3 typography
Text(
  'Display Large',
  style: Theme.of(context).textTheme.displayLarge,
)

Text(
  'Body Medium',
  style: Theme.of(context).textTheme.bodyMedium,
)

// Available styles:
// displayLarge, displayMedium, displaySmall
// headlineLarge, headlineMedium, headlineSmall
// titleLarge, titleMedium, titleSmall
// bodyLarge, bodyMedium, bodySmall
// labelLarge, labelMedium, labelSmall
```

### Custom Typography

```dart
ThemeData(
  useMaterial3: true,
  textTheme: TextTheme(
    displayLarge: GoogleFonts.roboto(
      fontSize: 57,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  ),
)
```

---

## Theme Extensions

For custom design tokens not in Material:

```dart
// Define extension
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color? success;
  final Color? warning;
  final Color? info;

  const AppColors({
    this.success,
    this.warning,
    this.info,
  });

  @override
  AppColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
      info: Color.lerp(info, other.info, t),
    );
  }

  static const light = AppColors(
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    info: Color(0xFF2196F3),
  );

  static const dark = AppColors(
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    info: Color(0xFF64B5F6),
  );
}

// Register in theme
ThemeData(
  useMaterial3: true,
  extensions: [AppColors.light],
)

// Use in widgets
final appColors = Theme.of(context).extension<AppColors>()!;
Container(color: appColors.success)
```

---

## Component Themes

```dart
ThemeData(
  useMaterial3: true,
  
  // Buttons
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(88, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  
  // Cards
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  // Input fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  
  // App bar
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
)
```

---

## Dynamic Color (Android 12+)

```dart
// Use dynamic_color package
import 'package:dynamic_color/dynamic_color.dart';

DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    ColorScheme lightScheme;
    ColorScheme darkScheme;
    
    if (lightDynamic != null && darkDynamic != null) {
      // Use dynamic colors from wallpaper
      lightScheme = lightDynamic.harmonized();
      darkScheme = darkDynamic.harmonized();
    } else {
      // Fallback to seed color
      lightScheme = ColorScheme.fromSeed(seedColor: brandColor);
      darkScheme = ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.dark,
      );
    }
    
    return MaterialApp(
      theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
      darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
    );
  },
)
```

---

## Accessibility

### Contrast

```dart
// Material 3 automatically ensures contrast
// But verify with custom colors:
final scheme = ColorScheme.fromSeed(seedColor: brandColor);

// These pairs should have sufficient contrast:
// primary / onPrimary
// primaryContainer / onPrimaryContainer
// surface / onSurface
```

### Text Scaling

```dart
// Don't use fixed sizes for text
// ✅ Good - scales with system settings
Text('Hello', style: Theme.of(context).textTheme.bodyLarge)

// ❌ Bad - ignores text scaling
Text('Hello', style: TextStyle(fontSize: 16))

// If you must use fixed size, allow scaling
MediaQuery.textScalerOf(context).scale(16)
```

### Semantic Labels

```dart
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: onDelete,
  tooltip: 'Delete item',  // For accessibility
)

Image.network(
  url,
  semanticLabel: 'Product image: Blue sneakers',
)
```

---

## Theme Organization

```dart
// lib/src/core/theme/app_theme.dart
class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      extensions: [AppColors.light, AppSpacing.standard],
      filledButtonTheme: _filledButtonTheme(colorScheme),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputTheme(colorScheme),
    );
  }
  
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: Brightness.dark,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      extensions: [AppColors.dark, AppSpacing.standard],
      filledButtonTheme: _filledButtonTheme(colorScheme),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputTheme(colorScheme),
    );
  }
  
  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(88, 48),
      ),
    );
  }
}
```
