import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/card_sliver_list.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/motion.dart';
import '../data/app_notification.dart';
import '../data/notification_providers.dart';

/// List filter: everything, unread only, or one category.
sealed class _Filter {
  const _Filter();
}

class _All extends _Filter {
  const _All();
}

class _Unread extends _Filter {
  const _Unread();
}

class _Category extends _Filter {
  const _Category(this.category);

  final NotificationCategory category;

  @override
  bool operator ==(Object other) =>
      other is _Category && other.category == category;

  @override
  int get hashCode => category.hashCode;
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with FirstLoadMixin {
  _Filter _filter = const _All();

  bool _matches(AppNotification n) => switch (_filter) {
    _All() => true,
    _Unread() => !n.read,
    _Category(:final category) => n.category == category,
  };

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final visible = all.where(_matches).toList();

    final today = <AppNotification>[];
    final week = <AppNotification>[];
    final earlier = <AppNotification>[];
    for (final n in visible) {
      final age = -Fmt.daysUntil(n.time);
      (age == 0 ? today : (age < 7 ? week : earlier)).add(n);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: unread == 0
                ? null
                : () => ref.read(notificationsProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: FilterChipBar<_Filter>(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
                options: [
                  const FilterOption(_All(), 'All'),
                  FilterOption(const _Unread(), 'Unread', count: unread),
                  for (final c in NotificationCategory.values)
                    FilterOption(_Category(c), c.label),
                ],
              ),
            ),
          ),
          if (firstLoading)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: SkeletonList(rows: 4)),
            )
          else if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.notifications_none_rounded,
                title: _filter is _Unread
                    ? 'You\'re all caught up'
                    : 'No notifications',
                message: _filter is _Unread
                    ? 'New updates about customers and earnings will show '
                          'up here.'
                    : 'Nothing in this category yet.',
                actionLabel: _filter is _All ? null : 'Show all',
                onAction: () => setState(() => _filter = const _All()),
              ),
            )
          else
            for (final (label, items) in [
              ('Today', today),
              ('This week', week),
              ('Earlier', earlier),
            ])
              if (items.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                    child: Text(
                      label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                CardSliverList(
                  itemCount: items.length,
                  itemBuilder: (context, i) =>
                      _NotificationTile(notification: items[i]),
                ),
              ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  void _open(BuildContext context, WidgetRef ref) {
    ref.read(notificationsProvider.notifier).markRead(notification.id);
    final route = notification.route;
    if (route == null) return;
    const tabs = {
      AppRoutes.home,
      AppRoutes.customers,
      AppRoutes.referrals,
      AppRoutes.earnings,
      AppRoutes.more,
    };
    // Tabs replace the stack; detail screens open on top of this list.
    tabs.contains(route) ? context.go(route) : context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final text = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.curve,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: AppRadius.control,
        color: n.read
            ? AppColors.primarySoft.withValues(alpha: 0)
            : AppColors.primarySoft.withValues(alpha: 0.6),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.control,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context, ref),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBox(
                  icon: n.category.icon,
                  color: n.category.color,
                  background: n.category.background,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: n.read
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        n.body,
                        style: text.bodyMedium?.copyWith(
                          color: n.read
                              ? AppColors.textTertiary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(Fmt.timeAgo(n.time), style: text.bodySmall),
                    ],
                  ),
                ),
                SizedBox(
                  width: 18,
                  child: n.read
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 8, left: 8),
                          child: Semantics(
                            label: 'Unread',
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
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
