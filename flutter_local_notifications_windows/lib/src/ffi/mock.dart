// Just a mock, doesn't need real types or safety.
// ignore_for_file: type_annotate_public_apis, always_specify_types

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';

/// Mocked FFI bindings.
class MockBindings implements NotificationsPluginBindings {
  @override
  void cancelAll(_) {}

  @override
  void cancelNotification(_, int id) {}

  @override
  Pointer<NativePlugin> createPlugin() => malloc<Int>().cast();

  @override
  void disposePlugin(_) {}

  @override
  void freeLaunchDetails(_) {}

  @override
  void freeDetailsArray(ptr) => malloc.free(ptr);

  @override
  Pointer<NativeNotificationDetails> getActiveNotifications(_, __) =>
      malloc<NativeNotificationDetails>();

  @override
  Pointer<NativeNotificationDetails> getPendingNotifications(_, __) =>
      malloc<NativeNotificationDetails>();

  @override
  bool hasPackageIdentity() => false;

  @override
  bool init(_, __, ___, ____, _____, ______) => true;

  @override
  bool isValidXml(ptr) => true;

  @override
  bool scheduleNotification(a, b, c, d) => true;

  @override
  bool showNotification(a, b, c, d) => true;

  @override
  NativeUpdateResult updateNotification(a, b, c) => NativeUpdateResult.success;
}
