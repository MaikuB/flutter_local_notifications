class NotificationActionData {
  NotificationActionData(
      {this.categoryIdentifier, this.actionIdentifier, this.payload});

  final String categoryIdentifier;
  final String actionIdentifier;
  final String payload;

  Map<String, Object> toMap() =>
      {
        "categoryIdentifier": categoryIdentifier,
        "actionIdentifier": actionIdentifier,
        "payload": payload,
      };

  static NotificationActionData fromMap(Map<dynamic, dynamic> map) =>
      NotificationActionData(
        categoryIdentifier: map["categoryIdentifier"],
        actionIdentifier: map["actionIdentifier"],
        payload: map["payload"],
      );
}