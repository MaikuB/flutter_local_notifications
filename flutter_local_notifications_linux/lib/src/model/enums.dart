import 'icon.dart';

/// Categories of notifications.
///
/// Corresponds to https://specifications.freedesktop.org/notification-spec/notification-spec-latest.html#categories
enum LinuxNotificationCategory {
  /// A generic device-related notification
  /// that doesn't fit into any other category.
  device('device'),

  /// A device, such as a USB device, was added to the system.
  deviceAdded('device.added'),

  /// A device had some kind of error.
  deviceError('device.error'),

  /// A device, such as a USB device, was removed from the system.
  deviceRemoved('device.removed'),

  /// A generic e-mail-related notification
  /// that doesn't fit into any other category.
  email('email'),

  /// A new e-mail notification.
  emailArrived('email.arrived'),

  /// A notification stating that an e-mail has bounced.
  emailBounced('email.bounced'),

  /// A generic instant message-related notification
  /// that doesn't fit into any other
  im('im'),

  /// An instant message error notification.
  imError('im.error'),

  /// A received instant message notification.
  imReceived('im.received'),

  /// A generic network notification that
  /// doesn't fit into any other category.
  network('network'),

  /// A network connection notification,
  /// such as successful sign-on to a network service.
  /// This should not be confused with
  /// [deviceAdded] for new network devices.
  networkConnected('network.connected'),

  /// A network disconnected notification.
  /// This should not be confused with [deviceRemoved]
  /// for disconnected network devices.
  networkDisconnected('network.disconnected'),

  /// A network-related or connection-related error.
  networkError('network.error'),

  /// A generic presence change notification
  /// that doesn't fit into any other category, such as going away or idle.
  presence('presence'),

  /// An offline presence change notification.
  presenceOffile('presence.offline'),

  /// An online presence change notification.
  presenceOnline('presence.online'),

  /// A generic file transfer or download notification
  /// that doesn't fit into any other category.
  transfer('transfer'),

  /// A file transfer or download complete notification.
  transferComplete('transfer.complete'),

  /// A file transfer or download error.
  transferError('transfer.error');

  /// Constructs an instance of [LinuxNotificationCategory]
  /// with a given [name] of category.
  const LinuxNotificationCategory(this.name);

  /// Name of category.
  final String name;
}

/// The urgency level of the Linux notification.
///
/// Corresponds to https://specifications.freedesktop.org/notification-spec/notification-spec-latest.html#urgency-levels
enum LinuxNotificationUrgency {
  /// Low urgency. Used for unimportant notifications.
  low,

  /// Normal urgency. Used for most standard notifications.
  normal,

  /// Critical urgency. Used for very important notifications.
  critical
}

/// Specifies the Linux notification icon type.
enum LinuxIconType {
  /// Icon from the Flutter Assets directory, see [AssetsLinuxIcon]
  assets,

  /// Icon from a raw image data bytes, see [ByteDataLinuxIcon].
  byteData,

  /// System theme icon, see [ThemeLinuxIcon].
  theme,

  /// Icon located at the path in the file system, see [FilePathLinuxIcon].
  filePath,
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
