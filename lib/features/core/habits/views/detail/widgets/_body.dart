part of '../detail.dart';

class _Body extends StatelessWidget {
  final Habit habit;

  const _Body({required this.habit});

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
            // Find live version of this habit if updated
            final liveHabit = habitsState.habits.firstWhere(
              (h) => h.id == habit.id,
              orElse: () => habit,
            );

            final metrics = HabitMetrics(
              habit: liveHabit,
              entries: habitsState.entries,
              settings: settings,
              now: now,
            );

            final isDone = habitsState.isCompleted(
              habit: liveHabit,
              asOf: now,
              settings: settings,
            );

            return Screen(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFCF6EC), Color(0xFFF5E7D3)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _DetailHeader(
                        habit: liveHabit,
                        onBack: () => Navigator.pop(context),
                        onEdit: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.habitForm,
                            arguments: liveHabit,
                          );
                        },
                      ),
                      Expanded(
                        child: ListView(
                          padding: Space.h.t20,
                          children: [
                            Space.y.t12,
                            _HeroFlameBlock(
                              habit: liveHabit,
                              currentStreak: metrics.stats.current,
                              isDone: isDone,
                              onToggle: () {
                                HabitsCubit.c(context).toggleCheckIn(
                                  habit: liveHabit,
                                  asOf: now,
                                  settings: settings,
                                );
                              },
                            ),
                            Space.y.t20,
                            _StatCards(metrics: metrics),
                            Space.y.t24,
                            _ThisWeekSection(
                              habit: liveHabit,
                              today: today,
                              weekStartsMonday: settings.weekStartMonday,
                              isDone: (d) => habitsState.isCompleted(
                                habit: liveHabit,
                                asOf: d,
                                settings: settings,
                              ),
                              onToggleDay: (d) {
                                _confirmAndToggle(
                                  context: context,
                                  habit: liveHabit,
                                  targetDay: d,
                                  today: today,
                                  isDone: habitsState.isCompleted(
                                    habit: liveHabit,
                                    asOf: d,
                                    settings: settings,
                                  ),
                                  settings: settings,
                                );
                              },
                            ),
                            Space.y.t24,
                            Text(
                              'LAST 18 WEEKS',
                              style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                            ),
                            Space.y.t12,
                            Container(
                              padding: Space.a.t16,
                              decoration: BoxDecoration(
                                color: AppColors.specBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: ContributionGrid(
                                color: liveHabit.color,
                                today: today,
                                weekStartsMonday: settings.weekStartMonday,
                                weeks: 18,
                                isDone: (d) => habitsState.isCompleted(
                                  habit: liveHabit,
                                  asOf: d,
                                  settings: settings,
                                ),
                              ),
                            ),
                            Space.y.t24,
                            Text(
                              DateFormat('MMMM yyyy').format(now).toUpperCase(),
                              style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                            ),
                            Space.y.t12,
                            Container(
                              padding: Space.a.t16,
                              decoration: BoxDecoration(
                                color: AppColors.specBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: MonthHeatmap(
                                color: liveHabit.color,
                                today: today,
                                weekStartsMonday: settings.weekStartMonday,
                                isDone: (d) => habitsState.isCompleted(
                                  habit: liveHabit,
                                  asOf: d,
                                  settings: settings,
                                ),
                                onToggleDay: (d) {
                                  _confirmAndToggle(
                                    context: context,
                                    habit: liveHabit,
                                    targetDay: d,
                                    today: today,
                                    isDone: habitsState.isCompleted(
                                      habit: liveHabit,
                                      asOf: d,
                                      settings: settings,
                                    ),
                                    settings: settings,
                                  );
                                },
                              ),
                            ),
                            Space.y.t32,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmAndToggle({
    required BuildContext context,
    required Habit habit,
    required DateTime targetDay,
    required DateTime today,
    required bool isDone,
    required DaySettings settings,
  }) {
    final isSameDay = targetDay.year == today.year &&
        targetDay.month == today.month &&
        targetDay.day == today.day;
    if (isSameDay) {
      HabitsCubit.c(context).toggleCheckIn(
        habit: habit,
        asOf: targetDay,
        settings: settings,
      );
      return;
    }

    final dateFormatted = DateFormat('EEEE, MMM d').format(targetDay);
    final action = isDone ? 'Remove check-in for' : 'Mark as complete for';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isDone ? 'Undo Check-in?' : 'Backfill Check-in?',
          style: AppText.h3b.cl(AppColors.text),
        ),
        content: Text(
          '$action $dateFormatted?',
          style: AppText.b1.cl(AppColors.subText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.b1.cl(AppColors.subText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HabitsCubit.c(context).toggleCheckIn(
                habit: habit,
                asOf: targetDay,
                settings: settings,
              );
            },
            child: Text('Confirm', style: AppText.b1b.cl(AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final Habit habit;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const _DetailHeader({
    required this.habit,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Padding(
      padding: Space.sym(16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.text,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(habit.emoji.isEmpty ? '🔥' : habit.emoji, style: const TextStyle(fontSize: 20)),
                Space.x.t08,
                Flexible(
                  child: Text(
                    habit.name,
                    style: AppText.h3b.cl(AppColors.text),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_note_rounded, size: 24),
            color: AppColors.text,
          ),
        ],
      ),
    );
  }
}

class _HeroFlameBlock extends StatelessWidget {
  final Habit habit;
  final int currentStreak;
  final bool isDone;
  final VoidCallback onToggle;

  const _HeroFlameBlock({
    required this.habit,
    required this.currentStreak,
    required this.isDone,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Container(
      width: double.infinity,
      padding: Space.v.t24,
      decoration: BoxDecoration(
        color: AppColors.specBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          FlameHero(size: 56, emoji: habit.emoji.isEmpty ? '🔥' : habit.emoji),
          Space.y.t08,
          Text(
            '$currentStreak',
            style: AppText.heroStat.copyWith(
              fontSize: 64,
              color: habit.color,
              height: 1.0,
            ),
          ),
          Space.y.t04,
          Text(
            'DAY STREAK',
            style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 2.0),
          ),
          Space.y.t16,
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: Space.sym(24, 12),
              decoration: BoxDecoration(
                color: isDone ? habit.color.withValues(alpha: 0.14) : habit.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isDone ? '✓ Done today' : 'Mark done today',
                style: AppText.b1b.cl(isDone ? habit.color : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCards extends StatelessWidget {
  final HabitMetrics metrics;

  const _StatCards({required this.metrics});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${metrics.stats.best}',
            label: 'Longest',
          ),
        ),
        Space.x.t08,
        Expanded(
          child: _StatTile(
            value: '${metrics.consistency}%',
            label: 'Consistency',
          ),
        ),
        Space.x.t08,
        Expanded(
          child: _StatTile(
            value: '${metrics.totalDays}',
            label: 'Total days',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

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
          Text(label, style: AppText.l1.cl(AppColors.inkFaint)),
        ],
      ),
    );
  }
}

class _ThisWeekSection extends StatelessWidget {
  final Habit habit;
  final DateTime today;
  final bool weekStartsMonday;
  final bool Function(DateTime date) isDone;
  final ValueChanged<DateTime> onToggleDay;

  const _ThisWeekSection({
    required this.habit,
    required this.today,
    required this.weekStartsMonday,
    required this.isDone,
    required this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final days = _buildWeekDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THIS WEEK',
          style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
        ),
        Space.y.t12,
        Container(
          padding: Space.sym(12, 16),
          decoration: BoxDecoration(
            color: AppColors.specBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final day in days)
                _WeekDayRing(
                  day: day,
                  today: today,
                  color: habit.color,
                  isDone: isDone(day),
                  onTap: () => onToggleDay(day),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<DateTime> _buildWeekDays() {
    final firstWeekday = weekStartsMonday ? DateTime.monday : DateTime.sunday;
    final weekdayOfToday = today.weekday;
    final rowOfToday = (weekdayOfToday - firstWeekday + 7) % 7;
    final weekStart = today.subtract(Duration(days: rowOfToday));

    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }
}

class _WeekDayRing extends StatelessWidget {
  final DateTime day;
  final DateTime today;
  final Color color;
  final bool isDone;
  final VoidCallback onTap;

  const _WeekDayRing({
    required this.day,
    required this.today,
    required this.color,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
    final isFuture = day.isAfter(today);
    final letter = DateFormat('E').format(day).substring(0, 1);

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? color : Colors.transparent,
              border: Border.all(
                color: isToday
                    ? color.withValues(alpha: 0.8)
                    : (isDone ? Colors.transparent : AppColors.fieldBorder),
                width: isToday ? 2.0 : 1.0,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          Space.y.t04,
          Text(
            letter,
            style: TextStyle(
              fontFamily: FontFamily.hanken,
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? color : AppColors.hint,
            ),
          ),
        ],
      ),
    );
  }
}

