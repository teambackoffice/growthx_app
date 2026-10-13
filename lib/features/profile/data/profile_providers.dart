import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'partner_profile.dart';
import 'profile_dummy_data.dart';

final profileProvider = NotifierProvider<ProfileNotifier, PartnerProfile>(
  ProfileNotifier.new,
);

class ProfileNotifier extends Notifier<PartnerProfile> {
  @override
  PartnerProfile build() => dummyProfile;

  void update(PartnerProfile profile) => state = profile;
}

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
      NotificationPreferencesNotifier.new,
    );

class NotificationPreferencesNotifier
    extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() => const NotificationPreferences();

  void set(NotificationPreferences prefs) => state = prefs;
}
