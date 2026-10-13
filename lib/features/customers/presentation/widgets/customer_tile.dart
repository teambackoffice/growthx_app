import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/customer.dart';

/// One customer row: avatar, name, plan + context line, status.
class CustomerTile extends StatelessWidget {
  const CustomerTile({
    super.key,
    required this.customer,
    this.showTrialEnd = false,
  });

  final Customer customer;

  /// Emphasise the trial end date instead of the status badge (Home).
  final bool showTrialEnd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final trialEnd = customer.trialEndsOn;
    final emphasiseTrial = showTrialEnd && trialEnd != null;

    return InkWell(
      onTap: () => context.push(AppRoutes.customer(customer.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            InitialsAvatar(name: customer.businessName),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.businessName,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${customer.plan.label} · ${_context(customer)}',
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (emphasiseTrial)
              _TrialEnds(date: trialEnd)
            else
              StatusBadge(
                label: customer.status.label,
                tone: customer.status.tone,
              ),
          ],
        ),
      ),
    );
  }

  static String _context(Customer c) {
    switch (c.status) {
      case SubscriptionStatus.trial:
        final end = c.trialEndsOn;
        return end == null
            ? 'On trial'
            : 'Trial ends ${Fmt.relativeDay(end).toLowerCase()}';
      case SubscriptionStatus.active:
        return c.contactName;
      case SubscriptionStatus.pastDue:
        return 'Payment overdue';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class _TrialEnds extends StatelessWidget {
  const _TrialEnds({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final days = Fmt.daysUntil(date);
    final urgent = days <= 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          days <= 0 ? 'Today' : (days == 1 ? '1 day' : '$days days'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: urgent ? AppColors.warning : AppColors.textPrimary,
          ),
        ),
        Text('left', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
