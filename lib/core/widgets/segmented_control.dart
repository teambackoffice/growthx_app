import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Two-or-more option switch with a white thumb that slides to the
/// selected segment.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final index = segments.indexWhere((s) => s.$1 == selected);
    final text = Theme.of(context).textTheme;
    final duration = AppMotion.of(context, AppMotion.medium);

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.control,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: duration,
            curve: AppMotion.emphasized,
            alignment: Alignment(
              segments.length == 1 ? 0 : -1 + 2 * index / (segments.length - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / segments.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: AppShadows.card,
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (value, label) in segments)
                Expanded(
                  child: Semantics(
                    selected: value == selected,
                    button: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: () => onChanged(value),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: duration,
                          style: text.labelLarge!.copyWith(
                            fontSize: 14,
                            color: value == selected
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                          child: Text(label),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
