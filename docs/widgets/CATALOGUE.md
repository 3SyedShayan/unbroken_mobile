# Shared Widget Catalogue — Unbroken Mobile

All shared widgets live in `lib/shared/widgets/`. They are domain-agnostic and prefixed with `App`.

---

## 1. Core Widgets (`lib/shared/widgets/core/`)

### `Screen` (`core/screen/screen.dart`)
Root scaffold wrapper for all full-screen views.
- **Parameters:**
  - `keyboardHandler: bool` — automatically dismisses keyboard on background tap.
  - `padding: EdgeInsets` — applies uniform padding (defaults to `Space.h.t16`).
  - `overlay: Widget?` — full-screen loading or banner overlay.

### `AppButton` (`core/buttons/app_button.dart`)
Data-driven branded button with variants and states.
- **Styles:** `.primary`, `.secondary`, `.creamy`, `.outline`, `.ghost`
- **Sizes:** `.small`, `.medium`, `.large`
- **States:** `.def`, `.disabled`, `.pressed`
- **Usage:**
```dart
AppButton(
  label: 'Save Changes',
  style: .primary,
  size: .medium,
  onPressed: () => _ScreenState.s(context).save(),
)
```

---

## 2. Design & Feedback (`lib/shared/widgets/design/` & `feedback/`)

### `AppShimmer` (`design/shimmer/app_shimmer.dart`)
Standard loading skeleton wrapper.
```dart
AppShimmer(
  child: Container(
    height: 120,
    decoration: BoxDecoration(
      color: AppTheme.c.subBackground,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### `UIFlash` (`feedback/app_snackbars.dart`)
Flash toast notifications:
```dart
UIFlash.success(context, 'Changes saved');
UIFlash.error(context, state.action.errorMessage);
```

### `AppActivityHeatmap` (`design/heatmap/app_activity_heatmap.dart`)
GitHub-style 5-level (`0..4`) intensity activity heatmap supporting `HeatmapLayout.calendarMonth` (1M) and `HeatmapLayout.weekColumns` (3M fit-width / 6M right-anchored scrollable).
```dart
AppActivityHeatmap(
  baseColor: AppTheme.c.accent,
  today: today,
  layout: HeatmapLayout.weekColumns,
  weeks: 13,
  fitWidth: true,
  levelForDate: (day) => summaryLevel(day),
)
```

---

## 3. Fluent Animation Extensions (`lib/shared/widgets/animations/`)

Chain fluent animations on any widget without deep nesting:
- `.withBottomAnimation()` — subtle staggered entry from bottom (+100ms cascade)
- `.withEntranceFader()` — subtle opacity and vertical slide entrance
- `.withScaleAnimation()` — interactive scale down on press
- `.withRippleEffect()` — ripple feedback wrapper

