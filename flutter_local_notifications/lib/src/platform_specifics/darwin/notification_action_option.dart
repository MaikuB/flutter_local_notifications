/// Describes when & how the notification action is displayed.
///
/// Corresponds to
/// https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions
/// for more details.
enum DarwinNotificationActionOption {
  /// The action can be performed only on an unlocked device.
  ///
  /// Corresponds to [`UNNotificationActionOptions.authenticationRequired`](https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions/1648196-authenticationrequired).
  authenticationRequired,

  /// The action performs a destructive task.
  ///
  /// Corresponds to [`UNNotificationActionOptions.destructive`](https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions/1648199-destructive)
  destructive,

  /// The action causes the app to launch in the foreground.
  ///
  /// Corresponds to [`UNNotificationActionOptions.foreground`](https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions/1648192-foreground)

  foreground,
}
