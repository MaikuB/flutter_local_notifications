import 'platform_specifics/ios/notification_details.dart';
import 'platform_specifics/android/notification_details.dart';

/// Contains notification settings for each platform
class NotificationDetails {
  const NotificationDetails(
    this.android,
    this.iOS,
  );

  /// Notification details for Android
  final AndroidNotificationDetails android;

  /// Notification details for iOS
  final IOSNotificationDetails iOS;
}
