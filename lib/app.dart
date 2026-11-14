import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/bindings/app_core_binding.dart';
// bloc-imports-start
// bloc-imports-end
import 'package:unbroken_mobile/features/support/connectivity/views/widgets/network_connectivity_overlay.dart';
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
        // bloc-initiate-start
        // bloc-initiate-end
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
