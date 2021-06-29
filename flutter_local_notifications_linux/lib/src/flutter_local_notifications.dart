import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'helpers.dart';
import 'initialization_settings.dart';
import 'notification_details.dart';
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
  Future<void> cancelAll() {
    // TODO(proninyaroslav): implement cancelAll
    throw UnimplementedError();
  }
}
