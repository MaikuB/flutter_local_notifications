class NotificationAction {
  final String title;

  final String identifier;

  NotificationAction(this.title, this.identifier);

  Map<String, dynamic> toMap() => <String, Object>{
        'title': title,
        'identifier': identifier,
      };
}
