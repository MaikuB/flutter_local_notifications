import 'notification_attachment.dart';

/// Configures notification details specific to macOS.
class MacOSNotificationDetails {
  /// Constructs an instance of [MacOSNotificationDetails].
  const MacOSNotificationDetails({
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.sound,
    this.badgeNumber,
    this.attachments,
    this.subtitle,
    this.threadIdentifier,
  });

  /// Display an alert when the notification is triggered while app is
  /// in the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [MacOSInitializationSettings.defaultPresentAlert].
  ///
  /// This property is only applicable to macOS 10.14 or newer.
  final bool? presentAlert;

  /// Play a sound when the notification is triggered while app is in
  /// the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given to
  /// [MacOSInitializationSettings.defaultPresentSound].
  ///
  /// This property is only applicable to macOS 10.14 or newer.
  final bool? presentSound;

  /// Apply the badge value when the notification is triggered while app is in
  /// the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given to
  /// [MacOSInitializationSettings.defaultPresentBadge].
  ///
  /// This property is only applicable to macOS 10.14 or newer.
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
  /// This property is only applicable to macOS 10.14 or newer.
  final List<MacOSNotificationAttachment>? attachments;

  /// Specifies the secondary description.
  final String? subtitle;

  /// Specifies the thread identifier that can be used to group
  /// notifications together.
  ///
  /// This property is only applicable to macOS 10.14 or newer.
  final String? threadIdentifier;
}
