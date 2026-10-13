import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/earnings_models.dart';

/// Transaction-style row: type icon, title, date, amount and status.
class CommissionTile extends StatelessWidget {
  const CommissionTile({
    super.key,
    required this.commission,
    this.showStatus = true,
    this.linkToCustomer = true,
    this.compact = false,
  });

  final Commission commission;
  final bool showStatus;
  final bool linkToCustomer;

  /// Status as small coloured text instead of a badge (Home feed).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = commission;
    final (icon, color, background) = switch (c.type) {
      CommissionType.bonus => (
        Icons.emoji_events_rounded,
        AppColors.warning,
        AppColors.warningSoft,
      ),
      CommissionType.firstMonth => (
        Icons.person_add_alt_1_rounded,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      CommissionType.recurring => (
        Icons.autorenew_rounded,
        AppColors.success,
        AppColors.successSoft,
      ),
    };
    final onTap = linkToCustomer && c.customerId != null
        ? () => context.push(AppRoutes.customer(c.customerId!))
        : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconBox(icon: icon, color: color, background: background, size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${c.type.label} · ${Fmt.dayMonth(c.date)}',
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${Fmt.inr(c.amount)}',
                  style: text.titleSmall?.copyWith(fontSize: 15).tabular,
                ),
                if (showStatus) ...[
                  const SizedBox(height: 3),
                  compact
                      ? Text(
                          c.status.label,
                          style: text.labelSmall?.copyWith(
                            color: c.status.tone.foreground,
                          ),
                        )
                      : StatusBadge(label: c.status.label, tone: c.status.tone),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
