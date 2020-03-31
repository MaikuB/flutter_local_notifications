/// Represents an attachment for an iOS notification.
class IOSNotificationAttachment {
  const IOSNotificationAttachment(
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
  /// When left empty, the iOS APIs will generate a unique identifier
  final String identifier;

  /// Creates a [Map] object that describes the [IOSNotificationAttachment] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identifier': identifier ?? '',
      'filePath': filePath,
    };
  }
}
