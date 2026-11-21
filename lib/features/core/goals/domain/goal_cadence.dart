enum GoalCadence {
  weekly,
  monthly,
  weekend,
  custom;

  String get label {
    switch (this) {
      case GoalCadence.weekly:
        return 'Weekly';
      case GoalCadence.monthly:
        return 'Monthly';
      case GoalCadence.weekend:
        return 'Weekend';
      case GoalCadence.custom:
        return 'Custom';
    }
  }

  String get defaultEmoji {
    switch (this) {
      case GoalCadence.weekly:
        return '📅';
      case GoalCadence.monthly:
        return '🗓️';
      case GoalCadence.weekend:
        return '🏖️';
      case GoalCadence.custom:
        return '🎯';
    }
  }
}
