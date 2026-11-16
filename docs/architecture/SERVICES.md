# Infrastructure Services & Telemetry — Unbroken Mobile

> Source of truth for app-wide infrastructure services living in `lib/services/` and `lib/core/services/`.
> Every feature module, data provider, cubit, and screen must follow these service conventions to ensure consistent error handling, telemetry, logging, and data access.

---

## 🧭 Services Directory Map

```
lib/
├── services/
│   ├── fault/                    # Universal typed error handling
│   │   └── faults.dart           # Fault sealed hierarchy (HttpFault, ExceptionFault, etc.)
│   ├── firebase/                 # Firebase infrastructure wrappers
│   │   ├── collections.dart      # Firestore collections and canonical path builders
│   │   ├── firebase_config.dart  # Region (asia-south1) and timeouts
│   │   └── crash/                # Crashlytics singleton & navigation tracker
│   │       ├── crashlytics.dart
│   │       └── _exts.dart
│   ├── logging/                  # Logging & navigation observers
│   │   ├── app_log.dart          # .appLog() ANSI colorized logger
│   │   └── route_logger.dart     # RouteLogger NavigatorObserver & stack history 
│   ├── connectivity/             # Network status monitoring
│   │   ├── connectivity_service.dart
│   │   └── connectivity_status.dart
│   ├── cache/                    # Multi-tier local cache
│   │   ├── ttl_cache.dart        # In-memory time-to-live cache
│   │   └── cache_service.dart    # Persistent cache layer
│   └── http/                     # REST HTTP & network inspector
│       ├── api.dart              # BaseApi client with retry interceptor
│       ├── urls.dart             # Base URLs configuration
│       └── alice.dart            # AppAlice (alice_lightweight inspector)
└── core/
    └── lifecycle/                # Global lifecycle
        └── sign_out_cleanup_registry.dart
```

---

## 1. Universal Error Handling (`lib/services/fault/faults.dart`)

Unbroken Mobile mandates the **`Fault` sealed class pattern** for all operations. Views and Cubits never deal with raw external SDK exceptions (`ClientException`, `HttpException`, etc.). All external exceptions are caught in DataProviders and converted to a typed `Fault`.

### The `Fault` Hierarchy

| Fault Subtype | Origin | Factory Constructor / Usage |
|---|---|---|
| `HttpFault` | `package:http` Client | `HttpFault.fromResponse(response, st)` or `.fromClientException(ex, st)` |
| `FirebaseFault` / `FirebaseAuthFault` | Firebase SDKs (if used) | `FirebaseFault.fromFirebase(ex, st)` |
| `ExceptionFault` | General Dart exceptions | `ExceptionFault(ex, stackTrace)` |
| `ErrorFault` | Dart runtime errors (`TypeError`, etc.) | `ErrorFault(err, stackTrace)` |
| `UnknownFault` | Uncategorized errors | `UnknownFault(message, stackTrace)` |

### DataProvider Invariant Rule

Always wrap external SDK calls with `try / on ... catch` blocks in `<feature>_data_provider.dart`:

```dart
try {
  final response = await BaseApi.get(endpoint);
  return response;
} on http.ClientException catch (e, st) {
  throw HttpFault.fromClientException(e, st);
} catch (e, st) {
  if (e is Fault) rethrow;
  throw UnknownFault(e.toString(), st);
}
```

### Cubit State Consumption

Cubits capture `Fault` instances and update asynchronous action states via `toFailed`:

```dart
try {
  emit(state.copyWith(fetch: state.fetch.toLoading()));
  final data = await FeatureRepo.ins.fetch();
  emit(state.copyWith(fetch: state.fetch.toSuccess(data: data)));
} on Fault catch (fault) {
  emit(state.copyWith(fetch: state.fetch.toFailed(fault: fault)));
}
```

---

## 2. Firestore Collections Registry (`lib/services/firebase/collections.dart`)

**Rule: NEVER hardcode Firestore collection names or document subpaths as string literals** (e.g. `collection('users')` or `collection('habits')`). Always reference the centralized `Collections` constants or canonical path builders:

```dart
// CORRECT (Using Collection Constants)
CollectionReference<Map<String, dynamic>> _userHabits(String uid) =>
    _firestore
        .collection(Collections.users)
        .doc(uid)
        .collection(Collections.habits);

// CORRECT (Using Canonical Path Helpers)
String docPath = Collections.habitDocPath(uid, habitId);
String entryPath = Collections.entryDocPath(uid, habitId, logicalDayKey);

// FORBIDDEN
CollectionReference<Map<String, dynamic>> _userHabits(String uid) =>
    _firestore.collection('users').doc(uid).collection('habits');
```

---

## 3. Infrastructure Firebase Configuration (`lib/services/firebase/firebase_config.dart`)

Contains infrastructure-level Firebase configuration constants:
- `FirebaseConfig.firestoreRegion`: Canonical datacenter region (`asia-south1`).
- `FirebaseConfig.queryTimeout`: Standard 15-second remote operation timeout.

---

## 4. Sign-Out Lifecycle Cleanup (`lib/core/lifecycle/sign_out_cleanup_registry.dart`)

All domain cubits and cross-cutting caches must register a cleanup callback upon initialization:
- `HabitsCubit`: Cancels `_habitsSub` and `_entriesSub`, resets to initial state.
- `FocusCubit`: Cancels `_sub`, resets to initial state.
- `SettingsCubit`: Cancels `_sub`, resets to initial state.
- `CacheService`: Purges Tier 1 in-memory TTL, Tier 2 SharedPreferences sync keys, and Tier 3 SQLite persistence.

When `AuthCubit.signOut()` runs, it calls `SignOutCleanupRegistry.ins.runAll()`, preventing cross-account state leakage.

