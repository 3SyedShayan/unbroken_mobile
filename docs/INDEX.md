# Unbroken Mobile — Documentation Index

Start here for any deep-dive. Each doc covers one concern in full detail.
For the orientation, see [README.md](../README.md) or [AGENTS.md](../AGENTS.md).

---

## Architecture

| Document | Read this when… |
|---|---|
| [architecture/OVERVIEW.md](architecture/OVERVIEW.md) | You need the system map, feature-first structure, or startup sequence |
| [architecture/FLUTTER.md](architecture/FLUTTER.md) | You're building feature modules or views and need the architecture + dependency reference |
| [architecture/SERVICES.md](architecture/SERVICES.md) | You need the services reference: Faults, AppLog, RouteLogger, Cache, HTTP, Alice |
| [architecture/CACHING.md](architecture/CACHING.md) | You're designing or implementing caching, TTL cache, and offline data sync |
| [architecture/DECISIONS.md](architecture/DECISIONS.md) | You want to understand *why* a technology or pattern was chosen (ADR log) |

---

## Conventions

| Document | Read this when… |
|---|---|
| [conventions/DART.md](conventions/DART.md) | You want the Dart style rules, zero-barrel-file & zero-backward-compatibility rules, and checklist |
| [conventions/STATE_MANAGEMENT.md](conventions/STATE_MANAGEMENT.md) | You're writing a `_ScreenState`, a Cubit, a `BlocConsumer`, a listener, or implementing paginated lists (`PaginatedList<T>`) |
| [conventions/CONFIGS.md](conventions/CONFIGS.md) | You need design tokens — spacing (`Space.*`), colours (`AppTheme.c.*`), typography (`AppText.*`), navigation extensions |

---

## Screens

| Document | Read this when… |
|---|---|
| [screens/FLOWS.md](screens/FLOWS.md) | You need a map of all screens and the user flows between them |
| [screens/STRUCTURE.md](screens/STRUCTURE.md) | You're building or modifying a screen and need the folder layout, part-file wiring, or router registration steps |

---

## Widgets

| Document | Read this when… |
|---|---|
| [widgets/CATALOGUE.md](widgets/CATALOGUE.md) | You need to know which shared widget to use, its API, and usage examples (`Screen`, `AppButton`, `AppFormTextInput`, `AppShimmer`, Animations, etc.) |

---

## Tooling

| Document | Read this when… |
|---|---|
| [tooling/HYGEN.md](tooling/HYGEN.md) | You're scaffolding a screen, cubit, listener, or running build_runner / Freezed |

---

## Testing

| Document | Read this when… |
|---|---|
| [TESTING.md](TESTING.md) | You're writing unit or widget tests — the stack, folder layout, repo test seam, and the harness patterns / gotchas |

---

## Execution Plans

Short-lived task breakdowns for larger features live in [exec-plans/](exec-plans/).
See [exec-plans/INDEX.md](exec-plans/INDEX.md) for the format.

