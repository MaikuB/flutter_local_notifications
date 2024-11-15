import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';
import '../flutter_local_notifications.dart';

/// Web implementation of the local notifications plugin.
class WebFlutterLocalNotificationsPlugin
  extends FlutterLocalNotificationsPlatform
{
  /// Registers the web plugin with the platform interface.
  static void registerWith(_) {
    FlutterLocalNotificationsPlatform.instance =
      WebFlutterLocalNotificationsPlugin();
  }

  ServiceWorkerRegistration? _registration;

  @override
  Future<void> show(
    int id, String? title, String? body, {String? payload}
  ) async {
    final Map<String, int> data = <String, int>{'id': id};
    final NotificationOptions options =
      NotificationOptions(data: jsonEncode(data).toJS);
    _registration?.showNotification(title ?? 'This is a notification', options);
  }

  /// Initializes the plugin.
  Future<bool?> initialize() async {
    _registration = await window.navigator.serviceWorker
      .getRegistration().toDart;
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
    final JSArray<Notification> notificationsArray = await _registration
      !.getNotifications().toDart;
    final List<ActiveNotification> result = <ActiveNotification>[];
    final Set<int> ids = <int>{};
    for (final Notification jsNotification in notificationsArray.toDart) {
      final dynamic data = jsonDecode(jsNotification.data.toString());
      if (data == null) {
        continue;
      }
      final int? id = data['id'];
      if (id == null) {
        continue;
      }
      final ActiveNotification notif = ActiveNotification(id: id);
      ids.add(id);
      result.add(notif);
    }
    return result;
  }
}
