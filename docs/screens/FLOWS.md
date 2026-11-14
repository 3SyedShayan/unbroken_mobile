# Screen Navigation Flows — Unbroken Mobile

> Map of user flows and screens across the application. This file is updated as features are defined.

---

## 1. Initial Launch Flow

```
Splash Screen (/splash)
  │
  ├─► [User Authenticated] ──► Dashboard / Home Screen (/home)
  │
  └─► [User Unauthenticated] ──► Login Screen (/login)
```

## 2. Core Navigation Register

| Screen | Route Path | Purpose |
|---|---|---|
| `SplashScreen` | `/splash` | App initialization, auth check, bootstrap |
| `HomeScreen` | `/home` | Main application productivity hub |
| `LoginScreen` | `/login` | User authentication & onboarding |

