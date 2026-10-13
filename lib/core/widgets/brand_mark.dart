import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo + wordmark. [onDark] for navy/gradient backgrounds.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: onDark ? null : AppGradients.primary,
            color: onDark ? Colors.white.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(10),
            border: onDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.18))
                : null,
          ),
          child: const Icon(
            Icons.trending_up_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                const TextSpan(text: 'GrowthX'),
                TextSpan(
                  text: ' Partner',
                  style: TextStyle(
                    color: onDark
                        ? AppColors.onNavyMuted
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: onDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
