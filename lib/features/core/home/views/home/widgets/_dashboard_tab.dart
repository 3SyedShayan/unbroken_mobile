part of '../home.dart';

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final now = DateTime.now();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final today = settings.logicalDay(now);

        return BlocBuilder<HabitsCubit, HabitsState>(
          builder: (context, habitsState) {
            final habits = habitsState.displayHabits(asOf: now, settings: settings);
            final progress = habitsState.todayProgress(asOf: now, settings: settings);

            final greeting = progress.total > 0 && progress.completed == progress.total
                ? 'You\'re unbroken today'
                : (progress.completed == 0
                    ? 'Let\'s get going'
                    : 'Keep it rolling');

            final showCoachMark = !settings.didCheckInOnce &&
                progress.completed < progress.total &&
                progress.total > 0;

            final firstUndoneIndex = habits.indexWhere(
              (h) => !habitsState.isCompleted(habit: h, asOf: now, settings: settings),
            );

            return SafeArea(
              child: ListView(
                padding: Space.h.t20,
                children: [
                  Space.y.t16,
                  _DashboardHeader(now: now, greeting: greeting),
                  Space.y.t16,
                  DayProgressBar(
                    completed: progress.completed,
                    total: progress.total,
                  ),
                  Space.y.t20,
                  FocusListCard(
                    today: today,
                    now: now,
                    settings: settings,
                  ),
                  Space.y.t20,
                  if (habits.isNotEmpty) ...[
                    Text(
                      'HABITS',
                      style: AppText.l1b.cl(AppColors.inkFaint).copyWith(
                            letterSpacing: 1.2,
                          ),
                    ),
                    Space.y.t12,
                  ],
                  for (var i = 0; i < habits.length; i++) ...[
                    HabitRowCard(
                      habit: habits[i],
                      isDone: habitsState.isCompleted(
                        habit: habits[i],
                        asOf: now,
                        settings: settings,
                      ),
                      stats: habitsState.streakStats(
                        habit: habits[i],
                        asOf: now,
                        settings: settings,
                      ),
                      last14: _computeLast14(
                        habit: habits[i],
                        today: today,
                        habitsState: habitsState,
                        settings: settings,
                      ),
                      showCoachMark: showCoachMark && i == firstUndoneIndex,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.habitDetail,
                          arguments: habits[i],
                        );
                      },
                      onToggle: () {
                        if (!settings.didCheckInOnce) {
                          final uid = AuthCubit.c(context).state.user?.uid;
                          SettingsCubit.c(context).setDidCheckInOnce(true, uid);
                        }
                        HabitsCubit.c(context).toggleCheckIn(
                          habit: habits[i],
                          asOf: now,
                          settings: settings,
                        );
                      },
                    ),
                    Space.y.t12,
                  ],
                  AddHabitButton(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.habitForm);
                    },
                  ),
                  Space.y.t24,
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<bool> _computeLast14({
    required Habit habit,
    required DateTime today,
    required HabitsState habitsState,
    required DaySettings settings,
  }) {
    final list = <bool>[];
    for (var i = 0; i < 14; i++) {
      final day = today.subtract(Duration(days: 13 - i));
      list.add(habitsState.isCompleted(
        habit: habit,
        asOf: day,
        settings: settings,
      ));
    }
    return list;
  }
}

class _DashboardHeader extends StatelessWidget {
  final DateTime now;
  final String greeting;

  const _DashboardHeader({required this.now, required this.greeting});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final dateStr = DateFormat('EEEE, MMM d').format(now).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.0),
        ),
        Space.y.t04,
        Text(
          greeting,
          style: AppText.h1b.cl(AppColors.text),
        ),
      ],
    );
  }
}

