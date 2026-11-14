# Architecture Decisions — Unbroken Mobile

Lightweight ADR log. Each decision records what was chosen, why, and what it rules out.

---

## ADR-001: Feature-First Organization with Modular Architecture

**Decision:** The project uses a **Feature-First Architecture** (`lib/features/<feature_name>/`) with strict separation of concerns, tiered repository patterns, Equatable/Freezed domain models, short file naming, and pure screen composition within each feature module:
- `lib/features/<feature>/views/<screen>/` for presentation (pure screen composition, part-file widgets, ephemeral state).
- `lib/features/<feature>/repositories/` for domain data persistence, caching, and network abstraction.
- `lib/features/<feature>/models/` for immutable domain entities (`<model>.dart` using `@freezed` / `Equatable`).
- `lib/features/<feature>/viewmodel/` for business logic (`cubit.dart` and `state.dart` with `BlocState<T>`).
- `lib/shared/widgets/` for cross-feature shared design system components.
- `lib/services/` for global infrastructure (`services/fault/faults.dart`, `logging/`, `connectivity/`, `cache/`).

Files use short, concise names (`cubit.dart`, `state.dart`, `<feature>_repo.dart`, `<entity>.dart`) rather than repetitive redundant prefixes.
**Why:** Combines high modularity and self-containment with clear separation of concerns, rapid unit-testability, and zero UI-logic entanglement.
**Rules out:** Monolithic global file dumping, raw SDK calls in views, GetX controllers, barrel files (all export aggregators), backward compatibility layers, or 1000-line god classes.

---

## ADR-002: Multi-Tier State Management — BLoC/Cubit for Domain, Riverpod for Global/Infrastructure Services, ChangeNotifier for Screen-Ephemeral

**Decision:**
- **Domain Business State:** `flutter_bloc` (`Cubit` / `Bloc`) for domain logic and cross-feature business state using `BlocState<T>`.
- **Global & Infrastructure Reactive State:** `flutter_riverpod` (`NotifierProvider`, `Notifier`) within the root `ProviderScope` for cross-cutting infrastructure services, overlays (e.g. `networkConnectivityProvider`), and reactive service bridges.
- **Screen-Internal Ephemeral State:** `ChangeNotifier` via `_ScreenState` in `_state.dart` per screen (using `ChangeNotifierProvider<_ScreenState>` and `_ScreenState.s(context)`). Handles text editing controllers, focus nodes, form validation, and dispatches actions to Cubits.
**Why:** Combines the strengths of BLoC for strictly predictable domain business logic with Riverpod for lightweight global state.
**Rules out:** GetX (`GetxController`, `Rx`, `Get.put`, `Get.find`, `Obx` — completely eliminated), uncontrolled `setState`, and scattered ad-hoc controllers.

---

## ADR-003: BlocState\<T\> as the Shared State Wrapper

**Decision:** Every async action in a Cubit is a `BlocState<T>` field — no hand-rolled sealed state hierarchies.
**Why:** Consistent transitions (`.toLoading()`, `.toSuccess()`, `.toFailed()`), boolean getters (`.isLoading`, `.isSuccess`, `.isFailed`), and `.when()` functional rendering across all cubits without boilerplate.
**Rules out:** Per-cubit sealed class hierarchies (`UserLoading extends UserState`, etc.).

---

## ADR-004: flutter_form_builder for All Forms

**Decision:** All form screens use `flutter_form_builder` with custom wrapper widgets (`AppFormTextInput`, `AppFormDropdown`, etc.).
**Why:** Declarative validation, built-in reset, `saveAndValidate()`, consistent field state management.
**Rules out:** Hand-rolled form state, raw `TextEditingController` grids, `TextField` without `FormBuilderField`.

---

## ADR-005: Private Widget Classes — Never Function Widgets

**Decision:** All widget extraction must be a private class (`class _Foo extends StatelessWidget`), never a function returning a `Widget`.
**Why:** Function widgets don't participate in Flutter's element tree correctly — they skip const constructors, prevent rebuild optimizations, and show poorly in DevTools.
**Rules out:** `Widget _buildFoo() => ...`, helper functions returning `Widget`.

---

## ADR-006: Freezed for Domain Data Models

**Decision:** Domain data classes use `@freezed` with `const factory` constructors, `json_serializable`, and `fromJson`/`toJson` generation.
**Why:** Guarantees immutability by default, generates clean `copyWith`, deep value equality, JSON serialization code, and concise data class definitions.
**Rules out:** Mutable data classes, manual boilerplate `copyWith`/`props` duplication for new models.

---

## ADR-007: Named Routes + String Extension Navigation

**Decision:** All navigation uses `AppRoutes.*` string constants. Navigation calls are made via String extensions (`.push()`, `.pushReplace()`, `.popUntil()`, etc.) that wrap standard `Navigator.*` functions.
**Why:** Keeps call sites clean (`AppRoutes.home.push(context)` vs. `Navigator.pushNamed(context, '/home')`). String constants make route names refactor-safe. No heavy third-party router dependency.
**Rules out:** GoRouter, auto_route, Beamer, raw `Navigator.pushNamed` string literals.

---

## ADR-008: Map-Only at Repo Boundary

**Decision:** Public functions on a `*Repo` class accept and return only `Map<String, dynamic>`, `List<Map<String, dynamic>>`, or primitives (`bool`, `int`, `String`, `double`, `void`). They MUST NOT return Dart model classes.
**Why:** Decouples backend response shapes from cubits and models. Repositories stay swappable without touching business logic or state definitions.
**Rules out:** Returning entity model instances directly from repos; importing domain models in repos.

---

## ADR-009: Sealed Fault Hierarchy for All Errors

**Decision:** All thrown errors use a subtype of `Fault` from `lib/services/fault/faults.dart`. Never `throw Exception(...)` or raw strings.
**Why:** Typed faults give consistent `.message` access for UI display, structured logging, and pattern matching.
**Rules out:** Raw exceptions, string throws, per-cubit ad-hoc error models.

---

## ADR-010: Zero Barrel Files (Direct Explicit Imports Only)

**Decision:** The project strictly prohibits barrel files (`export '...';`, `index.dart`, `<category>.dart` aggregators). Every Dart file must directly import the exact source file defining the needed symbols.
**Why:**
- Barrel files obscure the true dependency structure.
- They dramatically increase the risk of accidental circular dependencies.
- They bloat compiler and analyzer memory footprints and slow down incremental builds.
- Direct explicit imports guarantee unambiguous, transparent dependencies that are easy to refactor and trace.
**Rules out:** Creating or using barrel files, aggregator `index.dart` files, `models.dart` re-export files, `widgets.dart` re-export files.

---

## ADR-011: Zero Backward Compatibility Fallbacks

**Decision:** No backward compatibility layers, legacy wrappers, deprecated methods (`@deprecated`), compatibility aliases, or migration shims are permitted in the codebase. When an API, data model, route, or design token changes, all call sites across the application are refactored immediately and old code is removed in the same atomic change.
**Why:**
- Unbroken Mobile is an active greenfield mobile application, not a legacy public package.
- Maintaining compatibility shims adds dead code, increases cognitive burden, and causes divergent coding conventions.
- It ensures the codebase remains canonical, lean, and modern at all times.
**Rules out:** `@deprecated` shims, forwarding methods, dual-signature APIs, legacy fallback branches, and obsolete code retained "just in case".

