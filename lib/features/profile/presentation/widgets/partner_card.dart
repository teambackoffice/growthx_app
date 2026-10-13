import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../earnings/data/earnings_providers.dart';
import '../../data/profile_providers.dart';

/// Partner identity on the brand gradient: avatar, tier, ID and lifetime
/// earnings. Shown at the top of More and Profile.
class PartnerCard extends ConsumerWidget {
  const PartnerCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider);
    final lifetime = ref.watch(earningsSummaryProvider).lifetime;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadius.xl - 4);

    final card = Container(
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: radius,
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: InitialsAvatar(
                        name: p.name,
                        size: 52,
                        gradient: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md + 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: text.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            p.partnerId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: AppColors.onNavyMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: AppRadius.pill,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.workspace_premium_rounded,
                                        size: 13,
                                        color: Color(0xFFD7DBEF),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          p.tier,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: text.labelSmall?.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.onNavyMuted,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: AppRadius.control,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Figure(
                          label: 'Lifetime earnings',
                          child: AnimatedAmount(
                            value: lifetime,
                            style: text.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _Figure(
                          label: 'Partner since',
                          child: Text(
                            Fmt.monthYear(p.memberSince),
                            style: text.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return onTap == null ? card : PressScale(scale: 0.985, child: card);
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.onNavyMuted),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }
}
