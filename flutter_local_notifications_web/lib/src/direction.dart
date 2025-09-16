// https://developer.mozilla.org/en-US/docs/Web/API/Notification/dir
enum WebNotificationDirection {
  auto('auto'),
  leftToRight('ltr'),
  rightToLeft('rtl');

  const WebNotificationDirection(this.jsValue);
  final String jsValue;
}
