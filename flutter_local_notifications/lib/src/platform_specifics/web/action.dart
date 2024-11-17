enum WebNotificationActionType {
  button('button'),
  textInput('text');

  const WebNotificationActionType(this.jsValue);
  final String jsValue;
}

class WebNotificationAction {
  const WebNotificationAction({
    required this.action,
    required this.title,
    this.icon,
    this.type = WebNotificationActionType.button,
  });

  final WebNotificationActionType type;
  final String action;
  final String title;
  final Uri? icon;
}
