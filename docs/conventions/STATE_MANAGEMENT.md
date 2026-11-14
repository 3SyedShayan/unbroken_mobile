# State Management — Unbroken Mobile

## Multi-Tier System, Strict Rules

Unbroken Mobile enforces a strict division of responsibility across three tiers of state management:

| | Screen Controller (`_ScreenState`) | Global & Infrastructure (`flutter_riverpod`) | Feature Cubit (`flutter_bloc`) |
|---|---|---|---|
| **Scope** | **Screen-internal** ephemeral state | **Global / Infrastructure** reactive state | **Feature / App-wide** business state |
| **File** | `lib/features/{feature}/views/{screen}/_state.dart` | `lib/core/...` / `lib/services/...` | `lib/features/{feature}/viewmodel/cubit.dart` |
| **Tool** | `ChangeNotifier` (`provider`) | `NotifierProvider` / `Notifier` (`flutter_riverpod`) | `Cubit<FeatureState>` (`flutter_bloc`) |
| **Handles** | Form keys, text controllers, focus nodes, tab indexes | Connectivity overlays, reactive singletons, app status | Authentication, profile, productivity domains |
| **Can call DB/HTTP?** | **No** (delegates to Cubits) | Delegates to microservices (`ConnectivityService.ins`) | **No direct calls**; delegates to `FeatureRepo.ins` |
| **Data Layer Target** | Dispatches actions to Cubit | Listens to microservices / infrastructure streams | Interacts directly with `lib/features/{feature}/repositories/` |

> 🚫 **Zero GetX Rule**: GetX (`GetxController`, `Rx`, `Get.find`, `Get.put`, `Obx`, `GetMaterialApp`) is **strictly forbidden**.

---

## 1. Screen-Internal Ephemeral State (`_state.dart` Pattern)

Used for screen-level transient UI concerns: form keys, focus nodes, text controllers, tab selection, and filter chips.

> [!TIP]
> **When to omit `_ScreenState`:** If a screen has no local ephemeral UI state (e.g. no forms, focus nodes, controllers, or local tab/animation state), **omit `_state.dart` entirely**. Widgets can dispatch directly: `DomainCubit.c(context).doAction()`.

```dart
// lib/features/auth/views/login/_state.dart
part of 'login.dart';

class _ScreenState extends ChangeNotifier {
  static _ScreenState s(BuildContext context, [bool listen = false]) =>
      Provider.of<_ScreenState>(context, listen: listen);

  final formKey = GlobalKey<FormBuilderState>();

  void submit(BuildContext context) {
    final form = formKey.currentState;
    if (form == null || !form.saveAndValidate()) return;
    
    AuthCubit.c(context).login(form.value);
  }
}
```

---

## 2. Business Logic State (`FeatureCubit`)

Handles all application state and external API interactions.

### `BlocState<T>` — The Unified Async State Wrapper

Every async action in a Cubit state is a `BlocState<T>` field on the cubit's flat state class:

```dart
BlocState<UserData>(
  action: BlocAction.loading,  // enum: def | init | preparing | loading | success | failed | cancelled
  data: null,                  // T? — success payload
  fault: null,                 // Fault? — error payload
)
```

**Transition methods:**
- `state.action.toLoading()`
- `state.action.toSuccess(data: data)`
- `state.action.toFailed(fault: fault)`
- `state.action.toCancelled()`
- `state.action.toDefault()`

**Boolean getters:**
- `state.action.isLoading`
- `state.action.isSuccess`
- `state.action.isFailed`
- `state.action.errorMessage`

---

## 3. Standardized Pagination Contracts

All paginated features must use `PaginatedList<T>` containing:
- `List<T> items`
- `bool hasMore`
- `dynamic cursor`
- `bool isLoadingMore`
- Non-destructive errors: `toFailedMore()` must never clear existing list items on pagination error.
- Infinite scroll trigger standard: 200px before scroll max extent.

