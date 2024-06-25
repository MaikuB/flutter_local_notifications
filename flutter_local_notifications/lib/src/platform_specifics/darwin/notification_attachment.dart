/// Represents an attachment for a notification on Darwin-based operation
/// systems such as iOS and macOS
class DarwinNotificationAttachment {
  /// Constructs an instance of [DarwinNotificationAttachment].
  const DarwinNotificationAttachment(
    this.filePath, {
    this.identifier,
    this.hideThumbnail,
    this.thumbnailClippingRect,
  });

  /// The local file path to the attachment.
  ///
  /// See the documentation at https://developer.apple.com/documentation/usernotifications/unnotificationattachment?language=objc
  /// for details on the supported file types and the file size restrictions.
  final String filePath;

  /// The unique identifier for the attachment.
  ///
  /// When left empty, the platform's native APIs will generate a unique
  /// identifier
  final String? identifier;

  /// Should the attachment be considered for the notification thumbnail?
  final bool? hideThumbnail;

  /// The clipping rectangle for the thumbnail image.
  final DarwinNotificationAttachmentThumbnailClippingRect?
      thumbnailClippingRect;
}

/// Represents the clipping rectangle used for the thumbnail image.
class DarwinNotificationAttachmentThumbnailClippingRect {
  /// Constructs an instance of
  /// [DarwinNotificationAttachmentThumbnailClippingRect].
  const DarwinNotificationAttachmentThumbnailClippingRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Horizontal offset of the rectangle as proportion of the original image.
  ///
  /// Value in the range from 0.0 to 1.0.
  final double x;

  /// Vertical offset of the rectangle as proportion of the original image.
  ///
  /// Value in the range from 0.0 to 1.0.
  final double y;

  /// Width of the rectangle as proportion of the original image.
  ///
  /// Value in the range from 0.0 to 1.0.
  final double width;

  /// Height of the rectangle as proportion of the original image.
  ///
  /// Value in the range from 0.0 to 1.0.
  final double height;
}
