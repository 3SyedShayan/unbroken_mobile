enum ProgressRange {
  oneMonth(
    storageKey: '1m',
    shortLabel: '1M',
    subtitle: 'Last 30 days',
    days: 30,
    weeks: 5,
    requiredFetchDays: 65,
  ),
  threeMonths(
    storageKey: '3m',
    shortLabel: '3M',
    subtitle: 'Last 3 months',
    days: 91,
    weeks: 13,
    requiredFetchDays: 105,
  ),
  sixMonths(
    storageKey: '6m',
    shortLabel: '6M',
    subtitle: 'Last 6 months',
    days: 182,
    weeks: 26,
    requiredFetchDays: 195,
  );

  final String storageKey;
  final String shortLabel;
  final String subtitle;
  final int days;
  final int weeks;
  final int requiredFetchDays;

  const ProgressRange({
    required this.storageKey,
    required this.shortLabel,
    required this.subtitle,
    required this.days,
    required this.weeks,
    required this.requiredFetchDays,
  });

  bool get isCalendarMonthLayout => this == ProgressRange.oneMonth;

  static ProgressRange fromKey(String? key) {
    for (final range in ProgressRange.values) {
      if (range.storageKey == key) return range;
    }
    return ProgressRange.oneMonth;
  }
}
