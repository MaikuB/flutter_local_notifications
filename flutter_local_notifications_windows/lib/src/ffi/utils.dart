import "dart:ffi";

import "package:ffi/ffi.dart";
import "package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart";
import "package:flutter_local_notifications_windows/src/plugin/base.dart";

import "bindings.dart";
import "../details.dart";

typedef NativeCallbackType = Void Function(Pointer<NativeLaunchDetails> details);

extension PairUtils on Pointer<Pair> {
  Map<String, String> toMap(int length) => {
    for (var index = 0; index < length; index++)
      this[index].key.toDartString(): this[index].value.toDartString(),
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

extension MapToPairs on Map<String, String> {
  Pointer<Pair> toPairs(Arena arena) {
    final pairs = arena.call<Pair>(length);
    var index = 0;
    for (final entry in entries) {
      final pair = pairs[index++];
      pair.key = entry.key.toNativeUtf8(allocator: arena);
      pair.value = entry.value.toNativeUtf8(allocator: arena);
    }
    return pairs;
  }
}

List<ActiveNotification> parseActiveNotifications(Pointer<NativeDetails> array, int length) => [
  for (var index = 0; index < length; index++)
    ActiveNotification(id: array[index].id),
];

List<PendingNotificationRequest> parsePendingNotifications(Pointer<NativeDetails> array, int length) => [
  for (var index = 0; index < length; index++)
    PendingNotificationRequest(array[index].id, null, null, null),
];
