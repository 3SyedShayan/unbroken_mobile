import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unbroken_mobile/app.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/env/app_env.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/firebase_options.dart';
import 'package:unbroken_mobile/services/cache/cache_service.dart';
import 'package:unbroken_mobile/services/firebase/crash/crashlytics.dart';
import 'package:unbroken_mobile/services/notifications/local_notification_service.dart';

Future<void> bootstrap([String? rawFlavor]) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Resolve flavor
  final flavor = switch (rawFlavor?.trim().toLowerCase()) {
    'prod' => AppFlavor.prod,
    _ => AppFlavor.dev,
  };

  // 2. Initialize immutable environment
  Env.init(AppEnv(flavor: flavor));

  // 3. Initialize Firebase with offline persistent cache & Crashlytics
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    await EnhancedCrashlytics.ins.init();
  } catch (e) {
    debugPrint('[FirebaseBootstrap] Initialization notice: $e');
  }

  // 4. Register cache purge on user sign-out
  SignOutCleanupRegistry.ins.register(() {
    unawaited(CacheService.ins.clearAll());
  });

  // 5. Initialize Typography
  AppText.init();

  // 6. Initialize Local Notifications
  try {
    await LocalNotificationService.ins.init();
  } catch (e) {
    debugPrint('[NotificationBootstrap] Initialization notice: $e');
  }

  // 7. Device orientation & runApp
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: MainMobileApp()));
}
