/// The available intervals for periodically showing notifications.
enum RepeatInterval {
  /// An interval for every minute.
  everyMinute,

  /// Hourly interval.
  hourly,

  /// Daily interval.
  daily,

  /// Weekly interval.
  weekly
}

/// Details of a pending notification that has not been delivered.
class PendingNotificationRequest {
  /// Constructs an instance of [PendingNotificationRequest].
  const PendingNotificationRequest(
      this.id, this.title, this.body, this.payload);

  /// The notification's id.
  final int id;

  /// The notification's title.
  final String? title;

  /// The notification's body.
  final String? body;

  /// The notification's payload.
  final String? payload;
}

/// Details of a Notification Action that was triggered.
class NotificationActionDetails {
  /// Constructs an instance of [NotificationActionDetails]
  NotificationActionDetails({
    required this.id,
    required this.actionId,
    required this.input,
    required this.payload,
  });

  /// The notification's id.
  final int id;

  /// The id of the action that was triggered.
  final String actionId;

  /// The value of the input field if the notification action had an input field.
  final String? input;

  /// The notification's payload
  final String? payload;
}
