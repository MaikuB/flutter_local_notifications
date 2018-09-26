part of flutter_local_notifications;

class NotificationAppLaunchDetails {
  /// Indicates if the app was launched via notification
  final bool didNotificationLaunchApp;

  /// The payload of the notification that launched the app
  final String payload;

  const NotificationAppLaunchDetails(
      this.didNotificationLaunchApp, this.payload);
}
