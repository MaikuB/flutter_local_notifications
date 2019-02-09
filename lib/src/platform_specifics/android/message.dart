part of flutter_local_notifications;

class Message {
  final String text;
  final DateTime timestamp;
  final Person person;
  final String dataMimeType;
  final String dataUri;

  Message(this.text, this.timestamp, this.person,
      {this.dataMimeType, this.dataUri}) {
    assert(text != null && timestamp != null,
        'text and timestamp must be provided');
    assert(
        (dataMimeType == null && dataUri == null) ||
            (dataMimeType != null && dataUri != null),
        'Must provide both dataMimeType and dataUri together or not at all.');
  }

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
