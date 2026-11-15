part of 'cubit.dart';

class HabitsState extends Equatable {
  final List<Habit> habits;
  final List<Entry> entries;
  final BlocState<List<Habit>> fetch;
  final BlocState<void> action;

  const HabitsState({
    this.habits = const [],
    this.entries = const [],
    required this.fetch,
    required this.action,
  });

  HabitsState copyWith({
    List<Habit>? habits,
    List<Entry>? entries,
    BlocState<List<Habit>>? fetch,
    BlocState<void>? action,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      entries: entries ?? this.entries,
      fetch: fetch ?? this.fetch,
      action: action ?? this.action,
    );
  }

  bool isCompleted({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final dayKey = settings.logicalDayKey(asOf);
    return entries.any((e) => e.habitId == habit.id && e.logicalDayKey == dayKey);
  }

  ({int completed, int total}) todayProgress({
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final active = habits.where((h) => !h.isArchived).toList();
    if (active.isEmpty) return (completed: 0, total: 0);
    final dayKey = settings.logicalDayKey(asOf);
    final completedSet = entries
        .where((e) => e.logicalDayKey == dayKey)
        .map((e) => e.habitId)
        .toSet();
    final completedCount =
        active.where((h) => completedSet.contains(h.id)).length;
    return (completed: completedCount, total: active.length);
  }

  StreakStats streakStats({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    return StreakCalculator.stats(
      habit: habit,
      entries: entries,
      asOf: asOf,
      settings: settings,
    );
  }

  List<Habit> displayHabits({
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final active = habits.where((h) => !h.isArchived).toList();
    if (!settings.sinkCompletedHabits) {
      active.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return active;
    }

    final dayKey = settings.logicalDayKey(asOf);
    final completedSet = entries
        .where((e) => e.logicalDayKey == dayKey)
        .map((e) => e.habitId)
        .toSet();

    final uncompleted = <Habit>[];
    final completed = <Habit>[];

    for (final h in active) {
      if (completedSet.contains(h.id)) {
        completed.add(h);
      } else {
        uncompleted.add(h);
      }
    }

    uncompleted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    completed.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return [...uncompleted, ...completed];
  }

  @override
  List<Object?> get props => [habits, entries, fetch, action];
}
