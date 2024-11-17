import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'details.dart';

/// A stub implementation of the web plugin, for non-web platforms.
class WebFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  /// Initializes the plugin.
  Future<bool?> initialize() async => null;

  /// Requests permission to use the plugin.
  Future<bool> requestNotificationsPermission() async => false;

  @override
  Future<void> cancel(int id, {String? tag}) async {}

  @override
  Future<void> show(int id, String? title, String? body,
      {String? payload, WebNotificationDetails? details}) async {}
}
