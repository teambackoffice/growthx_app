import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/motion.dart';

/// Shimmering outline of the dashboard shown during the first load.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading dashboard',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: AppSpacing.pageBody.copyWith(top: 12),
        child: Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SkeletonBox(width: 44, height: 44, radius: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 90, height: 10),
                        SizedBox(height: 8),
                        SkeletonBox(width: 120, height: 16),
                      ],
                    ),
                  ),
                  SkeletonBox(width: 44, height: 44, radius: 22),
                ],
              ),
              const SizedBox(height: 20),
              const SkeletonBox(height: 214, radius: 24),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    const Expanded(child: SkeletonBox(height: 112, radius: 20)),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              const SkeletonBox(height: 190, radius: 20),
            ],
          ),
        ),
      ),
    );
  }
}
