import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/metric_tile.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/section_header.dart';
import '../../customers/data/customer.dart';
import '../../customers/data/customer_providers.dart';
import '../../earnings/data/earnings_providers.dart';
import '../../earnings/presentation/widgets/commission_tile.dart';
import '../../notifications/data/notification_providers.dart';
import '../../profile/data/profile_providers.dart';
import '../../referrals/presentation/widgets/referral_link_card.dart';
import 'widgets/earnings_overview_card.dart';
import 'widgets/home_skeleton.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        bottom: false,
        child: FirstLoad(placeholder: HomeSkeleton(), child: _HomeContent()),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newCustomers = ref.watch(newCustomersThisMonthProvider);
    final endingSoon = ref.watch(trialsEndingSoonProvider);
    final activity = ref.watch(recentCustomersProvider).take(4).toList();
    final commissions = ref.watch(commissionsProvider).take(3).toList();
    final filter = ref.read(customerFilterProvider.notifier);

    void openSegment(CustomerSegment segment) {
      filter.showSegment(segment);
      context.go(AppRoutes.customers);
    }

    final sections = <Widget>[
      const _Header(),
      EarningsOverviewCard(onTap: () => context.go(AppRoutes.earnings)),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MetricTile(
                icon: Icons.person_add_alt_1_rounded,
                iconColor: AppColors.success,
                iconBackground: AppColors.successSoft,
                value: newCustomers.length.toDouble(),
                label: 'New customers',
                caption: 'This month',
                onTap: () => openSegment(CustomerSegment.newThisMonth),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricTile(
                icon: Icons.hourglass_bottom_rounded,
                iconColor: AppColors.warning,
                iconBackground: AppColors.warningSoft,
                value: endingSoon.length.toDouble(),
                label: 'Trials ending',
                caption: 'Next 7 days',
                onTap: () => openSegment(CustomerSegment.trialsEndingSoon),
              ),
            ),
          ],
        ),
      ),
      const ReferralLinkCard(
        title: 'Invite & earn',
        subtitle: '50% of their first month, 20% every month after',
      ),
      Column(
        children: [
          SectionHeader(
            title: 'Customer activity',
            actionLabel: 'See all',
            onAction: () {
              filter.reset();
              context.go(AppRoutes.customers);
            },
          ),
          AppListCard(
            children: [for (final c in activity) _ActivityTile(customer: c)],
          ),
        ],
      ),
      Column(
        children: [
          SectionHeader(
            title: 'Recent commissions',
            actionLabel: 'See all',
            onAction: () => context.go(AppRoutes.earnings),
          ),
          AppListCard(
            children: [
              for (final k in commissions)
                CommissionTile(commission: k, compact: true),
            ],
          ),
        ],
      ),
    ];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => Future.delayed(const Duration(milliseconds: 600)),
      child: ListView(
        padding: AppSpacing.pageBody,
        children: [
          for (var i = 0; i < sections.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 8 : (i <= 3 ? 16 : 0)),
              child: FadeSlideIn(index: i, child: sections[i]),
            ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Profile',
          child: PressScale(
            scale: 0.92,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.push(AppRoutes.profile),
              child: InitialsAvatar(
                name: profile.name,
                size: 44,
                gradient: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: text.bodySmall),
              Text(
                profile.firstName,
                style: text.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
          excludeSemantics: true,
          child: PressScale(
            scale: 0.92,
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push(AppRoutes.notifications),
                child: SizedBox.square(
                  dimension: 44,
                  child: Center(
                    child: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      offset: const Offset(6, -6),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.customer});

  final Customer customer;

  (IconData, Color, String) get _event => switch (customer.status) {
    SubscriptionStatus.trial => (
      Icons.rocket_launch_outlined,
      AppColors.info,
      'Started a ${customer.plan.label} trial',
    ),
    SubscriptionStatus.active => (
      Icons.verified_rounded,
      AppColors.success,
      'Subscribed to ${customer.plan.label}',
    ),
    SubscriptionStatus.pastDue => (
      Icons.error_outline_rounded,
      AppColors.warning,
      'Renewal payment overdue',
    ),
    SubscriptionStatus.cancelled => (
      Icons.cancel_outlined,
      AppColors.textTertiary,
      'Cancelled subscription',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (icon, color, label) = _event;
    return InkWell(
      onTap: () => context.push(AppRoutes.customer(customer.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                InitialsAvatar(name: customer.businessName, size: 40),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                ),
              ],
            ),
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
                  Text(
                    label,
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(Fmt.dayMonth(customer.joinedOn), style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
