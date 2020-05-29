import '../../typedefs.dart';

/// Plugin initialization settings for iOS.
class IOSInitializationSettings {
  const IOSInitializationSettings({
    this.requestAlertPermission = true,
    this.requestSoundPermission = true,
    this.requestBadgePermission = true,
    this.defaultPresentAlert = true,
    this.defaultPresentSound = true,
    this.defaultPresentBadge = true,
    this.onDidReceiveLocalNotification,
  })  : assert(requestAlertPermission != null),
        assert(requestSoundPermission != null),
        assert(requestBadgePermission != null),
        assert(defaultPresentAlert != null),
        assert(defaultPresentBadge != null),
        assert(defaultPresentSound != null);

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

  /// Configures the default setting on if an alert should be displayed when a
  /// notification is triggered while app is in the foreground.
  ///
  /// Default value is true.
  ///
  /// This property is only applicable to iOS 10 or newer.

  final bool defaultPresentAlert;

  /// Configures the default setting on if a sound should be played when a
  /// notification is triggered while app is in the foreground by default.
  ///
  /// Default value is true.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool defaultPresentSound;

  /// Configures the default setting on if a badge value should be applied when
  /// a notification is triggered while app is in the foreground by default.
  ///
  /// Default value is true.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool defaultPresentBadge;

  /// Callback for handling when a notification is triggered while the app is
  /// in the foreground.
  ///
  /// This property is only applicable to iOS versions older than 10.
  final DidReceiveLocalNotificationCallback onDidReceiveLocalNotification;
}
