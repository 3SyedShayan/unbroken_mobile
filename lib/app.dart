import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/bindings/app_core_binding.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/support/connectivity/views/widgets/network_connectivity_overlay.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/router/router.dart';
import 'package:unbroken_mobile/router/routes.dart';
import 'package:unbroken_mobile/services/logging/route_logger.dart';

class MainMobileApp extends StatelessWidget {
  const MainMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...AppCoreBinding.providers,
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
        BlocProvider<HabitsCubit>(create: (_) => HabitsCubit()),
        BlocProvider<FocusCubit>(create: (_) => FocusCubit()),
        BlocProvider<GoalsCubit>(create: (_) => GoalsCubit()),
      ],
      child: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> with WidgetsBindingObserver {
  final RouteLogger _routeLogger = RouteLogger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      try {
        unawaited(FocusCubit.c(context).flushPendingCommits());
      } catch (_) {}
      return;
    }
    if (state == AppLifecycleState.resumed) {
      // Re-trigger date / active day check on resume (e.g. overnight 3:00 AM rollover)
      setState(() {});
      try {
        HabitsCubit.c(context).onAppResumed();
        FocusCubit.c(context).onAppResumed();
        GoalsCubit.c(context).onAppResumed();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unbroken',
      debugShowCheckedModeBanner: false,
      theme: materialLightTheme,
      darkTheme: materialDarkTheme,
      navigatorKey: navigator,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routes: appRoutes,
      onGenerateRoute: onGenerateRoutes,
      initialRoute: AppRoutes.splash,
      navigatorObservers: [
        _routeLogger,
        NavigationHistoryObserver(),
      ],
      builder: (context, child) {
        App.init(context);
        return NetworkConnectivityOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
