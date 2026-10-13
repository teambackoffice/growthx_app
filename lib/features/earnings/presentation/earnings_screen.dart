import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/card_sliver_list.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/page_title.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../../core/widgets/stat_strip.dart';
import '../../../core/widgets/status_badge.dart';
import '../../profile/data/profile_providers.dart';
import '../data/earnings_models.dart';
import '../data/earnings_providers.dart';
import 'widgets/commission_tile.dart';

enum _View { commissions, payouts }

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with FirstLoadMixin {
  _View _view = _View.commissions;
  CommissionStatus? _status;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(earningsSummaryProvider);
    final commissions = ref.watch(commissionsProvider);
    final payouts = ref.watch(payoutsProvider);
    final visible = _status == null
        ? commissions
        : commissions.where((c) => c.status == _status).toList();

    final header = <Widget>[
      _NextPayoutCard(summary: summary),
      const SizedBox(height: AppSpacing.md),
      StatStrip(
        items: [
          StatItem(
            value: summary.pending,
            format: Fmt.inr,
            label: 'Under review',
            dotColor: AppColors.warning,
          ),
          StatItem(
            value: summary.approved,
            format: Fmt.inr,
            label: 'Approved',
            dotColor: AppColors.info,
          ),
          StatItem(
            value: summary.paidLifetime,
            format: Fmt.inr,
            label: 'Paid',
            dotColor: AppColors.success,
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      const _HowItWorks(),
      const SizedBox(height: AppSpacing.lg),
      SegmentedControl<_View>(
        segments: const [
          (_View.commissions, 'Commissions'),
          (_View.payouts, 'Payouts'),
        ],
        selected: _view,
        onChanged: (v) => setState(() => _view = v),
      ),
      const SizedBox(height: AppSpacing.lg),
    ];

    return Scaffold(
      appBar: AppBar(
        title: PageTitle(
          'Earnings',
          subtitle: '${Fmt.inr(summary.lifetime)} earned with GrowthX',
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            sliver: SliverList.list(
              children: [
                for (var i = 0; i < header.length; i++)
                  FadeSlideIn(index: i ~/ 2, child: header[i]),
              ],
            ),
          ),
          if (_view == _View.commissions)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: FilterChipBar<CommissionStatus?>(
                  selected: _status,
                  onSelected: (s) => setState(() => _status = s),
                  options: [
                    FilterOption(null, 'All', count: commissions.length),
                    for (final s in CommissionStatus.values)
                      FilterOption(
                        s,
                        s.label,
                        count: commissions.where((c) => c.status == s).length,
                      ),
                  ],
                ),
              ),
            ),
          if (firstLoading)
            const SliverPadding(
              padding: AppSpacing.page,
              sliver: SliverToBoxAdapter(child: SkeletonList()),
            )
          else if (_view == _View.commissions && visible.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No commissions here',
                message: 'Nothing is "${_status?.label}" right now.',
                actionLabel: 'Show all',
                onAction: () => setState(() => _status = null),
              ),
            )
          else if (_view == _View.commissions)
            CardSliverList(
              key: ValueKey('commissions-$_status'),
              itemCount: visible.length,
              itemBuilder: (context, i) =>
                  CommissionTile(commission: visible[i]),
            )
          else if (payouts.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.account_balance_outlined,
                title: 'No payouts yet',
                message:
                    'Your first payout is sent on the 15th after your '
                    'commissions are approved.',
              ),
            )
          else
            CardSliverList(
              key: const ValueKey('payouts'),
              itemCount: payouts.length,
              itemBuilder: (context, i) => _PayoutTile(payout: payouts[i]),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _NextPayoutCard extends ConsumerWidget {
  const _NextPayoutCard({required this.summary});

  final EarningsSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final text = Theme.of(context).textTheme;
    final days = Fmt.daysUntil(summary.nextPayoutDate);
    final when = days <= 0
        ? 'today'
        : (days == 1 ? 'tomorrow' : 'in $days days');

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(AppRadius.xl - 4),
        boxShadow: AppShadows.floating,
      ),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next payout',
                  style: text.bodyMedium?.copyWith(
                    color: AppColors.onNavyMuted,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  when,
                  style: text.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              value: summary.approved,
              style: text.displaySmall?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: AppRadius.control,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.bankName} ${profile.maskedAccount}',
                        style: text.bodyMedium?.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Paid on ${Fmt.date(summary.nextPayoutDate)}',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.onNavyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: AppRadius.control,
      onTap: () => AppFeedback.sheet<void>(
        context,
        builder: (context) => const _HowItWorksSheet(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'How commissions and payouts work',
                style: text.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final steps = [
      (
        Icons.person_add_alt_1_rounded,
        'You earn',
        '${Fmt.percent(CommissionRates.firstMonth)} of a customer\'s first '
            'payment, then ${Fmt.percent(CommissionRates.recurring)} of every '
            'monthly payment after that.',
      ),
      (
        Icons.hourglass_bottom_rounded,
        'In review',
        'New commissions are held for 30 days in case of refunds.',
      ),
      (
        Icons.verified_rounded,
        'Approved',
        'After 30 days the commission is approved for your next payout.',
      ),
      (
        Icons.account_balance_rounded,
        'Paid',
        'Approved amounts are sent to your bank on the 15th of each month, '
            'after ${Fmt.percent(Payout.tdsRate)} TDS.',
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How you get paid', style: text.titleLarge),
            const SizedBox(height: AppSpacing.lg + 4),
            for (var i = 0; i < steps.length; i++)
              FadeSlideIn(
                index: i + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBox(icon: steps[i].$1, size: 38),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(steps[i].$2, style: text.titleSmall),
                            const SizedBox(height: 2),
                            Text(steps[i].$3, style: text.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PayoutTile extends StatelessWidget {
  const _PayoutTile({required this.payout});

  final Payout payout;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => context.push(AppRoutes.payout(payout.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const IconBox(
              icon: Icons.account_balance_rounded,
              size: 40,
              color: AppColors.success,
              background: AppColors.successSoft,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Fmt.month(payout.period)} payout',
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Sent ${Fmt.dayMonth(payout.date)} · '
                    '${payout.commissions.length} commissions',
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Fmt.inr(payout.net),
                  style: text.titleSmall?.copyWith(fontSize: 15).tabular,
                ),
                const SizedBox(height: 3),
                StatusBadge(
                  label: payout.status.label,
                  tone: payout.status.tone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
