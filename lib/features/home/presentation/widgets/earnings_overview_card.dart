import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/motion.dart';
import '../../../earnings/data/earnings_providers.dart';

/// The visual focus of Home: this month's earnings on a navy→indigo
/// gradient with a 6-month bar chart that grows in.
class EarningsOverviewCard extends ConsumerWidget {
  const EarningsOverviewCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(earningsSummaryProvider);
    final months = ref.watch(monthlyEarningsProvider);
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final change = summary.lastMonth == 0
        ? null
        : (summary.thisMonth - summary.lastMonth) / summary.lastMonth;

    return PressScale(
      scale: 0.985,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.hero,
          borderRadius: BorderRadius.circular(AppRadius.xl - 4),
          boxShadow: AppShadows.floating,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(AppRadius.xl - 4),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // A single soft glow for depth.
                Positioned(
                  right: -60,
                  top: -80,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7C74FF).withValues(alpha: 0.35),
                          const Color(0xFF7C74FF).withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Earned in ${Fmt.month(now)}',
                              style: text.bodyMedium?.copyWith(
                                color: AppColors.onNavyMuted,
                              ),
                            ),
                          ),
                          if (change != null)
                            Flexible(
                              flex: 2,
                              child: _TrendChip(
                                change: change,
                                versus: Fmt.monthShort(
                                  DateTime(now.year, now.month - 1),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedAmount(
                          value: summary.thisMonth,
                          style: text.displaySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Fmt.inr(summary.lastMonth)} in '
                        '${Fmt.month(DateTime(now.year, now.month - 1))}',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onNavyMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _MonthBars(months: months),
                      const SizedBox(height: 16),
                      _PendingPayoutRow(
                        amount: summary.approved,
                        date: summary.nextPayoutDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.change, required this.versus});

  final double change;
  final String versus;

  @override
  Widget build(BuildContext context) {
    final up = change >= 0;
    return Semantics(
      label:
          '${up ? 'Up' : 'Down'} ${Fmt.percent(change.abs())} compared with '
          '$versus',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 4, 9, 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: AppRadius.pill,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 15,
              color: up ? AppColors.accent : const Color(0xFFFF9B8F),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${up ? '+' : '-'}${Fmt.percent(change.abs())}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass row under the chart: what's approved and when it's paid.
class _PendingPayoutRow extends StatelessWidget {
  const _PendingPayoutRow({required this.amount, required this.date});

  final double amount;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppRadius.control,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              size: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending payout',
                  style: text.bodySmall?.copyWith(color: AppColors.onNavyMuted),
                ),
                Text(
                  'Paid on ${Fmt.dayMonth(date)}',
                  style: text.labelMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          AnimatedAmount(
            value: amount,
            style: text.titleMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MonthBars extends StatelessWidget {
  const _MonthBars({required this.months});

  final List<(DateTime, double)> months;

  static const _maxBar = 54.0;

  @override
  Widget build(BuildContext context) {
    final peak = months.map((m) => m.$2).fold<double>(1, math.max);
    final text = Theme.of(context).textTheme;

    return Semantics(
      label: 'Earnings for the last ${months.length} months',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppMotion.of(context, const Duration(milliseconds: 800)),
        curve: AppMotion.curve,
        builder: (context, t, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < months.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // Each bar starts a beat after the previous one.
                      height: math.max(
                        4,
                        _maxBar *
                            (months[i].$2 / peak) *
                            ((t * 1.5) - i * 0.1).clamp(0.0, 1.0),
                      ),
                      decoration: BoxDecoration(
                        color: i == months.length - 1
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Fmt.monthShort(months[i].$1),
                      style: text.labelSmall
                          ?.copyWith(
                            fontSize: 10.5,
                            color: i == months.length - 1
                                ? Colors.white
                                : AppColors.onNavyMuted,
                          )
                          .tabular,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
