class NotificationAction {
  /// Icon for the action. This is visible only if NotificationStyle is MediaStyle
  String icon;
  /// Label of the button
  String title;
  /// Key associated to the action. You will receive this key back in onNotificationActionTapped callback.
  String actionKey;
  /// Extras associated to the action. You will receive this extras back in onNotificationActionTapped callback.
  Map<String, String> extras;

  NotificationAction({this.icon, this.title, this.actionKey, this.extras});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'icon': icon,
      'title': title,
      'actionKey': actionKey,
      'extras': this.extras,
    };
  }
}