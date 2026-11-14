part of 'notifier.dart';

enum ReachabilityState { connected, disconnected }

/// State model for the network connectivity overlay UI.
@immutable
class NetworkConnectivityState extends Equatable {
  final ReachabilityState reachability;
  final bool fullPromptDismissed;
  final bool isChecking;
  final bool hasResolvedInitialCheck;

  const NetworkConnectivityState({
    this.reachability = ReachabilityState.connected,
    this.fullPromptDismissed = false,
    this.isChecking = false,
    this.hasResolvedInitialCheck = false,
  });

  bool get isOffline => reachability == ReachabilityState.disconnected;

  NetworkConnectivityState copyWith({
    ReachabilityState? reachability,
    bool? fullPromptDismissed,
    bool? isChecking,
    bool? hasResolvedInitialCheck,
  }) {
    return NetworkConnectivityState(
      reachability: reachability ?? this.reachability,
      fullPromptDismissed: fullPromptDismissed ?? this.fullPromptDismissed,
      isChecking: isChecking ?? this.isChecking,
      hasResolvedInitialCheck:
          hasResolvedInitialCheck ?? this.hasResolvedInitialCheck,
    );
  }

  @override
  List<Object?> get props => [
        reachability,
        fullPromptDismissed,
        isChecking,
        hasResolvedInitialCheck,
      ];
}

