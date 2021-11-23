import 'package:flutter/foundation.dart';

/// Represents a Linux notification information
@immutable
class LinuxNotificationInfo {
  /// Constructs an instance of [LinuxPlatformInfoData].
  const LinuxNotificationInfo({
    required this.id,
    required this.systemId,
    this.payload,
  });

  /// Constructs an instance of [LinuxPlatformInfoData] from [json].
  factory LinuxNotificationInfo.fromJson(Map<String, dynamic> json) =>
      LinuxNotificationInfo(
        id: json['id'] as int,
        systemId: json['systemId'] as int,
        payload: json['payload'] as String?,
      );

  /// Notification id
  final int id;

  /// Notification id, which is returned by the system,
  /// see Desktop Notifications Specification https://specifications.freedesktop.org/notification-spec/latest/
  final int systemId;

  /// Notification payload, that will be passed back to the app
  /// when a notification is tapped on.
  final String? payload;

  /// Returns the object as a key-value map
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'systemId': systemId,
        'payload': payload,
      };

  /// Creates a copy of this object,
  /// but with the given fields replaced with the new values.
  LinuxNotificationInfo copyWith({
    int? id,
    int? systemId,
    String? payload,
  }) =>
      LinuxNotificationInfo(
        id: id ?? this.id,
        systemId: systemId ?? this.systemId,
        payload: payload ?? this.payload,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxNotificationInfo &&
        other.id == id &&
        other.systemId == systemId &&
        other.payload == payload;
  }

  @override
  int get hashCode => id.hashCode ^ systemId.hashCode ^ payload.hashCode;
}
