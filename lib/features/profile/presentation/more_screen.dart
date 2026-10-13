import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/nav_tile.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/data/auth_providers.dart';
import '../../leads/data/lead.dart';
import '../../leads/data/lead_providers.dart';
import '../../notifications/data/notification_providers.dart';
import '../data/profile_providers.dart';
import 'widgets/help_sheet.dart';
import 'widgets/partner_card.dart';

const supportEmail = 'partners@teambackoffice.com';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppFeedback.confirm(
      context,
      title: 'Log out?',
      message:
          'You\'ll need to sign in again to see your customers and '
          'earnings.',
      confirmLabel: 'Log out',
      destructive: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed) ref.read(authProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final prefs = ref.watch(notificationPreferencesProvider);
    final prefsNotifier = ref.read(notificationPreferencesProvider.notifier);
    final unread = ref.watch(unreadNotificationCountProvider);
    final openLeads = ref
        .watch(leadsProvider)
        .where(
          (l) =>
              l.status != LeadStatus.converted && l.status != LeadStatus.lost,
        )
        .length;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: AppSpacing.pageBody,
        children: [
          FadeSlideIn(
            child: PartnerCard(onTap: () => context.push(AppRoutes.profile)),
          ),
          const SectionHeader(title: 'Your work'),
          AppListCard(
            children: [
              NavTile(
                icon: Icons.list_alt_rounded,
                title: 'Leads',
                subtitle: 'Track businesses you\'ve referred',
                trailing: openLeads > 0 ? CountBadge(count: openLeads) : null,
                onTap: () => context.push(AppRoutes.leads),
              ),
              NavTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                trailing: unread > 0 ? CountBadge(count: unread) : null,
                onTap: () => context.push(AppRoutes.notifications),
              ),
              NavTile(
                icon: Icons.account_balance_outlined,
                title: 'Payout account',
                subtitle: '${profile.bankName} ${profile.maskedAccount}',
                onTap: () => context.push(AppRoutes.profile),
              ),
            ],
          ),
          const SectionHeader(title: 'Notify me about'),
          AppListCard(
            children: [
              _SwitchTile(
                icon: Icons.payments_outlined,
                title: 'Commissions & payouts',
                value: prefs.commissions,
                onChanged: (v) =>
                    prefsNotifier.set(prefs.copyWith(commissions: v)),
              ),
              _SwitchTile(
                icon: Icons.hourglass_bottom_rounded,
                title: 'Trials ending soon',
                value: prefs.trialReminders,
                onChanged: (v) =>
                    prefsNotifier.set(prefs.copyWith(trialReminders: v)),
              ),
              _SwitchTile(
                icon: Icons.campaign_outlined,
                title: 'New campaigns & updates',
                value: prefs.productUpdates,
                onChanged: (v) =>
                    prefsNotifier.set(prefs.copyWith(productUpdates: v)),
              ),
            ],
          ),
          const SectionHeader(title: 'Help'),
          AppListCard(
            children: [
              NavTile(
                icon: Icons.help_outline_rounded,
                title: 'FAQs',
                onTap: () => AppFeedback.sheet<void>(
                  context,
                  scrollControlled: true,
                  builder: (_) => const HelpSheet(),
                ),
              ),
              NavTile(
                icon: Icons.support_agent_outlined,
                title: 'Contact partner support',
                subtitle: supportEmail,
                onTap: () => AppFeedback.open(
                  context,
                  Uri(
                    scheme: 'mailto',
                    path: supportEmail,
                    query: 'subject=Partner ${profile.partnerId}',
                  ),
                  value: supportEmail,
                ),
              ),
              NavTile(
                icon: Icons.description_outlined,
                title: 'Terms & privacy',
                onTap: () => AppFeedback.dialog<void>(
                  context,
                  builder: (context) => AlertDialog(
                    title: const Text('Terms & privacy'),
                    content: const Text(
                      'Commissions are paid under the GrowthX Partner '
                      'Agreement. Customer details shown here are for '
                      'follow-up only and must not be shared.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppListCard(
            children: [
              NavTile(
                icon: Icons.logout_rounded,
                title: 'Log out',
                destructive: true,
                onTap: () => _logout(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'GrowthX Partner · version 0.1.0',
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: NavTile(
        icon: icon,
        title: title,
        showChevron: false,
        onTap: () => onChanged(!value),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
