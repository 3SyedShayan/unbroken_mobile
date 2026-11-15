import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/core/auth/models/auth_user.dart';
import 'package:unbroken_mobile/features/core/auth/repositories/auth_repo.dart';

part 'state.dart';

class AuthCubit extends Cubit<AuthState> {
  static AuthCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<AuthCubit>(context, listen: listen);

  final AuthRepo _repo;
  StreamSubscription<Map<String, dynamic>?>? _sub;

  AuthCubit({AuthRepo? repo})
      : _repo = repo ?? AuthRepo.ins,
        super(AuthState(
          login: BlocState<AuthUser>(),
          signOut: BlocState<void>(),
        )) {
    _init();
  }

  void _init() {
    final current = _repo.currentUser;
    if (current != null) {
      emit(state.copyWith(
        user: AuthUser.fromJson(current),
        syncState: SyncState.synced,
      ));
    }

    _sub = _repo.authStateChanges().listen((userData) {
      if (userData != null) {
        emit(state.copyWith(
          user: AuthUser.fromJson(userData),
          syncState: SyncState.synced,
        ));
      } else {
        emit(state.copyWith(
          clearUser: true,
          syncState: SyncState.offline,
        ));
      }
    });
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(login: state.login.toLoading()));
    try {
      final raw = await _repo.signInWithGoogle();
      final user = AuthUser.fromJson(raw);
      emit(state.copyWith(
        user: user,
        syncState: SyncState.synced,
        login: state.login.toSuccess(data: user),
      ));
    } on Fault catch (f) {
      emit(state.copyWith(login: state.login.toFailed(fault: f)));
    } catch (e, s) {
      emit(state.copyWith(
        login: state.login.toFailed(
          fault: Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(signOut: state.signOut.toLoading()));
    try {
      await _repo.signOut();
      SignOutCleanupRegistry.ins.runAll();
      emit(state.copyWith(
        clearUser: true,
        syncState: SyncState.offline,
        signOut: state.signOut.toSuccess(),
      ));
    } on Fault catch (f) {
      emit(state.copyWith(signOut: state.signOut.toFailed(fault: f)));
    } catch (e, s) {
      emit(state.copyWith(
        signOut: state.signOut.toFailed(
          fault: Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  void updateSyncState(SyncState syncState) {
    emit(state.copyWith(syncState: syncState));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
