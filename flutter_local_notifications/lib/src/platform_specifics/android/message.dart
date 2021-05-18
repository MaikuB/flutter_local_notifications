import 'person.dart';

/// Represents a message used in Android messaging style notifications.
class Message {
  /// Constructs an instance of [Message].
  const Message(
    this.text,
    this.timestamp,
    this.person, {
    this.dataMimeType,
    this.dataUri,
  }) : assert(
          (dataMimeType == null && dataUri == null) ||
              (dataMimeType != null && dataUri != null),
          'Must provide both dataMimeType and dataUri together or not at all.',
        );

  /// The message text
  final String text;

  /// Time at which the message arrived.
  ///
  /// Note that this is eventually converted to milliseconds since epoch as
  /// required by Android.
  final DateTime timestamp;

  /// Person that sent this message.
  ///
  /// When this is set to `null` the `Person` given to
  /// [MessagingStyleInformation.person] i.e. this would indicate that the
  /// message was sent from the user.
  final Person? person;

  /// MIME type for this message context when the [dataUri] is provided.
  final String? dataMimeType;

  /// Uri containing the content.
  ///
  /// The original text will be used if the content or MIME type isn't supported
  final String? dataUri;
}
