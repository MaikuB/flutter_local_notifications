/// Represents an attachment for an iOS notification.
class IOSNotificationAttachment {
  /// Constructs an instance of [IOSNotificationAttachment].
  const IOSNotificationAttachment(
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
  /// When left empty, the iOS APIs will generate a unique identifier
  final String? identifier;
}
