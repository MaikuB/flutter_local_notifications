import 'package:flutter/foundation.dart';

/// Represents a Linux notification information
@immutable
class LinuxNotificationInfo {
  /// Constructs an instance of [LinuxPlatformInfoData].
  const LinuxNotificationInfo({
    required this.id,
    this.payload,
    this.actions = const <LinuxNotificationActionInfo>[],
  });

  /// Constructs an instance of [LinuxPlatformInfoData] from [json].
  factory LinuxNotificationInfo.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? actionsJson = json['actions'] as List<dynamic>?;
    final List<LinuxNotificationActionInfo>? actions = actionsJson
        // ignore: avoid_annotating_with_dynamic
        ?.map((dynamic json) =>
            LinuxNotificationActionInfo.fromJson(json as Map<String, dynamic>))
        .toList();
    return LinuxNotificationInfo(
      id: json['id'] as int,
      payload: json['payload'] as String?,
      actions: actions ?? <LinuxNotificationActionInfo>[],
    );
  }

  /// Notification id
  final int id;

  /// Notification payload, that will be passed back to the app
  /// when a notification is tapped on.
  final String? payload;

  /// List of actions info
  final List<LinuxNotificationActionInfo> actions;

  /// Returns the object as a key-value map
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'payload': payload,
        'actions':
            actions.map((LinuxNotificationActionInfo a) => a.toJson()).toList(),
      };

  /// Creates a copy of this object,
  /// but with the given fields replaced with the new values.
  LinuxNotificationInfo copyWith({
    int? id,
    int? systemId,
    String? payload,
    List<LinuxNotificationActionInfo>? actions,
  }) =>
      LinuxNotificationInfo(
        id: id ?? this.id,
        payload: payload ?? this.payload,
        actions: actions ?? this.actions,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxNotificationInfo &&
        other.id == id &&
        other.payload == payload &&
        listEquals(other.actions, actions);
  }

  @override
  int get hashCode => id.hashCode ^ payload.hashCode ^ actions.hashCode;
}

/// Represents a Linux notification action information
@immutable
class LinuxNotificationActionInfo {
  /// Constructs an instance of [LinuxNotificationActionInfo].
  const LinuxNotificationActionInfo({
    required this.key,
  });

  /// Constructs an instance of [LinuxNotificationActionInfo] from [json].
  factory LinuxNotificationActionInfo.fromJson(Map<String, dynamic> json) =>
      LinuxNotificationActionInfo(key: json['key'] as String);

  /// Unique action key.
  final String key;

  /// Returns the object as a key-value map
  Map<String, dynamic> toJson() => <String, dynamic>{'key': key};

  /// Creates a copy of this object,
  /// but with the given fields replaced with the new values.
  LinuxNotificationActionInfo copyWith({
    String? key,
    String? payload,
  }) =>
      LinuxNotificationActionInfo(key: key ?? this.key);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxNotificationActionInfo && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
