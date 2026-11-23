part of '../home.dart';

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  void _showTaskUndoSnackbar(
    BuildContext context,
    FocusItem item,
    int index,
    DateTime now,
    DaySettings settings,
  ) {
    SnackbarService.instance.showInfo(
      'Deleted "${item.text}"',
      title: null,
      context: context,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Undo',
        textColor: Colors.white,
        onPressed: () => FocusCubit.c(
          context,
        ).restoreTask(item: item, index: index, asOf: now, settings: settings),
      ),
    );
  }

  void _openPullFromGoals(
    BuildContext context,
    FocusState focusState,
    DateTime now,
    DaySettings settings,
  ) {
    final user = AuthCubit.c(context).state.user;
    if (user != null) {
      GoalsCubit.c(context).startObserving(user.uid);
    }
    final dayKey = settings.logicalDayKey(now);
    final todayItems = focusState.focusForDay(dayKey).itemsList;
    final todayTitlesLower = todayItems
        .map((it) => it.text.trim().toLowerCase())
        .toSet();

    showPullGoalSheet(
      context,
      todayTitlesLower: todayTitlesLower,
      currentTaskCount: todayItems.length,
      onPullGoal: (goal) => FocusCubit.c(
        context,
      ).addTask(text: goal.title, asOf: now, settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final now = DateTime.now();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final today = settings.logicalDay(now);
        final todayKey = settings.logicalDayKey(now);

        return BlocBuilder<HabitsCubit, HabitsState>(
          builder: (context, habitsState) {
            return BlocBuilder<FocusCubit, FocusState>(
              builder: (context, focusState) {
                return BlocBuilder<GoalsCubit, GoalsState>(
                  builder: (context, goalsState) {
                    if (habitsState.fetch.isLoading ||
                        focusState.fetch.isLoading) {
                      return AnimatedSwitcher(
                        duration: AppProps.medium,
                        child: const TodayShimmer(
                          key: ValueKey('today_shimmer'),
                        ),
                      );
                    }

                    final orderedActive = habitsState.activeHabits(
                      settings.habitOrder,
                    );
                    final displayHabits = habitsState.displayHabits(
                      asOf: now,
                      settings: settings,
                    );
                    final todayTasks = focusState
                        .focusForDay(todayKey)
                        .itemsList;
                    final summary = TodaySummaryCalculator.compute(
                      activeHabits: orderedActive,
                      entries: habitsState.entries,
                      todayTasks: todayTasks,
                      now: now,
                      settings: settings,
                    );

                    final hasPullableGoals =
                        AuthCubit.c(context).state.user != null ||
                        goalsState.activeFolders.any(
                          (f) =>
                              goalsState.activeGoalsForFolder(f.id).isNotEmpty,
                        );
                    final showCoachMark =
                        !settings.didCheckInOnce &&
                        summary.habitsCompleted < summary.habitsTotal &&
                        summary.habitsTotal > 0;
                    final firstUndoneIndex = displayHabits.indexWhere(
                      (h) => !habitsState.isCompleted(
                        habit: h,
                        asOf: now,
                        settings: settings,
                      ),
                    );

                    return AnimatedSwitcher(
                      duration: AppProps.medium,
                      child: SafeArea(
                        key: const ValueKey('today_content'),
                        child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: Space.h.t20,
                          children: [
                            Space.y.t16,
                            _DashboardHeader(
                              today: today,
                              greeting: summary.greeting,
                            ),
                            Space.y.t16,
                            TodayHeroCard(summary: summary),
                            Space.y.t16,
                            FocusListCard(
                              today: today,
                              now: now,
                              settings: settings,
                              showPullFromGoals: hasPullableGoals,
                              onPullFromGoals: () => _openPullFromGoals(
                                context,
                                focusState,
                                now,
                                settings,
                              ),
                              onTaskDeleted: (item, index) =>
                                  _showTaskUndoSnackbar(
                                    context,
                                    item,
                                    index,
                                    now,
                                    settings,
                                  ),
                            ),
                            Space.y.t20,
                            _HabitsSectionHeader(
                              completed: summary.habitsCompleted,
                              total: summary.habitsTotal,
                              canReorder: orderedActive.length >= 2,
                              onReorder: () => showHabitReorderSheet(
                                context,
                                habits: orderedActive,
                                onSave: (reordered) {
                                  final order = reordered
                                      .map((h) => h.id)
                                      .toList();
                                  SettingsCubit.c(
                                    context,
                                  ).updateHabitOrderLocally(order);
                                  HabitsCubit.c(
                                    context,
                                  ).reorderHabits(reordered);
                                },
                              ),
                              onAddHabit: () => Navigator.pushNamed(
                                context,
                                AppRoutes.habitForm,
                              ),
                            ),
                            Space.y.t12,
                            if (displayHabits.isEmpty)
                              _EmptyHabitsCard(
                                onCreate: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.habitForm,
                                ),
                              )
                            else ...[
                              AnimatedReorderList<Habit>(
                                items: displayHabits,
                                itemKey: (h) => h.id,
                                separator: Space.y.t12,
                                itemBuilder: (context, habit, i) {
                                  return HabitRowCard(
                                    key: ValueKey(habit.id),
                                    habit: habit,
                                    isDone: habitsState.isCompleted(
                                      habit: habit,
                                      asOf: now,
                                      settings: settings,
                                    ),
                                    stats: habitsState.streakStats(
                                      habit: habit,
                                      asOf: now,
                                      settings: settings,
                                    ),
                                    recentDays: habitsState
                                        .recentDaysCompletion(
                                          habit: habit,
                                          today: today,
                                        ),
                                    showCoachMark:
                                        showCoachMark && i == firstUndoneIndex,
                                    isAtRisk: summary.isAtRisk,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.habitDetail,
                                      arguments: habit,
                                    ),
                                    onToggle: () {
                                      if (!settings.didCheckInOnce) {
                                        final uid = AuthCubit.c(
                                          context,
                                        ).state.user?.uid;
                                        SettingsCubit.c(
                                          context,
                                        ).setDidCheckInOnce(true, uid);
                                      }
                                      HabitsCubit.c(context).toggleCheckIn(
                                        habit: habit,
                                        asOf: now,
                                        settings: settings,
                                      );
                                    },
                                  );
                                },
                              ),
                              Space.y.t12,
                              AddHabitButton(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.habitForm,
                                ),
                              ),
                            ],
                            Space.y.t24,
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final DateTime today;
  final String greeting;

  const _DashboardHeader({required this.today, required this.greeting});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final dateStr = DateFormat('EEEE, MMM d').format(today).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: AppText.l1b
              .cl(AppTheme.c.subText)
              .copyWith(letterSpacing: 1.0),
        ),
        Space.y.t04,
        AppAnimatedText(text: greeting, style: AppText.h1b.cl(AppTheme.c.text)),
      ],
    );
  }
}

class _HabitsSectionHeader extends StatelessWidget {
  final int completed;
  final int total;
  final bool canReorder;
  final VoidCallback onReorder;
  final VoidCallback onAddHabit;

  const _HabitsSectionHeader({
    required this.completed,
    required this.total,
    required this.canReorder,
    required this.onReorder,
    required this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final title = total > 0 ? 'HABITS · $completed/$total' : 'HABITS';

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppText.l1b
                .cl(AppTheme.c.subText)
                .copyWith(letterSpacing: 1.2),
          ),
        ),
        if (canReorder) ...[
          GestureDetector(
            onTap: onReorder,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.c.specBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.c.border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 14,
                    color: AppTheme.c.subText,
                  ),
                  const SizedBox(width: 3),
                  Text('Order', style: AppText.l1b.cl(AppTheme.c.subText)),
                ],
              ),
            ),
          ),
          Space.x.t08,
        ],
        GestureDetector(
          onTap: onAddHabit,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.c.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('+ Habit', style: AppText.l1b.cl(AppTheme.c.accent)),
          ),
        ),
      ],
    );
  }
}

class _EmptyHabitsCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyHabitsCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: Space.a.t20,
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Column(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 30)),
          Space.y.t08,
          Text(
            'Build your first daily habit',
            style: AppText.h3b.cl(AppTheme.c.text),
            textAlign: TextAlign.center,
          ),
          Space.y.t04,
          Text(
            'Start small — one consistent check-in each day starts your unbroken streak.',
            style: AppText.b2.cl(AppTheme.c.subText),
            textAlign: TextAlign.center,
          ),
          Space.y.t16,
          AppButton(
            label: 'Create Habit',
            icon: Icons.add_rounded,
            style: .primary,
            size: .small,
            onTap: onCreate,
          ),
        ],
      ),
    );
  }
}
