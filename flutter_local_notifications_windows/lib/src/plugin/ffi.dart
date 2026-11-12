import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import '../details.dart';
import '../details/notification_to_xml.dart';
import '../ffi/bindings.dart';
import '../ffi/utils.dart';

import 'base.dart';

const String _nativeLibraryName = 'flutter_local_notifications_windows.dll';

NotificationsPluginBindings _backgroundBindings() =>
    NotificationsPluginBindings(DynamicLibrary.open(_nativeLibraryName));

List<int> _queryNotificationIds((int pluginAddress, bool pending) request) {
  final NotificationsPluginBindings bindings = _backgroundBindings();
  final Pointer<NativePlugin> plugin = Pointer<NativePlugin>.fromAddress(
    request.$1,
  );
  return using((Arena arena) {
    final Pointer<Int> length = arena<Int>();
    final Pointer<NativeNotificationDetails> array = request.$2
        ? bindings.getPendingNotifications(plugin, length)
        : bindings.getActiveNotifications(plugin, length);
    try {
      if (length.value < 0 || (length.value > 0 && array == nullptr)) {
        throw StateError('Invalid native notification query array');
      }
      return <int>[
        for (int index = 0; index < length.value; index++) array[index].id,
      ];
    } finally {
      bindings.freeDetailsArray(array);
    }
  });
}

int _updateNotificationBindings(
  (int pluginAddress, int id, Map<String, String> values) request,
) {
  final NotificationsPluginBindings bindings = _backgroundBindings();
  final Pointer<NativePlugin> plugin = Pointer<NativePlugin>.fromAddress(
    request.$1,
  );
  return using((Arena arena) {
    return bindings
        .updateNotification(plugin, request.$2, request.$3.toNativeMap(arena))
        .value;
  });
}

void _disposeNativePlugin(int pluginAddress) {
  _backgroundBindings().disposePlugin(
    Pointer<NativePlugin>.fromAddress(pluginAddress),
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

  /// The most recently initialized instance, cleared after native disposal.
  static FlutterLocalNotificationsWindows? instance;

  /// The FFI generated bindings to the native code.
  late final NotificationsPluginBindings _bindings =
      NotificationsPluginBindings(_library);

  late final DynamicLibrary _library = DynamicLibrary.open(_nativeLibraryName);

  /// A pointer to the C++ handler class.
  late final Pointer<NativePlugin> _plugin;

  bool _isReady = false;

  /// Completes once a pending [initialize] finishes; null when none is pending.
  Future<bool>? _initialization;
  int _blockingCalls = 0;
  bool _disposeRequested = false;
  bool _nativeDisposalStarted = false;
  NativeCallable<NativeNotificationCallbackFunction>? _launchCallback;

  /// The last recorded launch details, if any.
  ///
  /// If the app is opened with a notification, this can be read with
  /// [getNotificationAppLaunchDetails]. If a notification is pressed while the
  /// app is running, this will be passed to [userCallback].
  NativeLaunchDetails? _details;

  /// A callback from [initialize] to run when a notification is pressed.
  DidReceiveNotificationResponseCallback? userCallback;

  /// Calls made while initializing share the first call's settings and result.
  @override
  Future<bool> initialize({
    required WindowsInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    if (_isReady) {
      return true;
    }
    final Future<bool>? pending = _initialization;
    if (pending != null) {
      return pending;
    }
    if (_disposeRequested || _nativeDisposalStarted) {
      throw StateError(
        'Flutter Local Notifications cannot be reinitialized after dispose',
      );
    }
    // The C++ code will crash if there's an invalid GUID, so check it before
    // createPlugin starts the native worker thread.
    if (!settings.guid.isValidGuid) {
      throw ArgumentError.value(
        settings.guid,
        'GUID',
        'Invalid GUID. Please use xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
            ' format.\nYou can get one by searching GUID generators online',
      );
    }
    _plugin = _bindings.createPlugin();
    instance = this;
    userCallback = onDidReceiveNotificationResponse;
    final Completer<bool> completer = Completer<bool>();

    void finish(bool success) {
      _initialization = null;
      if (_disposeRequested) {
        completer.complete(false);
      } else if (success) {
        _isReady = true;
        completer.complete(true);
      } else {
        // Releases the native worker; a failed instance cannot be reused.
        _disposeRequested = true;
        userCallback = null;
        final NativeLaunchDetails? details = _details;
        _details = null;
        if (details != null) {
          _bindings.freeLaunchDetails(details);
        }
        completer.complete(false);
      }
      _endBlockingCall();
    }

    late final NativeCallable<NativeInitCallbackFunction> onReady;
    onReady = NativeCallable<NativeInitCallbackFunction>.listener((
      bool success,
    ) {
      onReady.close();
      finish(success);
    });
    final NativeCallable<NativeNotificationCallbackFunction> callback =
        NativeCallable<NativeNotificationCallbackFunction>.listener(
          (NativeLaunchDetails details) =>
              _onDidReceiveNotificationResponse(details),
        );
    _launchCallback = callback;
    _initialization = completer.future;
    // dispose() waits for the queued init, like any other in-flight native call.
    _beginBlockingCall();
    final bool queued;
    try {
      queued = using((Arena arena) {
        final Pointer<Utf8> appName = settings.appName.toNativeUtf8(
          allocator: arena,
        );
        final Pointer<Utf8> aumId = settings.appUserModelId.toNativeUtf8(
          allocator: arena,
        );
        final Pointer<Utf8> guid = settings.guid.toNativeUtf8(allocator: arena);
        final Pointer<Utf8> iconPath =
            settings.iconPath?.toNativeUtf8(allocator: arena) ?? nullptr;
        return _bindings.init(
          _plugin,
          appName,
          aumId,
          guid,
          iconPath,
          callback.nativeFunction,
          onReady.nativeFunction,
        );
      });
    } catch (_) {
      onReady.close();
      finish(false);
      rethrow;
    }
    if (!queued) {
      onReady.close();
      finish(false);
    }
    return completer.future;
  }

  @override
  void dispose() {
    if (!_isReady && !_disposeRequested && _initialization == null) {
      return;
    }
    if (_isReady || _initialization != null) {
      _isReady = false;
      _disposeRequested = true;
      userCallback = null;
      final NativeLaunchDetails? details = _details;
      _details = null;
      if (details != null) {
        _bindings.freeLaunchDetails(details);
      }
    }
    _finishDisposeIfIdle();
  }

  void _finishDisposeIfIdle() {
    if (!_disposeRequested || _nativeDisposalStarted || _blockingCalls != 0) {
      return;
    }
    _nativeDisposalStarted = true;
    // NativePlugin teardown can join a slow worker; never block the UI isolate.
    unawaited(_disposeNativePluginAsync(_plugin.address));
  }

  Future<void> _disposeNativePluginAsync(int pluginAddress) async {
    try {
      await Isolate.run(() => _disposeNativePlugin(pluginAddress));
    } catch (_) {
      // Keep the callback open until the native owner is released; calling
      // dispose again retries. Rethrowing here would surface as unhandled.
      _nativeDisposalStarted = false;
      return;
    }
    _disposeRequested = false;
    _launchCallback?.close();
    _launchCallback = null;
    if (identical(instance, this)) {
      instance = null;
    }
  }

  void _beginBlockingCall() {
    _blockingCalls++;
  }

  void _endBlockingCall() {
    _blockingCalls--;
    assert(_blockingCalls >= 0);
    _finishDisposeIfIdle();
  }

  void _onDidReceiveNotificationResponse(NativeLaunchDetails details) {
    // A launch activation can arrive while init is still pending.
    final bool accepting =
        _isReady || (_initialization != null && !_disposeRequested);
    if (!accepting) {
      // dispose can be waiting for a helper-isolate query. The native callback
      // remains registered until that query completes, so release late details
      // instead of leaking their native strings.
      _bindings.freeLaunchDetails(details);
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
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final int pluginAddress = _plugin.address;
    _beginBlockingCall();
    try {
      final List<int> ids = await Isolate.run(
        () => _queryNotificationIds((pluginAddress, false)),
      );
      return <ActiveNotification>[
        for (final int id in ids) ActiveNotification(id: id),
      ];
    } finally {
      _endBlockingCall();
    }
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final int pluginAddress = _plugin.address;
    _beginBlockingCall();
    try {
      final List<int> ids = await Isolate.run(
        () => _queryNotificationIds((pluginAddress, true)),
      );
      return <PendingNotificationRequest>[
        for (final int id in ids)
          PendingNotificationRequest(id, null, null, null),
      ];
    } finally {
      _endBlockingCall();
    }
  }

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
    String? payload,
    required RepeatInterval repeatInterval,
    WindowsNotificationDetails? notificationDetails,
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
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
    WindowsNotificationDetails? notificationDetails,
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
  }) async {
    if (!_isReady) {
      throw StateError(
        'Flutter Local Notifications must be initialized before use',
      );
    }
    final int pluginAddress = _plugin.address;
    final Map<String, String> values = Map<String, String>.of(bindings);
    _beginBlockingCall();
    try {
      final int result = await Isolate.run(
        () => _updateNotificationBindings((pluginAddress, id, values)),
      );
      return getUpdateResult(NativeUpdateResult.fromValue(result));
    } finally {
      _endBlockingCall();
    }
  }
}
