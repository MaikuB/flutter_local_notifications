import '../../typedefs.dart';
import 'notification_category.dart';

/// Plugin initialization settings for Darwin-based operating systems
/// such as iOS and macOS
class DarwinInitializationSettings {
  /// Constructs an instance of [DarwinInitializationSettings].
  const DarwinInitializationSettings({
    this.requestAlertPermission = true,
    this.requestSoundPermission = true,
    this.requestBadgePermission = true,
    this.requestCriticalPermission = false,
    this.onDidReceiveLocalNotification,
    this.notificationCategories = const <DarwinNotificationCategory>[],
  });

  /// Request permission to display an alert.
  ///
  /// Default value is true.
  final bool requestAlertPermission;

  /// Request permission to play a sound.
  ///
  /// Default value is true.
  final bool requestSoundPermission;

  /// Request permission to badge app icon.
  ///
  /// Default value is true.
  final bool requestBadgePermission;

  /// Request permission to show critical notifications.
  ///
  /// Subject to specific approval from Apple:
  /// https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/
  ///
  /// Default value is 'false'.
  final bool requestCriticalPermission;

  /// Callback for handling when a notification is triggered while the app is
  /// in the foreground.
  ///
  /// This property is only applicable to iOS versions older than 10.
  final DidReceiveLocalNotificationCallback? onDidReceiveLocalNotification;

  /// Configure the notification categories ([DarwinNotificationCategory])
  /// available. This allows for fine-tuning of preview display.
  ///
  /// IMPORTANT: A change to the category actions will either require a full app
  /// uninstall / reinstall or a change to the category identifier. This is
  /// because iOS/macOS configures the categories once per App launch and considers
  /// them immutable while the App is installed.
  ///
  /// Notification actions are configured in each [DarwinNotificationCategory].
  ///
  /// On iOS, this is only applicable to iOS 10 or newer.
  /// On macOS, this is only applicable to macOS 10.14 or newer.
  final List<DarwinNotificationCategory> notificationCategories;
}
