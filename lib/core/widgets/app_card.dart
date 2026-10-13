import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'motion.dart';

/// Soft white surface with a whisper of shadow — the single card style.
/// Tappable cards scale down slightly while pressed.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg + 2),
    this.onTap,
    this.color = AppColors.surface,
    this.gradient,
    this.shadow = AppShadows.card,
    this.borderColor,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Gradient? gradient;
  final List<BoxShadow> shadow;
  final Color? borderColor;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppRadius.card;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: r,
        boxShadow: shadow,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    return onTap == null ? card : PressScale(scale: 0.985, child: card);
  }
}

/// A card holding rows separated by hairline dividers.
class AppListCard extends StatelessWidget {
  const AppListCard({super.key, required this.children, this.animate = true});

  final List<Widget> children;

  /// Stagger rows in on first build.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 20, endIndent: 20),
            animate
                ? FadeSlideIn(index: i, offset: 8, child: children[i])
                : children[i],
          ],
        ],
      ),
    );
  }
}
