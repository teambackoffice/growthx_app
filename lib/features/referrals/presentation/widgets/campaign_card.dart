import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/feedback.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../profile/data/profile_providers.dart';
import '../../data/referral_models.dart';

class CampaignCard extends ConsumerWidget {
  const CampaignCard({super.key, required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(profileProvider.select((p) => p.referralCode));
    final link = campaign.link(code);
    final text = Theme.of(context).textTheme;
    final c = campaign;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(c.name, style: text.titleMedium)),
              const SizedBox(width: AppSpacing.sm),
              c.isActive
                  ? const StatusBadge(label: 'Active', tone: BadgeTone.success)
                  : const StatusBadge(label: 'Ended', tone: BadgeTone.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(c.offer, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              _Meta(icon: Icons.sell_outlined, label: c.code, emphasise: true),
              _Meta(
                icon: Icons.event_outlined,
                label: c.isActive
                    ? 'Ends ${Fmt.dayMonth(c.endsOn)}'
                    : 'Ended ${Fmt.dayMonth(c.endsOn)}',
              ),
              _Meta(
                icon: Icons.insights_outlined,
                label: '${c.signups} sign-ups · ${c.conversions} paying',
              ),
            ],
          ),
          if (c.isActive) ...[
            const SizedBox(height: AppSpacing.md),
            _TimeLeftBar(campaign: c),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => AppFeedback.copy(
                      context,
                      link,
                      label: 'Campaign link copied',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      backgroundColor: AppColors.surfaceMuted,
                      side: BorderSide.none,
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy link'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => AppFeedback.share(
                      context,
                      text:
                          '${c.name}: ${c.offer}. Sign up with my link: $link',
                      subject: c.name,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.primarySoft,
                      side: BorderSide.none,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// How much of the campaign has run; grows in on first build.
class _TimeLeftBar extends StatelessWidget {
  const _TimeLeftBar({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final total = campaign.endsOn.difference(campaign.startsOn).inHours;
    final elapsed = DateTime.now().difference(campaign.startsOn).inHours;
    final progress = total <= 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: AppMotion.of(context, const Duration(milliseconds: 700)),
      curve: AppMotion.curve,
      builder: (context, value, _) => ClipRRect(
        borderRadius: AppRadius.pill,
        child: LinearProgressIndicator(
          value: value,
          minHeight: 5,
          backgroundColor: AppColors.surfaceMuted,
          color: AppColors.primary,
          semanticsLabel: 'Campaign progress',
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.icon,
    required this.label,
    this.emphasise = false,
  });

  final IconData icon;
  final String label;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: emphasise
                ? text.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 0.6,
                  )
                : text.bodySmall,
          ),
        ),
      ],
    );
  }
}
