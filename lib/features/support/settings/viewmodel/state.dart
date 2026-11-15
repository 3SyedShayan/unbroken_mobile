part of 'cubit.dart';

class SettingsState extends Equatable {
  final DaySettings settings;
  final BlocState<DaySettings> fetch;
  final BlocState<void> update;

  const SettingsState({
    required this.settings,
    required this.fetch,
    required this.update,
  });

  SettingsState copyWith({
    DaySettings? settings,
    BlocState<DaySettings>? fetch,
    BlocState<void>? update,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      fetch: fetch ?? this.fetch,
      update: update ?? this.update,
    );
  }

  @override
  List<Object?> get props => [settings, fetch, update];
}

