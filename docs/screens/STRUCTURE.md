# Screen Structure — Unbroken Mobile

> Never create screen files manually. Always use `hygen screen new` to generate the scaffold. See `docs/tooling/HYGEN.md`.

---

## Screen Directory Layout

A feature module (`lib/features/core/<feature>/`) can contain multiple screens:

```
lib/features/<feature_name>/
├── views/
│   ├── <screen_name>/
│   │   ├── <screen_name>.dart # Entry: imports, part declarations, pure composition
│   │   ├── _state.dart        # _ScreenState extends ChangeNotifier (only if ephemeral UI state exists)
│   │   ├── static/            # (only if form screen: _form_keys.dart, _form_data.dart)
│   │   ├── listeners/         # (only if cubit side-effects needed: _{action}.dart)
│   │   └── widgets/           # Private widget classes (part files: _header.dart, _card.dart)
│   │
└── widgets/                   # Feature-shared domain widgets reused across 2+ screens
```

All files inside `<screen_name>/widgets/` are `part of '<screen_name>.dart'`.
Widgets placed in `<feature_name>/widgets/` are **feature-level shared widgets** (public classes, standalone imports).

---

## 🛑 Invariant: Pure Screen Composition

The main screen file (`<screen_name>.dart`) is strictly a **layout composition coordinator**. It contains:
- Library imports and optional `part` file declarations.
- The root `StatelessWidget` (wrapping with `ChangeNotifierProvider<_ScreenState>` only if `_ScreenState` is needed).
- The `_Body` widget, which arranges high-level child widgets (`_Header`, `_ContentCard`, `_Footer`, etc.).

**Strict Rules:**
1. **No Deep Inlined Widget Trees:** Do not nest dozens of rows, columns, containers, or buttons in `<screen_name>.dart`.
2. **Private Classes Only:** Never return widgets from helper functions (`Widget _buildHeader() => ...` is forbidden). Always create a private class (`class _Header extends StatelessWidget`).
3. **Pragmatic Extraction:** For complex screens, extract subwidgets into `widgets/_<widget_name>.dart`. For small screens (< 100–120 lines total), private classes can live directly in `<screen_name>.dart`.
4. **No Direct Business Logic:** The screen never calls external APIs or repos directly. User actions are delegated to `_ScreenState.s(context)` or directly to `DomainCubit.c(context)`.

