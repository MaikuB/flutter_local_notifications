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