import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unbroken_mobile/services/connectivity/connectivity_status.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

/// Microservice for monitoring and verifying internet connectivity.
///
/// Combines hardware interface observation via [Connectivity] with multi-pass
/// parallel HTTP probes and DNS verification to accurately detect dead links,
/// captive portals, and offline routers.
class ConnectivityService {
  ConnectivityService._({
    Connectivity? connectivity,
    http.Client? httpClient,
  })  : _connectivity = connectivity ?? Connectivity(),
        _httpClient = httpClient ?? http.Client();

  static ConnectivityService? _instance;

  /// Singleton access facade.
  static ConnectivityService get ins => _instance ??= ConnectivityService._();

  @visibleForTesting
  static set ins(ConnectivityService value) => _instance = value;

  final Connectivity _connectivity;
  final http.Client _httpClient;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();
  final StreamController<bool> _connectivityChangedController =
      StreamController<bool>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.checking;
  List<ConnectivityResult> _activeInterfaces = const [ConnectivityResult.none];
  bool _isInitialized = false;
  int _checkSeq = 0;

  static const List<String> _httpProbeUrls = [
    'https://connectivitycheck.gstatic.com/generate_204',
    'https://www.google.com/generate_204',
    'https://www.cloudflare.com/cdn-cgi/trace',
  ];

  static const Duration _httpTimeout = Duration(seconds: 5);
  static const Duration _passDelay = Duration(milliseconds: 500);
  static const Duration _startupGrace = Duration(milliseconds: 1200);
  static const int _offlineGraceAttempts = 3;
  static const Duration _offlineGraceInterval = Duration(milliseconds: 1200);

  /// Current reachability status.
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Whether public internet access is verified.
  bool get isConnected => _currentStatus == ConnectivityStatus.connected;

  /// Current network hardware interfaces reported by the OS.
  List<ConnectivityResult> get activeInterfaces =>
      List.unmodifiable(_activeInterfaces);

  /// Primary network interface type (Wi-Fi, Cellular, Ethernet, etc.).
  NetworkType get primaryNetworkType =>
      NetworkType.fromConnectivityResults(_activeInterfaces);

  /// Broadcast stream of [ConnectivityStatus] updates.
  Stream<ConnectivityStatus> get statusStream {
    if (!_isInitialized) {
      unawaited(init());
    }
    return _statusController.stream;
  }

  /// Broadcast stream emitting `true` (online) or `false` (offline).
  Stream<bool> get onConnectivityChanged {
    if (!_isInitialized) {
      unawaited(init());
    }
    return _connectivityChangedController.stream;
  }

  /// Initializes the service and starts observing network interface changes.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _handleInterfaceChange(results, reason: 'stream'),
    );

    try {
      final initialResults = await _connectivity.checkConnectivity();
      await _handleInterfaceChange(initialResults, reason: 'initial', isStartup: true);
    } catch (e) {
      'Error reading initial connectivity: $e'.appLog(
        level: AppLogLevel.error,
        tag: 'CONNECTIVITY',
      );
      _updateStatus(ConnectivityStatus.disconnected);
    }
  }

  /// Actively checks whether the device can communicate with the internet.
  Future<bool> hasInternetConnection({
    bool forceProbe = false,
    bool useOfflineGrace = false,
  }) async {
    final seq = ++_checkSeq;
    try {
      final results = await _connectivity.checkConnectivity();
      _activeInterfaces = results;

      final hasInterface = results.any((r) => r != ConnectivityResult.none);
      if (!hasInterface && !forceProbe) {
        if (seq == _checkSeq) {
          _updateStatus(ConnectivityStatus.disconnected);
        }
        return false;
      }

      final isReachable = useOfflineGrace
          ? await _probeWithOfflineGrace(seq)
          : await _executeMultiPassProbe();

      if (seq == _checkSeq) {
        _updateStatus(
          isReachable
              ? ConnectivityStatus.connected
              : ConnectivityStatus.disconnected,
        );
      }
      return isReachable;
    } catch (e) {
      'Reachability check error: $e'.appLog(
        level: AppLogLevel.warning,
        tag: 'CONNECTIVITY',
      );
      if (seq == _checkSeq) {
        _updateStatus(ConnectivityStatus.disconnected);
      }
      return false;
    }
  }

  /// Guards an operation by throwing a typed [NetworkFault] if offline.
  Future<void> ensureConnected() async {
    final connected = await hasInternetConnection();
    if (!connected) {
      'No active internet connection verified'.appLog(
        level: AppLogLevel.warning,
        tag: 'CONNECTIVITY',
      );
      throw NetworkFault(
        'No internet connection. Please check your network and try again.',
        StackTrace.current,
      );
    }
  }

  /// Forces an immediate reachability check and returns the updated status.
  Future<ConnectivityStatus> checkStatus() async {
    await hasInternetConnection(forceProbe: true);
    return _currentStatus;
  }

  Future<void> _handleInterfaceChange(
    List<ConnectivityResult> results, {
    required String reason,
    bool isStartup = false,
  }) async {
    final seq = ++_checkSeq;
    _activeInterfaces = results;
    final hasInterface = results.any((r) => r != ConnectivityResult.none);

    'Interface change ($reason): $results (hasInterface=$hasInterface)'.appLog(
      level: AppLogLevel.info,
      tag: 'CONNECTIVITY',
    );

    if (!hasInterface) {
      if (isStartup) {
        await Future<void>.delayed(_startupGrace);
        if (seq != _checkSeq) return;
        final recheck = await _connectivity.checkConnectivity();
        if (recheck.any((r) => r != ConnectivityResult.none)) {
          await _handleInterfaceChange(recheck, reason: 'startup-recovery');
          return;
        }
      }
      if (seq == _checkSeq) {
        _updateStatus(ConnectivityStatus.disconnected);
      }
      return;
    }

    _updateStatus(ConnectivityStatus.checking);
    final reachable = await _probeWithOfflineGrace(seq);
    if (seq == _checkSeq) {
      _updateStatus(
        reachable
            ? ConnectivityStatus.connected
            : ConnectivityStatus.disconnected,
      );
    }
  }

  Future<bool> _probeWithOfflineGrace(int seq) async {
    for (var attempt = 0; attempt < _offlineGraceAttempts; attempt++) {
      if (seq != _checkSeq) return true;
      if (attempt > 0) {
        await Future<void>.delayed(_offlineGraceInterval);
        if (seq != _checkSeq) return true;
      }
      final reachable = await _executeMultiPassProbe();
      if (reachable) return true;
    }
    return false;
  }

  /// Multi-pass parallel HTTP probes with DNS lookup fallback.
  Future<bool> _executeMultiPassProbe() async {
    for (var pass = 0; pass < 2; pass++) {
      if (pass > 0) {
        await Future<void>.delayed(_passDelay);
      }

      final httpOk = await _runParallelHttpProbes();
      if (httpOk) return true;

      final dnsOk = await _runDnsProbe();
      if (dnsOk) return true;
    }
    return false;
  }

  Future<bool> _runParallelHttpProbes() async {
    try {
      final futures = _httpProbeUrls.map((url) => _singleHttpProbe(url));
      final outcomes = await Future.wait(futures);
      return outcomes.any((success) => success);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _singleHttpProbe(String url) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse(url),
            headers: const {
              'Connection': 'close',
              'User-Agent': 'unbroken_mobile/1.0 (reachability)',
            },
          )
          .timeout(_httpTimeout);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _runDnsProbe() async {
    try {
      final addresses = await InternetAddress.lookup('google.com')
          .timeout(_httpTimeout);
      return addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus == status) return;
    _currentStatus = status;

    'Status updated to: $status'.appLog(
      level: AppLogLevel.info,
      tag: 'CONNECTIVITY',
    );

    _statusController.add(status);
    _connectivityChangedController.add(status.isConnected);
  }

  /// Disposes active listeners and stream controllers.
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
    _connectivityChangedController.close();
  }
}
