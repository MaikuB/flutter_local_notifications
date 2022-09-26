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
    this.sound,
    this.badgeNumber,
    this.attachments,
    this.subtitle,
    this.threadIdentifier,
    this.categoryIdentifier,
    this.interruptionLevel,
  });

  /// Display an alert when the notification is triggered while app is
  /// in the foreground.
  ///
  /// When this is set to `null`, it will use the default setting given
  /// to [IOSInitializationSettings.defaultPresentAlert].
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
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
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
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
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  final List<DarwinNotificationAttachment>? attachments;

  /// Specifies the secondary description.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  final String? subtitle;

  /// Specifies the thread identifier that can be used to group
  /// notifications together.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
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
