import 'enums.dart';

/// Details of a person e.g. someone who sent a message.
class Person {
  /// Whether or not this person represents a machine rather than a human.
  final bool bot;

  /// Icon for this person.
  final String icon;

  /// Determines how the icon should be interpreted/resolved e.g. as a drawable.
  final IconSource iconSource;

  /// Whether or not this is an important person.
  final bool important;

  /// Unique identifier for this person.
  final String key;

  /// Name of this person.
  final String name;

  /// Uri for this person.
  final String uri;

  Person(
      {this.bot,
      this.icon,
      this.iconSource,
      this.important,
      this.key,
      this.name,
      this.uri});

  /// Create a [Map] object that describes the [Person] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bot': bot,
      'icon': icon,
      'iconSource': iconSource?.index,
      'important': important,
      'key': key,
      'name': name,
      'uri': uri
    };
  }
}
