# Configs Layer Reference — Unbroken Mobile

> `lib/configs/` is the UI foundation layer. Everything that touches spacing, color, typography, navigation, or shared Dart extensions lives here.
> Read this before writing any UI code — raw `EdgeInsets`, `SizedBox`, `TextStyle`, and `Navigator` calls are replaced by these APIs.

Import everything with a single import:
```dart
import 'package:unbroken_mobile/configs/configs.dart';
```

---

## `App.init(context)`

Every `build()` method **must** call this first:

```dart
@override
Widget build(BuildContext context) {
  App.init(context);   // initializes AppMedia, AppTheme, Space, AppText, AppUnit
  ...
}
```

---

## Navigation

Routes are plain strings in `lib/router/routes.dart`. The string extension (from `lib/configs/extension/_string.dart`) adds named-navigation methods:

| Method | Underlying call |
|---|---|
| `.push(context)` | `Navigator.pushNamed` |
| `.pushReplace(context)` | `Navigator.pushReplacementNamed` |
| `.pushAndClear(context)` | `Navigator.pushNamedAndRemoveUntil(…, (r) => false)` |
| `.pop(context, [result])` | `Navigator.pop` |
| `.popUntil(context)` | `Navigator.popUntil(ModalRoute.withName(this))` |
| `.sameRoute()` | `NavigationHistoryObserver` — `true` if already on top |

---

## Space System

| Property | Type | What it produces |
|---|---|---|
| `Space.x.t16` | `Widget` (SizedBox) | Horizontal gap of 16 px — use in `Row` |
| `Space.y.t16` | `Widget` (SizedBox) | Vertical gap of 16 px — use in `Column` |
| `Space.a.t20` | `EdgeInsets` | `EdgeInsets.all(20)` |
| `Space.h.t20` | `EdgeInsets` | `EdgeInsets.symmetric(horizontal: 20)` |
| `Space.v.t20` | `EdgeInsets` | `EdgeInsets.symmetric(vertical: 20)` |
| `Space.t/b/l/r.t20` | `EdgeInsets` | `EdgeInsets.only(...)` |
| `Space.sym([h, v])` | `EdgeInsets` | `EdgeInsets.symmetric` |
| `Space.only([t,r,b,l])` | `EdgeInsets` | `EdgeInsets.only` |

---

## Theme & Colors

### `AppTheme.c` — semantic color tokens
Always use these — auto-resolves light/dark:

- `AppTheme.c.primary`
- `AppTheme.c.accent`
- `AppTheme.c.text`
- `AppTheme.c.subText`
- `AppTheme.c.background`
- `AppTheme.c.subBackground`
- `AppTheme.c.border`
- `AppTheme.c.error`
- `AppTheme.c.success`
- `AppTheme.c.warning`

---

## Typography

Use `AppText.h1/h2/h3(+b)`, `AppText.b1/b2(+b)`, `AppText.l1/l1b` with chaining extensions:
```dart
Text('Title', style: AppText.h2b.cl(AppTheme.c.text));
```

