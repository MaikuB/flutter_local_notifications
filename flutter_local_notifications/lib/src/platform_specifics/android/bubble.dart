/// Defines metadata to be set for the notification's chat bubble
/// See: https://developer.android.com/develop/ui/views/notifications/bubbles
class BubbleMetadata {
  final String activity;
  final String? extra;
  final int? desiredHeight;
  final bool? autoExpand;

  BubbleMetadata(
    this.activity, {
    this.extra,
    this.autoExpand,
    this.desiredHeight,
  });
}
