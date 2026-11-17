# Unbroken Mobile — Antigravity Agent Context Harness

This repository uses a **Documentation Context Harness**. Antigravity must follow this harness protocol for every user request.

---

## 🧭 Mandatory Context Harness Protocol

**DO NOT make assumptions or guess APIs, tokens, or structures.** Before creating or modifying code, always consult the documentation starting at [docs/INDEX.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/INDEX.md) and load the specific doc for your task:

| Domain / Task | Mandatory Document to Consult First | Key Focus |
|---|---|---|
| **Screens & Views** | [docs/screens/STRUCTURE.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/screens/STRUCTURE.md) & [docs/screens/FLOWS.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/screens/FLOWS.md) | Folder layout, part-file wiring, `_ScreenState`, router registration |
| **Shared UI Widgets** | [docs/widgets/CATALOGUE.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/widgets/CATALOGUE.md) | Standard widgets (`Screen`, `AppButton`, `AppFormTextInput`, chips, cards) |
| **Design Tokens** | [docs/conventions/CONFIGS.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/CONFIGS.md) | Spacing (`Space.*`), colors (`AppTheme.c.*`), typography (`AppText.*`), navigation |
| **State Management** | [docs/conventions/STATE_MANAGEMENT.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/STATE_MANAGEMENT.md) | BLoC/Cubit for domain, Riverpod for global/infrastructure, listeners, zero GetX |
| **Dart Style & Rules** | [docs/conventions/DART.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/DART.md) | Private widget classes, zero barrel files, zero backward compatibility, checklist |
| **Architecture** | [docs/architecture/FLUTTER.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/architecture/FLUTTER.md) & [docs/architecture/OVERVIEW.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/architecture/OVERVIEW.md) | Feature-first modular layers (views, viewmodel, repositories, models) |
| **Services & Telemetry** | [docs/architecture/SERVICES.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/architecture/SERVICES.md) | Universal Fault handling, Collections, .appLog(), RouteLogger, Cache, HTTP BaseApi, Alice |
| **Caching & Sync** | [docs/architecture/CACHING.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/architecture/CACHING.md) | Multi-tier caching, TTL cache, delta sync, offline resilience |
| **Code Generation** | [docs/tooling/HYGEN.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/tooling/HYGEN.md) | Hygen scaffolding, build_runner, Freezed code-gen |
| **Testing & Verification**| [docs/TESTING.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/TESTING.md) | Test seams, widget test harness, mocks |

---

## 📐 Core Architecture & Invariant Rules

### 1. Feature-First Modular Layout & Pragmatic Architecture Tiering
Code is organized by business feature domain (`lib/features/core/<feature_name>/` for productivity domain features, and `lib/features/support/<support_name>/` for system utilities). To prevent boilerplate bloat while maintaining strict separation of concerns, the architecture is **pragmatically tiered**:

* **Tier A: Core Domain Features**:
  * `views/<screen_name>/`:
    * `<screen_name>.dart` — Entry point. Pure composition coordinator.
    * `_state.dart` — Screen-ephemeral controller (`_ScreenState extends ChangeNotifier`) for forms, focus nodes, tab indexes, or local UI animations.
    * `widgets/` — Private widget part files (`_<widget>.dart`) when screen subtrees exceed 100 lines or form distinct visual sections.
    * `listeners/` — `BlocConsumer` / `BlocListener` part files (`_<action>.dart`) for dialogs, toasts, loaders, and navigation side effects.
    * `static/` — `_form_keys.dart` and `_form_data.dart` (for form-driven screens).
  * `viewmodel/`: `cubit.dart` (`<Feature>Cubit`) and `state.dart` (`<Feature>State` using `BlocState<T>`).
  * `repositories/`: 4-part repo pattern (`<feature>_repo.dart`, `_<feature>_data_provider.dart`, `_<feature>_parser.dart`, `_<feature>_mocks.dart`) when complex queries, pagination, or multi-source parsing are required.
  * `models/`: Immutable domain models using Freezed (`@freezed`) and JSON Serializable.

* **Tier B: Support & Utility Features / Simple Screens** (App Update, Connectivity, Feedback, Settings):
  * **Compressed Data Layer**: Consolidate data provider, parsing, and repo facade into a single, clean `<feature>_repo.dart` or service file when logic is under 150 lines. Avoid creating 10-line artificial parser or provider part files.
  * **No Empty `_ScreenState` (No Double Controller)**: If a screen has **no ephemeral UI state** (no text controllers, focus nodes, or local form state), **omit `_state.dart` entirely**. Widgets dispatch actions directly to `FeatureCubit.c(context).doAction()`. Never write a pass-through `_ScreenState` whose only purpose is forwarding calls to Cubit.
  * **Single-File Small Screens**: If a screen is under 100–120 lines total with 1–2 private subwidgets, keep them directly inside `<screen_name>.dart` rather than fragmenting into a `widgets/` subfolder.
  * **Mock Hygiene**: Avoid bundling unused mock fixtures into production code. Mocks belong in `test/mocks/` unless actively powering an offline development flavor.

* **Shared & Core Cross-Cutting Layers:**
  * `lib/shared/widgets/` — Shared reusable UI widgets (`core/`, `design/`, `forms/`, `feedback/`, `headless/`, `animations/`). Zero domain knowledge; `App` prefix.
  * `lib/services/` — App-wide infrastructure services (`fault/`, `logging/`, `connectivity/`, `cache/`, `http/`).
  * `lib/configs/` — Design tokens, theme, typography, `BlocState` base types.
  * `lib/core/` — Global routes, bindings, app lifecycle, bootstrap.

### 2. Strict Unidirectional Data Flow
```
┌────────────────────────────────────────────────────────┐
│ UI Widgets (lib/features/<feat>/views/<screen>/...)    │
└─────────────┬───────────────────────────┬──────────────┘
              │ If forms/ephemeral state  │ If simple/no ephemeral state
              ▼                           │
┌───────────────────────────────────┐     │
│ Screen Controller (_ScreenState)  │     │
└─────────────┬─────────────────────┘     │
              │ Dispatches action         │
              └───────────────┬───────────┘
                              ▼
┌────────────────────────────────────────────────────────┐
│ Business Logic (FeatureCubit in viewmodel/cubit.dart)  │
│ Emits state.copyWith(action: action.toLoading())       │
└─────────────────────────────┬──────────────────────────┘
                              │ Calls FeatureRepo.ins.action()
                              ▼
┌────────────────────────────────────────────────────────┐
│ Repository Facade (repositories/<feat>_repo.dart)      │
│ (In Tier B: contains direct provider & parser logic)   │
└─────────────────────────────┬──────────────────────────┘
                              │ (Tier A only: delegates)
                              ▼
┌────────────────────────────────────────────────────────┐
│ Data Provider (_<Feat>Provider in data_provider.dart)   │
└────────────────────────────────────────────────────────┘
```
* **Map-Only Repo Boundary (ADR-013):** Public functions on repository classes accept and return `Map<String, dynamic>`, `List<Map<String, dynamic>>`, or primitives. Cubits convert Map responses to Freezed models via `Model.fromJson(raw)`.
* **Return Flow:** SDK/DB → DataProvider/Repo (catches errors, throws `Fault`) → Cubit (emits `toSuccess(data: Model)` or `toFailed(fault: e)`) → UI (`BlocConsumer` / `BlocListener` handles loading overlay, toasts, navigation).
* **Hard Rule:** Views never call external backends or repos directly; Cubits never import UI widgets or talk directly to external SDKs.

### 3. Widget Conventions ([docs/conventions/DART.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/DART.md))
* **Private Widget Classes Only:** Never return widgets from helper functions (e.g. `Widget _buildHeader() => ...` is forbidden). Always create a private class (`class _Header extends StatelessWidget`).
* **The 3-Tier Widget Scope Hierarchy:**
  * **Tier 1 (Screen-Private):** If a screen is large (≥ 100–120 lines) or has distinct sub-sections, extract widgets into private classes (`part of '<screen>.dart'`) under `views/<screen>/widgets/_<name>.dart`. For small screens (< 100 lines), keep private classes in `<screen>.dart`.
  * **Tier 2 (Feature-Shared):** If a widget is reused across ≥ 2 screens in the same feature domain, place it in `lib/features/core/<feature>/widgets/<name>.dart` as a public class with its own imports.
  * **Tier 3 (App-Wide):** If a widget is domain-agnostic and app-wide, place it in `lib/shared/widgets/` prefixed with `App` (`AppButton`, `AppFormTextInput`, `AppShimmer`).
* **Complex Screen Decomposition:** Large screens must be broken down into dedicated private widget files under `widgets/`, keeping the main screen file under 150 lines as a pure composition coordinator.

### 4. Design Tokens ([docs/conventions/CONFIGS.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/CONFIGS.md))
* **Spacing:** Use `Space.x/y.t*` for gaps, `Space.a/h/v/t/b/l/r.t*` for padding, `Space.sym(h, v)`, `Space.top/bottom` for safe areas. Available named tokens: `t04, t08, t12, t16, t20, t24, t28, t32, t60, t100`. For arbitrary sizes, use `Space.xf(n) / yf(n)`.
* **Colors:** Use `AppTheme.c.<token>` (`primary`, `accent`, `text`, `subText`, `background`, `subBackground`, `border`, `error`, `success`, `warning`). Never hardcode raw hex colors in widgets.
* **Typography:** Use `AppText.h1/h2/h3(+b)`, `AppText.b1/b2(+b)`, `AppText.l1/l1b` with extensions (`.cl(color)`, `.w(n)`).

### 5. Shimmer Loading & Tasteful Motion Invariants ([docs/widgets/CATALOGUE.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/widgets/CATALOGUE.md))
* **Loading Skeleton First:** Asynchronous content must render an `AppShimmer` skeleton matching destination layout — never blank screens or raw solitary spinners for screen content.
* **Decent & Tasteful Motion:** Keep animations purposeful, fast, and subtle. Never over-animate or stack conflicting animations on the same widget. Translation deltas should be small (10–20px).
* **Duration Tokens:** Always use `AppProps.*` tokens (`quick` 100ms, `fast` 200ms, `medium` 300ms, `normal` 500ms). Zero raw millisecond numbers in widget animations.
* **Smooth State Transitions:** Use `AnimatedSwitcher(duration: AppProps.medium)` with distinct `ValueKey`s when switching between shimmer skeleton and loaded content to prevent harsh pops.
* **Feed Entrance:** Use `.withBottomAnimation()` for subtle, auto-staggered (+100ms) cascade entry on feed/card lists.
* **Fluent Extensions:** Prefer unnested fluent extensions on widgets (`.withBottomAnimation()`, `.withEntranceFader()`, `.withScaleAnimation()`, `.withRippleEffect()`, `.withShimmer()`, `.withLinearProgress()`) over manual deep wrapping.

### 6. Error Handling & Infrastructure Services ([docs/architecture/SERVICES.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/architecture/SERVICES.md))
* Catch and emit `Fault` subtypes (`HttpFault`, `FirebaseFault`, `FirebaseAuthFault`, `ExceptionFault`, `UnknownFault` in `lib/services/fault/faults.dart`).
* Convert all backend/HTTP/external exceptions to `Fault` before surfacing to UI state.
* Use `.appLog()` instead of `print()` for debugging and error tracking.

### 7. Zero Barrel Files & Zero Backward Compatibility ([docs/architecture/DECISIONS.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/architecture/DECISIONS.md))
* **Zero Barrel Files (Direct Imports Only):** NEVER create or import barrel files (`index.dart`, `models.dart`, `<category>.dart` aggregators with `export '...'`). Every file must directly import the exact source file where each type or symbol is defined.
* **Zero Backward Compatibility:** NEVER introduce or retain `@deprecated` wrappers, legacy shims, alias classes, dual signatures, or compatibility fallbacks. If an API, route, model, or token changes, migrate all call sites directly and delete obsolete code.

### 8. Standardized Pagination Contracts ([docs/conventions/STATE_MANAGEMENT.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/STATE_MANAGEMENT.md))
* **Unified Pagination Container:** All paginated features must use `PaginatedList<T>` containing `items`, `hasMore`, `cursor`, and `isLoadingMore`.
* **Non-Destructive Errors & Guard Invariants:** Cubit `loadMore()` must guard against concurrent calls (`!hasMore || isLoadingMore || fetch.isLoading`). Errors during pagination must never wipe existing list items (`toFailedMore()`).

### 9. Autonomous Command Execution & Document-First Review Gate
* **Terminal Autonomy:** Execute all terminal commands (builds, tests, code-gen, Git, analysis) autonomously without asking the user for confirmation beforehand.
* **Document-First Review Invariant:** Whenever requested to explore or create documents for different implementation approaches:
  1. Draft the comparison document / plan artifact with `RequestFeedback: true`.
  2. Stop execution immediately and present the document for user review.
  3. Never proceed with implementation code or modifications until the user explicitly approves and directs you to proceed.

### 10. Cross-Platform Sync Protocol (`SYNC_QUEUE.md`)
* **Shared File:** `SYNC_QUEUE.md` is symlinked between `unbroken` (macOS Swift) and `unbroken_mobile` (Flutter).
* **Outbound Sync (When Modifying Shared Concepts):** Whenever you modify domain models, Firestore schemas/rules, design tokens, or shared feature logic in this project:
  1. Add an entry under `## 📋 Active Queue` in `SYNC_QUEUE.md`.
  2. Mark `[x] Mobile: Done` and `[ ] macOS: PENDING`.
  3. Detail what changed, target files in `unbroken`, and acceptance criteria.
* **Inbound Sync (When Asked to Sync with macOS):** When instructed to sync with macOS or process `SYNC_QUEUE.md`:
  1. Open `SYNC_QUEUE.md` and locate all items marked `[ ] Mobile: PENDING`.
  2. Implement changes in the specified target files in this project.
  3. Verify with `flutter test` and `dart analyze`.
  4. Check off `[x] Mobile: Done`. Once both platforms are done, move the entry to `Completed Archive`.

---

## ✅ Pre-Completion Quality Gate
Before declaring any task or feature complete:
1. Run static analysis: `dart analyze` or `flutter analyze` to ensure zero warnings/errors.
2. If new models, Freezed entities, or JSON serializable classes are modified, run `dart run build_runner build --delete-conflicting-outputs`.
3. Verify zero barrel files were created or consumed, and no backward compatibility shims or deprecated fallbacks were introduced.

