part of '../login.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Screen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCF6EC), Color(0xFFF5E7D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                prev.login.action != curr.login.action ||
                prev.user != curr.user,
            listener: (context, state) {
              if (state.login.isSuccess && state.user != null) {
                final uid = state.user!.uid;
                HabitsCubit.c(context).startObserving(uid);
                FocusCubit.c(context).startObserving(uid);
                SettingsCubit.c(context).startObserving(uid);

                final settings = SettingsCubit.c(context).state.settings;
                if (!settings.hasOnboarded) {
                  AppRoutes.onboarding.pushReplace(context);
                } else {
                  AppRoutes.home.pushReplace(context);
                }
              }
            },
            builder: (context, state) {
              final isSigningIn = state.login.isLoading;
              final errorMessage =
                  state.login.isFailed ? state.login.errorMessage : null;

              return Center(
                child: SingleChildScrollView(
                  padding: Space.h.t24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FlameHero(size: 80),
                      Space.y.t24,
                      _Headline(),
                      Space.y.t16,
                      Text(
                        'Sign in with Google to keep your habits, Today\'s 3, and streaks synchronized across your devices. Once signed in, Unbroken runs offline anytime.',
                        style: AppText.b1.cl(AppColors.subText),
                        textAlign: TextAlign.center,
                      ),
                      if (errorMessage != null) ...[
                        Space.y.t16,
                        Container(
                          padding: Space.sym(16, 10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            errorMessage,
                            style: AppText.b2.cl(AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      Space.y.t32,
                      AppButton(
                        label: isSigningIn
                            ? 'Signing in with Google…'
                            : 'Continue with Google',
                        style: .primary,
                        size: .large,
                        mainAxisSize: MainAxisSize.max,
                        state: isSigningIn ? .disabled : .def,
                        onTap: isSigningIn
                            ? null
                            : () {
                                AuthCubit.c(context).signInWithGoogle();
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    App.init(context);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppText.heroStat.copyWith(
          fontSize: 32,
          color: AppColors.text,
          height: 1.15,
        ),
        children: const [
          TextSpan(text: 'Keep the streak\n'),
          TextSpan(
            text: 'synced.',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
