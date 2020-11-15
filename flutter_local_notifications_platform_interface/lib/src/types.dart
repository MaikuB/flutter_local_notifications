/// The available intervals for periodically showing notifications.
enum RepeatInterval { everyMinute, hourly, daily, weekly }

/// Details of a pending notification that has not been delivered.
class PendingNotificationRequest {
  const PendingNotificationRequest(
      this.id, this.title, this.body, this.payload);

  /// The notification's id.
  final int id;

  /// The notification's title.
  final String title;

  /// The notification's body.
  final String body;

  /// The notification's payload.
  final String payload;
}
