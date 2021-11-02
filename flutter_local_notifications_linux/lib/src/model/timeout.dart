import 'package:flutter/foundation.dart';

/// The timeout of the Linux notification.
@immutable
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxNotificationTimeout && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LinuxNotificationTimeout(value: $value)';
}
