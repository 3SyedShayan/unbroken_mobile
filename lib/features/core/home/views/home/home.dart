import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/widgets/focus_list_card.dart';
import 'package:unbroken_mobile/features/core/focus/widgets/pull_goal_sheet.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/views/folder_form/folder_form.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/archived_folders_sheet.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/empty_folders_view.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/folder_banner_card.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/folder_carousel.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/goal_edit_sheet.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/goal_tile.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/goals_header.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/goals_shimmer.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/quick_add_goal_bar.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/add_habit_button.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/habit_reorder_sheet.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/habit_row_card.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/today_hero_card.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/today_shimmer.dart';
import 'package:unbroken_mobile/features/core/home/domain/today_summary_calculator.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_aggregator.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_models.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_range.dart';
import 'package:unbroken_mobile/features/core/progress/widgets/activity_overview_card.dart';
import 'package:unbroken_mobile/features/core/progress/widgets/habit_progress_card.dart';
import 'package:unbroken_mobile/features/core/progress/widgets/momentum_summary_row.dart';
import 'package:unbroken_mobile/features/core/progress/widgets/progress_header.dart';
import 'package:unbroken_mobile/features/core/progress/widgets/progress_insights_card.dart';
import 'package:unbroken_mobile/features/core/progress/widgets/progress_shimmer.dart';
import 'package:unbroken_mobile/features/core/progress/widgets/task_momentum_card.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/router/router.dart';
import 'package:unbroken_mobile/router/routes.dart';
import 'package:unbroken_mobile/services/notifications/local_notification_service.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_reorder_list.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_text.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';
import 'package:unbroken_mobile/shared/widgets/core/screen/screen.dart';
import 'package:unbroken_mobile/shared/widgets/design/misc/app_empty_state.dart';
import 'package:unbroken_mobile/shared/widgets/feedback/app_snackbars.dart';

part 'widgets/_body.dart';
part 'widgets/_dashboard_tab.dart';
part 'widgets/_goals_tab.dart';
part 'widgets/_progress_tab.dart';
part 'widgets/_settings_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return const _Body();
  }
}
