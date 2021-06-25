/// The timeout of the Linux notification.
class LinuxNotificationTimeout {
  /// Constructs an instance of [LinuxNotificationTimeout]
  /// with a given [value] in milliseconds.
  const LinuxNotificationTimeout(this.value);

  /// Constructs an instance of [LinuxNotificationTimeout]
  /// with a given [Duration] value.
  LinuxNotificationTimeout.fromDuration(Duration duration)
      : value = duration.inMilliseconds;

  /// Constructs an instance of [LinuxNotificationTimeout]
  /// with a [value] equal to `-1`.
  /// The system default timeout value will be used.
  const LinuxNotificationTimeout.systemDefault() : value = -1;

  /// Constructs an instance of [LinuxNotificationTimeout]
  /// with a [value] equal to `0`. The notification will be never expires.
  const LinuxNotificationTimeout.expiresNever() : value = 0;

  /// The integer representation in milliseconds.
  final int value;
}
