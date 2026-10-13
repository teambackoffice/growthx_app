/// Dummy data is anchored to "now" so relative labels (trial ends in 3 days,
/// this month's earnings) stay meaningful whenever the app is opened.
DateTime daysFromNow(int days, {int hour = 10, int minute = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + days, hour, minute);
}

DateTime hoursAgo(int hours) =>
    DateTime.now().subtract(Duration(hours: hours, minutes: 7));

/// A day within the current month, clamped so it's never in the future.
DateTime thisMonth(int day) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, day.clamp(1, now.day), 11);
}

/// A day in a previous month.
DateTime monthsAgo(int months, int day) {
  final now = DateTime.now();
  return DateTime(now.year, now.month - months, day, 11);
}
