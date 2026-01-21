# Flutter Performance Deep Dive

## Build Optimization

### Use const Everywhere

```dart
// ✅ Good - cached by framework
const SizedBox(height: 16);
const EdgeInsets.all(8);
const Icon(Icons.add);
const Text('Static text');

// ❌ Bad - new instance every build
SizedBox(height: 16);
EdgeInsets.all(8);
```

### Avoid Heavy build() Methods

```dart
// ❌ Bad - computation runs every rebuild
@override
Widget build(BuildContext context) {
  final sorted = items.toList()..sort((a, b) => a.name.compareTo(b.name));
  return ListView.builder(
    itemCount: sorted.length,
    itemBuilder: (_, i) => ItemTile(item: sorted[i]),
  );
}

// ✅ Good - compute once
class _MyWidgetState extends State<MyWidget> {
  late final sorted = widget.items.toList()..sort((a, b) => a.name.compareTo(b.name));
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (_, i) => ItemTile(item: sorted[i]),
    );
  }
}
```

### Localize setState

```dart
// ❌ Bad - rebuilds entire subtree
class _ParentState extends State<Parent> {
  int counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveWidget(),           // Rebuilds unnecessarily
        Text('$counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

// ✅ Good - isolate changing state
class Parent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExpensiveWidget(),     // Never rebuilds
        const CounterWidget(),       // Self-contained state
      ],
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});
  
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

---

## List Optimization

### Use ListView.builder

```dart
// ❌ Bad - builds all 1000 items immediately
ListView(
  children: items.map((i) => ItemTile(item: i)).toList(),
)

// ✅ Good - builds only visible items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (_, index) => ItemTile(
    key: ValueKey(items[index].id),
    item: items[index],
  ),
)
```

### Add Keys for Reorderable Lists

```dart
// Required for correct state preservation
ListView.builder(
  itemCount: items.length,
  itemBuilder: (_, index) => Dismissible(
    key: ValueKey(items[index].id),  // Must be unique
    child: ItemTile(item: items[index]),
  ),
)
```

### Cache Extent

```dart
ListView.builder(
  cacheExtent: 100,  // Pixels to cache beyond viewport
  itemCount: items.length,
  itemBuilder: (_, i) => ItemTile(item: items[i]),
)
```

---

## Animation Pitfalls

### Opacity Widget

```dart
// ❌ Bad - creates saveLayer (expensive)
Opacity(
  opacity: 0.5,
  child: ExpensiveWidget(),
)

// ✅ Good - for animations
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 300),
  child: ExpensiveWidget(),
)

// ✅ Good - for images
FadeInImage.memoryNetwork(
  placeholder: kTransparentImage,
  image: imageUrl,
)
```

### AnimatedBuilder Optimization

```dart
// ❌ Bad - rebuilds static child every frame
AnimatedBuilder(
  animation: controller,
  builder: (context, _) {
    return Transform.rotate(
      angle: controller.value * 2 * pi,
      child: ExpensiveStaticWidget(),  // Rebuilds 60x/sec
    );
  },
)

// ✅ Good - pass static child
AnimatedBuilder(
  animation: controller,
  child: const ExpensiveStaticWidget(),  // Built once
  builder: (context, child) {
    return Transform.rotate(
      angle: controller.value * 2 * pi,
      child: child,  // Reused
    );
  },
)
```

### RepaintBoundary

```dart
// Isolate frequently updating widgets
Stack(
  children: [
    const StaticBackground(),
    RepaintBoundary(
      child: AnimatedWidget(),  // Repaints don't affect siblings
    ),
  ],
)
```

---

## Image Optimization

### Cache Network Images

```dart
// Use cached_network_image package
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => const CircularProgressIndicator(),
  errorWidget: (_, __, ___) => const Icon(Icons.error),
)
```

### Resize Images

```dart
// Decode at display size, not original
Image.network(
  url,
  cacheWidth: 200,   // Decode width
  cacheHeight: 200,  // Decode height
)
```

### Precache Images

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(const AssetImage('assets/hero.png'), context);
}
```

---

## String Building

```dart
// ❌ Bad - creates new String on each +
String buildMessage(List<String> items) {
  var result = '';
  for (final item in items) {
    result += '$item, ';  // O(n²) allocation
  }
  return result;
}

// ✅ Good - single allocation
String buildMessage(List<String> items) {
  final buffer = StringBuffer();
  for (final item in items) {
    buffer.write('$item, ');
  }
  return buffer.toString();
}

// ✅ Better - use join
String buildMessage(List<String> items) => items.join(', ');
```

---

## Profiling Checklist

1. **Run in release mode**: `flutter run --release`
2. **Open DevTools Performance tab**: `flutter pub global run devtools`
3. **Check for jank**: Look for frames > 16ms
4. **Identify rebuild storms**: Use Performance Overlay
5. **Memory profiling**: Check for leaks and large allocations

### DevTools Commands

```bash
# Start DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Profile mode (includes profiling overhead)
flutter run --profile

# Release mode (real performance)
flutter run --release
```

---

## Quick Wins Checklist

- [ ] All static widgets use `const`
- [ ] Lists use `ListView.builder`
- [ ] Keys on reorderable/dismissible items
- [ ] No heavy computation in `build()`
- [ ] `RepaintBoundary` around animations
- [ ] Images sized appropriately
- [ ] No `Opacity` widget in animations
- [ ] Static children passed to AnimatedBuilder
