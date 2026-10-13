import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../earnings/data/earnings_models.dart';
import '../../earnings/data/earnings_providers.dart';
import '../../earnings/presentation/widgets/commission_tile.dart';
import '../data/customer.dart';
import '../data/customer_providers.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  const CustomerDetailsScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerByIdProvider(customerId));

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Customer not found',
            message: 'This customer may have been removed.',
            actionLabel: 'View all customers',
            onAction: () => context.go(AppRoutes.customers),
          ),
        ),
      );
    }

    final commissions = ref.watch(commissionsForCustomerProvider(customerId));
    final earned = commissions.fold<double>(0, (sum, c) => sum + c.amount);
    final c = customer;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: ListView(
        padding: AppSpacing.pageBody,
        children: [
          FadeSlideIn(child: _Header(customer: c)),
          if (_notice(c) case final notice?) ...[
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(index: 1, child: notice),
          ],
          const SectionHeader(title: 'Subscription'),
          AppListCard(
            children: [
              InfoRow(
                label: 'Plan',
                value:
                    '${c.plan.label} · ${Fmt.inr(c.plan.monthlyPrice)}/month',
              ),
              InfoRow(label: 'Joined', value: Fmt.date(c.joinedOn)),
              if (c.trialEndsOn != null)
                InfoRow(label: 'Trial ends', value: Fmt.date(c.trialEndsOn!)),
              if (c.renewsOn != null &&
                  c.status != SubscriptionStatus.cancelled)
                InfoRow(
                  label: c.status == SubscriptionStatus.pastDue
                      ? 'Payment was due'
                      : 'Renews on',
                  value: Fmt.date(c.renewsOn!),
                ),
              InfoRow(label: 'Signed up via', value: c.source),
            ],
          ),
          SectionHeader(
            title: 'Your commission',
            actionLabel: earned > 0 ? '${Fmt.inr(earned)} earned' : null,
            onAction: earned > 0 ? () => context.go(AppRoutes.earnings) : null,
          ),
          if (commissions.isEmpty)
            AppCard(
              child: Row(
                children: [
                  const IconBox(icon: Icons.savings_outlined),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      c.status == SubscriptionStatus.trial
                          ? 'You\'ll earn ${Fmt.inr(c.plan.monthlyPrice * CommissionRates.firstMonth)} '
                                'when they pay for their first month.'
                          : 'No commissions from this customer yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            AppListCard(
              children: [
                for (final k in commissions)
                  CommissionTile(commission: k, linkToCustomer: false),
              ],
            ),
          const SectionHeader(title: 'Contact'),
          AppListCard(
            children: [
              InfoRow(label: 'Contact person', value: c.contactName),
              InfoRow(
                label: 'Phone',
                value: c.phone,
                trailing: const _CopyIcon(),
                onTap: () =>
                    AppFeedback.copy(context, c.phone, label: 'Phone copied'),
              ),
              InfoRow(
                label: 'Email',
                value: c.email,
                trailing: const _CopyIcon(),
                onTap: () =>
                    AppFeedback.copy(context, c.email, label: 'Email copied'),
              ),
              InfoRow(label: 'City', value: c.city),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _notice(Customer c) {
    switch (c.status) {
      case SubscriptionStatus.trial when c.trialEndsOn != null:
        final days = Fmt.daysUntil(c.trialEndsOn!);
        final when = days <= 0
            ? 'today'
            : (days == 1 ? 'tomorrow' : 'in $days days');
        return InlineBanner(
          tone: days <= 2 ? BadgeTone.warning : BadgeTone.info,
          icon: Icons.hourglass_bottom_rounded,
          message: 'Trial ends $when. A quick call now helps them pick a plan.',
        );
      case SubscriptionStatus.pastDue:
        return const InlineBanner(
          tone: BadgeTone.danger,
          icon: Icons.error_outline_rounded,
          message:
              'Renewal payment is overdue. Your commission is on hold until '
              'they pay.',
        );
      default:
        return null;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = customer;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        children: [
          InitialsAvatar(name: c.businessName, size: 68),
          const SizedBox(height: AppSpacing.md),
          Text(
            c.businessName,
            style: text.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '${c.contactName} · ${c.city}',
            style: text.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          StatusBadge(label: c.status.label, tone: c.status.tone),
          const SizedBox(height: AppSpacing.lg + 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CircleAction(
                  icon: Icons.call_rounded,
                  label: 'Call',
                  filled: true,
                  onTap: () => AppFeedback.open(
                    context,
                    Uri(scheme: 'tel', path: c.phone.replaceAll(' ', '')),
                    value: c.phone,
                  ),
                ),
              ),
              Expanded(
                child: CircleAction(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  onTap: () => AppFeedback.open(
                    context,
                    Uri(scheme: 'mailto', path: c.email),
                    value: c.email,
                  ),
                ),
              ),
              Expanded(
                child: CircleAction(
                  icon: Icons.copy_rounded,
                  label: 'Copy phone',
                  onTap: () =>
                      AppFeedback.copy(context, c.phone, label: 'Phone copied'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CopyIcon extends StatelessWidget {
  const _CopyIcon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 2),
      child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textDisabled),
    );
  }
}
