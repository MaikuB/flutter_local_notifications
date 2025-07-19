/// Defines metadata to be set for the notification's chat bubble
/// See: https://developer.android.com/develop/ui/views/notifications/bubbles
class BubbleMetadata {
  /// Encapsulates the information needed to display a notification as a bubble.
  /// A bubble is used to display app content in a floating window over the
  /// existing foreground activity. A bubble has a collapsed state represented
  /// by an icon and an expanded state that displays an activity.
  /// - https://developer.android.com/reference/android/app/Notification.BubbleMetadata
  BubbleMetadata(
    this.activity, {
    this.extra,
    this.autoExpand,
    this.desiredHeight,
  });

  /// Define which activity should be started by the bubble
  /// This activity needs to be declared in your android Manfiest.xml
  /// As well as in the native code
  final String activity;

  /// Pass additional data to the bubble activities intent
  final String? extra;

  /// the ideal height, in DPs, for the floating window created by this activity
  final int? desiredHeight;

  /// whether this bubble should auto expand when it is posted.
  final bool? autoExpand;
}
