import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/section_header.dart';
import '../../earnings/data/earnings_models.dart';
import '../data/profile_providers.dart';
import 'widgets/partner_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.editProfile),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: AppSpacing.pageBody,
        children: [
          const FadeSlideIn(child: PartnerCard()),
          const SectionHeader(title: 'Personal details'),
          AppListCard(
            children: [
              InfoRow(
                label: 'Partner ID',
                value: p.partnerId,
                trailing: const _CopyHint(),
                onTap: () => AppFeedback.copy(
                  context,
                  p.partnerId,
                  label: 'Partner ID copied',
                ),
              ),
              InfoRow(label: 'Email', value: p.email),
              InfoRow(label: 'Phone', value: p.phone),
              InfoRow(label: 'City', value: p.city),
            ],
          ),
          const SectionHeader(title: 'Business'),
          AppListCard(
            children: [
              InfoRow(label: 'Company', value: p.company),
              InfoRow(label: 'GSTIN', value: p.gstin),
              InfoRow(
                label: 'PAN',
                value: '${p.pan.substring(0, 2)}••••${p.pan.substring(6)}',
              ),
            ],
          ),
          const SectionHeader(title: 'Payout account'),
          AppListCard(
            children: [
              InfoRow(label: 'Bank', value: p.bankName),
              InfoRow(label: 'Account', value: p.maskedAccount),
              InfoRow(label: 'IFSC', value: p.ifsc),
              InfoRow(label: 'UPI ID', value: p.upiId),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, AppSpacing.sm, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 15,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'For your security, bank details can only be changed by '
                    'partner support.',
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Commission plan'),
          AppListCard(
            children: [
              InfoRow(
                label: 'First month',
                value: '${Fmt.percent(CommissionRates.firstMonth)} of payment',
              ),
              InfoRow(
                label: 'Every month after',
                value: '${Fmt.percent(CommissionRates.recurring)} of payment',
              ),
              InfoRow(label: 'Payout day', value: '15th of each month'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CopyHint extends StatelessWidget {
  const _CopyHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 2),
      child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textDisabled),
    );
  }
}
