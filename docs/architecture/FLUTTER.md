# Flutter Architecture — Unbroken Mobile

> For the full configs API — Space system, navigation shortcuts, typography, theme tokens, extensions — see **[docs/conventions/CONFIGS.md](../conventions/CONFIGS.md)**.
> For the state management guide, see **[docs/conventions/STATE_MANAGEMENT.md](../conventions/STATE_MANAGEMENT.md)**.
> For screen wiring and part-file structure, see **[docs/screens/STRUCTURE.md](../screens/STRUCTURE.md)**.

---

## 🏛️ Guiding Architectural Principles

**Domain Separation, Strict Unidirectional Data Flow & Mobile Focus.**

Unbroken Mobile adopts a production-grade architecture designed for high scalability, loose coupling, and maintainability:
1. **Clear Separation of Concerns**: UI layout is completely separated from screen controller state (`_ScreenState`), which is separated from business logic (`Cubit`), domain data abstraction (`Repo`), and raw data integrations (`DataProvider`).
2. **Strict Unidirectional Data Flow**: State and events move strictly in one direction. Views never touch repositories directly.
3. **Short File Names & Domain Folders**: Files are grouped into focused domain folders with short names (`cubit.dart`, `state.dart`, `<feature>_repo.dart`, `<model>.dart`).
4. **Pure Screen Composition**: Screen root files (`<screen>.dart`) only import and compose subwidgets (`_Header`, `_Card`, `_Body`). Deep UI trees or business logic are strictly forbidden in the screen root.
5. **Direct Source Imports (Zero Barrel Files)**: Barrel files (`export '...';`, `index.dart`, `models.dart`) are strictly prohibited. Every file must import the exact source file defining the needed symbols.
6. **Canonical Modern Codebase (Zero Backward Compatibility)**: No deprecated shims, legacy compatibility wrappers, or fallback bridges. Call sites are migrated directly and outdated code is deleted immediately.

---

## 🗺️ Feature-First Directory Map & Pragmatic Tiering

Code is separated into core productivity features (`lib/features/core/`) and app support utilities (`lib/features/support/`). To eliminate unnecessary code bloat while preserving architectural integrity, we adopt **pragmatic tiering**:

- **Tier A (Complex Domain Modules)**:
  - Adopts full separation: 4-part repository facade (`_repo.dart`, `_data_provider.dart`, `_parser.dart`, `_mocks.dart`), Freezed domain models, dedicated `_state.dart` controllers for forms/interactions, and subwidget extraction.
- **Tier B (Utility & Support Modules / Simple Screens)**:
  - Compact data layer: single `<feature>_repo.dart` or service without artificial 10-line parser part files.
  - Direct dispatch: omit `_state.dart` if the screen has no forms or ephemeral state; call `FeatureCubit.c(context)` directly from widgets.
  - Single-file screens: small screens (< 100–120 lines) keep private widgets in `<screen_name>.dart`.
  - Mocks in `test/mocks/`: do not bundle unused mock fixtures into production sources.

```
lib/
├── features/
│   ├── core/<feature_name>/          # Productivity domain modules
│   │   ├── views/<screen_name>/      # Multiple screens per feature
│   │   │   ├── <screen_name>.dart    # Screen root (pure composition coordinator, _Body)
│   │   │   ├── _state.dart           # _ScreenState extends ChangeNotifier (only when local ephemeral UI state exists)
│   │   │   ├── widgets/              # Screen-private widgets (part files: _header.dart, _card.dart)
│   │   │   ├── listeners/            # BlocConsumer / BlocListener part files (_submit.dart)
│   │   │   └── static/               # _form_keys.dart, _form_data.dart (if forms)
│   │   ├── widgets/                  # Feature-shared widgets (domain components reused across 2+ screens in this feature)
│   │   ├── viewmodel/                # Business logic & domain state management
│   │   │   ├── cubit.dart            # <Feature>Cubit (.c() accessor, domain state)
│   │   │   └── state.dart            # <Feature>State (part of 'cubit.dart', BlocState<T> fields)
│   │   ├── repositories/             # Domain Data Layer (4-file part pattern for Tier A; single repo for Tier B)
│   │   └── models/                   # Feature Domain Entities (Freezed / Equatable)
│   │
│   └── support/<support_feature>/    # App support & lifecycle features (app_update, connectivity, feedback, settings)
│
├── shared/                           # App-wide UI design system (zero domain knowledge, 'App' prefix)
│   └── widgets/                      # Centralized design system (core, design, forms, feedback, headless, animations)
├── services/                         # App-wide infrastructure services
│   ├── fault/                        # Fault hierarchy (faults.dart: HttpFault, ExceptionFault, etc.)
│   ├── logging/                      # .appLog(), RouteLogger
│   ├── connectivity/                 # ConnectivityService
│   ├── cache/                        # TTLCache, CacheService
│   └── http/                         # BaseApi, AppAlice network inspector
├── configs/                          # Design tokens, theme, typography, BlocState types
├── core/                             # Global routes, app lifecycle, core bindings, env, bootstrap
└── app.dart                          # Root MainMobileApp widget
```

---

## 🔄 Strict Unidirectional Data Flow

```
UI Presentation (widgets/_<widget>.dart)
  │ (Dispatches tap/event)
  ▼
Screen Controller (_ScreenState in _state.dart) [Only if ephemeral UI state exists]
  │ (Validates form, calls cubit)
  ▼
Business Logic (FeatureCubit in viewmodel/cubit.dart)
  │ (Emits .toLoading(), calls repo)
  ▼
Repository Facade (FeatureRepo.ins in repositories/<feat>_repo.dart)
  │ (Map-only boundary: Map<String, dynamic> / primitives)
  ▼
Concrete Data Provider (_<Feature>Provider in repositories/<feat>_data_provider.dart)
  │ (Calls backend SDK / HTTP client; catches errors -> throws Fault)
  ▼
External Service / Database / REST API
```

### Invariant Rules:
1. **Views NEVER call repositories or external APIs directly.** All interactions go through `_ScreenState` or Cubits.
2. **Cubits NEVER import UI widgets or layout files.**
3. **Cubits NEVER call external SDKs directly.** They delegate exclusively to `FeatureRepo.ins`.
4. **DataProviders ALWAYS catch external exceptions and throw `Fault` types.**
5. **Always use `.appLog()`** instead of raw `print()` for debugging and telemetry.
6. **Zero Barrel Files**: NEVER create or use barrel files (`index.dart`, `models.dart`, `<feature>.dart` re-export aggregators). Every file must import the exact source file directly.
7. **Zero Backward Compatibility**: NEVER add or retain `@deprecated` wrappers, legacy shims, or dual-compatibility layers. Update call sites atomically and keep the codebase canonical.

