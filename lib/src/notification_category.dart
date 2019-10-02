import 'package:flutter_local_notifications/src/notification_action.dart';

class NotificationCategory {
  final String identifier;

  final List<NotificationAction> actions;

  NotificationCategory(this.identifier, this.actions);

  Map<String, Object> toMap() => {
        'identifier': identifier,
        'actions': actions.map((a) => a.toMap()).toList(),
      };
}
