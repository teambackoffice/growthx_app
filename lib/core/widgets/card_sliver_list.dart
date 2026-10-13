import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'motion.dart';

/// A lazily built list rendered inside a single card, for long lists
/// (customers, commissions, notifications) inside a [CustomScrollView].
/// The first rows stagger in; rows scrolled into view later appear at once.
class CardSliverList extends StatelessWidget {
  const CardSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppSpacing.page,
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.card,
        ),
        sliver: SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          sliver: SliverList.separated(
            itemCount: itemCount,
            separatorBuilder: (_, _) =>
                const Divider(indent: 20, endIndent: 20),
            // Transparent Material so ink ripples paint above the decoration.
            itemBuilder: (context, i) => FadeSlideIn(
              index: i,
              offset: 8,
              child: Material(
                type: MaterialType.transparency,
                child: itemBuilder(context, i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
