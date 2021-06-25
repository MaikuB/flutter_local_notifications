import 'enums.dart';
import 'notification_timeout.dart';

/// Configures notification details specific to Linux.
class LinuxNotificationDetails {
  /// Constructs an instance of [LinuxNotificationDetails].
  const LinuxNotificationDetails({
    this.iconPath,
    this.category,
    this.urgency = LinuxNotificationUrgency.unspecified,
    this.timeout = const LinuxNotificationTimeout.systemDefault(),
  });

  /// Specifies the icon for notification.
  /// The icon path is a relative path inside the Flutter Assets directory
  final String? iconPath;

  /// Specifies the category for notification.
  /// This can be used by the notification server to filter or
  /// display the data in a certain way.
  final String? category;

  /// Sets the urgency level for notification.
  final LinuxNotificationUrgency urgency;

  /// Sets the timeout for notification.
  /// To set the default time, pass [LinuxNotificationTimeout.systemDefault()]
  /// value. To set the notification to never expire,
  /// pass [LinuxNotificationTimeout.expiresNever()].
  ///
  /// Note that the timeout may be ignored by the server.
  final LinuxNotificationTimeout timeout;
}
