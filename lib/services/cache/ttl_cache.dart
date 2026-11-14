/// An internal entry in the [TtlCache] tracking value and expiration.
class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;

  const _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// A lightweight, generic in-memory time-to-live (TTL) cache.
///
/// Designed as Tier 1 in the multi-tier caching stack to eliminate redundant
/// Firestore reads and provide instant (0ms) responses across navigation tabs.
class TtlCache<K, V> {
  /// Default TTL duration if none is specified during [set].
  final Duration defaultTtl;

  final Map<K, _CacheEntry<V>> _storage = {};

  static final List<TtlCache<dynamic, dynamic>> _allInstances = [];

  TtlCache({this.defaultTtl = const Duration(minutes: 5)}) {
    _allInstances.add(this);
  }

  /// Retrieves the cached value for [key], or `null` if absent or expired.
  V? get(K key) {
    final entry = _storage[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _storage.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Stores a [value] under [key] with an optional custom [ttl].
  void set(K key, V value, {Duration? ttl}) {
    final duration = ttl ?? defaultTtl;
    _storage[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(duration),
    );
  }

  /// Checks if [key] is currently cached and unexpired.
  bool containsKey(K key) => get(key) != null;

  /// Removes a single entry from this cache instance.
  void invalidate(K key) {
    _storage.remove(key);
  }

  /// Clears all entries stored in this cache instance.
  void clear() {
    _storage.clear();
  }

  /// Global purge: clears all active [TtlCache] instances across the app.
  ///
  /// Invoked upon user sign-out or switching university tenants.
  static void clearAll() {
    for (final cache in _allInstances) {
      cache.clear();
    }
  }
}
