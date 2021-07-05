import 'enums.dart';

/// Represents Linux notification sound.
abstract class LinuxNotificationSound {
  /// Implementation-defined sound content.
  Object get content;

  /// Defines the type of sound.
  LinuxSoundType get type;
}

/// Represents a sound from the Flutter Assets directory.
class AssetsLinuxSound extends LinuxNotificationSound {
  /// Constructs an instance of [AssetsLinuxSound].
  AssetsLinuxSound(this.relativePath);

  @override
  Object get content => relativePath;

  @override
  LinuxSoundType get type => LinuxSoundType.assets;

  /// Sound relative path inside the Flutter Assets directory
  final String relativePath;
}

/// Represents a system theme sound.
/// See https://www.freedesktop.org/wiki/Specifications/sound-theme-spec/ for more help.
class ThemeLinuxSound extends LinuxNotificationSound {
  /// Constructs an instance of [ThemeLinuxSound].
  ThemeLinuxSound(this.name);

  @override
  Object get content => name;

  @override
  LinuxSoundType get type => LinuxSoundType.theme;

  /// A themeable named sound from the
  /// freedesktop.org sound naming specification http://0pointer.de/public/sound-naming-spec.html
  final String name;
}
