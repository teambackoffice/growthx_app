import 'package:intl/intl.dart';

/// Shared formatting so every amount and date reads the same across screens.
abstract final class Fmt {
  static final _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final _inrPaise = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  static final _count = NumberFormat.decimalPattern('en_IN');
  static final _date = DateFormat('d MMM yyyy');
  static final _dayMonth = DateFormat('d MMM');
  static final _time = DateFormat('h:mm a');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _month = DateFormat('MMMM');
  static final _monthShort = DateFormat('MMM');

  /// ₹1,24,500 — whole rupees, Indian digit grouping.
  static String inr(num amount) => _inr.format(amount);

  /// ₹1,24,500.50 — use where paise matter (payout breakdowns).
  static String inrExact(num amount) => _inrPaise.format(amount);

  static String count(num value) => _count.format(value);

  static String date(DateTime d) => _date.format(d);
  static String dayMonth(DateTime d) => _dayMonth.format(d);
  static String time(DateTime d) => _time.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
  static String month(DateTime d) => _month.format(d);
  static String monthShort(DateTime d) => _monthShort.format(d);

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  /// "Today", "Tomorrow", "in 5 days", "3 days ago".
  static String relativeDay(DateTime d, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final diff = _dateOnly(d).difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return diff > 0 ? 'in $diff days' : '${-diff} days ago';
  }

  /// Compact time for feeds: "Just now", "25m", "3h", "Yesterday", "12 Sep".
  static String timeAgo(DateTime d, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && ref.day == d.day) return '${diff.inHours}h ago';
    if (_dateOnly(ref).difference(_dateOnly(d)).inDays == 1) {
      return 'Yesterday';
    }
    return dayMonth(d);
  }

  static int daysUntil(DateTime d, {DateTime? now}) =>
      _dateOnly(d).difference(_dateOnly(now ?? DateTime.now())).inDays;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
