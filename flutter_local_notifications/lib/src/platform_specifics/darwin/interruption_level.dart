/// Type used to indicate the importance and delivery timing of a notification.
///
/// Corresponds to [UNNotificationInterruptionLevel](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel).
enum InterruptionLevel {
  /// The system adds the notification to the notification
  /// list without lighting up the screen or playing a sound.
  ///
  /// Corresponds to [`UNNotificationInterruptionLevel.passive`](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/passive).
  passive,

  /// The system presents the notification immediately,
  /// lights up the screen, and can play a sound.
  ///
  /// Corresponds to [`UNNotificationInterruptionLevel.active`](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/active).
  active,

  /// The system presents the notification immediately,
  /// lights up the screen, and can play a sound,
  /// but won’t break through system notification controls.
  ///
  /// In order for this to work, the 'Time Sensitive Notifications'
  /// capability needs to be added to the iOS project.
  /// See https://help.apple.com/xcode/mac/current/#/dev88ff319e7
  ///
  /// Corresponds to [`UNNotificationInterruptionLevel.timeSensitive`](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/timesensitive).
  timeSensitive,

  /// The system presents the notification immediately,
  /// lights up the screen, and bypasses the mute switch to play a sound.
  ///
  /// Subject to specific approval from Apple:
  /// https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/
  ///
  /// Corresponds to [`UNNotificationInterruptionLevel.critical`](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/critical).
  critical
}
