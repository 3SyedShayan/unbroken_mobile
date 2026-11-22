import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/models/daily_task_result.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/widgets/focus_list_card.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/views/folder_form/folder_form.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/add_habit_button.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/contribution_grid.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/day_progress_bar.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/habit_row_card.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/router/router.dart';
import 'package:unbroken_mobile/router/routes.dart';
import 'package:unbroken_mobile/services/notifications/local_notification_service.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_reorder_list.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_text.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';
import 'package:unbroken_mobile/shared/widgets/core/screen/screen.dart';
import 'package:unbroken_mobile/shared/widgets/feedback/app_snackbars.dart';

part 'widgets/_body.dart';
part 'widgets/_dashboard_tab.dart';
part 'widgets/_goals_tab.dart';
part 'widgets/_history_tab.dart';
part 'widgets/_settings_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return const _Body();
  }
}
