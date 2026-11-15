part of 'splash.dart';

class _ScreenState extends ChangeNotifier {
  static _ScreenState s(BuildContext context, [bool listen = false]) =>
      Provider.of<_ScreenState>(context, listen: listen);

  _ScreenState(BuildContext context) {
    _init(context);
  }

  Future<void> _init(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!context.mounted) return;

    final authCubit = AuthCubit.c(context);
    final user = authCubit.state.user;

    if (user != null) {
      // Start observing user streams
      HabitsCubit.c(context).startObserving(user.uid);
      FocusCubit.c(context).startObserving(user.uid);
      SettingsCubit.c(context).startObserving(user.uid);

      final settings = SettingsCubit.c(context).state.settings;
      if (!settings.hasOnboarded) {
        AppRoutes.onboarding.pushReplace(context);
      } else {
        AppRoutes.home.pushReplace(context);
      }
    } else {
      AppRoutes.login.pushReplace(context);
    }
  }
}

