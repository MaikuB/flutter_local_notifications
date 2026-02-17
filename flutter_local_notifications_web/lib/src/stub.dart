import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'details.dart';

/// A stub implementation of the web plugin, for non-web platforms.
class WebFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  /// Initializes the plugin.
  Future<bool?> initialize({
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async =>
      null;

  /// Requests notification permission from the browser.
  ///
  /// Be sure to only request permissions in response to a user gesture, or it
  /// may be automatically rejected.
  Future<bool?> requestNotificationsPermission() async => false;

  /// Returns the current permission status as a string.
  String get permissionStatus => 'denied';

  /// Whether the user has granted permission to show notifications.
  bool get hasPermission => false;

  /// Whether the user has explicitly denied permission to show notifications.
  bool get isPermissionDenied => false;

  @override
  Future<void> cancel({required int id}) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelAllPendingNotifications() async {}

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
    WebNotificationDetails? details,
  }) async {}

  @override
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async => null;

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async =>
      <ActiveNotification>[];

  @override
  Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() async => <PendingNotificationRequest>[];
}
