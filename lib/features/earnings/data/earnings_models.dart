import '../../../core/widgets/status_badge.dart';

enum CommissionStatus {
  pending('Under review', BadgeTone.warning),
  approved('Approved', BadgeTone.info),
  paid('Paid', BadgeTone.success);

  const CommissionStatus(this.label, this.tone);

  final String label;
  final BadgeTone tone;
}

enum CommissionType {
  firstMonth('First month'),
  recurring('Recurring'),
  bonus('Bonus');

  const CommissionType(this.label);

  final String label;
}

class Commission {
  const Commission({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
    this.customerId,
    this.payoutId,
  });

  final String id;

  /// Customer business name, or a bonus description.
  final String title;
  final CommissionType type;
  final double amount;
  final CommissionStatus status;
  final DateTime date;
  final String? customerId;
  final String? payoutId;
}

enum PayoutStatus {
  processing('Processing', BadgeTone.warning),
  paid('Paid', BadgeTone.success);

  const PayoutStatus(this.label, this.tone);

  final String label;
  final BadgeTone tone;
}

class Payout {
  const Payout({
    required this.id,
    required this.reference,
    required this.period,
    required this.date,
    required this.status,
    required this.method,
    required this.commissions,
  });

  /// TDS on commission under Section 194H.
  static const tdsRate = 0.02;

  final String id;
  final String reference;
  final DateTime period;
  final DateTime date;
  final PayoutStatus status;
  final String method;
  final List<Commission> commissions;

  double get gross => commissions.fold(0, (sum, c) => sum + c.amount);
  double get tds => gross * tdsRate;
  double get net => gross - tds;
}

class EarningsSummary {
  const EarningsSummary({
    required this.thisMonth,
    required this.lastMonth,
    required this.pending,
    required this.approved,
    required this.paidLifetime,
    required this.nextPayoutDate,
  });

  final double thisMonth;
  final double lastMonth;

  /// Within the 30-day review window.
  final double pending;

  /// Cleared and included in the next payout.
  final double approved;
  final double paidLifetime;
  final DateTime nextPayoutDate;

  double get lifetime => pending + approved + paidLifetime;
}

/// Partner commission plan.
abstract final class CommissionRates {
  static const firstMonth = 0.5;
  static const recurring = 0.2;
}
