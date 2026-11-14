# Testing Guide — Unbroken Mobile

## 1. Testing Stack & Layers

- **Unit Tests**: Test Cubits, repositories, parsers, and data services in isolation.
- **Widget Tests**: Test screen presentation, interaction triggers, and conditional UI states using test harnesses.
- **Repository Seams**: Every repository facade exposes a `@visibleForTesting static set ins` seam to inject mock repositories easily.

## 2. Directory Structure

```
test/
├── features/
│   ├── <feature>/
│   │   ├── cubit_test.dart
│   │   └── repo_test.dart
├── screens/
│   └── <screen>/
│       └── <screen>_test.dart
└── mocks/
    └── mock_data.dart
```

