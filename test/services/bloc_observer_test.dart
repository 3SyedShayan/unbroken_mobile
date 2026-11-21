import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/services/logging/app_bloc_observer.dart';

class _TestCompositeState extends Equatable {
  final BlocState<void> action;
  final BlocState<int> fetch;

  const _TestCompositeState({
    required this.action,
    required this.fetch,
  });

  _TestCompositeState copyWith({
    BlocState<void>? action,
    BlocState<int>? fetch,
  }) =>
      _TestCompositeState(
        action: action ?? this.action,
        fetch: fetch ?? this.fetch,
      );

  @override
  List<Object?> get props => [action, fetch];
}

class _TestCubit extends Cubit<_TestCompositeState> {
  _TestCubit()
      : super(_TestCompositeState(
          action: BlocState<void>(),
          fetch: BlocState<int>(),
        ));

  void triggerSuccess() {
    emit(state.copyWith(action: state.action.toSuccess()));
  }

  void triggerFailure(Fault fault) {
    emit(state.copyWith(action: state.action.toFailed(fault: fault)));
  }

  void triggerError() {
    addError(Exception('Direct test error'), StackTrace.current);
  }
}

void main() {
  group('AppBlocObserver', () {
    late AppBlocObserver observer;
    late _TestCubit cubit;

    setUp(() {
      observer = AppBlocObserver();
      cubit = _TestCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('ignores routine non-failing state transitions to avoid console clutter', () {
      expect(
        () {
          final change = Change(
            currentState: cubit.state,
            nextState: cubit.state.copyWith(action: cubit.state.action.toLoading()),
          );
          observer.onChange(cubit, change);

          final successChange = Change(
            currentState: change.nextState,
            nextState: cubit.state.copyWith(action: cubit.state.action.toSuccess()),
          );
          observer.onChange(cubit, successChange);
        },
        returnsNormally,
      );
    });

    test('captures and logs failed state transitions', () {
      expect(
        () {
          final fault = UnknownFault('Database read failed', StackTrace.current);
          final change = Change(
            currentState: cubit.state,
            nextState: cubit.state.copyWith(action: cubit.state.action.toFailed(fault: fault)),
          );
          observer.onChange(cubit, change);
        },
        returnsNormally,
      );
    });

    test('does not re-log identical duplicate failure states', () {
      expect(
        () {
          final fault = UnknownFault('Database read failed', StackTrace.current);
          final failedState = cubit.state.copyWith(
            action: cubit.state.action.toFailed(fault: fault),
          );
          final change1 = Change(
            currentState: cubit.state,
            nextState: failedState,
          );
          observer.onChange(cubit, change1);

          final change2 = Change(
            currentState: failedState,
            nextState: failedState,
          );
          observer.onChange(cubit, change2);
        },
        returnsNormally,
      );
    });

    test('captures onError without throwing', () {
      expect(
        () {
          observer.onError(cubit, Exception('Unhandled test error'), StackTrace.current);
        },
        returnsNormally,
      );
    });
  });
}
