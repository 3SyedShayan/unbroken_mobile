/// Infrastructure-level Firebase configuration constants for Unbroken.
abstract final class FirebaseConfig {
  const FirebaseConfig._();

  /// Canonical Google Cloud datacenter region for Unbroken Firestore (asia-south1).
  static const String firestoreRegion = 'asia-south1';

  /// Default timeout for remote Firestore read operations.
  static const Duration queryTimeout = Duration(seconds: 15);

  /// Timeout for optimistic Firestore write operations before resolving locally.
  static const Duration writeTimeout = Duration(seconds: 2);

  /// Bounded offline persistence cache size (50 MB).
  static const int maxCacheSizeBytes = 50 * 1024 * 1024;

  /// Safe chunk size under Firestore's 500-operation WriteBatch limit.
  static const int maxDeleteBatchSize = 450;

  /// How long immutable cold historical months remain cache-preferred.
  static const Duration coldMonthCacheTtl = Duration(days: 7);
}
