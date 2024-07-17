import "package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart";
import "package:timezone/timezone.dart";

import "../details.dart";

export "package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart";
export "package:timezone/timezone.dart";

/// The Windows implementation of `package:flutter_local_notifications`.
abstract class WindowsNotificationsBase extends FlutterLocalNotificationsPlatform {
  /// Initializes the plugin. No other method should be called before this.
  Future<bool> initialize(
    WindowsInitializationSettings settings, {
    DidReceiveNotificationResponseCallback? onNotificationReceived,
  });

  /// Releases any resources used by this plugin.
  void dispose();

  /// The raw XML passed to the Windows API.
  ///
  /// See https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/schema-root.
  /// For validation, see [the Windows Notifications Visualizer](https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/notifications-visualizer).
  Future<void> showRawXml({
    required int id,
    required String xml,
    Map<String, String> bindings = const {},
  });

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    String? payload,
    WindowsNotificationDetails? details,
  });

  /// Schedules a notification to appear at the given date and time.
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    WindowsNotificationDetails? details, {
    String? payload,
  });

  /// Updates the progress bar in the notification with the given ID.
  ///
  /// Note that in order to update [WindowsProgressBar.label], it must
  /// not have been set to null when [show] was called.
  Future<NotificationUpdateResult> updateProgressBar({
    required int notificationId,
    required WindowsProgressBar progressBar,
  }) => updateBindings(id: notificationId, bindings: progressBar.data);

  /// Updates any data binding in the given notification.
  ///
  /// Instead of a text value, you can replace any value in the `<binding>`
  /// element with `{name}`, and then use this function to update that value
  /// by passing `data: {'name': value}`.
  Future<NotificationUpdateResult> updateBindings({
    required int id,
    required Map<String, String> bindings,
  });
}
