import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCoL-Fz2s0RASzktcov_kKsS3UJHC0ql9s',
    appId: '1:528485350901:web:44e13d97412216ecc174bc',
    messagingSenderId: '528485350901',
    projectId: 'unbroken-19c6d',
    authDomain: 'unbroken-19c6d.firebaseapp.com',
    storageBucket: 'unbroken-19c6d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoL-Fz2s0RASzktcov_kKsS3UJHC0ql9s',
    appId: '1:528485350901:android:44e13d97412216ecc174bc',
    messagingSenderId: '528485350901',
    projectId: 'unbroken-19c6d',
    storageBucket: 'unbroken-19c6d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCoL-Fz2s0RASzktcov_kKsS3UJHC0ql9s',
    appId: '1:528485350901:ios:44e13d97412216ecc174bc',
    messagingSenderId: '528485350901',
    projectId: 'unbroken-19c6d',
    storageBucket: 'unbroken-19c6d.firebasestorage.app',
    iosClientId:
        '528485350901-p9pg4p1pi0egordi7eipnl11nbuipv1b.apps.googleusercontent.com',
    iosBundleId: 'app.unbroken.Unbroken',
  );
}

