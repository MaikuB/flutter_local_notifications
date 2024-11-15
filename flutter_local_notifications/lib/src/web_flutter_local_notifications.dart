import 'dart:js_interop';

import 'package:web/web.dart';
import '../flutter_local_notifications.dart';

/// Web implementation of the local notifications plugin.
class WebFlutterLocalNotificationsPlugin extends FlutterLocalNotificationsPlatform {
  static void registerWith(_) {
    FlutterLocalNotificationsPlatform.instance = WebFlutterLocalNotificationsPlugin();
  }

  @override
  Future<void> show(int id, String? title, String? body, {String? payload}) async {
    final registration = await window.navigator.serviceWorker.getRegistration().toDart;
    print("This is the registration: $registration");
    if (registration == null) return;
    registration.showNotification(title ?? 'This is a notification');
  }
}
