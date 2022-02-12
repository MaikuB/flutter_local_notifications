import '../../typedefs.dart';

/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  /// Constructs an instance of [AndroidInitializationSettings].
  const AndroidInitializationSettings(
    this.defaultIcon, {
    this.onDidReceiveLocalNotification,
  });

  /// Specifies the default icon for notifications.
  final String defaultIcon;

  /// Callback for handling when a notification is triggered while the app is
  /// in the foreground.
  final DidReceiveLocalNotificationCallback? onDidReceiveLocalNotification;
}
