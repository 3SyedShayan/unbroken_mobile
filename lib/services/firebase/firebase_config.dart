/// Infrastructure-level Firebase configuration constants for Unbroken.
abstract final class FirebaseConfig {
  const FirebaseConfig._();

  /// Canonical Google Cloud datacenter region for Unbroken Firestore (asia-south1).
  static const String firestoreRegion = 'asia-south1';

  /// Default timeout for remote Firestore operations.
  static const Duration queryTimeout = Duration(seconds: 15);
}
