---
name: docs-harness
description: >-
  Executes the Unbroken Mobile documentation context harness workflow. Use whenever planning, implementing,
  refactoring, or reviewing any feature, screen, widget, state management, or tests in unbroken_mobile.
---

# Unbroken Mobile Documentation Context Harness

This skill guides the agent through the context verification and execution lifecycle using the `/docs` documentation suite.

## Step 1: Pre-Execution Context Retrieval
Before generating or altering any code, read the relevant documentation files based on the task:

1. **Router**: Inspect [docs/INDEX.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/INDEX.md) to confirm all relevant documentation paths.
2. **Target Domain Docs**:
   - **Screen creation / modification**: Read [docs/screens/STRUCTURE.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/screens/STRUCTURE.md) and [docs/screens/FLOWS.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/screens/FLOWS.md).
   - **Shared widgets**: Read [docs/widgets/CATALOGUE.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/widgets/CATALOGUE.md).
   - **Design tokens**: Read [docs/conventions/CONFIGS.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/CONFIGS.md).
   - **Cubit / Bloc**: Read [docs/conventions/STATE_MANAGEMENT.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/STATE_MANAGEMENT.md).
   - **Style & Widget thresholds**: Read [docs/conventions/DART.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/conventions/DART.md).
   - **Services & Telemetry**: Read [docs/architecture/SERVICES.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/architecture/SERVICES.md).
   - **Testing**: Read [docs/TESTING.md](file:///Users/syed/Development/Flutter_Projects/unbroken_mobile/docs/TESTING.md).

## Step 2: Implementation Constraints
Adhere strictly to:
- Feature-first structure: `lib/features/<core|support>/<feature>/[views|viewmodel|repositories|models]`
- Never write functions returning widgets (`Widget _buildSomething()`). Always use private classes (`class _Something extends StatelessWidget`).
- Only extract a private widget class if subtree has ≥5 child widgets, ≥30 lines, or is reused.
- Use `Space.*` and `AppTheme.c.*` exclusively for spacing and colors.
- Use `Fault` subclasses for error propagation.

## Step 3: Post-Implementation Verification Seam
1. Run `dart analyze` or `flutter analyze` using `run_command` or static analysis MCP tool.
2. If Freezed models or generated files were added or modified, run `dart run build_runner build --delete-conflicting-outputs`.
3. Verify zero barrel files and ensure direct imports are maintained.

