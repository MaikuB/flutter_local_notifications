import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../details.dart';
import '../details/notification_to_xml.dart';
import '../ffi/bindings.dart';
import '../ffi/utils.dart';

import 'base.dart';

void _globalLaunchCallback(NativeLaunchDetails details) {
  FlutterLocalNotificationsWindows.instance?._onDidReceiveNotificationResponse(
    details,
  );
}

extension on String {
  bool get isValidGuid =>
      length == 36 &&
      this[8] == '-' &&
      this[13] == '-' &&
      this[18] == '-' &&
      this[23] == '-';
}

/// The Windows implementation of `package:flutter_local_notifications`.
class FlutterLocalNotificationsWindows extends WindowsNotificationsBase {
  /// Creates an instance of the native plugin.
  FlutterLocalNotificationsWindows();

  /// Registers the Windows implementation with Flutter.
  static void registerWith() {
    FlutterLocalNotificationsPlatform.instance =
        FlutterLocalNotificationsWindows();
  }

  /// The global instance of this plugin. Used in [_globalLaunchCallback].
  static FlutterLocalNotificationsWindows? instance;

  /// The FFI generated bindings to the native code.
  late final NotificationsPluginBindings _bindings =
      NotificationsPluginBindings(_library);

  final DynamicLibrary _library = DynamicLibrary.open(
    'flutter_local_notifications_windows.dll',
  );

  /// A pointer to the C++ handler class.
  late final Pointer<NativePlugin> _plugin;

  bool _isReady = false;

  /// The last recorded launch details, if any.
  ///
  /// If the app is opened with a notification, this can be read with
  /// [getNotificationAppLaunchDetails]. If a notification is pressed while the
  /// app is running, this will be passed to [userCallback].
  NativeLaunchDetails? _details;

  /// A callback from [initialize] to run when a notification is pressed.
  DidReceiveNotificationResponseCallback? userCallback;

  @override
  Future<bool> initialize({
    required WindowsInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async => using((Arena arena) {
    if (_isReady) {
      return true;
    }
    _plugin = _bindings.createPlugin();
    // The C++ code will crash if there's an invalid GUID, so check it here
    if (!settings.guid.isValidGuid) {
      throw ArgumentError.value(
        settings.guid,
        'GUID',
        'Invalid GUID. Please use xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            ' format.\nYou can get one by searching GUID generators online',
      );
    }
    instance = this;
    userCallback = onDidReceiveNotificationResponse;
    final Pointer<Utf8> appName = settings.appName.toNativeUtf8(
      allocator: arena,
    );
    final Pointer<Utf8> aumId = settings.appUserModelId.toNativeUtf8(
      allocator: arena,
    );
    final Pointer<Utf8> guid = settings.guid.toNativeUtf8(allocator: arena);
    final Pointer<Utf8> iconPath =
        settings.iconPath?.toNativeUtf8(allocator: arena) ?? nullptr;
    final NativeNotificationCallback callback =
        NativeCallable<NativeNotificationCallbackFunction>.listener(
          _globalLaunchCallback,
        ).nativeFunction;
    final bool result = _bindings.init(
      _plugin,
      appName,
      aumId,
      guid,
      iconPath,
      callback,
    );
    _isReady = result;
    return result;
  });

  @override
  void dispose() {
    if (!_isReady) {
      return;
    }
    _bindings.disposePlugin(_plugin);
    instance = null;
    _isReady = false;
  }

  void _onDidReceiveNotificationResponse(NativeLaunchDetails details) {
    if (!_isReady) {
      return;
    } else if (_details != null) {
      _bindings.freeLaunchDetails(_details!);
    }
    _details = details;
    final Map<String, String> data = details.data.toMap();
    final NotificationResponse response = NotificationResponse(
      notificationResponseType: getResponseType(details.launchType),
      payload: details.payload.toDartString(),
      actionId: details.payload.toDartString(),
      data: data,
    );
    userCallback?.call(response);
  }

  @override
  Future<void> cancel({required int id}) async {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    _bindings.cancelNotification(_plugin, id);
  }

  @override
  Future<void> cancelAll() async {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    _bindings.cancelAll(_plugin);
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async =>
      using((Arena arena) {
        if (!_isReady) {
          throw StateError(
            'Flutter Local Notifications must be initialized before use',
          );
        }
        final Pointer<Int> length = arena<Int>();
        final Pointer<NativeNotificationDetails> array = _bindings
            .getActiveNotifications(_plugin, length);
        final List<ActiveNotification> result = array.asActiveNotifications(
          length.value,
        );
        _bindings.freeDetailsArray(array);
        return result;
      });

  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => using((Arena arena) {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final Pointer<Int> length = arena<Int>();
    final Pointer<NativeNotificationDetails> array = _bindings
        .getPendingNotifications(_plugin, length);
    final List<PendingNotificationRequest> result = array.asPendingRequests(
      length.value,
    );
    _bindings.freeDetailsArray(array);
    return result;
  });

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final NativeLaunchDetails? details = _details;
    if (details == null) {
      return null;
    }
    final Map<String, String> data = details.data.toMap();
    return NotificationAppLaunchDetails(
      details.didLaunch,
      notificationResponse: NotificationResponse(
        notificationResponseType: getResponseType(details.launchType),
        payload: details.payload.toDartString(),
        actionId: details.payload.toDartString(),
        data: data,
      ),
    );
  }

  @override
  Future<void> periodicallyShow({
    required int id,
    String? title,
    String? body,
    required RepeatInterval repeatInterval,
  }) async {
    throw UnsupportedError(
      'Windows devices cannot periodically show notifications',
    );
  }

  @override
  Future<void> periodicallyShowWithDuration({
    required int id,
    String? title,
    String? body,
    required Duration repeatDurationInterval,
  }) async {
    throw UnsupportedError(
      'Windows devices cannot periodically show notifications',
    );
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
    WindowsNotificationDetails? notificationDetails,
  }) async => using((Arena arena) {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final Map<String, String> bindings = <String, String>{
      if (notificationDetails != null) ...notificationDetails.bindings,
      for (final WindowsProgressBar progressBar
          in notificationDetails?.progressBars ?? <WindowsProgressBar>[])
        ...progressBar.data,
    };
    final NativeStringMap nativeMap = bindings.toNativeMap(arena);
    final String xml = notificationToXml(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: notificationDetails,
    );
    final bool result = _bindings.showNotification(
      _plugin,
      id,
      xml.toNativeUtf8(allocator: arena),
      nativeMap,
    );
    if (!result) {
      throw Exception(
        'Flutter Local Notifications could not show notification',
      );
    }
  });

  @override
  Future<void> showRawXml({
    required int id,
    required String xml,
    Map<String, String> bindings = const <String, String>{},
  }) async => using((Arena arena) {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final bool result = _bindings.showNotification(
      _plugin,
      id,
      xml.toNativeUtf8(allocator: arena),
      bindings.toNativeMap(arena),
    );
    if (!result) {
      throw ArgumentError('Flutter Local Notifications: Invalid XML');
    }
  });

  @override
  bool isValidXml(String xml) => using((Arena arena) {
    final Pointer<Utf8> nativeXml = xml.toNativeUtf8(allocator: arena);
    return _bindings.isValidXml(nativeXml);
  });

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required TZDateTime scheduledDate,
    WindowsNotificationDetails? notificationDetails,
    String? payload,
  }) async => using((Arena arena) {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError(
        'Flutter Local Notifications cannot'
        ' schedule notifications in the past',
      );
    }
    final String xml = notificationToXml(
      title: title,
      body: body,
      payload: payload,
      notificationDetails: notificationDetails,
    );
    final int secondsSinceEpoch = scheduledDate.millisecondsSinceEpoch ~/ 1000;
    _bindings.scheduleNotification(
      _plugin,
      id,
      xml.toNativeUtf8(allocator: arena),
      secondsSinceEpoch,
    );
  });

  @override
  Future<void> zonedScheduleRawXml({
    required int id,
    required String xml,
    required TZDateTime scheduledDate,
  }) async => using((Arena arena) {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError(
        'Flutter Local Notifications cannot'
        ' schedule notifications in the past',
      );
    }
    final int secondsSinceEpoch = scheduledDate.millisecondsSinceEpoch ~/ 1000;
    _bindings.scheduleNotification(
      _plugin,
      id,
      xml.toNativeUtf8(allocator: arena),
      secondsSinceEpoch,
    );
  });

  @override
  Future<NotificationUpdateResult> updateBindings({
    required int id,
    required Map<String, String> bindings,
  }) async => using((Arena arena) {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final NativeUpdateResult result = _bindings.updateNotification(
      _plugin,
      id,
      bindings.toNativeMap(arena),
    );
    return getUpdateResult(result);
  });
}
