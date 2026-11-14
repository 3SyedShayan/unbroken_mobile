---
trigger: always_on
description: Autonomous terminal command execution and document-first implementation review protocol.
---

# Autonomous Execution & Document Review Workflow

## 1. Terminal Command Execution (Full Autonomy)
- Run all required terminal commands autonomously without hesitating, asking for permission, or seeking confirmation beforehand (e.g., `dart analyze`, `flutter test`, `flutter pub run build_runner`, git commands, lint fixes, scripts, and build processes).
- Never ask questions like "Should I run this command?" or pause for approval before executing safe, standard terminal operations.

## 2. Document-First Implementation Workflow (Mandatory Review Gate)
- Whenever requested to evaluate, design, or create a document for different implementations or architecture options:
  1. **Do NOT begin implementation or modify code files immediately.**
  2. **Generate an implementation proposal document / artifact**: Detail the candidate approaches, pros/cons, trade-offs, architecture alignment, and step-by-step rollout plan. Ensure `RequestFeedback: true` is set if using an artifact.
  3. **Present the document and STOP**: Summarize key decision points concisely and halt further tool execution.
  4. **Await Explicit Confirmation**: Do not write code or run implementation commands until the user reviews the document and explicitly commands to proceed with the chosen approach.

