part of '../home.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Screen(
      child: Center(
        child: Padding(
          padding: Space.a.t24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Unbroken',
                style: AppText.h1b.cl(AppTheme.c.text),
                textAlign: TextAlign.center,
              ),
              Space.y.t12,
              Text(
                'Architecture foundation initialized successfully.',
                style: AppText.b1.cl(AppTheme.c.subText),
                textAlign: TextAlign.center,
              ),
              Space.y.t24,
              AppButton(
                label: 'Get Started',
                style: .primary,
                size: .medium,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
