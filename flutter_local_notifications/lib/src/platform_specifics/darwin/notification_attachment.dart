/// Represents an attachment for a notification on Darwin-based operation
/// systems such as iOS and macOS
class DarwinNotificationAttachment {
  /// Constructs an instance of [DarwinNotificationAttachment].
  const DarwinNotificationAttachment(
    this.filePath, {
    this.identifier,
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
}
