part of 'cubit.dart';

class FocusState extends Equatable {
  final List<DailyFocus> focusList;
  final BlocState<List<DailyFocus>> fetch;
  final BlocState<void> action;

  const FocusState({
    this.focusList = const [],
    required this.fetch,
    required this.action,
  });

  FocusState copyWith({
    List<DailyFocus>? focusList,
    BlocState<List<DailyFocus>>? fetch,
    BlocState<void>? action,
  }) {
    return FocusState(
      focusList: focusList ?? this.focusList,
      fetch: fetch ?? this.fetch,
      action: action ?? this.action,
    );
  }

  DailyFocus focusForDay(String dayKey) {
    return focusList.firstWhere(
      (f) => f.logicalDayKey == dayKey,
      orElse: () => DailyFocus(logicalDayKey: dayKey),
    );
  }

  StreakStats streakStats({
    required DateTime asOf,
    required DaySettings settings,
  }) {
    return FocusStreakCalculator.stats(
      focusList: focusList,
      asOf: asOf,
      settings: settings,
    );
  }

  List<DailyTaskResult> get dailyTaskResults {
    final results = <DailyTaskResult>[];
    for (final focus in focusList) {
      final parsed = DaySettings.startOfDay(focus.logicalDayKey);
      if (parsed != null && focus.itemsList.isNotEmpty) {
        results.add(DailyTaskResult(
          dayKey: focus.logicalDayKey,
          day: parsed,
          items: focus.itemsList,
        ));
      }
    }
    results.sort((a, b) => b.day.compareTo(a.day));
    return results;
  }

  @override
  List<Object?> get props => [focusList, fetch, action];
}

