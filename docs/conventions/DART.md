# Dart Code Conventions — Unbroken Mobile

Follow these rules for every file you touch.

---

## Widgets

### Private Widget Classes — Always, No Exceptions

Never return a widget from a function. Always create a private class:

```dart
// WRONG
Widget _buildHeader() => Text('Hello');

// CORRECT
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Text('Hello');
}
```

### Widget Extraction Threshold & The 3-Tier Hierarchy

The "always a private class" rule governs HOW to extract, not WHEN. Don't extract widgets that aren't worth extracting — a single Row or a one-line Container should be inlined in its parent.

Extract a widget according to the **3-Tier Hierarchy**:

1. **Tier 1 — Screen-Private Widget** (`views/<screen>/widgets/_<name>.dart`):
   - Extract if subtree has **≥5 child widgets** (counting every node), OR
   - Subtree is **≥30 lines** of build code, OR
   - Represents a distinct logical section or tab.
   - Defined as a private class with `part of '<screen>.dart'`.

2. **Tier 2 — Feature-Level Shared Widget** (`features/<feature>/widgets/<name>.dart`):
   - When a widget is reused across **≥2 screens within the same feature**, and depends on domain models.
   - Defined as a public class with its own standalone file and imports (not a part file).

3. **Tier 3 — App-Wide Design System Widget** (`lib/shared/widgets/<category>/`):
   - When a widget is generic across the entire application and has **zero domain knowledge**.
   - Must use the **`App` prefix** (`AppButton`, `AppFormTextInput`, `AppShimmer`).

---

## Motion, Shimmer & Animation Invariants

1. **Skeleton Loading First (`AppShimmer`)**:
   - Every asynchronous loading screen or widget must render an `AppShimmer` skeleton approximating the destination content.
   - Do not display blank white/empty screens or solitary spinner wheels for primary screen loading.

2. **Decent & Tasteful Motion**:
   - Keep motion purposeful (guiding focus, spatial continuity, feedback).
   - Keep displacement offsets small (10–20px).
   - Never stack multiple competing animations on the same widget.

3. **Duration Tokens from `AppProps`**:
   - Zero raw milliseconds in animation definitions. Always use:
     - `AppProps.quick` (100ms) — micro-interactions, selection changes.
     - `AppProps.fast` (200ms) — icons, badge toggles, expand/collapse trays.
     - `AppProps.medium` (300ms) — state transitions, feed card cascades.
     - `AppProps.normal` (500ms) — modal dialogues and sheet entrances.

4. **Smooth State Transitions (`AnimatedSwitcher`)**:
   - Wrap transitions between loading skeletons and content in `AnimatedSwitcher(duration: AppProps.medium)` with distinct `ValueKey`s.

5. **Fluent Animation Extensions**:
   - Prefer fluent chained extensions (`.withBottomAnimation()`, `.withEntranceFader()`, `.withScaleAnimation()`, `.withRippleEffect()`, `.withShimmer()`, `.withLinearProgress()`) over deeply nested widget wrappers.

---

## File Size Limits

| File type | Max lines | Action if exceeded |
|---|---|---|
| UI / screen files | 150–200 | Split into `part` files or extract private widget classes |
| Functions / methods | 30–50 | Refactor into smaller helpers or private methods |

---

## Dart Style & Syntax

- **Trailing commas**: Always include trailing commas for auto-formatting.
- **const**: Use `const` wherever possible.
- **Color values**: Always use `color.withValues(alpha: 0.5)`, NEVER deprecated `color.withOpacity()`.
- **Dot Shorthands**: Use leading-dot shorthand (`.primary`, `.medium`, `.disabled`) when type is inferred.

---

## Zero Barrel Files (Direct Imports Only)

Unbroken Mobile strictly prohibits **barrel files** (`index.dart`, `models.dart`, `<category>.dart` re-exporting internal files with `export '...'`).

- Every file must directly import only the exact file declaring the symbols it requires.
- Never create `index.dart` or files whose sole purpose is to re-export other files.

---

## Zero Backward Compatibility

- Never leave `@deprecated` shims or backward-compatibility wrappers.
- Update all callers atomically and delete obsolete code immediately.

