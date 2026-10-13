import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'motion.dart';

class FilterOption<T> {
  const FilterOption(this.value, this.label, {this.count});

  final T value;
  final String label;
  final int? count;
}

/// Horizontally scrolling single-select pills. The selected pill fills with
/// navy; colours animate between states.
class FilterChipBar<T> extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<FilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.page,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => AppChoicePill(
          label: options[i].label,
          count: options[i].count,
          selected: options[i].value == selected,
          onTap: () => onSelected(options[i].value),
        ),
      ),
    );
  }
}

/// One selectable pill. Also used standalone (plan picker, lead status).
class AppChoicePill extends StatelessWidget {
  const AppChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final duration = AppMotion.of(context, AppMotion.medium);
    final fg = selected ? Colors.white : AppColors.textSecondary;

    return Semantics(
      selected: selected,
      button: true,
      child: PressScale(
        scale: 0.95,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.curve,
          height: 38,
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : AppColors.surface,
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.border,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.pill,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: duration,
                      style: text.labelMedium!.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                      child: Text(label),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: duration,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.16)
                              : AppColors.surfaceMuted,
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          '$count',
                          style: text.labelSmall?.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
