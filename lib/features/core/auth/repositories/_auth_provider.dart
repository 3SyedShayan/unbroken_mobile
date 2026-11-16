part of 'auth_repo.dart';

class _AuthProvider {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();

  Stream<Map<String, dynamic>?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  Map<String, dynamic>? get currentUser => _mapUser(_auth.currentUser);

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase authentication returned no user');
      }

      final mapped = _mapUser(user);
      if (mapped == null) {
        throw Exception('Failed to map user profile');
      }
      return mapped;
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Map<String, dynamic>? _mapUser(User? user) {
    if (user == null) return null;
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
    };
  }
}

