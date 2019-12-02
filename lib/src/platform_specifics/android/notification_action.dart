class NotificationAction {
  /// Icon for the action (not supported yet)
  String icon;
  /// Label of the button
  String title;
  /// Key associated to the action. You will receive this key back in onNotificationActionTapped callback.
  String actionKey;

  NotificationAction({this.icon, this.title, this.actionKey});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'icon': icon,
      'title': title,
      'actionKey': actionKey,
    };
  }
}