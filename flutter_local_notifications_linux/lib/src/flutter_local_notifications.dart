import 'package:flutter/foundation.dart';

import 'flutter_local_notifications_platform_linux.dart';
import 'model/capabilities.dart';
import 'model/initialization_settings.dart';
import 'model/notification_details.dart';
import 'notifications_manager.dart';

/// Linux implementation of the local notifications plugin.
class LinuxFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatformLinux {
  /// Constructs an instance of [LinuxNotificationDetails].
  LinuxFlutterLocalNotificationsPlugin()
      : _manager = LinuxNotificationManager();

  /// Constructs an instance of [LinuxNotificationDetails]
  /// with the give [manager].
  @visibleForTesting
  LinuxFlutterLocalNotificationsPlugin.private(
    LinuxNotificationManager manager,
  ) : _manager = manager;

  final LinuxNotificationManager _manager;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
  ///
  /// This should only be done once. When a notification created by this plugin
  /// was used to launch the app, calling [initialize] is what will trigger to
  /// the [onSelectNotification] callback to be fire.
  ///
  /// [onSelectNotificationAction] specifies a callback handler which receives
  /// notification action IDs.
  @override
  Future<bool?> initialize(
    LinuxInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) =>
      _manager.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

  /// Show a notification with an optional payload that will be passed back to
  /// the app when a notification is tapped on.
  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    LinuxNotificationDetails? notificationDetails,
    String? payload,
  }) {
    validateId(id);
    return _manager.show(
      id,
      title,
      body,
      details: notificationDetails,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int id) {
    validateId(id);
    return _manager.cancel(id);
  }

  @override
  Future<void> cancelAll() => _manager.cancelAll();

  /// Returns the system notification server capabilities.
  /// Some functionality may not be implemented by the notification server,
  /// conforming clients should check if it is available before using it.
  @override
  Future<LinuxServerCapabilities> getCapabilities() =>
      _manager.getCapabilities();
}
