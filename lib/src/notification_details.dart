part of flutter_local_notifications;

/// Contains notification settings for each platform
class NotificationDetails {
  /// Notification details for Android
  final AndroidNotificationDetails android;

  /// Notification details for iOS
  final IOSNotificationDetails iOS;

  const NotificationDetails(this.android, this.iOS);
}
