---
name: Responsive UI
description: Membuat layout yang responsif untuk berbagai ukuran layar
---
# Responsive UI — PokéAtlas

`lib/utility/responsive.dart`

## Breakpoints

```dart
class Breakpoints {
  static const double mobile  = 600;   // < 600
  static const double tablet  = 900;   // 600 - 1200
  static const double desktop = 1200;  // >= 1200
}
```

## Responsive Widget

```dart
Responsive(
  mobile: GridView(crossAxisCount: 2, ...),
  tablet: GridView(crossAxisCount: 3, ...),   // opsional
  desktop: GridView(crossAxisCount: 4, ...),
)
```

## Extension pada BuildContext

```dart
// Cek breakpoint
if (context.isMobile) { ... }
if (context.isTablet) { ... }
if (context.isDesktop) { ... }

// Pilih value berdasarkan breakpoint
final columns = context.responsive(mobile: 2, tablet: 3, desktop: 4);
final padding = context.responsive<double>(mobile: 12, desktop: 24);

// Ukuran layar
final w = context.screenWidth;
final h = context.screenHeight;
```

## Contoh di Grid Pokemon

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.responsive(mobile: 2, tablet: 3, desktop: 5),
    childAspectRatio: 0.8,
  ),
  ...
)
```
