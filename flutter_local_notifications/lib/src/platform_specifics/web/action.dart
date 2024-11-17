class WebNotificationAction {
  final String action;
  final String title;
  final Uri? icon;

  const WebNotificationAction({
    required this.action,
    required this.title,
    this.icon,
  });
}
