part of '../splash.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    App.init(context);
    _ScreenState.s(context);
    return Screen(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'UNBROKEN',
              style: AppText.h1b.cl(AppTheme.c.primary),
            ),
            Space.y.t12,
            Text(
              'Productivity & Focus',
              style: AppText.b1.cl(AppTheme.c.subText),
            ),
          ],
        ),
      ),
    );
  }
}
