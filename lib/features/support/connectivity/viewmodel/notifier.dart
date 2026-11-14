import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unbroken_mobile/services/connectivity/connectivity_service.dart';
import 'package:unbroken_mobile/services/connectivity/connectivity_status.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

part 'state.dart';

/// Riverpod notifier managing reactive UI state for network connectivity overlay.
class NetworkConnectivityNotifier extends Notifier<NetworkConnectivityState> {
  static const Duration _offlineAutoRetryInterval = Duration(seconds: 3);

  StreamSubscription<ConnectivityStatus>? _subscription;
  Timer? _offlineAutoRetryTimer;

  @override
  NetworkConnectivityState build() {
    _subscription =
        ConnectivityService.ins.statusStream.listen(_onStatusChanged);
    ref.onDispose(() {
      _stopOfflineAutoRetry();
      _subscription?.cancel();
    });
    unawaited(_initialCheck());
    return const NetworkConnectivityState();
  }

  Future<void> _initialCheck() async {
    try {
      await ConnectivityService.ins.init();
      _onStatusChanged(ConnectivityService.ins.currentStatus);
    } finally {
      state = state.copyWith(hasResolvedInitialCheck: true);
    }
  }

  void _onStatusChanged(ConnectivityStatus status) {
    if (status == ConnectivityStatus.checking) return;

    final next = status.isConnected
        ? ReachabilityState.connected
        : ReachabilityState.disconnected;

    if (state.reachability == next) return;

    'Network overlay state: $next'.appLog(
      level: AppLogLevel.info,
      tag: 'NETWORK_RIVERPOD',
    );

    if (next == ReachabilityState.connected) {
      _stopOfflineAutoRetry();
      state = state.copyWith(
        reachability: next,
        fullPromptDismissed: false,
      );
    } else {
      state = state.copyWith(reachability: next);
      _startOfflineAutoRetry();
    }
  }

  void dismissFullPrompt() {
    state = state.copyWith(fullPromptDismissed: true);
  }

  /// Forces an immediate reachability re-probe via [ConnectivityService].
  Future<void> retryCheck() async {
    if (state.isChecking) return;
    state = state.copyWith(isChecking: true);
    try {
      final status = await ConnectivityService.ins.checkStatus();
      _onStatusChanged(status);
    } finally {
      state = state.copyWith(isChecking: false);
    }
  }

  void _startOfflineAutoRetry() {
    if (_offlineAutoRetryTimer != null) return;
    _offlineAutoRetryTimer = Timer.periodic(_offlineAutoRetryInterval, (_) {
      if (state.reachability != ReachabilityState.disconnected) {
        _stopOfflineAutoRetry();
        return;
      }
      unawaited(retryCheck());
    });
  }

  void _stopOfflineAutoRetry() {
    _offlineAutoRetryTimer?.cancel();
    _offlineAutoRetryTimer = null;
  }
}

/// Global Riverpod provider for network connectivity state.
final networkConnectivityProvider =
    NotifierProvider<NetworkConnectivityNotifier, NetworkConnectivityState>(
  NetworkConnectivityNotifier.new,
);

