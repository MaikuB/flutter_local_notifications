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

/// Desribes the options of each notification category.
///
/// See official docs at
/// https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions
/// for more details.
enum DarwinNotificationCategoryOption {
  /// Send dismiss actions to the UNUserNotificationCenter object’s delegate for
  /// handling
  customDismissAction,

  /// Allow CarPlay to display notifications of this type.
  allowInCarPlay,

  /// Show the notification's title, even if the user has disabled notification
  /// previews for the app.
  hiddenPreviewShowTitle,

  /// Show the notification's subtitle, even if the user has disabled
  /// notification previews for the app.
  hiddenPreviewShowSubtitle,

  /// An option that grants Siri permission to read incoming messages out loud
  /// when the user has a compatible audio output device connected.
  allowAnnouncement,
}
