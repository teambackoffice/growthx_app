import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum NotificationCategory {
  commission(
    'Commissions',
    Icons.payments_outlined,
    AppColors.success,
    AppColors.successSoft,
  ),
  payout(
    'Payouts',
    Icons.account_balance_outlined,
    AppColors.primary,
    AppColors.primarySoft,
  ),
  customer(
    'Customers',
    Icons.storefront_outlined,
    AppColors.info,
    AppColors.infoSoft,
  ),
  trial(
    'Trials',
    Icons.hourglass_bottom_rounded,
    AppColors.warning,
    AppColors.warningSoft,
  ),
  account(
    'Account',
    Icons.campaign_outlined,
    AppColors.textSecondary,
    AppColors.surfaceMuted,
  );

  const NotificationCategory(
    this.label,
    this.icon,
    this.color,
    this.background,
  );

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
    this.route,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String body;
  final DateTime time;
  final bool read;

  /// Where tapping the notification takes the user, if anywhere.
  final String? route;

  AppNotification markRead() => AppNotification(
    id: id,
    category: category,
    title: title,
    body: body,
    time: time,
    read: true,
    route: route,
  );
}
