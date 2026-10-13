import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'motion.dart';

/// Compact KPI tile: small tinted icon, animated figure, label.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.format,
    this.caption,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.primarySoft,
    this.onTap,
  });

  final IconData icon;
  final double value;
  final String Function(num value)? format;
  final String label;
  final String? caption;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              value: value,
              format: format ?? (v) => '${v.round()}',
              style: text.titleLarge?.copyWith(fontSize: 20).tabular,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: text.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null)
            Text(
              caption!,
              style: text.bodySmall?.copyWith(fontSize: 11.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
