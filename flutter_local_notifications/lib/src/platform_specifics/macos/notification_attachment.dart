/// Represents an attachment for an macOS notification.
class MacOSNotificationAttachment {
  /// Constructs an instance of [MacOSNotificationAttachment].
  const MacOSNotificationAttachment(
    this.filePath, {
    this.identifier,
  }) : assert(filePath != null);

  /// The local file path to the attachment.
  ///
  /// See the documentation at https://developer.apple.com/documentation/usernotifications/unnotificationattachment?language=objc
  /// for details on the supported file types and the file size restrictions.
  final String filePath;

  /// The unique identifier for the attachment.
  ///
  /// When left empty, the macOS APIs will generate a unique identifier
  final String identifier;
}
