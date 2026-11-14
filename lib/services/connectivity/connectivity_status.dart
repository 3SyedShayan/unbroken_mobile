import 'package:connectivity_plus/connectivity_plus.dart';

/// Represents the high-level internet reachability status.
enum ConnectivityStatus {
  connected,
  disconnected,
  checking;

  bool get isConnected => this == ConnectivityStatus.connected;
  bool get isDisconnected => this == ConnectivityStatus.disconnected;
  bool get isChecking => this == ConnectivityStatus.checking;
}

/// Represents the underlying physical network medium.
enum NetworkType {
  wifi,
  cellular,
  ethernet,
  bluetooth,
  vpn,
  other,
  none;

  static NetworkType fromConnectivityResult(ConnectivityResult result) {
    return switch (result) {
      ConnectivityResult.wifi => NetworkType.wifi,
      ConnectivityResult.mobile => NetworkType.cellular,
      ConnectivityResult.ethernet => NetworkType.ethernet,
      ConnectivityResult.bluetooth => NetworkType.bluetooth,
      ConnectivityResult.vpn => NetworkType.vpn,
      ConnectivityResult.none => NetworkType.none,
      ConnectivityResult.other || ConnectivityResult.satellite => NetworkType.other,
    };
  }

  static NetworkType fromConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty || (results.length == 1 && results.first == ConnectivityResult.none)) {
      return NetworkType.none;
    }
    if (results.contains(ConnectivityResult.ethernet)) return NetworkType.ethernet;
    if (results.contains(ConnectivityResult.wifi)) return NetworkType.wifi;
    if (results.contains(ConnectivityResult.mobile)) return NetworkType.cellular;
    if (results.contains(ConnectivityResult.vpn)) return NetworkType.vpn;
    if (results.any((r) => r != ConnectivityResult.none)) return NetworkType.other;
    return NetworkType.none;
  }
}
