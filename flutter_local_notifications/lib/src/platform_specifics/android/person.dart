import 'icon.dart';

/// Details of a person e.g. someone who sent a message.
class Person {
  /// Constructs an instance of [Person].
  const Person({
    this.bot,
    this.icon,
    this.important,
    this.key,
    this.name,
    this.uri,
  });

  /// Whether or not this person represents a machine rather than a human.
  final bool bot;

  /// Icon for this person.
  final AndroidIcon icon;

  /// Whether or not this is an important person.
  final bool important;

  /// Unique identifier for this person.
  final String key;

  /// Name of this person.
  final String name;

  /// Uri for this person.
  final String uri;
}
