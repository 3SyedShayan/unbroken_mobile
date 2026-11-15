part of '../splash.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    App.init(context);
    _ScreenState.s(context);
    return Screen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCF6EC), Color(0xFFF5E7D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlameHero(size: 72),
              Space.y.t24,
              Text(
                'UNBROKEN',
                style: AppText.stat.cl(AppColors.primary).copyWith(
                      letterSpacing: 2.0,
                    ),
              ),
              Space.y.t08,
              Text(
                'Keep the streak going.',
                style: AppText.b1.cl(AppColors.subText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
