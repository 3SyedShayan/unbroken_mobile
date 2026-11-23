part of '../home.dart';

class _ProgressTab extends StatefulWidget {
  const _ProgressTab();

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  ActivityFilter _filter = ActivityFilter.all;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final range = ProgressRange.fromKey(
        SettingsCubit.c(context).state.settings.progressRange,
      );
      _ensureWindows(range);
      final user = AuthCubit.c(context).state.user;
      if (user != null) {
        GoalsCubit.c(context).startObserving(user.uid);
      }
    });
  }

  void _ensureWindows(ProgressRange range) {
    HabitsCubit.c(context).ensureHistoryWindowDays(range.requiredFetchDays);
    FocusCubit.c(context).ensureHistoryWindowDays(range.requiredFetchDays);
  }

  void _onRangeChanged(ProgressRange range) {
    setState(() => _selectedDay = null);
    SettingsCubit.c(context).setProgressRange(range.storageKey);
    _ensureWindows(range);
  }

  void _onDayTap(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    setState(() {
      _selectedDay = _selectedDay == normalized ? null : normalized;
    });
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final now = DateTime.now();

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (prev, curr) =>
          prev.settings.progressRange != curr.settings.progressRange,
      listener: (context, state) {
        _ensureWindows(ProgressRange.fromKey(state.settings.progressRange));
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final settings = settingsState.settings;
          final range = ProgressRange.fromKey(settings.progressRange);

          return BlocBuilder<HabitsCubit, HabitsState>(
            builder: (context, habitsState) {
              return BlocBuilder<FocusCubit, FocusState>(
                builder: (context, focusState) {
                  return BlocBuilder<GoalsCubit, GoalsState>(
                    builder: (context, goalsState) {
                      final isLoading =
                          habitsState.fetch.isLoading || focusState.fetch.isLoading;

                      if (isLoading) {
                        return AnimatedSwitcher(
                          duration: AppProps.medium,
                          child: const ProgressShimmer(
                            key: ValueKey('progress_shimmer'),
                          ),
                        );
                      }

                      final habitsWindow = HabitsCubit.c(context).observedWindowDays;
                      final focusWindow = FocusCubit.c(context).observedWindowDays;
                      final minWindow =
                          habitsWindow < focusWindow ? habitsWindow : focusWindow;

                      final snapshot = ProgressAggregator.compute(
                        activeHabits: habitsState.activeHabits(settings.habitOrder),
                        entries: habitsState.entries,
                        focusList: focusState.focusList,
                        goals: goalsState.goals,
                        settings: settings,
                        range: range,
                        now: now,
                        observedWindowDays: minWindow,
                      );

                      final isEmpty = snapshot.habitSummaries.isEmpty &&
                          snapshot.taskSummary.trackedDaysInRange == 0;

                      return AnimatedSwitcher(
                        duration: AppProps.medium,
                        child: SafeArea(
                          key: const ValueKey('progress_content'),
                          child: isEmpty
                              ? _ProgressEmptyBody(
                                  snapshot: snapshot,
                                  onRangeChanged: _onRangeChanged,
                                )
                              : ListView(
                                  padding: Space.h.t20,
                                  children: [
                                    Space.y.t16,
                                    ProgressHeader(
                                      selectedRange: range,
                                      startDay: snapshot.startDay,
                                      endDay: snapshot.endDay,
                                      deltaVsPreviousPercent:
                                          snapshot.deltaVsPreviousPercent,
                                      onRangeChanged: _onRangeChanged,
                                    ),
                                    Space.y.t16,
                                    MomentumSummaryRow(
                                      consistencyPercent:
                                          snapshot.consistencyPercent,
                                      unbrokenDaysCount:
                                          snapshot.unbrokenDaysCount,
                                      bestHabitStreak: snapshot.bestHabitStreak,
                                    ),
                                    Space.y.t16,
                                    ActivityOverviewCard(
                                      snapshot: snapshot,
                                      filter: _filter,
                                      weekStartsMonday: settings.weekStartMonday,
                                      selectedDay: _selectedDay,
                                      onFilterChanged: (next) =>
                                          setState(() => _filter = next),
                                      onDayTap: _onDayTap,
                                      onClearSelectedDay: () =>
                                          setState(() => _selectedDay = null),
                                    ),
                                    if (snapshot.taskSummary.trackedDaysInRange > 0 ||
                                        snapshot.taskSummary.bestStreak > 0) ...[
                                      Space.y.t12,
                                      TaskMomentumCard(
                                        summary: snapshot.taskSummary,
                                        onViewMap: () => setState(
                                          () => _filter = ActivityFilter.tasks,
                                        ),
                                      ),
                                    ],
                                    if (snapshot.strongestWeekday != null ||
                                        snapshot.topHabit != null ||
                                        snapshot.goalsCompletedInRange > 0) ...[
                                      Space.y.t12,
                                      ProgressInsightsCard(snapshot: snapshot),
                                    ],
                                    if (snapshot.habitSummaries.isNotEmpty) ...[
                                      Space.y.t20,
                                      Text(
                                        'HABITS',
                                        style: AppText.l1b
                                            .cl(AppTheme.c.subText)
                                            .copyWith(letterSpacing: 1.2),
                                      ),
                                      Space.y.t12,
                                      for (final summary
                                          in snapshot.habitSummaries) ...[
                                        HabitProgressCard(
                                          summary: summary,
                                          range: range,
                                          today: snapshot.endDay,
                                          weekStartsMonday:
                                              settings.weekStartMonday,
                                        ),
                                        Space.y.t12,
                                      ],
                                    ],
                                    Space.y.t16,
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
      ),
    );
  }
}

class _ProgressEmptyBody extends StatelessWidget {
  final ProgressSnapshot snapshot;
  final ValueChanged<ProgressRange> onRangeChanged;

  const _ProgressEmptyBody({
    required this.snapshot,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return ListView(
      padding: Space.h.t20,
      children: [
        Space.y.t16,
        ProgressHeader(
          selectedRange: snapshot.range,
          startDay: snapshot.startDay,
          endDay: snapshot.endDay,
          deltaVsPreviousPercent: null,
          onRangeChanged: onRangeChanged,
        ),
        Space.y.t32,
        const AppEmptyState(
          icon: Icons.insights_rounded,
          title: 'Your Progress Starts Today',
          subtitle:
              'Check off a habit or complete a daily task to start building your activity heatmap.',
        ),
      ],
    );
  }
}
