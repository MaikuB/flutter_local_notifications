import "dart:ffi";

import "package:ffi/ffi.dart";
import "package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart";
import "package:flutter_local_notifications_windows/src/plugin/base.dart";

import "bindings.dart";
import "../details.dart";

typedef NativeCallbackType = Void Function(NativeLaunchDetails details);

extension NativeStringMapUtils on NativeStringMap {
  Map<String, String> toMap() => {
    for (var index = 0; index < size; index++)
      entries[index].key.toDartString(): entries[index].value.toDartString(),
  };
}

extension IntUtils on int {
  bool toBool() => this == 1;
}

NotificationResponseType getResponseType(int launchType) {
  switch (launchType) {
    case NativeLaunchType.notification: return NotificationResponseType.selectedNotification;
    case NativeLaunchType.action: return NotificationResponseType.selectedNotificationAction;
    default: throw ArgumentError("Invalid launch type: $launchType");
  }
}

NotificationUpdateResult getUpdateResult(int result) {
  switch (result) {
    case 0: return NotificationUpdateResult.success;
    case 1: return NotificationUpdateResult.error;
    case 2: return NotificationUpdateResult.notFound;
    default: throw ArgumentError("Invalid update result: $result");
  }
}

extension MapToNativeMap on Map<String, String> {
  NativeStringMap toNativeMap(Arena arena) {
    final pointer = arena<NativeStringMap>();
    pointer.ref.size = length;
    pointer.ref.entries = arena<StringMapEntry>(length);
    var index = 0;
    for (final entry in entries) {
      pointer.ref.entries[index].key = entry.key.toNativeUtf8(allocator: arena);
      pointer.ref.entries[index].value = entry.value.toNativeUtf8(allocator: arena);
      index++;
    }
    return pointer.ref;
  }
}

List<ActiveNotification> parseActiveNotifications(Pointer<NativeNotificationDetails> array, int length) => [
  for (var index = 0; index < length; index++)
    ActiveNotification(id: array[index].id),
];

List<PendingNotificationRequest> parsePendingNotifications(Pointer<NativeNotificationDetails> array, int length) => [
  for (var index = 0; index < length; index++)
    PendingNotificationRequest(array[index].id, null, null, null),
];
