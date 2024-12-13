import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import '../details.dart';
import '../plugin/base.dart';
import 'bindings.dart';

/// Helpful methods on native string maps.
extension NativeStringMapUtils on NativeStringMap {
  /// Converts this map to a typical Dart map.
  Map<String, String> toDart() => <String, String>{
        for (int index = 0; index < size; index++)
          entries[index].key.toDartString():
              entries[index].value.toDartString(),
      };
}

/// Gets the [NotificationResponseType] from a [NativeLaunchType].
extension NativeLaunchTypeUtils on NativeLaunchType {
  /// Gets the [NotificationResponseType] from a [NativeLaunchType].
  NotificationResponseType toDart() => switch (this) {
        NativeLaunchType.notification =>
          NotificationResponseType.selectedNotification,
        NativeLaunchType.action =>
          NotificationResponseType.selectedNotificationAction,
      };
}

/// Gets the [NotificationUpdateResult] from a [NativeUpdateResult].
extension NativeUpdateResultUtils on NativeUpdateResult {
  /// Gets the [NotificationUpdateResult] from a [NativeUpdateResult].
  NotificationUpdateResult toDart() => switch (this) {
        NativeUpdateResult.success => NotificationUpdateResult.success,
        NativeUpdateResult.failed => NotificationUpdateResult.error,
        NativeUpdateResult.notFound => NotificationUpdateResult.notFound,
      };
}

/// Helpful methods on string maps.
extension MapToNativeMap on Map<String, String> {
  /// Allocates a [NativeStringMap] using the provided arena.
  NativeStringMap toNativeMap(Arena arena) {
    final Pointer<NativeStringMap> pointer = arena<NativeStringMap>();
    pointer.ref.size = length;
    pointer.ref.entries = arena<StringMapEntry>(length);
    int index = 0;
    for (final MapEntry<String, String> entry in entries) {
      pointer.ref.entries[index].key = entry.key.toNativeUtf8(allocator: arena);
      pointer.ref.entries[index].value =
          entry.value.toNativeUtf8(allocator: arena);
      index++;
    }
    return pointer.ref;
  }
}

/// Helpful methods on native notification details.
extension NativeNotificationDetailsUtils on Pointer<NativeNotificationDetails> {
  /// Parses this array as a list of [ActiveNotification]s.
  List<ActiveNotification> asActiveNotifications(int length) =>
      <ActiveNotification>[
        for (int index = 0; index < length; index++)
          ActiveNotification(id: this[index].id),
      ];

  /// Parses this array os a list of [PendingNotificationRequest]s.
  List<PendingNotificationRequest> asPendingRequests(int length) =>
      <PendingNotificationRequest>[
        for (int index = 0; index < length; index++)
          PendingNotificationRequest(this[index].id, null, null, null),
      ];
}
