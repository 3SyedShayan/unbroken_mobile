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

  final List<void Function()> _handlers = [];

  void register(void Function() onSignedOut) {
    _handlers.add(onSignedOut);
  }

  void runAll() {
    for (final h in List<void Function()>.from(_handlers)) {
      try {
        h();
      } catch (_) {}
    }
  }
}

