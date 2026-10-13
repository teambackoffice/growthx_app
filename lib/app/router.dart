import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_providers.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/customers/presentation/customer_details_screen.dart';
import '../features/customers/presentation/customers_screen.dart';
import '../features/earnings/presentation/earnings_screen.dart';
import '../features/earnings/presentation/payout_details_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/leads/presentation/add_lead_screen.dart';
import '../features/leads/presentation/leads_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/more_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/referrals/presentation/referrals_screen.dart';
import 'routes.dart';
import 'shell/app_shell.dart';
import 'shell/not_found_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  // Bridges Riverpod auth state into GoRouter's refreshListenable.
  final signedIn = ValueNotifier<bool>(ref.read(authProvider));
  ref.listen(authProvider, (_, next) => signedIn.value = next);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: signedIn,
    redirect: (context, state) {
      final onAuthScreen =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.forgotPassword;
      if (!signedIn.value) return onAuthScreen ? null : AppRoutes.login;
      if (onAuthScreen) return AppRoutes.home;
      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.home),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            FadingBranchContainer(
              currentIndex: shell.currentIndex,
              children: children,
            ),
        branches: [
          _branch(AppRoutes.home, const HomeScreen()),
          _branch(AppRoutes.customers, const CustomersScreen()),
          _branch(AppRoutes.referrals, const ReferralsScreen()),
          _branch(AppRoutes.earnings, const EarningsScreen()),
          _branch(AppRoutes.more, const MoreScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.customerDetails,
        builder: (context, state) =>
            CustomerDetailsScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.payoutDetails,
        builder: (context, state) =>
            PayoutDetailsScreen(payoutId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.leads,
        builder: (context, state) => const LeadsScreen(),
      ),
      // Top-level (not nested under /leads) so back returns to wherever the
      // form was opened from — Home, Referrals or the leads list.
      GoRoute(
        path: AppRoutes.addLead,
        builder: (context, state) => const AddLeadScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    signedIn.dispose();
  });
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
