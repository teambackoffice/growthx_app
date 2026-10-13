/// Route paths in one place so screens never hard-code strings.
abstract final class AppRoutes {
  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  // Bottom-navigation tabs.
  static const home = '/home';
  static const customers = '/customers';
  static const referrals = '/referrals';
  static const earnings = '/earnings';
  static const more = '/more';

  // Full-screen routes pushed on top of the tabs.
  static const customerDetails = '/customer/:id';
  static const payoutDetails = '/payout/:id';
  static const notifications = '/notifications';
  static const leads = '/leads';
  static const addLead = '/leads/new';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  static String customer(String id) => '/customer/$id';
  static String payout(String id) => '/payout/$id';
}
