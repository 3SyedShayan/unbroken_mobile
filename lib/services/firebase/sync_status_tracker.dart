import 'dart:async';

/// Real-time Firestore synchronization status derived from snapshot metadata.
enum FirestoreSyncStatus {
  connecting,
  synced,
  offline,
}

/// Tracks the aggregate Firestore sync health across active user listeners.
class SyncStatusTracker {
  SyncStatusTracker._();

  static final SyncStatusTracker _instance = SyncStatusTracker._();

  static SyncStatusTracker get ins => _instance;

  final StreamController<FirestoreSyncStatus> _controller =
      StreamController<FirestoreSyncStatus>.broadcast();

  FirestoreSyncStatus _current = FirestoreSyncStatus.connecting;

  FirestoreSyncStatus get current => _current;

  Stream<FirestoreSyncStatus> get stream => _controller.stream;

  void reportSnapshot({
    required bool isFromCache,
    required bool hasPendingWrites,
  }) {
    final next = isFromCache
        ? FirestoreSyncStatus.offline
        : (hasPendingWrites
            ? FirestoreSyncStatus.connecting
            : FirestoreSyncStatus.synced);
    _emit(next);
  }

  void reportError() {
    _emit(FirestoreSyncStatus.offline);
  }

  void reset() {
    _emit(FirestoreSyncStatus.connecting);
  }

  void _emit(FirestoreSyncStatus next) {
    if (_current == next) return;
    _current = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }
}
