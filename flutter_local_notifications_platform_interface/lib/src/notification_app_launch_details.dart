class NotificationAppLaunchDetails {
  const NotificationAppLaunchDetails(
      this.didNotificationLaunchApp, this.payload);

  /// Indicates if the app was launched via notification
  final bool didNotificationLaunchApp;

  /// The payload of the notification that launched the app
  final String payload;
}
