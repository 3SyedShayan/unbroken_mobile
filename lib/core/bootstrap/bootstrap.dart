import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unbroken_mobile/app.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/env/app_env.dart';

Future<void> bootstrap([String? rawFlavor]) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Resolve flavor
  final flavor = switch (rawFlavor?.trim().toLowerCase()) {
    'prod' => AppFlavor.prod,
    _ => AppFlavor.dev,
  };

  // 2. Initialize immutable environment
  Env.init(AppEnv(flavor: flavor));

  // 3. Initialize Typography
  AppText.init();

  // 4. Device orientation & runApp
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: MainMobileApp()));
}

