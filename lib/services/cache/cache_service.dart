import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unbroken_mobile/services/cache/ttl_cache.dart';

/// Centralized Cache & Sync Coordinator for Unbroken Mobile.
///
/// Implements the 3-Tier caching stack:
/// - Tier 1: In-Memory TTL Cache ([TtlCache]).
/// - Tier 2: Sync metadata & timestamps in [SharedPreferences].
/// - Tier 3: Remote delta coordination and persistence cleanup.
class CacheService {
  static CacheService _instance = CacheService._();
  CacheService._();

  /// Test constructor for mock subclasses.
  @visibleForTesting
  CacheService.test();

  static CacheService get ins => _instance;

  /// Test seam: swap in mock cache service in unit tests.
  @visibleForTesting
  static set ins(CacheService svc) => _instance = svc;

  /// Prefix for sync timestamps stored in [SharedPreferences].
  static const String _syncKeyPrefix = 'sp_sync_last_search_';

  String _formatKey(String collectionName) => '$_syncKeyPrefix$collectionName';

  /// Retrieves the persisted `lastSearchTime` timestamp for a collection.
  Future<DateTime?> getLastSearchTime(String collectionName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isoString = prefs.getString(_formatKey(collectionName));
      if (isoString == null || isoString.isEmpty) return null;
      return DateTime.tryParse(isoString);
    } catch (_) {
      return null;
    }
  }

  /// Persists the `lastSearchTime` timestamp for a collection.
  Future<void> setLastSearchTime(String collectionName, DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_formatKey(collectionName), timestamp.toIso8601String());
    } catch (_) {}
  }

  /// Clears the `lastSearchTime` for a specific collection (e.g. on manual pull-to-refresh).
  Future<void> clearLastSearchTime(String collectionName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_formatKey(collectionName));
    } catch (_) {}
  }

  /// Computes a query timestamp with an intentional clock-skew overlap buffer.
  ///
  /// Prevents missing documents when client device clock is ahead of server timestamp.
  DateTime getBufferedSearchTime(
    DateTime lastSearchTime, {
    Duration buffer = const Duration(minutes: 1),
  }) {
    return lastSearchTime.subtract(buffer);
  }

  /// Complete cache purge across all tiers.
  ///
  /// Invoked upon user logout or session reset.
  Future<void> clearAll() async {
    // 1. Purge Tier 1 In-Memory TTL caches
    TtlCache.clearAll();

    // 2. Purge Tier 2 Sync metadata in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs
          .getKeys()
          .where((k) => k.startsWith(_syncKeyPrefix) || (k.startsWith('sp_') && k.contains('last_search')))
          .toList();
      for (final k in keysToRemove) {
        await prefs.remove(k);
      }
    } catch (_) {}

    // 3. Purge Tier 3 disk persistence if available
    try {
      await FirebaseFirestore.instance.clearPersistence();
    } catch (_) {
      // clearPersistence() may throw if queries are still active or unsupported in mock mode; ignore quietly.
    }
  }
}
