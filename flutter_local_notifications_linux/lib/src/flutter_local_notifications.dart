import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'helpers.dart';
import 'model/capabilities.dart';
import 'model/initialization_settings.dart';
import 'model/notification_details.dart';
import 'notifications_manager.dart';
import 'typedefs.dart';

/// Linux implementation of the local notifications plugin.
class LinuxFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
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
  /// This should only be done once. When a notification created by this plugin
  /// was used to launch the app, calling `initialize` is what will trigger to
  /// the `onSelectNotification` callback to be fire.
  Future<bool?> initialize(
    LinuxInitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
  }) async {
    await _manager.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

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
  Future<LinuxServerCapabilities> getCapabilities() =>
      _manager.getCapabilities();

  /// Returns a [Map] with the specified notification id as the key
  /// and the id, assigned by the system, as the value.
  ///
  /// Note: the system ID is unique only within the current user session,
  /// so it's undesirable to save it to persistable storage without any
  /// invalidation/update. For more information, please see
  /// Desktop Notifications Specification https://developer.gnome.org/notification-spec/#basic-design
  Future<Map<int, int>> getSystemIdMap() => _manager.getSystemIdMap();
}
