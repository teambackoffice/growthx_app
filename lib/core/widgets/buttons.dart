import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'motion.dart';

/// Full-width gradient call-to-action. Scales on press and cross-fades to
/// a spinner while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final text = Theme.of(context).textTheme;
    final content = loading
        ? const SizedBox.square(
            key: ValueKey('loading'),
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
        : Row(
            key: const ValueKey('label'),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$label, loading' : null,
      child: PressScale(
        enabled: enabled && !loading,
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.medium),
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: enabled ? AppGradients.primary : null,
            color: enabled ? null : AppColors.border,
            borderRadius: AppRadius.control,
            boxShadow: enabled ? AppShadows.primaryGlow : const [],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadius.control,
              // Ignore taps while busy, but stay visually enabled.
              onTap: enabled && !loading ? onPressed : null,
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.fast),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round icon action with a caption underneath (Call, Email, Copy…).
class CircleAction extends StatelessWidget {
  const CircleAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: PressScale(
        scale: 0.92,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.control,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: filled ? AppGradients.primary : null,
                    color: filled ? null : AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: filled
                        ? AppShadows.primaryGlow
                        : AppShadows.card,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: filled ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
