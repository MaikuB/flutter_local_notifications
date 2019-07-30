class PendingNotificationRequest {
  final int id;
  final String title;
  final String body;
  final String payload;
  final Map<dynamic, dynamic> data;

  const PendingNotificationRequest(
      this.id, this.title, this.body, this.payload, this.data);
}
