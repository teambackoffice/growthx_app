import '../../../app/routes.dart';
import '../../../core/utils/demo_dates.dart';
import 'app_notification.dart';

final dummyNotifications = <AppNotification>[
  AppNotification(
    id: 'n01',
    category: NotificationCategory.trial,
    title: 'Trial ends tomorrow',
    body:
        'Sunrise Dental Clinic\'s Growth trial ends tomorrow. A quick call '
        'now can help them convert.',
    time: hoursAgo(1),
    route: AppRoutes.customer('c07'),
  ),
  AppNotification(
    id: 'n02',
    category: NotificationCategory.commission,
    title: 'Bonus earned: ₹2,500',
    body:
        'You reached 5 sign-ups in Diwali Business Boost. Your bonus is '
        'under review.',
    time: hoursAgo(5),
    route: AppRoutes.earnings,
  ),
  AppNotification(
    id: 'n03',
    category: NotificationCategory.customer,
    title: 'New customer signed up',
    body: 'Hilltop Bakers started a Starter trial using your referral link.',
    time: hoursAgo(26),
    route: AppRoutes.customer('c10'),
  ),
  AppNotification(
    id: 'n04',
    category: NotificationCategory.customer,
    title: 'Payment due',
    body:
        'Urban Threads Boutique\'s renewal payment failed. Commission is on '
        'hold until it\'s paid.',
    time: hoursAgo(50),
    read: true,
    route: AppRoutes.customer('c05'),
  ),
  AppNotification(
    id: 'n05',
    category: NotificationCategory.commission,
    title: 'Commission earned: ₹1,250',
    body: 'Lotus Wellness Spa paid their first month on the Growth plan.',
    time: hoursAgo(24 * 6),
    read: true,
    route: AppRoutes.earnings,
  ),
  AppNotification(
    id: 'n06',
    category: NotificationCategory.payout,
    title: 'Payout sent',
    body: 'Your payout has been transferred to HDFC Bank •••• 7812.',
    time: daysFromNow(-27, hour: 9, minute: 30),
    read: true,
    route: AppRoutes.payout('p03'),
  ),
  AppNotification(
    id: 'n07',
    category: NotificationCategory.account,
    title: 'New campaign: Diwali Business Boost',
    body: 'Share the festive offer with your network — 25% off for 3 months.',
    time: daysFromNow(-20, hour: 11),
    read: true,
    route: AppRoutes.referrals,
  ),
];
