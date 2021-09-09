/// Contains details on the notification that launched the application.
class NotificationAppLaunchDetails {
  /// Constructs an instance of [NotificationAppLaunchDetails].
  const NotificationAppLaunchDetails(
      this.didNotificationLaunchApp, this.payload);

  /// Indicates if the app was launched via notification
  final bool didNotificationLaunchApp;

  /// The payload of the notification that launched the app
  final String? payload;
}
