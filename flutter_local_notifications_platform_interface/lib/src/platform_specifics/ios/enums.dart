/// Describes how the fire date (date used to schedule a notification) of the
/// `UILocalNotification` on iOS is interpreted.
///
/// This is needed as time zone support in the deprecated UILocalNotification
/// APIs is limited. See official docs at
/// https://developer.apple.com/documentation/uikit/uilocalnotification/1616659-timezone
/// for more details.
enum UILocalNotificationDateInterpretation {
  /// The date is interpreted as absolute GMT time.
  absoluteTime,

  /// The date is interpreted as a wall-clock time.
  wallClockTime
}
