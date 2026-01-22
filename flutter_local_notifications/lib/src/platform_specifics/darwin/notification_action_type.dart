/// Describes the notification action type.
///
/// This type is used internally.
enum DarwinNotificationActionType {
  /// Corresponds to the `UNNotificationAction` type defined at
  /// https://developer.apple.com/documentation/usernotifications/unnotificationaction
  plain,

  /// Corresponds to the `UNTextInputNotificationAction` type defined at
  /// https://developer.apple.com/documentation/usernotifications/untextinputnotificationaction
  text,
}
