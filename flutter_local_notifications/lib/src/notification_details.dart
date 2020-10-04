import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/ios/notification_details.dart';
import 'platform_specifics/macos/notification_details.dart';

/// Contains notification details specific to each platform.
class NotificationDetails {
  const NotificationDetails({
    this.android,
    this.iOS,
    this.macOS,
  });

  /// Notification details for Android.
  final AndroidNotificationDetails android;

  /// Notification details for iOS.
  final IOSNotificationDetails iOS;

  /// Notification details for macOS.
  final MacOSNotificationDetails macOS;
}
