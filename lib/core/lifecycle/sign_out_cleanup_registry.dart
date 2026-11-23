import 'dart:async';

import 'package:flutter/foundation.dart';

/// Registers callbacks to run on sign-out so authentication stays decoupled
/// from feature-specific controllers.
class SignOutCleanupRegistry {
  static final SignOutCleanupRegistry _instance = SignOutCleanupRegistry._();
  SignOutCleanupRegistry._();
  factory SignOutCleanupRegistry() => _instance;
  static SignOutCleanupRegistry get ins => _instance;

  @visibleForTesting
  SignOutCleanupRegistry.forTesting();

  final List<FutureOr<void> Function()> _preHandlers = [];
  final List<FutureOr<void> Function()> _postHandlers = [];

  /// Registers a Phase 1 callback invoked BEFORE `FirebaseAuth.signOut()`.
  ///
  /// Use for cancelling active Firestore listeners and resetting Cubit state.
  void register(FutureOr<void> Function() onPreSignOut) {
    _preHandlers.add(onPreSignOut);
  }

  /// Registers a Phase 2 callback invoked AFTER listeners stop and Auth signs out.
  ///
  /// Use for terminating Firestore and purging persistent disk caches.
  void registerPostSignOut(FutureOr<void> Function() onPostSignOut) {
    _postHandlers.add(onPostSignOut);
  }

  Future<void> runPreSignOut() async {
    for (final h in List<FutureOr<void> Function()>.from(_preHandlers)) {
      try {
        final result = h();
        if (result is Future) {
          await result;
        }
      } catch (_) {}
    }
  }

  Future<void> runPostSignOut() async {
    for (final h in List<FutureOr<void> Function()>.from(_postHandlers)) {
      try {
        final result = h();
        if (result is Future) {
          await result;
        }
      } catch (_) {}
    }
  }

  Future<void> runAll() async {
    await runPreSignOut();
    await runPostSignOut();
  }
}

