import "dart:ffi";
import "package:ffi/ffi.dart";

import "../details.dart";
import "../ffi/bindings.dart";
import "../ffi/utils.dart";

import "base.dart";

void _globalLaunchCallback(NativeLaunchDetails details) {
  FlutterLocalNotificationsWindows.instance?._onNotificationReceived(details);
}

extension on String {
  bool get isValidGuid => length == 36
    && this[8] == "-"
    && this[13] == "-"
    && this[18] == "-"
    && this[23] == "-";
}

/// The FFI implementation of `package:flutter_local_notifications`.
class FlutterLocalNotificationsWindows extends WindowsNotificationsBase {
  /// The global instance of this plugin. Used in [_globalLaunchCallback].
  static FlutterLocalNotificationsWindows? instance;

  /// The FFI generated bindings to the native code.
  late final NotificationsPluginBindings _bindings;

  /// A pointer to the C++ handler class.
  late final Pointer<NativePlugin> _plugin;

  /// The last recorded launch details, if any.
  ///
  /// If the app is opened with a notification, this can be read with [getNotificationAppLaunchDetails].
  /// If a notification is pressed while the app is running, this will be passed to [userCallback].
  NativeLaunchDetails? _details;

  /// A user-provided callback from [initialize] to run when a notification is pressed.
  DidReceiveNotificationResponseCallback? userCallback;

  /// Creates an instance of the native plugin.
  FlutterLocalNotificationsWindows() {
    final library = DynamicLibrary.open("flutter_local_notifications_windows.dll");
    _bindings = NotificationsPluginBindings(library);
    _plugin = _bindings.createPlugin();
  }

  @override
  Future<bool> initialize(
    WindowsInitializationSettings settings, {
    DidReceiveNotificationResponseCallback? onNotificationReceived,
  }) async => using((arena) {
    // The C++ code will crash if there's an invalid GUID, so check it here first.
    if (!settings.guid.isValidGuid) {
      throw ArgumentError.value(settings.guid, "GUID", "Invalid GUID. Please use xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx format\nYou can get one by searching GUID generators online");
    }
    if (instance != null) return false;
    instance = this;
    userCallback = onNotificationReceived;
    final appName = settings.appName.toNativeUtf8(allocator: arena);
    final aumId = settings.appUserModelId.toNativeUtf8(allocator: arena);
    final guid = settings.guid.toNativeUtf8(allocator: arena);
    final iconPath = settings.iconPath?.toNativeUtf8(allocator: arena) ?? nullptr;
    final callback = NativeCallable<NativeNotificationCallbackFunction>.listener(_globalLaunchCallback).nativeFunction;
    final result = _bindings.init(_plugin, appName, aumId, guid, iconPath, callback);
    return result.toBool();
  });

  void _onNotificationReceived(NativeLaunchDetails details) {
    if (_details != null) _bindings.freeLaunchDetails(_details!);
    _details = details;
    final data = details.data.toMap();
    final response = NotificationResponse(
      notificationResponseType: getResponseType(details.launchType),
      payload: details.payload.toDartString(),
      actionId: details.payload.toDartString(),
      data: data,
    );
    userCallback?.call(response);
  }

  @override
  Future<void> cancel(int id) async => _bindings.cancelNotification(_plugin, id);

  @override
  Future<void> cancelAll() async => _bindings.cancelAll(_plugin);

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => using((arena) {
    final length = arena<Int>();
    final array = _bindings.getActiveNotifications(_plugin, length);
    final result = array.asActiveNotifications(length.value);
    _bindings.freeDetailsArray(array);
    return result;
  });

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async => using((arena) {
    final length = arena<Int>();
    final array = _bindings.getPendingNotifications(_plugin, length);
    final result = array.asPendingRequests(length.value);
    _bindings.freeDetailsArray(array);
    return result;
  });

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    final details = _details;
    if (details == null) return null;
    final data = details.data.toMap();
    return NotificationAppLaunchDetails(
      details.didLaunch.toBool(),
      notificationResponse: NotificationResponse(
        notificationResponseType: getResponseType(details.launchType),
        payload: details.payload.toDartString(),
        actionId: details.payload.toDartString(),
        data: data,
      ),
    );
  }

  @override
  Future<void> periodicallyShow(int id, String? title, String? body, RepeatInterval repeatInterval) async {
    throw UnsupportedError("Windows devices cannot periodically show notifications");
  }

  @override
  Future<void> periodicallyShowWithDuration(int id, String? title, String? body, Duration repeatDurationInterval) async {
    throw UnsupportedError("Windows devices cannot periodically show notifications");
  }

  @override
  Future<void> show(int id, String? title, String? body, {String? payload, WindowsNotificationDetails? details}) async => using((arena) {
    final bindings = <String, String>{
      if (details != null) ...details.bindings,
      for (final progressBar in details?.progressBars ?? [])
        ...progressBar.data,
    };
    final nativeMap = bindings.toNativeMap(arena);
    final xml = notificationToXml(title: title, body: body, payload: payload, details: details);
    _bindings.showNotification(_plugin, id, xml.toNativeUtf8(allocator: arena), nativeMap);
  });

  @override
  Future<void> showRawXml({required int id, required String xml, Map<String, String> bindings = const {}}) async => using((arena) {
    _bindings.showNotification(_plugin, id, xml.toNativeUtf8(allocator: arena), bindings.toNativeMap(arena));
  });

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    WindowsNotificationDetails? details, {
    String? payload,
  }) async => using((arena) {
    final xml = notificationToXml(title: title, body: body, payload: payload, details: details);
    final secondsSinceEpoch = scheduledDate.millisecondsSinceEpoch ~/ 1000;
    _bindings.scheduleNotification(_plugin, id, xml.toNativeUtf8(allocator: arena), secondsSinceEpoch);
  });

  @override
  Future<NotificationUpdateResult> updateBindings({required int id, required Map<String, String> bindings}) async => using((arena) {
    final result = _bindings.updateNotification(_plugin, id, bindings.toNativeMap(arena));
    return getUpdateResult(result);
  });
}
