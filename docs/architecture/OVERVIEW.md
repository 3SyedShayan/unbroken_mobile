# Unbroken Mobile — System Overview

Unbroken Mobile is a high-performance productivity mobile application built with Flutter, targeting iOS and Android.

## System Map

```
┌────────────────────────────────────────────────────────┐
│  Flutter Mobile App (iOS + Android)                    │
│  lib/ — UI, Cubits, Repos, Services, Configs           │
└──────────┬──────────────────────────┬──────────────────┘
           │ Backend / Cloud SDK      │ Local Services
┌──────────▼──────────┐   ┌──────────▼───────────────────┐
│  Cloud Services     │   │  Local Storage / Engine      │
│  Auth · Database    │   │  TTL Cache · Preferences     │
│  Storage · Telemetry│   │  Offline Data Synchronization│
└─────────────────────┘   └──────────────────────────────┘
```

## Project Structure

```
unbroken_mobile/
├── lib/
│   ├── features/          # Feature-first modules
│   │   ├── core/<feat>/   # Core productivity features
│   │   └── support/<feat>/# App support & lifecycle features (app_update, connectivity, feedback, settings)
│   ├── shared/            # Shared UI components across features
│   │   └── widgets/       # Centralized design system (core, design, forms, feedback, headless, animations)
│   ├── services/          # Infrastructure services (fault, logging, connectivity, cache, http)
│   ├── core/              # Core bindings, env, bootstrap, core lifecycle
│   ├── configs/           # Design tokens, theme, typography, BlocState definitions
│   ├── app.dart           # Root MainMobileApp widget with route observers and overlays
│   └── router/            # Named routing and screen transitions
├── docs/                  # Project documentation (Context Harness)
└── AGENTS.md              # Antigravity Agent context harness instructions
```

## Flutter App — Architecture Rules

**Modular domain separation & strict unidirectional data flow:**

```
UI Widgets (lib/features/<feature>/views/<screen>/widgets/)
  │  (dispatches user interactions)
  ▼
_ScreenState (lib/features/<feature>/views/<screen>/_state.dart) [Only if forms/ephemeral state exists]
  │  (dispatches business action)
  ▼
FeatureCubit (lib/features/<feature>/viewmodel/cubit.dart)
  │  (calls repository facade)
  ▼
FeatureRepo.ins (lib/features/<feature>/repositories/<feature>_repo.dart)
  │  (delegates to concrete data provider)
  ▼
_<Feature>Provider (lib/features/<feature>/repositories/<feature>_data_provider.dart)
  │  (calls Database / Cloud / REST API)
  ▼
SDKs / Cloud / Database
```

**Hard rules:**
- Views must NEVER execute raw network/database calls directly — they delegate to `_ScreenState` and Cubits.
- Main screens (`<screen>.dart`) strictly compose subwidgets and register ephemeral state; no raw inlined trees.
- Cubits and Riverpod notifiers manage state and logic, never importing UI layout files or talking directly to database SDKs.
- All database/network exceptions are caught in `_data_provider.dart` and thrown as typed `Fault` exceptions.
- Always use `.appLog()` instead of `print()` for debugging and error logging.
- **Zero barrel files:** Always import directly from the source file where a symbol is defined; do not create or use barrel files (`export '...'` aggregators).
- **Zero backward compatibility:** Do not maintain deprecated shims or legacy wrappers; refactor directly to canonical, modern APIs.

