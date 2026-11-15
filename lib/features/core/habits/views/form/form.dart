import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';
import 'package:unbroken_mobile/shared/widgets/core/screen/screen.dart';

part 'widgets/_body.dart';

class HabitFormScreen extends StatelessWidget {
  final Habit? habit; // null for create, non-null for edit

  const HabitFormScreen({super.key, this.habit});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return _Body(habit: habit);
  }
}

