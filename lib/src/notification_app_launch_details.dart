class NotificationAppLaunchDetails {
  /// Indicates if the app was launched via notification
  final bool didNotificationLaunchApp;

  /// The payload of the notification that launched the app
  final String payload;

  final Map<dynamic, dynamic> data;

  const NotificationAppLaunchDetails(this.didNotificationLaunchApp, this.data, this.payload);
}
