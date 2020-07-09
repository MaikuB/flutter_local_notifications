class ActiveNotification {
  const ActiveNotification(
    this.id,
    this.channelId,
    this.title,
    this.body,
  );

  final int id;
  final String channelId;
  final String title;
  final String body;

  toString() {
    return {
      'id': id,
      'channelId': channelId,
      'title': title,
      'body': body,
    }.toString();
  }
}
