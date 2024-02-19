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
    this.requestProvisionalPermission = false,
    this.requestCriticalPermission = false,
    this.defaultPresentAlert = true,
    this.defaultPresentSound = true,
    this.defaultPresentBadge = true,
    this.defaultPresentBanner = true,
    this.defaultPresentList = true,
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

  /// Request permission to send provisional notification for iOS 12+
  ///
  /// Subject to specific approval from Apple: https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications#3544375
  ///
  /// Default value is false.
  ///
  /// On iOS, this property is only applicable to iOS 12 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  final bool requestProvisionalPermission;

  /// Request permission to show critical notifications.
  ///
  /// Subject to specific approval from Apple:
  /// https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/
  ///
  /// Default value is 'false'.
  final bool requestCriticalPermission;

  /// Configures the default setting on if an alert should be displayed when a
  /// notification is triggered while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/1649506-alert
  ///
  /// Default value is true.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer but not iOS 14
  /// or beyond (i.e. iOS versions >= 10 and < 14)
  /// On macOS, this property is only applicable to macOS 10.14 but not macOS 11
  /// or beyond (i.e. macOS verisons >= 10.14 and < 14)
  /// For iOS and macOS versions beyond the aforementioned ranges,
  /// [defaultPresentBanner] and [defaultPresentList] are referenced as Apple
  /// deprecated the alert presentation option.
  final bool defaultPresentAlert;

  /// Configures the default setting on if a sound should be played when a
  /// notification is triggered while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/1649521-sound
  ///
  /// Default value is true.
  ///
  /// If this is set to false to indicate that the notification shouldn't play
  /// a sound in the foreground then note that for consistency, the notification
  /// won't play a sound when the app is in the background. If the intention in
  /// this scenario is to have the app also play the default notification sound
  /// whilst the app is in the background as well, then the
  /// [DarwinNotificationDetails.sound] should be set to an arbitrary value
  /// (e.g. empty string) that doesn't match a custom sound file. This way the
  /// platform fails to find a custom sound file to fallback to the default
  /// notification sound.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  final bool defaultPresentSound;

  /// Configures the default setting on if a badge value should be applied when
  /// a notification is triggered while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/1649515-badge
  ///
  /// Default value is true.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  final bool defaultPresentBadge;

  /// Configures the default setting on if the notification should be
  /// presented as a banner when a notification is triggered while app is in
  /// the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/3564812-banner
  ///
  /// Default value is true.
  ///
  /// On iOS, this property is only applicable to iOS 14 or newer.
  /// On macOS, this property is only applicable to macOS 11 or newer.
  final bool defaultPresentBanner;

  /// Configures the default setting on if the notification should be
  /// in the notification centre when notification is triggered while app is in
  /// the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/3564813-list
  ///
  /// Default value is true.
  ///
  /// On iOS, this property is only applicable to iOS 14 or newer.
  /// On macOS, this property is only applicable to macOS 11 or newer.
  final bool defaultPresentList;

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
