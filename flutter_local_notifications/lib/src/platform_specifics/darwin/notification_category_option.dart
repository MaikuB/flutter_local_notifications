/// Desribes the options of each notification category.
///
/// Corresponds to
/// https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions
enum DarwinNotificationCategoryOption {
  /// Send dismiss actions to the UNUserNotificationCenter object’s delegate for
  /// handling.
  ///
  /// Corresponds to [`UNNotificationCategoryOptions.customDismissAction`](https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions/1649280-customdismissaction).
  customDismissAction,

  /// Allow CarPlay to display notifications of this type.
  ///
  /// Corresponds to [`UNNotificationCategoryOptions.allowInCarPlay`](https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions/1649281-allowincarplay).
  allowInCarPlay,

  /// Show the notification's title, even if the user has disabled notification
  /// previews for the app.
  ///
  /// Corresponds to [`UNNotificationCategoryOptions.hiddenPreviewShowTitle`](https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions/2873735-hiddenpreviewsshowtitle).
  hiddenPreviewShowTitle,

  /// Show the notification's subtitle, even if the user has disabled
  /// notification previews for the app.
  ///
  /// Corresponds to [`UNNotificationCategoryOptions.hiddenPreviewShowSubtitle`](https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions/2873734-hiddenpreviewsshowsubtitle).
  hiddenPreviewShowSubtitle,

  /// An option that grants Siri permission to read incoming messages out loud
  /// when the user has a compatible audio output device connected.
  ///
  /// Corresponds to [`UNNotificationCategoryOptions.allowAnnouncement`](https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions/3240647-allowannouncement).
  allowAnnouncement,
}
