import 'package:flutter/material.dart';
import 'package:unbroken_mobile/features/core/auth/views/login/login.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/views/detail/detail.dart';
import 'package:unbroken_mobile/features/core/habits/views/form/form.dart';
import 'package:unbroken_mobile/features/core/home/views/home/home.dart';
import 'package:unbroken_mobile/features/core/onboarding/views/onboarding/onboarding.dart';
import 'package:unbroken_mobile/features/core/splash/views/splash/splash.dart';
import 'package:unbroken_mobile/router/routes.dart';

final navigator = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final appRoutes = <String, WidgetBuilder>{
  AppRoutes.splash: (_) => const SplashScreen(),
  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.onboarding: (_) => const OnboardingScreen(),
};

Route<dynamic>? onGenerateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return FadeRoute(
        child: const HomeScreen(),
        settings: settings,
      );
    case AppRoutes.habitDetail:
      final habit = settings.arguments as Habit;
      return SlideUpRoute(
        child: HabitDetailScreen(habit: habit),
        settings: settings,
      );
    case AppRoutes.habitForm:
      final habit = settings.arguments as Habit?;
      return SlideUpRoute(
        child: HabitFormScreen(habit: habit),
        settings: settings,
      );
    default:
      return null;
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget child;

  @override
  final RouteSettings settings;

  FadeRoute({required this.child, required this.settings})
    : super(
        settings: settings,
        pageBuilder: (context, ani1, ani2) => child,
        transitionsBuilder: (context, ani1, ani2, child) {
          return FadeTransition(opacity: ani1, child: child);
        },
      );
}

/// A bottom-to-top slide route (slides back down on dismiss).
class SlideUpRoute extends PageRouteBuilder {
  final Widget child;

  @override
  final RouteSettings settings;

  SlideUpRoute({required this.child, required this.settings})
    : super(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, ani1, ani2) => child,
        transitionsBuilder: (context, ani1, ani2, child) {
          final curved = CurvedAnimation(
            parent: ani1,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      );
}

