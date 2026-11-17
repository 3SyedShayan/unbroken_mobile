part of '../home.dart';

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

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
            final habits = habitsState.habits.where((h) => !h.isArchived).toList();
            final activeStreaks = habits
                .where((h) => habitsState.streakStats(habit: h, asOf: now, settings: settings).current > 0)
                .length;
            final totalDays = habitsState.entries.length;
            final bestRun = habits.isEmpty
                ? 0
                : habits
                    .map((h) => habitsState.streakStats(habit: h, asOf: now, settings: settings).best)
                    .reduce((a, b) => a > b ? a : b);

            return BlocBuilder<FocusCubit, FocusState>(
              builder: (context, focusState) {
                final taskResults = focusState.dailyTaskResults;
                final taskStreak = focusState.streakStats(asOf: now, settings: settings);
                final clearedTaskDays = taskResults.where((r) => r.isCleared).length;

                return SafeArea(
                  child: ListView(
                    padding: Space.h.t20,
                    children: [
                      Space.y.t16,
                      Text('History & Analytics', style: AppText.h1b.cl(AppColors.text)),
                      Space.y.t16,
                      _StreaksSummaryCards(
                        activeStreaks: activeStreaks,
                        totalDays: totalDays,
                        bestRun: bestRun,
                      ),
                      Space.y.t24,
                      if (habits.isNotEmpty) ...[
                        Text(
                          'HABIT CONTRIBUTION GRIDS',
                          style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                        ),
                        Space.y.t12,
                        for (final habit in habits) ...[
                          _HabitContributionCard(
                            habit: habit,
                            today: today,
                            settings: settings,
                            habitsState: habitsState,
                            now: now,
                          ),
                          Space.y.t12,
                        ],
                        Space.y.t16,
                      ],
                      if (taskResults.isNotEmpty) ...[
                        Text(
                          'DAILY TASKS HISTORY',
                          style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                        ),
                        Space.y.t12,
                        _TaskStreaksSummaryCards(
                          currentStreak: taskStreak.current,
                          bestStreak: taskStreak.best,
                          clearedDays: clearedTaskDays,
                        ),
                        Space.y.t12,
                        for (final result in taskResults.take(15)) ...[
                          _TaskResultCard(result: result),
                          Space.y.t08,
                        ],
                      ],
                      Space.y.t24,
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StreaksSummaryCards extends StatelessWidget {
  final int activeStreaks;
  final int totalDays;
  final int bestRun;

  const _StreaksSummaryCards({
    required this.activeStreaks,
    required this.totalDays,
    required this.bestRun,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        Expanded(child: _SummaryTile(value: '$activeStreaks', label: 'Active streaks')),
        Space.x.t08,
        Expanded(child: _SummaryTile(value: '$totalDays', label: 'Total check-ins')),
        Space.x.t08,
        Expanded(child: _SummaryTile(value: '$bestRun', label: 'Best run')),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: Space.sym(12, 14),
      decoration: BoxDecoration(
        color: AppColors.specBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Text(value, style: AppText.stat.cl(AppColors.text)),
          Space.y.t04,
          Text(
            label,
            style: AppText.l1.cl(AppColors.inkFaint),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HabitContributionCard extends StatelessWidget {
  final Habit habit;
  final DateTime today;
  final DaySettings settings;
  final HabitsState habitsState;
  final DateTime now;

  const _HabitContributionCard({
    required this.habit,
    required this.today,
    required this.settings,
    required this.habitsState,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final stats = habitsState.streakStats(habit: habit, asOf: now, settings: settings);

    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: AppColors.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(habit.emoji.isEmpty ? '🔥' : habit.emoji, style: const TextStyle(fontSize: 18)),
              Space.x.t08,
              Expanded(
                child: Text(habit.name, style: AppText.h3b.cl(AppColors.text)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text('${stats.current}d', style: AppText.b2b.cl(habit.color)),
                ],
              ),
            ],
          ),
          Space.y.t12,
          ContributionGrid(
            color: habit.color,
            today: today,
            weekStartsMonday: settings.weekStartMonday,
            weeks: 20,
            isDone: (date) => habitsState.isCompleted(
              habit: habit,
              asOf: date,
              settings: settings,
            ),
            onToggleDay: (date) {
              HabitsCubit.c(context).toggleCheckIn(
                habit: habit,
                asOf: date,
                settings: settings,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TaskStreaksSummaryCards extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final int clearedDays;

  const _TaskStreaksSummaryCards({
    required this.currentStreak,
    required this.bestStreak,
    required this.clearedDays,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        Expanded(child: _SummaryTile(value: '$currentStreak', label: 'Current streak')),
        Space.x.t08,
        Expanded(child: _SummaryTile(value: '$bestStreak', label: 'Best streak')),
        Space.x.t08,
        Expanded(child: _SummaryTile(value: '$clearedDays', label: 'Days cleared')),
      ],
    );
  }
}

class _TaskResultCard extends StatefulWidget {
  final DailyTaskResult result;

  const _TaskResultCard({required this.result});

  @override
  State<_TaskResultCard> createState() => _TaskResultCardState();
}

class _TaskResultCardState extends State<_TaskResultCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final formattedDate = DateFormat('EEE, MMM d').format(widget.result.day);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppProps.fast,
        padding: Space.sym(14, 10),
        decoration: BoxDecoration(
          color: AppColors.specBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.result.isCleared
                ? AppColors.accent.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.result.isCleared
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: widget.result.isCleared ? AppColors.accent : AppColors.hint,
                    ),
                    Space.x.t12,
                    Text(formattedDate, style: AppText.b1.cl(AppColors.text)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.result.completedCount} of ${widget.result.totalCount} done',
                      style: AppText.b2b.cl(
                        widget.result.isCleared ? AppColors.accent : AppColors.subText,
                      ),
                    ),
                    Space.x.t04,
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.hint,
                    ),
                  ],
                ),
              ],
            ),
            if (_expanded && widget.result.items.isNotEmpty) ...[
              Space.y.t08,
              const Divider(height: 1, color: AppColors.border),
              Space.y.t08,
              for (final item in widget.result.items) ...[
                Padding(
                  padding: Space.v.t04,
                  child: Row(
                    children: [
                      Icon(
                        item.done ? Icons.check : Icons.circle_outlined,
                        size: 14,
                        color: item.done ? AppColors.accent : AppColors.hint,
                      ),
                      Space.x.t08,
                      Expanded(
                        child: Text(
                          item.text,
                          style: TextStyle(
                            fontFamily: FontFamily.hanken,
                            fontSize: 13,
                            color: item.done ? AppColors.hint : AppColors.text,
                            decoration: item.done ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.hint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

