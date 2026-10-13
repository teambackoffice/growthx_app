import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/nav_tile.dart';
import '../../../core/widgets/page_title.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_strip.dart';
import '../../leads/data/lead.dart';
import '../../leads/data/lead_providers.dart';
import '../../profile/data/profile_providers.dart';
import '../data/referral_providers.dart';
import 'widgets/campaign_card.dart';
import 'widgets/referral_link_card.dart';
import 'widgets/referral_qr_card.dart';

class ReferralsScreen extends ConsumerWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    final stats = ref.watch(referralStatsProvider);
    final code = ref.watch(profileProvider.select((p) => p.referralCode));
    final active = campaigns.where((c) => c.isActive).toList();
    final ended = campaigns.where((c) => !c.isActive).toList();
    final openLeads = ref
        .watch(leadsProvider)
        .where(
          (l) =>
              l.status != LeadStatus.converted && l.status != LeadStatus.lost,
        )
        .length;

    final sections = <Widget>[
      const ReferralQrCard(),
      const Padding(
        padding: EdgeInsets.only(top: AppSpacing.lg),
        child: ReferralLinkCard(
          title: 'Your referral link',
          subtitle: 'Every sign-up through it is credited to you',
        ),
      ),
      Column(
        children: [
          const SectionHeader(title: 'This month'),
          StatStrip(
            items: [
              StatItem(value: stats.clicks.toDouble(), label: 'Link clicks'),
              StatItem(value: stats.signups.toDouble(), label: 'Sign-ups'),
              StatItem(
                value: stats.conversions.toDouble(),
                label: 'Paying',
                caption: '${Fmt.percent(stats.conversionRate)} converted',
              ),
            ],
          ),
        ],
      ),
      if (active.isNotEmpty)
        Column(
          children: [
            const SectionHeader(title: 'Active campaigns'),
            for (final c in active) ...[
              CampaignCard(campaign: c),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      if (ended.isNotEmpty)
        Column(
          children: [
            SectionHeader(
              title: 'Past campaigns',
              padding: EdgeInsets.only(
                top: active.isEmpty ? AppSpacing.xl : AppSpacing.md,
                bottom: AppSpacing.md,
              ),
            ),
            for (final c in ended) ...[
              CampaignCard(campaign: c),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      Column(
        children: [
          const SectionHeader(title: 'Leads'),
          AppListCard(
            children: [
              NavTile(
                icon: Icons.add_business_rounded,
                title: 'Add a lead',
                subtitle: 'We follow up and credit the sign-up to you',
                onTap: () => context.push(AppRoutes.addLead),
              ),
              NavTile(
                icon: Icons.checklist_rounded,
                iconColor: AppColors.success,
                iconBackground: AppColors.successSoft,
                title: 'My leads',
                subtitle: openLeads == 1
                    ? '1 open lead'
                    : '$openLeads open leads',
                onTap: () => context.push(AppRoutes.leads),
              ),
            ],
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: PageTitle('Referrals', subtitle: 'Your code · $code'),
      ),
      body: ListView(
        padding: AppSpacing.pageBody,
        children: [
          for (var i = 0; i < sections.length; i++)
            FadeSlideIn(index: i, child: sections[i]),
        ],
      ),
    );
  }
}
