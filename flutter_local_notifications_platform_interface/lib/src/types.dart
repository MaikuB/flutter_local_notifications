/// The available intervals for periodically showing notifications
enum RepeatInterval { everyMinute, hourly, daily, weekly }

/// Details of a pending notification that has not been delivered
class PendingNotificationRequest {
  const PendingNotificationRequest(
      this.id, this.title, this.body, this.payload);

  final int id;
  final String title;
  final String body;
  final String payload;
}
