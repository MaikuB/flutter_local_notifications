
/// Represents notification attachment for iOS
class IOSNotificationAttachment {
  /// Identifier for the attachment.
  final String identifier;

  /// Local file path to the attachment.
  final String filePath;

  IOSNotificationAttachment(this.identifier, this.filePath);

  /// Create a [Map] object that describes the [IOSNotificationAttachment] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identifier': identifier,
      'filePath': filePath
    };
  }
}
