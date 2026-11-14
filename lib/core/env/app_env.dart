import 'package:flutter/foundation.dart';

/// Supported application flavors.
enum AppFlavor { dev, prod }

/// Immutable environment configuration container.
class AppEnv {
  final AppFlavor flavor;

  const AppEnv({required this.flavor});

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
  bool get isProdRelease => isProd && kReleaseMode;
}

/// Global read-only accessor for the active environment.
abstract final class Env {
  static AppEnv? _current;

  static AppEnv get current {
    if (_current == null) {
      throw StateError('Env.init() has not been called.');
    }
    return _current!;
  }

  static void init(AppEnv env) {
    _current = env;
  }
}

