import 'categories.dart';
import 'enums.dart';
import 'icon.dart';
import 'sound.dart';
import 'timeout.dart';

/// Configures notification details specific to Linux.
class LinuxNotificationDetails {
  /// Constructs an instance of [LinuxNotificationDetails].
  const LinuxNotificationDetails({
    this.icon,
    this.sound,
    this.category,
    this.urgency,
    this.timeout = const LinuxNotificationTimeout.systemDefault(),
  });

  /// Specifies the notification icon.
  final LinuxNotificationIcon? icon;

  /// Specifies the notification sound.
  final LinuxNotificationSound? sound;

  /// Specifies the category for notification.
  /// This can be used by the notification server to filter or
  /// display the data in a certain way.
  final LinuxNotificationCategory? category;

  /// Sets the urgency level for notification.
  final LinuxNotificationUrgency? urgency;

  /// Sets the timeout for notification.
  /// To set the default time, pass [LinuxNotificationTimeout.systemDefault()]
  /// value. To set the notification to never expire,
  /// pass [LinuxNotificationTimeout.expiresNever()].
  ///
  /// Note that the timeout may be ignored by the server.
  final LinuxNotificationTimeout timeout;
}
