import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'motion.dart';

class StatItem {
  const StatItem({
    required this.value,
    required this.label,
    this.format,
    this.caption,
    this.dotColor,
  });

  final double value;
  final String Function(num value)? format;
  final String label;
  final String? caption;

  /// Small colour key before the label (e.g. status colour).
  final Color? dotColor;
}

/// Two to four animated figures side by side in one card.
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.items});

  final List<StatItem> items;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const VerticalDivider(indent: 4, endIndent: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedAmount(
                          value: items[i].value,
                          format: items[i].format ?? (v) => '${v.round()}',
                          style: text.titleLarge
                              ?.copyWith(fontSize: 18)
                              .tabular,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (items[i].dotColor != null) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: items[i].dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              items[i].label,
                              maxLines: 1,
                              style: text.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (items[i].caption != null)
                        Text(
                          items[i].caption!,
                          style: text.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
