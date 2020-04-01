import 'notification_attachment.dart';

/// Configures the notification details on iOS.
class IOSNotificationDetails {
  const IOSNotificationDetails({
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.sound,
    this.badgeNumber,
    this.attachments,
  });

  /// Display an alert when the notification is triggered while app is in the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given to [IOSInitializationSettings.defaultPresentAlert].
  /// Applicable to iOS 10 and above.
  final bool presentAlert;

  /// Play a sound when the notification is triggered while app is in the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given to [IOSInitializationSettings.defaultPresentSound].
  /// Applicable to iOS 10 and above.
  final bool presentSound;

  /// Apply the badge value when the notification is triggered while app is in the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given to [IOSInitializationSettings.defaultPresentBadge].
  /// Applicable to iOS 10 and above.
  final bool presentBadge;

  /// Specifies the name of the file to play for the notification.
  ///
  /// Requires setting [presentSound] to true. If [presentSound] is set to true but [sound] isn't specified then it will use the default notification sound.
  final String sound;

  /// Specify the number to display as the app icon's badge when the notification arrives.
  ///
  /// Specify the number `0` to remove the current badge, if present. Greater than `0` to display a badge with that number.
  /// Specify `null` to leave the current badge unchanged.
  final int badgeNumber;

  /// Specifies the list of attachments included with the notification.
  ///
  /// Applicable to iOS 10 and above.
  final List<IOSNotificationAttachment> attachments;

  /// Creates a [Map] object that describes the [IOSNotificationDetails] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'presentAlert': presentAlert,
      'presentSound': presentSound,
      'presentBadge': presentBadge,
      'sound': sound,
      'badgeNumber': badgeNumber,
      'attachments': attachments?.map((a) => a.toMap())?.toList()
    };
  }
}
