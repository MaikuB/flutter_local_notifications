import 'package:flutter/foundation.dart';

/// Constants that indicate the importance and delivery
/// timing of a notification.
///
/// This mirrors the following Apple API
/// https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel
@immutable
class InterruptionLevel {
  /// Constructs an instance of [InterruptionLevel]
  const InterruptionLevel(this.value);

  /// The system adds the notification to the notification
  /// list without lighting up the screen or playing a sound.
  ///
  /// https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/passive
  static const InterruptionLevel passive = InterruptionLevel(0);

  /// The system presents the notification immediately,
  /// lights up the screen, and can play a sound.
  ///
  /// https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/active
  static const InterruptionLevel active = InterruptionLevel(1);

  /// The system presents the notification immediately,
  /// lights up the screen, and can play a sound,
  /// but won’t break through system notification controls.
  ///
  /// In order for this to work, the 'Time Sensitive Notifications'
  /// capability needs to be added to the iOS project.
  /// See https://help.apple.com/xcode/mac/current/#/dev88ff319e7
  ///
  /// https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/timesensitive
  static const InterruptionLevel timeSensitive = InterruptionLevel(2);

  /// The system presents the notification immediately,
  /// lights up the screen, and bypasses the mute switch to play a sound.
  ///
  /// Subject to specific approval from Apple:
  /// https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/
  ///
  /// https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/critical
  static const InterruptionLevel critical = InterruptionLevel(3);

  /// The integer representation.
  final int value;

  @override
  int get hashCode => value;

  @override
  bool operator ==(Object other) =>
      other is InterruptionLevel && other.value == value;
}
