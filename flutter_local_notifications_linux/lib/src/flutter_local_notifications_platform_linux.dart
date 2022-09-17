import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'model/capabilities.dart';
import 'model/initialization_settings.dart';
import 'model/notification_details.dart';

export 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

/// The interface that all implementations of flutter_local_notifications_linux
/// must implement.
abstract class FlutterLocalNotificationsPlatformLinux
    extends FlutterLocalNotificationsPlatform {
  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
  ///
  /// The [onDidReceiveNotificationResponse] callback is fired when the user
  /// selects a notification or notification action.
  Future<bool?> initialize(
    LinuxInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  });

  /// Show a notification with an optional payload that will be passed back to
  /// the app when a notification is tapped on.
  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    LinuxNotificationDetails? notificationDetails,
    String? payload,
  });

  /// Returns the system notification server capabilities.
  /// Some functionality may not be implemented by the notification server,
  /// conforming clients should check if it is available before using it.
  Future<LinuxServerCapabilities> getCapabilities();

  /// Returns a [Map] with the specified notification id as the key
  /// and the id, assigned by the system, as the value.
  ///
  /// Note: the system ID is unique only within the current user session,
  /// so it's undesirable to save it to persistable storage without any
  /// invalidation/update. For more information, please see
  /// Desktop Notifications Specification https://specifications.freedesktop.org/notification-spec/latest/ar01s02.html
  Future<Map<int, int>> getSystemIdMap();
}
