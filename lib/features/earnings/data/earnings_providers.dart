import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'earnings_dummy_data.dart';
import 'earnings_models.dart';

final commissionsProvider = Provider<List<Commission>>((ref) {
  return [...dummyCommissions]..sort((a, b) => b.date.compareTo(a.date));
});

final payoutsProvider = Provider<List<Payout>>((ref) => dummyPayouts);

final payoutByIdProvider = Provider.family<Payout?, String>((ref, id) {
  for (final p in ref.watch(payoutsProvider)) {
    if (p.id == id) return p;
  }
  return null;
});

final commissionsForCustomerProvider =
    Provider.family<List<Commission>, String>(
      (ref, customerId) => ref
          .watch(commissionsProvider)
          .where((c) => c.customerId == customerId)
          .toList(),
    );

final earningsSummaryProvider = Provider<EarningsSummary>((ref) {
  final commissions = ref.watch(commissionsProvider);
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1);

  double sum(bool Function(Commission c) test) =>
      commissions.where(test).fold(0, (total, c) => total + c.amount);

  bool inMonth(DateTime d, DateTime month) =>
      d.year == month.year && d.month == month.month;

  // Payouts go out on the 15th of every month.
  final nextPayout = now.day <= 15
      ? DateTime(now.year, now.month, 15)
      : DateTime(now.year, now.month + 1, 15);

  return EarningsSummary(
    thisMonth: sum((c) => inMonth(c.date, now)),
    lastMonth: sum((c) => inMonth(c.date, lastMonth)),
    pending: sum((c) => c.status == CommissionStatus.pending),
    approved: sum((c) => c.status == CommissionStatus.approved),
    paidLifetime: sum((c) => c.status == CommissionStatus.paid),
    nextPayoutDate: nextPayout,
  );
});

/// Earned per month for the last [monthlyChartLength] months, oldest first.
const monthlyChartLength = 6;

final monthlyEarningsProvider = Provider<List<(DateTime, double)>>((ref) {
  final commissions = ref.watch(commissionsProvider);
  final now = DateTime.now();
  return [
    for (var i = monthlyChartLength - 1; i >= 0; i--)
      (
        DateTime(now.year, now.month - i),
        commissions
            .where((c) {
              final m = DateTime(now.year, now.month - i);
              return c.date.year == m.year && c.date.month == m.month;
            })
            .fold<double>(0, (sum, c) => sum + c.amount),
      ),
  ];
});
