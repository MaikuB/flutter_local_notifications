import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';
import '../flutter_local_notifications.dart';

/// Web implementation of the local notifications plugin.
class WebFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  /// Registers the web plugin with the platform interface.
  static void registerWith(_) {
    FlutterLocalNotificationsPlatform.instance =
        WebFlutterLocalNotificationsPlugin();
  }

  ServiceWorkerRegistration? _registration;

  @override
  Future<void> show(int id, String? title, String? body,
      {String? payload}) async {
    final Map<String, int> data = <String, int>{'id': id};
    final NotificationOptions options =
        NotificationOptions(data: jsonEncode(data).toJS);
    _registration?.showNotification(title ?? 'This is a notification', options);
  }

  /// Initializes the plugin.
  Future<bool?> initialize() async {
    _registration =
        await window.navigator.serviceWorker.getRegistration().toDart;
    return _registration != null;
  }

  /// Requests notification permission from the browser.
  ///
  /// It is highly recommended and sometimes required that this be called only
  /// in response to a user gesture, and not automatically.
  Future<bool> requestNotificationsPermission() async {
    final JSString result = await Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (_registration == null) {
      return <ActiveNotification>[];
    }
    final List<ActiveNotification> result = <ActiveNotification>[];
    final Set<int> ids = <int>{};
    final List<Notification> jsNotifs =
        await _registration!.getDartNotifications();
    for (final Notification jsNotification in jsNotifs) {
      final int? id = jsNotification.id;
      if (id == null) {
        continue;
      }
      final ActiveNotification notif = ActiveNotification(id: id);
      ids.add(id);
      result.add(notif);
    }
    return result;
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    if (_registration == null) {
      return;
    }
    final List<Notification> notifs =
        await _registration!.getDartNotifications();
    for (final Notification notification in notifs) {
      if (notification.id == id || (tag != null && tag == notification.tag)) {
        notification.close();
      }
    }
  }

  @override
  Future<void> cancelAll() async {
    if (_registration == null) {
      return;
    }
    final List<Notification> notifs =
        await _registration!.getDartNotifications();
    for (final Notification notification in notifs) {
      notification.close();
    }
  }
}

extension on Notification {
  /// Gets the ID of the notification.
  int? get id => jsonDecode(data.toString())?['id'];
}

extension on ServiceWorkerRegistration {
  Future<List<Notification>> getDartNotifications() async =>
      (await getNotifications().toDart).toDart;
}
