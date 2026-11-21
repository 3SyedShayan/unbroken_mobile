import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

/// App-wide [BlocObserver] that captures unhandled errors and failed state transitions
/// without cluttering the debug console with routine events or state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (!kDebugMode) return;

    '[BLOC_ERROR:${bloc.runtimeType}] $error'.appLog(
      tag: 'BLOC',
      level: AppLogLevel.error,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (!kDebugMode) return;

    _checkFailedStates(bloc, change.currentState, change.nextState);
  }

  void _checkFailedStates(BlocBase bloc, dynamic current, dynamic next) {
    if (next is BlocState) {
      if (next.action == BlocAction.failed) {
        final isNew = current is! BlocState ||
            current.action != BlocAction.failed ||
            current.fault != next.fault;
        if (isNew) {
          _logBlocStateFailure(bloc, next);
        }
      }
    } else if (next is Equatable) {
      final nextProps = next.props;
      final currentProps = current is Equatable ? current.props : const [];
      for (var i = 0; i < nextProps.length; i++) {
        final nextProp = nextProps[i];
        if (nextProp is BlocState && nextProp.action == BlocAction.failed) {
          final currentProp =
              (i < currentProps.length) ? currentProps[i] : null;
          final isNew = currentProp is! BlocState ||
              currentProp.action != BlocAction.failed ||
              currentProp.fault != nextProp.fault;
          if (isNew) {
            _logBlocStateFailure(bloc, nextProp);
          }
        }
      }
    }
  }

  void _logBlocStateFailure(BlocBase bloc, BlocState failedState) {
    final fault = failedState.fault;
    final message = fault != null
        ? '${fault.runtimeType}: ${fault.message}'
        : failedState.errorMessage;

    '[BLOC_FAILED:${bloc.runtimeType}] $message'.appLog(
      tag: 'BLOC',
      level: AppLogLevel.error,
      error: fault,
      stackTrace: fault?.stackTrace,
    );
  }
}
