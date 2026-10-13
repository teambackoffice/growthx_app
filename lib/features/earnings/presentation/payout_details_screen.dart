import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/earnings_models.dart';
import '../data/earnings_providers.dart';
import 'widgets/commission_tile.dart';

class PayoutDetailsScreen extends ConsumerWidget {
  const PayoutDetailsScreen({super.key, required this.payoutId});

  final String payoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payout = ref.watch(payoutByIdProvider(payoutId));
    if (payout == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Payout not found',
            message: 'We couldn\'t find this payout.',
            actionLabel: 'Back to earnings',
            onAction: () => context.go(AppRoutes.earnings),
          ),
        ),
      );
    }

    final text = Theme.of(context).textTheme;
    final p = payout;
    final total = text.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Payout details')),
      body: ListView(
        padding: AppSpacing.pageBody,
        children: [
          FadeSlideIn(
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1),
                    duration: AppMotion.of(context, AppMotion.slow),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.successSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('${Fmt.month(p.period)} payout', style: text.bodyMedium),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedAmount(
                      value: p.net,
                      format: Fmt.inrExact,
                      style: text.displaySmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatusBadge(label: p.status.label, tone: p.status.tone),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Transfer'),
          AppListCard(
            children: [
              InfoRow(
                label: p.status == PayoutStatus.paid ? 'Paid on' : 'Expected',
                value: Fmt.date(p.date),
              ),
              InfoRow(label: 'Sent to', value: p.method),
              InfoRow(
                label: 'Reference',
                value: p.reference,
                trailing: const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: AppColors.textDisabled,
                  ),
                ),
                onTap: () => AppFeedback.copy(
                  context,
                  p.reference,
                  label: 'Reference copied',
                ),
              ),
            ],
          ),
          const SectionHeader(title: 'Breakdown'),
          AppListCard(
            children: [
              InfoRow(
                label: 'Commissions (${p.commissions.length})',
                value: Fmt.inrExact(p.gross),
              ),
              InfoRow(
                label: 'TDS (${Fmt.percent(Payout.tdsRate)})',
                value: '− ${Fmt.inrExact(p.tds)}',
              ),
              InfoRow(
                label: 'Amount paid',
                value: Fmt.inrExact(p.net),
                valueStyle: total,
              ),
            ],
          ),
          const SectionHeader(title: 'Included commissions'),
          AppListCard(
            children: [
              for (final c in p.commissions)
                CommissionTile(commission: c, showStatus: false),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () => AppFeedback.share(
              context,
              subject: 'GrowthX payout ${p.reference}',
              text:
                  'GrowthX partner payout ${p.reference}\n'
                  'Period: ${Fmt.monthYear(p.period)}\n'
                  'Commissions: ${Fmt.inrExact(p.gross)}\n'
                  'TDS: ${Fmt.inrExact(p.tds)}\n'
                  'Paid: ${Fmt.inrExact(p.net)} on ${Fmt.date(p.date)}',
            ),
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Share payout summary'),
          ),
        ],
      ),
    );
  }
}
