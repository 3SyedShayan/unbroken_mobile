part of 'splash.dart';

class _ScreenState extends ChangeNotifier {
  static _ScreenState s(BuildContext context, [bool listen = false]) =>
      Provider.of<_ScreenState>(context, listen: listen);

  _ScreenState(BuildContext context) {
    _init(context);
  }

  Future<void> _init(BuildContext context) async {
    final splashDelay = Future.delayed(const Duration(milliseconds: 1200));

    final authCubit = AuthCubit.c(context);
    final habitsCubit = HabitsCubit.c(context);
    final focusCubit = FocusCubit.c(context);
    final goalsCubit = GoalsCubit.c(context);
    final settingsCubit = SettingsCubit.c(context);
    final user = authCubit.state.user;

    if (user != null) {
      // Start observing user streams concurrently with splash animation
      habitsCubit.startObserving(user.uid);
      focusCubit.startObserving(user.uid);
      goalsCubit.startObserving(user.uid);
      final settingsFuture = settingsCubit.startObserving(user.uid);

      await Future.wait([
        splashDelay,
        settingsFuture.timeout(
          const Duration(seconds: 2),
          onTimeout: () => settingsCubit.state.settings,
        ),
      ]);
      if (!context.mounted) return;

      final settings = settingsCubit.state.settings;
      if (!settings.hasOnboarded) {
        AppRoutes.onboarding.pushReplace(context);
      } else {
        AppRoutes.home.pushReplace(context);
      }
    } else {
      await splashDelay;
      if (!context.mounted) return;
      AppRoutes.login.pushReplace(context);
    }
  }
}

