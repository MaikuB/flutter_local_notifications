import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:path/path.dart' as path;

import 'dbus_wrapper.dart';
import 'model/enums.dart';
import 'model/icon.dart';
import 'model/initialization_settings.dart';
import 'model/notification_details.dart';
import 'notification_info.dart';
import 'platform_info.dart';
import 'storage.dart';
import 'typedefs.dart';

/// Linux notification manager and client
class LinuxNotificationManager {
  /// Constructs an instance of of [LinuxNotificationManager]
  LinuxNotificationManager({
    DBusWrapper? dbus,
    LinuxPlatformInfo? platformInfo,
    NotificationStorage? storage,
  })  : _dbus = dbus ?? DBusWrapperImpl(),
        _platformInfo = platformInfo ?? LinuxPlatformInfoImpl(),
        _storage = storage ?? NotificationStorageImpl();

  final DBusWrapper _dbus;
  final LinuxPlatformInfo _platformInfo;
  final NotificationStorage _storage;

  late final LinuxInitializationSettings _initializationSettings;
  late final SelectNotificationCallback? _onSelectNotification;
  late final LinuxPlatformInfoData _platformData;

  /// Initializes the manager.
  /// Call this method on application before using the manager further.
  Future<void> initialize(
    LinuxInitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
  }) async {
    _initializationSettings = initializationSettings;
    _onSelectNotification = onSelectNotification;
    _dbus.build(
      destination: _DBusInterfaceSpec.destination,
      path: _DBusInterfaceSpec.path,
    );
    _platformData = await _platformInfo.getAll();

    await _storage.forceReloadCache();
    _subscribeSignals();
  }

  /// Show notification
  Future<void> show(
    int id,
    String? title,
    String? body, {
    LinuxNotificationDetails? details,
    String? payload,
  }) async {
    final LinuxNotificationInfo? prevNotify = await _storage.getById(id);
    final LinuxNotificationIcon? defaultIcon =
        _initializationSettings.defaultIcon;

    final DBusMethodSuccessResponse result = await _dbus.callMethod(
      _DBusInterfaceSpec.destination,
      _DBusMethodsSpec.notify,
      <DBusValue>[
        // app_name
        DBusString(_platformData.appName ?? ''),
        // replaces_id
        DBusUint32(prevNotify?.systemId ?? 0),
        // app_icon
        DBusString(_getAppIcon(details?.icon ?? defaultIcon) ?? ''),
        // summary
        DBusString(title ?? ''),
        // body
        DBusString(body ?? ''),
        // TODO(proninyaroslav): add actions
        // actions
        DBusArray.string(const <String>[]),
        // hints
        DBusDict.stringVariant(_makeHints(details, defaultIcon)),
        // expire_timeout
        DBusInt32(details?.timeout.value ?? 0)
      ],
      replySignature: DBusSignature('u'),
    );

    final int systemId = (result.returnValues[0] as DBusUint32).value;
    final LinuxNotificationInfo notify = prevNotify?.copyWith(
          systemId: systemId,
          payload: payload,
        ) ??
        LinuxNotificationInfo(
          id: id,
          systemId: systemId,
          payload: payload,
        );
    await _storage.insert(notify);
  }

  Map<String, DBusValue> _makeHints(
    LinuxNotificationDetails? details,
    LinuxNotificationIcon? defaultIcon,
  ) {
    final Map<String, DBusValue> hints = <String, DBusValue>{};
    if (details == null && defaultIcon == null) {
      return hints;
    }
    final LinuxNotificationIcon? icon = details?.icon ?? defaultIcon;
    if (icon?.type == LinuxIconType.byteData) {
      final RawIconData data = icon!.content as RawIconData;
      hints['image-data'] = DBusStruct(
        <DBusValue>[
          DBusInt32(data.width),
          DBusInt32(data.height),
          DBusInt32(data.rowStride),
          DBusBoolean(data.hasAlpha),
          DBusInt32(data.bitsPerSample),
          DBusInt32(data.channels),
          DBusArray.byte(data.data),
        ],
      );
    }

    return hints;
  }

  /// Cancel notification with the given [id].
  Future<void> cancel(int id) async {
    final LinuxNotificationInfo? notify = await _storage.getById(id);
    await _storage.removeById(id);
    if (notify != null) {
      await _dbusCancel(notify.systemId);
    }
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    final List<LinuxNotificationInfo> notifyList = await _storage.getAll();
    final List<int> idList = <int>[];
    for (final LinuxNotificationInfo notify in notifyList) {
      idList.add(notify.id);
      await _dbusCancel(notify.systemId);
    }
    await _storage.removeByIdList(idList);
  }

  Future<void> _dbusCancel(int systemId) => _dbus.callMethod(
        _DBusInterfaceSpec.destination,
        _DBusMethodsSpec.closeNotification,
        <DBusValue>[DBusUint32(systemId)],
        replySignature: DBusSignature(''),
      );

  String? _getAppIcon(LinuxNotificationIcon? icon) {
    if (icon == null) {
      return null;
    }
    switch (icon.type) {
      case LinuxIconType.assets:
        if (_platformData.assetsPath == null) {
          return null;
        } else {
          final String relativePath = icon.content as String;
          return path.join(_platformData.assetsPath!, relativePath);
        }
      case LinuxIconType.byteData:
        return null;
      case LinuxIconType.theme:
        return icon.content as String;
    }
  }

  /// Subscribe to the signals for actions and closing notifications.
  void _subscribeSignals() {
    _dbus.subscribeSignal(_DBusMethodsSpec.actionInvoked).listen(
      (DBusSignal s) {
        if (s.signature != DBusSignature('us')) {
          return;
        }

        // TODO(proninyaroslav): add actions
        final int id = (s.values[0] as DBusUint32).value;
        final String actionKey = (s.values[1] as DBusString).value;
      },
    );

    _dbus.subscribeSignal(_DBusMethodsSpec.notificationClosed).listen(
      (DBusSignal s) async {
        if (s.signature != DBusSignature('uu')) {
          return;
        }

        final int systemId = (s.values[0] as DBusUint32).value;
        await _storage.removeBySystemId(systemId);
      },
    );
  }
}

class _DBusInterfaceSpec {
  static const String destination = 'org.freedesktop.Notifications';
  static const String path = '/org/freedesktop/Notifications';
}

class _DBusMethodsSpec {
  static const String notify = 'Notify';
  static const String closeNotification = 'CloseNotification';
  static const String actionInvoked = 'ActionInvoked';
  static const String notificationClosed = 'NotificationClosed';
}
