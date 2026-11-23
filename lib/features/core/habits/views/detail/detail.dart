import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/domain/habit_metrics.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/flame_hero.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/month_heatmap.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_aggregator.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/router/routes.dart';
import 'package:unbroken_mobile/shared/widgets/core/screen/screen.dart';
import 'package:unbroken_mobile/shared/widgets/design/heatmap/app_activity_heatmap.dart';

part 'widgets/_body.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return _Body(habit: habit);
  }
}
