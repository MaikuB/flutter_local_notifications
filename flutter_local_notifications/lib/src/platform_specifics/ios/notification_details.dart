import 'notification_attachment.dart';

/// Configures notification details specific to iOS.
class IOSNotificationDetails {
  /// Constructs an instance of [IOSNotificationDetails].
  const IOSNotificationDetails({
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.sound,
    this.badgeNumber,
    this.attachments,
    this.subtitle,
    this.threadIdentifier,
    this.interruptionLevel,
  });

  /// Display an alert when the notification is triggered while app is
  /// in the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [IOSInitializationSettings.defaultPresentAlert].
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool? presentAlert;

  /// Play a sound when the notification is triggered while app is in
  /// the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given to
  /// [IOSInitializationSettings.defaultPresentSound].
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool? presentSound;

  /// Apply the badge value when the notification is triggered while app is in
  /// the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given to
  /// [IOSInitializationSettings.defaultPresentBadge].
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool? presentBadge;

  /// Specifies the name of the file to play for the notification.
  ///
  /// Requires setting [presentSound] to true. If [presentSound] is set to true
  /// but [sound] isn't specified then it will use the default notification
  /// sound.
  final String? sound;

  /// Specify the number to display as the app icon's badge when the
  /// notification arrives.
  ///
  /// Specify the number `0` to remove the current badge, if present. Greater
  /// than `0` to display a badge with that number.
  /// Specify `null` to leave the current badge unchanged.
  final int? badgeNumber;

  /// Specifies the list of attachments included with the notification.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final List<IOSNotificationAttachment>? attachments;

  /// Specifies the secondary description.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final String? subtitle;

  /// Specifies the thread identifier that can be used to group
  /// notifications together.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final String? threadIdentifier;

  /// The interruption level that indicates the priority and
  /// delivery timing of a notification.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final InterruptionLevel? interruptionLevel;
}

/// Constants that indicate the importance and delivery
/// timing of a notification.
enum InterruptionLevel {
  /// The system adds the notification to the notification
  /// list without lighting up the screen or playing a sound.
  passive,

  /// The system presents the notification immediately,
  /// lights up the screen, and can play a sound.
  active,

  /// The system presents the notification immediately,
  /// lights up the screen, and can play a sound,
  /// but won’t break through system notification controls.
  ///
  /// In order for this to work, the 'Time Sensitive Notifications'
  /// capability needs to be added to the iOS project.
  /// See https://help.apple.com/xcode/mac/current/#/dev88ff319e7
  timeSensitive,

  /// The system presents the notification immediately,
  /// lights up the screen, and bypasses the mute switch to play a sound.
  ///
  /// Subject to specific approval from Apple:
  /// https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/
  critical,
}
