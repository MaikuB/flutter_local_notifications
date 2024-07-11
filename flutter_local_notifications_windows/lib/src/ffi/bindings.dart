// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as pkg_ffi;

/// Bindings for `src/ffi_api.h`.
///
/// Regenerate bindings with `dart run ffigen --config ffigen.yaml`.
///
class NotificationsPluginBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NotificationsPluginBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NotificationsPluginBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ffi.Pointer<NativePlugin> createPlugin() {
    return _createPlugin();
  }

  late final _createPluginPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<NativePlugin> Function()>>(
          'createPlugin');
  late final _createPlugin =
      _createPluginPtr.asFunction<ffi.Pointer<NativePlugin> Function()>();

  void disposePlugin(
    ffi.Pointer<NativePlugin> ptr,
  ) {
    return _disposePlugin(
      ptr,
    );
  }

  late final _disposePluginPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<NativePlugin>)>>(
          'disposePlugin');
  late final _disposePlugin =
      _disposePluginPtr.asFunction<void Function(ffi.Pointer<NativePlugin>)>();

  int init(
    ffi.Pointer<NativePlugin> plugin,
    ffi.Pointer<pkg_ffi.Utf8> appName,
    ffi.Pointer<pkg_ffi.Utf8> aumId,
    ffi.Pointer<pkg_ffi.Utf8> guid,
    ffi.Pointer<pkg_ffi.Utf8> iconPath,
    NativeNotificationCallback callback,
  ) {
    return _init(
      plugin,
      appName,
      aumId,
      guid,
      iconPath,
      callback,
    );
  }

  late final _initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<NativePlugin>,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>,
              NativeNotificationCallback)>>('init');
  late final _init = _initPtr.asFunction<
      int Function(
          ffi.Pointer<NativePlugin>,
          ffi.Pointer<pkg_ffi.Utf8>,
          ffi.Pointer<pkg_ffi.Utf8>,
          ffi.Pointer<pkg_ffi.Utf8>,
          ffi.Pointer<pkg_ffi.Utf8>,
          NativeNotificationCallback)>();

  int showNotification(
    ffi.Pointer<NativePlugin> plugin,
    int id,
    ffi.Pointer<pkg_ffi.Utf8> xml,
    NativeStringMap bindings,
  ) {
    return _showNotification(
      plugin,
      id,
      xml,
      bindings,
    );
  }

  late final _showNotificationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<NativePlugin>, ffi.Int,
              ffi.Pointer<pkg_ffi.Utf8>, NativeStringMap)>>('showNotification');
  late final _showNotification = _showNotificationPtr.asFunction<
      int Function(ffi.Pointer<NativePlugin>, int, ffi.Pointer<pkg_ffi.Utf8>,
          NativeStringMap)>();

  int scheduleNotification(
    ffi.Pointer<NativePlugin> plugin,
    int id,
    ffi.Pointer<pkg_ffi.Utf8> xml,
    int time,
  ) {
    return _scheduleNotification(
      plugin,
      id,
      xml,
      time,
    );
  }

  late final _scheduleNotificationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<NativePlugin>, ffi.Int,
              ffi.Pointer<pkg_ffi.Utf8>, ffi.Int)>>('scheduleNotification');
  late final _scheduleNotification = _scheduleNotificationPtr.asFunction<
      int Function(
          ffi.Pointer<NativePlugin>, int, ffi.Pointer<pkg_ffi.Utf8>, int)>();

  int updateNotification(
    ffi.Pointer<NativePlugin> plugin,
    int id,
    NativeStringMap bindings,
  ) {
    return _updateNotification(
      plugin,
      id,
      bindings,
    );
  }

  late final _updateNotificationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<NativePlugin>, ffi.Int,
              NativeStringMap)>>('updateNotification');
  late final _updateNotification = _updateNotificationPtr.asFunction<
      int Function(ffi.Pointer<NativePlugin>, int, NativeStringMap)>();

  void cancelAll(
    ffi.Pointer<NativePlugin> plugin,
  ) {
    return _cancelAll(
      plugin,
    );
  }

  late final _cancelAllPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<NativePlugin>)>>(
          'cancelAll');
  late final _cancelAll =
      _cancelAllPtr.asFunction<void Function(ffi.Pointer<NativePlugin>)>();

  void cancelNotification(
    ffi.Pointer<NativePlugin> plugin,
    int id,
  ) {
    return _cancelNotification(
      plugin,
      id,
    );
  }

  late final _cancelNotificationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<NativePlugin>, ffi.Int)>>('cancelNotification');
  late final _cancelNotification = _cancelNotificationPtr
      .asFunction<void Function(ffi.Pointer<NativePlugin>, int)>();

  ffi.Pointer<NativeNotificationDetails> getActiveNotifications(
    ffi.Pointer<NativePlugin> plugin,
    ffi.Pointer<ffi.Int> size,
  ) {
    return _getActiveNotifications(
      plugin,
      size,
    );
  }

  late final _getActiveNotificationsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<NativeNotificationDetails> Function(
              ffi.Pointer<NativePlugin>,
              ffi.Pointer<ffi.Int>)>>('getActiveNotifications');
  late final _getActiveNotifications = _getActiveNotificationsPtr.asFunction<
      ffi.Pointer<NativeNotificationDetails> Function(
          ffi.Pointer<NativePlugin>, ffi.Pointer<ffi.Int>)>();

  ffi.Pointer<NativeNotificationDetails> getPendingNotifications(
    ffi.Pointer<NativePlugin> plugin,
    ffi.Pointer<ffi.Int> size,
  ) {
    return _getPendingNotifications(
      plugin,
      size,
    );
  }

  late final _getPendingNotificationsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<NativeNotificationDetails> Function(
              ffi.Pointer<NativePlugin>,
              ffi.Pointer<ffi.Int>)>>('getPendingNotifications');
  late final _getPendingNotifications = _getPendingNotificationsPtr.asFunction<
      ffi.Pointer<NativeNotificationDetails> Function(
          ffi.Pointer<NativePlugin>, ffi.Pointer<ffi.Int>)>();

  void freeDetailsArray(
    ffi.Pointer<NativeNotificationDetails> ptr,
  ) {
    return _freeDetailsArray(
      ptr,
    );
  }

  late final _freeDetailsArrayPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<NativeNotificationDetails>)>>('freeDetailsArray');
  late final _freeDetailsArray = _freeDetailsArrayPtr
      .asFunction<void Function(ffi.Pointer<NativeNotificationDetails>)>();

  void freeLaunchDetails(
    NativeLaunchDetails details,
  ) {
    return _freeLaunchDetails(
      details,
    );
  }

  late final _freeLaunchDetailsPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(NativeLaunchDetails)>>(
          'freeLaunchDetails');
  late final _freeLaunchDetails =
      _freeLaunchDetailsPtr.asFunction<void Function(NativeLaunchDetails)>();
}

class NativePlugin extends ffi.Opaque {}

class StringMapEntry extends ffi.Struct {
  external ffi.Pointer<pkg_ffi.Utf8> key;

  external ffi.Pointer<pkg_ffi.Utf8> value;
}

class NativeStringMap extends ffi.Struct {
  external ffi.Pointer<StringMapEntry> entries;

  @ffi.Int()
  external int size;
}

class NativeNotificationDetails extends ffi.Struct {
  @ffi.Int()
  external int id;
}

abstract class NativeLaunchType {
  static const int notification = 0;
  static const int action = 1;
}

class NativeLaunchDetails extends ffi.Struct {
  @ffi.Int()
  external int didLaunch;

  @ffi.Int32()
  external int launchType;

  external ffi.Pointer<pkg_ffi.Utf8> payload;

  external NativeStringMap data;
}

/// See: https://learn.microsoft.com/en-us/uwp/api/windows.ui.notifications.notificationupdateresult
abstract class NativeUpdateResult {
  static const int success = 0;
  static const int failed = 1;
  static const int notFound = 2;
}

typedef NativeNotificationCallback = ffi.Pointer<
    ffi.NativeFunction<ffi.Void Function(NativeLaunchDetails details)>>;
