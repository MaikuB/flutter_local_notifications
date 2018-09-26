part of flutter_local_notifications;

class NotificationAppLaunchDetails {
  final bool didNotificationLaunchApp;
  final String payload;

  const NotificationAppLaunchDetails(
      this.didNotificationLaunchApp, this.payload);
}
