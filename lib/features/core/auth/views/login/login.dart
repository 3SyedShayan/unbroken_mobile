import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/flame_hero.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/router/routes.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';
import 'package:unbroken_mobile/shared/widgets/core/screen/screen.dart';

part 'widgets/_body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return const _Body();
  }
}

