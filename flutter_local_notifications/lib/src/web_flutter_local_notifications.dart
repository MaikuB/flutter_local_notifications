import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';
import '../flutter_local_notifications.dart';

/// Web implementation of the local notifications plugin.
class WebFlutterLocalNotificationsPlugin extends FlutterLocalNotificationsPlatform {
  static void registerWith(_) {
    FlutterLocalNotificationsPlatform.instance = WebFlutterLocalNotificationsPlugin();
  }

  ServiceWorkerRegistration? _registration;

  @override
  Future<void> show(int id, String? title, String? body, {String? payload}) async {
    final data = {"id": id};
    final options = NotificationOptions(data: jsonEncode(data).toJS);
    print("JSON: ${jsonEncode(data).toJS}");
    _registration?.showNotification(title ?? 'This is a notification', options);
  }

  Future<bool?> initialize() async {
    _registration = await window.navigator.serviceWorker.getRegistration().toDart;
    return true;
  }


  Future<bool> requestNotificationsPermission() async {
    final JSString result = await Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (_registration == null) return [];
    final notificationsArray = await _registration!.getNotifications().toDart;
    final result = <ActiveNotification>[];
    final ids = <int>{};
    for (final jsNotification in notificationsArray.toDart) {
      final data = jsonDecode(jsNotification.data.toString());
      if (data == null) continue;
      final id = data["id"];
      if (id == null) continue;
      final notif = ActiveNotification(id: id);
      ids.add(id);
      result.add(notif);
    }
    return result;
  }
}
