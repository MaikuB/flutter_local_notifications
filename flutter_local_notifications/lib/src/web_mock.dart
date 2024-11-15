import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

/// A stub implementation of the web plugin, for non-web platforms.
class WebFlutterLocalNotificationsPlugin extends FlutterLocalNotificationsPlatform {
  Future<bool?> initialize() async { return null; }

  Future<bool> requestNotificationsPermission() async { return false; }
}
