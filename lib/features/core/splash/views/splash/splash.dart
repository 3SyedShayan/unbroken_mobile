import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/router/routes.dart';
import 'package:unbroken_mobile/shared/widgets/core/screen/screen.dart';

part '_state.dart';
part 'widgets/_body.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return ChangeNotifierProvider<_ScreenState>(
      create: (ctx) => _ScreenState(ctx),
      child: const _Body(),
    );
  }
}

