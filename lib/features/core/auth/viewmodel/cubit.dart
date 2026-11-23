import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/core/auth/models/auth_user.dart';
import 'package:unbroken_mobile/features/core/auth/repositories/auth_repo.dart';
import 'package:unbroken_mobile/services/firebase/crash/crashlytics.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';

part 'state.dart';

class AuthCubit extends Cubit<AuthState> {
  static AuthCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<AuthCubit>(context, listen: listen);

  final AuthRepo _repo;
  StreamSubscription<Map<String, dynamic>?>? _sub;
  StreamSubscription<FirestoreSyncStatus>? _syncSub;

  AuthCubit({AuthRepo? repo})
      : _repo = repo ?? AuthRepo.ins,
        super(AuthState(
          login: BlocState<AuthUser>(),
          signOut: BlocState<void>(),
        )) {
    _init();
  }

  SyncState _mapSyncStatus(FirestoreSyncStatus status) => switch (status) {
        FirestoreSyncStatus.connecting => SyncState.connecting,
        FirestoreSyncStatus.synced => SyncState.synced,
        FirestoreSyncStatus.offline => SyncState.offline,
      };

  void _init() {
    _syncSub = SyncStatusTracker.ins.stream.listen((status) {
      if (!isClosed && state.user != null) {
        emit(state.copyWith(syncState: _mapSyncStatus(status)));
      }
    });

    final current = _repo.currentUser;
    if (current != null) {
      final user = AuthUser.fromJson(current);
      emit(state.copyWith(
        user: user,
        syncState: _mapSyncStatus(SyncStatusTracker.ins.current),
      ));
      unawaited(EnhancedCrashlytics.ins.setUserContext(userId: user.uid));
    }

    _sub = _repo.authStateChanges().listen((userData) {
      if (userData != null) {
        final user = AuthUser.fromJson(userData);
        emit(state.copyWith(
          user: user,
          syncState: _mapSyncStatus(SyncStatusTracker.ins.current),
        ));
        unawaited(EnhancedCrashlytics.ins.setUserContext(userId: user.uid));
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
      unawaited(EnhancedCrashlytics.ins.setUserContext(userId: user.uid));
      emit(state.copyWith(
        user: user,
        syncState: _mapSyncStatus(SyncStatusTracker.ins.current),
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
      await SignOutCleanupRegistry.ins.runPreSignOut();
      await _repo.signOut();
      await SignOutCleanupRegistry.ins.runPostSignOut();
      SyncStatusTracker.ins.reset();
      unawaited(EnhancedCrashlytics.ins.clearUserContext());
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
    unawaited(_sub?.cancel());
    unawaited(_syncSub?.cancel());
    return super.close();
  }
}
