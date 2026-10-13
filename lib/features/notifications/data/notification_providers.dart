import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_notification.dart';
import 'notifications_dummy_data.dart';

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => dummyNotifications;

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.markRead() else n,
    ];
  }

  void markAllRead() => state = [for (final n in state) n.markRead()];

  void remove(String id) => state = state.where((n) => n.id != id).toList();
}

final unreadNotificationCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => !n.read).length,
);
