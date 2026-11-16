import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';

part '_auth_provider.dart';

class AuthRepo {
  static AuthRepo _instance = AuthRepo._();
  AuthRepo._();
  factory AuthRepo() => _instance;

  @visibleForTesting
  AuthRepo.test();

  static AuthRepo get ins => _instance;

  @visibleForTesting
  static set ins(AuthRepo repo) => _instance = repo;

  final _provider = _AuthProvider();

  Stream<Map<String, dynamic>?> authStateChanges() =>
      _provider.authStateChanges();

  Map<String, dynamic>? get currentUser => _provider.currentUser;

  Future<Map<String, dynamic>> signInWithGoogle() =>
      _provider.signInWithGoogle();

  Future<void> signOut() => _provider.signOut();
}

