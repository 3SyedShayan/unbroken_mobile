part of 'cubit.dart';

enum SyncState {
  connecting,
  synced,
  offline;

  String get label => switch (this) {
        connecting => 'Connecting…',
        synced => 'Synced to cloud',
        offline => 'Offline (local cache)',
      };
}

class AuthState extends Equatable {
  final AuthUser? user;
  final SyncState syncState;
  final BlocState<AuthUser> login;
  final BlocState<void> signOut;

  const AuthState({
    this.user,
    this.syncState = SyncState.connecting,
    required this.login,
    required this.signOut,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool clearUser = false,
    SyncState? syncState,
    BlocState<AuthUser>? login,
    BlocState<void>? signOut,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      syncState: syncState ?? this.syncState,
      login: login ?? this.login,
      signOut: signOut ?? this.signOut,
    );
  }

  @override
  List<Object?> get props => [user, syncState, login, signOut];
}

