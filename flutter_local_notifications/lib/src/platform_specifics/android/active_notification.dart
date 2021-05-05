/// Contains details on active Android notification that is currently displayed
/// within the status bar.
class ActiveNotification {
  /// Constructs an instance of [ActiveNotification].
  const ActiveNotification(
    this.id,
    this.channelId,
    this.title,
    this.body,
  );

  /// The notification's id.
  final int id;

  /// The notification channel's id.
  ///
  /// Returned only on Android 8.0 or newer.
  final String? channelId;

  /// The notification's title.
  final String? title;

  /// The notification's content.
  final String? body;
}
