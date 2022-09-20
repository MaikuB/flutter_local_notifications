import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';

import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/darwin/notification_details.dart';

/// Contains notification details specific to each platform.
class NotificationDetails {
  /// Constructs an instance of [NotificationDetails].
  const NotificationDetails({
    this.android,
    this.iOS,
    this.macOS,
    this.linux,
  });

  /// Notification details for Android.
  final AndroidNotificationDetails? android;

  /// Notification details for iOS.
  final DarwinNotificationDetails? iOS;

  /// Notification details for macOS.
  final DarwinNotificationDetails? macOS;

  /// Notification details for Linux.
  final LinuxNotificationDetails? linux;
}
