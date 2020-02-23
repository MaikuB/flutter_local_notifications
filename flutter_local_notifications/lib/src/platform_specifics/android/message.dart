import 'person.dart';

/// Represents a message used in Android messaging style notifications.
class Message {
  /// The message text
  final String text;

  /// Time at which the message arrived.
  ///
  /// Note that this is eventually converted to milliseconds since epoch as required by Android.
  final DateTime timestamp;

  /// Person that sent this message.
  final Person person;

  /// MIME type for this message context when the [dataUri] is provided.
  final String dataMimeType;

  /// Uri containing the content.
  ///
  /// The original text will be used if the content or MIME type isn't supported
  final String dataUri;

  Message(this.text, this.timestamp, this.person,
      {this.dataMimeType, this.dataUri}) {
    assert(timestamp != null, 'timestamp must be provided');
    assert(
        (dataMimeType == null && dataUri == null) ||
            (dataMimeType != null && dataUri != null),
        'Must provide both dataMimeType and dataUri together or not at all.');
  }

  /// Create a [Map] object that describes the [Message] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'person': person?.toMap(),
      'dataMimeType': dataMimeType,
      'dataUri': dataUri
    };
  }
}
