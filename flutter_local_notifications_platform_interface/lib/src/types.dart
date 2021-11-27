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

/// Details of an active notification.
class ActiveNotification {
  /// Constructs an instance of [ActiveNotification].
  const ActiveNotification({
    required this.id,
    this.groupKey,
    this.channelId,
    this.title,
    this.body,
    this.payload,
  });

  /// The notification's id.
  final int id;

  /// The notification's channel id.
  ///
  /// Returned only on Android 8.0 or newer.
  final String? channelId;

  /// The notification's group.
  ///
  /// Returned only on Android.
  final String? groupKey;

  /// The notification's title.
  final String? title;

  /// The notification's body.
  final String? body;

  /// The notification's payload.
  final String? payload;
}
