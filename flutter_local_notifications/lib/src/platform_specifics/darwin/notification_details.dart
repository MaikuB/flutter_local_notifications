import 'interruption_level.dart';
import 'notification_attachment.dart';

/// Configures notification details specific to Darwin-based operation systems
/// such as iOS and macOS
class DarwinNotificationDetails {
  /// Constructs an instance of [DarwinNotificationDetails].
  const DarwinNotificationDetails({
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.presentBanner,
    this.presentList,
    this.sound,
    this.badgeNumber,
    this.attachments,
    this.subtitle,
    this.threadIdentifier,
    this.categoryIdentifier,
    this.interruptionLevel,
  });

  /// Indicates if an alert should be display when the notification is triggered
  /// while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/1649506-alert
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [DarwinInitializationSettings.defaultPresentAlert].
  ///
  /// On iOS, this property is only applicable to iOS 10 to 14.
  /// On macOS, this property is only applicable to macOS 10.14 to 15.
  /// On newer versions of iOS and macOS, [presentList] and [presentBanner]
  final bool? presentAlert;

  /// Indicates if a sound should be played when the notification is triggered
  /// while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/1649521-sound
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [DarwinInitializationSettings.defaultPresentSound].
  ///
  /// If this is set to false to indicate that the notification shouldn't play
  /// a sound in the foreground then note that for consistency, the notification
  /// won't play a sound when the app is in the background. If the intention in
  /// this scenario is to have the app also play the default notification sound
  /// whilst the app is in the background as well, then the [sound] should be
  /// set to an arbitrary value (e.g. empty string) that doesn't match a custom
  /// sound file. This way the platform fails to find a custom sound file to
  /// fallback to the default notification sound.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool? presentSound;

  /// Indicates if badge value should be applied when the notification is
  /// triggered while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/1649515-badge
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [DarwinInitializationSettings.defaultPresentBadge].
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  final bool? presentBadge;

  /// Indicates if the notification should be presented as a banner when the
  /// notification is triggered while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/3564812-banner
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [DarwinInitializationSettings.defaultPresentBanner].
  ///
  /// On iOS, this property is only applicable to iOS 14 or newer
  /// On macOs, this property is only applicable to macOS 11 or newer.
  final bool? presentBanner;

  /// Indicates if the notification should be shown in the notification centre
  /// when the notification is
  /// triggered while app is in the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/3564813-list
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [DarwinInitializationSettings.defaultPresentList].
  ///
  /// On iOS, this property is only applicable to iOS 14 or newer
  /// On macOs, this property is only applicable to macOS 11 or newer.
  final bool? presentList;

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
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  final List<DarwinNotificationAttachment>? attachments;

  /// Specifies the secondary description.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  final String? subtitle;

  /// Specifies the thread identifier that can be used to group
  /// notifications together.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  final String? threadIdentifier;

  /// The identifier of the app-defined category object.
  ///
  /// This must refer to a [DarwinNotificationCategory] identifier configured
  /// via [InitializationSettings].
  ///
  /// On iOS, this is only applicable to iOS 10 or newer.
  /// On macOS, this is only applicable to macOS 10.14 or newer.
  final String? categoryIdentifier;

  /// The interruption level that indicates the priority and
  /// delivery timing of a notification.
  ///
  /// This property is only applicable to iOS 15.0 and macOS 12.0 or newer.
  /// https://developer.apple.com/documentation/usernotifications/unnotificationcontent/3747256-interruptionlevel
  final InterruptionLevel? interruptionLevel;
}
