/// The text direction of a web notification.
///
/// Note: This may be ignored by browsers. See the [docs](https://developer.mozilla.org/en-US/docs/Web/API/Notification/dir)
enum WebNotificationDirection {
  /// Adopt the browser's setting.
  auto('auto'),

  /// Left to right.
  leftToRight('ltr'),

  /// Right to left.
  rightToLeft('rtl');

  const WebNotificationDirection(this.jsValue);

  /// A string value to pass to JavaScript functions.
  final String jsValue;
}
