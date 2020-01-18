/// The available intervals for periodically showing notifications
enum RepeatInterval { EveryMinute, Hourly, Daily, Weekly }

/// Details of a pending notification that has not been delivered
class PendingNotificationRequest {
  final int id;
  final String title;
  final String body;
  final String payload;

  const PendingNotificationRequest(
      this.id, this.title, this.body, this.payload);
}
