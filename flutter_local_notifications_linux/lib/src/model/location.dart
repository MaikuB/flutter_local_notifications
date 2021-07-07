import 'package:flutter/foundation.dart';

/// Represents the location on the screen that the notification should point to.
@immutable
class LinuxNotificationLocation {
  /// Constructs an instance of [LinuxNotificationLocation]
  const LinuxNotificationLocation(this.x, this.y);

  /// Represents the `X` location on the screen that the notification
  /// should point to.
  final int x;

  /// Represents the `Y` location on the screen that the notification
  /// should point to.
  final int y;

  /// Creates a copy of this object,
  /// but with the given fields replaced with the new values.
  LinuxNotificationLocation copyWith({
    int? x,
    int? y,
  }) =>
      LinuxNotificationLocation(x ?? this.x, y ?? this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxNotificationLocation && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'LinuxNotificationLocation(x: $x, y: $y)';
}
