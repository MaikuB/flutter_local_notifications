import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

/// A stub implementation of the web plugin, for non-web platforms.
class WebFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  /// Initializes the plugin.
  Future<bool?> initialize() async => null;

  /// Requests permission to use the plugin.
  Future<bool> requestNotificationsPermission() async => false;

  @override
  Future<void> cancel(int id, {String? tag}) async { }
}
