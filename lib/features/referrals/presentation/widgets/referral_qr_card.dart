import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/feedback.dart';
import '../../../../core/widgets/motion.dart';
import '../../../profile/data/profile_providers.dart';

/// QR showcase on the brand gradient: the code people scan in person.
class ReferralQrCard extends ConsumerWidget {
  const ReferralQrCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(AppRadius.xl - 4),
        boxShadow: AppShadows.floating,
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: 'Show QR code full screen',
            excludeSemantics: true,
            child: PressScale(
              child: GestureDetector(
                onTap: () => showReferralQr(context, profile.referralLink),
                child: Hero(
                  tag: 'referral-qr',
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ReferralQr(data: profile.referralLink, size: 150),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Scan to start a free trial',
            style: text.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            'Show this to customers in person',
            style: text.bodySmall?.copyWith(color: AppColors.onNavyMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  icon: Icons.copy_rounded,
                  label: profile.referralCode,
                  semanticLabel: 'Copy referral code ${profile.referralCode}',
                  onTap: () => AppFeedback.copy(
                    context,
                    profile.referralCode,
                    label: 'Referral code copied',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassButton(
                  icon: Icons.open_in_full_rounded,
                  label: 'Full screen',
                  onTap: () => showReferralQr(context, profile.referralLink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String? semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: PressScale(
        child: Material(
          color: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.control,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.control,
            child: SizedBox(
              height: 46,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 17, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large QR for scanning across a counter.
void showReferralQr(BuildContext context, String link) {
  AppFeedback.dialog<void>(
    context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan to start your free trial',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) => ReferralQr(
                data: link,
                size: constraints.maxWidth.clamp(0, 260).toDouble(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              link.replaceFirst('https://', ''),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ReferralQr extends StatelessWidget {
  const ReferralQr({super.key, required this.data, required this.size});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      size: size,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: AppColors.navy,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: AppColors.navy,
      ),
    );
  }
}
