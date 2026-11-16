/// Centralized Cloud Firestore Collections & Path Registry for Unbroken.
///
/// Follows the Firestore backend contract defined in `docs/architecture/FIRESTORE_CONTRACT.md`.
/// Eliminates hardcoded raw string literals across repositories and data providers.
abstract final class Collections {
  const Collections._();

  // ── Root Collections ─────────────────────────────────────────────
  /// Top-level root collection for user profile and document settings.
  static const String users = 'users';

  // ── User Subcollections ──────────────────────────────────────────
  /// User habits subcollection: `users/{uid}/habits`
  static const String habits = 'habits';

  /// User habit check-in entries subcollection: `users/{uid}/entries`
  static const String entries = 'entries';

  /// User Today's 3 focus subcollection: `users/{uid}/focus`
  static const String focus = 'focus';

  /// User settings alias subcollection: `users/{uid}/settings`
  static const String settings = 'settings';

  // ── Support & Diagnostics Collections ────────────────────────────
  /// Application feedback and bug reports collection.
  static const String appFeedback = 'app_feedback';

  /// Public dynamic app configuration collection.
  static const String appPublicConfig = 'app_public_config';

  // ── Canonical Path Builders ──────────────────────────────────────
  /// Canonical path to a user document: `users/{uid}`
  static String userDocPath(String uid) => '$users/$uid';

  /// Canonical path to a user's habits collection: `users/{uid}/habits`
  static String habitsCollectionPath(String uid) => '$users/$uid/$habits';

  /// Canonical path to a specific habit document: `users/{uid}/habits/{habitId}`
  static String habitDocPath(String uid, String habitId) =>
      '$users/$uid/$habits/${habitId.toLowerCase()}';

  /// Canonical path to a user's entries collection: `users/{uid}/entries`
  static String entriesCollectionPath(String uid) => '$users/$uid/$entries';

  /// Canonical path to a specific entry document: `users/{uid}/entries/{habitId}_{logicalDayKey}`
  static String entryDocPath(String uid, String habitId, String logicalDayKey) =>
      '$users/$uid/$entries/${habitId.toLowerCase()}_$logicalDayKey';

  /// Canonical path to a user's focus collection: `users/{uid}/focus`
  static String focusCollectionPath(String uid) => '$users/$uid/$focus';

  /// Canonical path to a specific focus document: `users/{uid}/focus/{logicalDayKey}`
  static String focusDocPath(String uid, String logicalDayKey) =>
      '$users/$uid/$focus/$logicalDayKey';
}
