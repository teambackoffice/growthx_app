import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/feedback.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../profile/data/profile_providers.dart';
import 'copy_link_field.dart';
import 'share_referral_button.dart';

String referralShareMessage(String link) =>
    'I use GrowthX to run my business — billing, customers and reports in '
    'one app. Start your free trial with my link: $link';

/// The partner's referral link: one-tap Copy and a prominent Share button.
class ReferralLinkCard extends ConsumerWidget {
  const ReferralLinkCard({super.key, this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(profileProvider.select((p) => p.referralLink));
    final text = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                const IconBox(
                  icon: Icons.card_giftcard_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: text.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: text.bodySmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          CopyLinkField(
            value: link,
            display: link.replaceFirst('https://', ''),
          ),
          const SizedBox(height: AppSpacing.md),
          ShareReferralButton(
            onPressed: () => AppFeedback.share(
              context,
              text: referralShareMessage(link),
              subject: 'Try GrowthX for your business',
            ),
          ),
        ],
      ),
    );
  }
}
