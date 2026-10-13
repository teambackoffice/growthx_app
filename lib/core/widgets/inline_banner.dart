import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'status_badge.dart';

/// Tinted message box for inline errors, notices and tips.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.message,
    this.tone = BadgeTone.info,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final BadgeTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.control,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: tone.foreground),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: tone.foreground, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
