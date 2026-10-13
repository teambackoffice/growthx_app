import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

enum BadgeTone {
  success(AppColors.success, AppColors.successSoft),
  warning(AppColors.warning, AppColors.warningSoft),
  danger(AppColors.danger, AppColors.dangerSoft),
  info(AppColors.info, AppColors.infoSoft),
  primary(AppColors.primary, AppColors.primarySoft),
  neutral(AppColors.textSecondary, AppColors.surfaceMuted);

  const BadgeTone(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

/// Status chip. Colour and label animate when the status changes.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.curve,
      padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: duration,
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tone.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: AnimatedSwitcher(
              duration: duration,
              child: Text(
                label,
                key: ValueKey(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tone.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
