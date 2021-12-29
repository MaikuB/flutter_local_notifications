/// Describes when & how the notification action is displayed.
///
/// See official docs at
/// https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions
/// for more details.
enum DarwinNotificationActionOption {
  /// The action can be performed only on an unlocked device.
  authenticationRequired,

  /// The action performs a destructive task.
  destructive,

  /// The action causes the app to launch in the foreground.
  foreground,
}
