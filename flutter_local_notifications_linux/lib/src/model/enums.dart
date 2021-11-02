import 'icon.dart';

/// The urgency level of the Linux notification.
class LinuxNotificationUrgency {
  /// Constructs an instance of [LinuxNotificationUrgency].
  const LinuxNotificationUrgency(this.value);

  /// Low urgency. Used for unimportant notifications.
  static const LinuxNotificationUrgency low = LinuxNotificationUrgency(0);

  /// Normal urgency. Used for most standard notifications.
  static const LinuxNotificationUrgency normal = LinuxNotificationUrgency(1);

  /// Critical urgency. Used for very important notifications.
  static const LinuxNotificationUrgency critical = LinuxNotificationUrgency(2);

  /// All the possible values for the [LinuxNotificationUrgency] enumeration.
  static List<LinuxNotificationUrgency> get values =>
      <LinuxNotificationUrgency>[low, normal, critical];

  /// The integer representation.
  final int value;
}

/// Specifies the Linux notification icon type.
enum LinuxIconType {
  /// Icon from the Flutter Assets directory, see [AssetsLinuxIcon]
  assets,

  /// Icon from a raw image data bytes, see [ByteDataLinuxIcon].
  byteData,

  /// System theme icon, see [ThemeLinuxIcon].
  theme,
}

/// Specifies the Linux notification sound type.
enum LinuxSoundType {
  /// Sound from the Flutter Assets directory, see [AssetsLinuxSound]
  assets,

  /// System theme sound, see [ThemeLinuxSound].
  theme,
}

/// Represents the notification hint value type.
enum LinuxHintValueType {
  /// Ordered list of values of the same type.
  array,

  /// Boolean value.
  boolean,

  /// Unsigned 8 bit value.
  byte,

  /// Associative array of values.
  dict,

  /// 64-bit floating point value.
  double,

  /// Signed 16-bit integer.
  int16,

  /// Signed 32-bit integer.
  int32,

  /// Signed 64-bit integer.
  int64,

  /// Unicode text string.
  string,

  /// Value that contains a fixed set of other values.
  struct,

  /// Unsigned 16-bit integer.
  uint16,

  /// Unsigned 32-bit integer.
  uint32,

  /// Unsigned 64-bit integer.
  uint64,

  /// Value that contains any type.
  variant,
}
