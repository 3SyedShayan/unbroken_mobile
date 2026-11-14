# Caching & Offline Synchronization — Unbroken Mobile

> Architectural guide for in-memory and persistent caching to support offline responsiveness, minimize network requests, and preserve battery life.

---

## 1. Overview & Strategy

Unbroken Mobile uses a multi-tier caching strategy:
1. **In-Memory TTL Cache (`lib/services/cache/ttl_cache.dart`)**:
   - Short-lived in-memory caching for frequently accessed data during an active app session.
   - Configurable Time-To-Live (TTL) per cache key (e.g., 5 minutes for lists, 15 minutes for profile).
2. **Persistent Cache (`lib/services/cache/cache_service.dart`)**:
   - Backed by `shared_preferences` and local file cache.
   - Used for app configuration, user session state, and offline persistence.
3. **Image Cache**:
   - Managed via `cached_network_image` and `flutter_cache_manager`.
   - Invariant: Always specify `memCacheWidth` / `memCacheHeight` to prevent Out-Of-Memory (OOM) crashes on high-res assets.

---

## 2. Invalidation & Refresh Rules

- **Pull-to-Refresh**: Always bypasses cache and updates local storage with fresh server data.
- **Mutations (Create / Update / Delete)**: Immediately invalidate related in-memory cache entries and update cubit state optimistically or synchronously.
- **Session Logout**: All cached user data is purged via `SignOutCleanupRegistry`.

