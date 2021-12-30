import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:path/path.dart' as path;

import 'dbus_wrapper.dart';
import 'helpers.dart';
import 'model/capabilities.dart';
import 'model/enums.dart';
import 'model/hint.dart';
import 'model/icon.dart';
import 'model/initialization_settings.dart';
import 'model/location.dart';
import 'model/notification_details.dart';
import 'model/sound.dart';
import 'model/timeout.dart';
import 'notification_info.dart';
import 'platform_info.dart';
import 'storage.dart';

/// Linux notification manager and client
class LinuxNotificationManager {
  /// Constructs an instance of of [LinuxNotificationManager]
  LinuxNotificationManager()
      : _dbus = DBusWrapper(),
        _platformInfo = LinuxPlatformInfo(),
        _storage = NotificationStorage();

  /// Constructs an instance of of [LinuxNotificationManager]
  /// with the given class dependencies.
  @visibleForTesting
  LinuxNotificationManager.private({
    DBusWrapper? dbus,
    LinuxPlatformInfo? platformInfo,
    NotificationStorage? storage,
  })  : _dbus = dbus ?? DBusWrapper(),
        _platformInfo = platformInfo ?? LinuxPlatformInfo(),
        _storage = storage ?? NotificationStorage();

  final DBusWrapper _dbus;
  final LinuxPlatformInfo _platformInfo;
  final NotificationStorage _storage;

  late final LinuxInitializationSettings _initializationSettings;
  late final SelectNotificationCallback? _onSelectNotification;
  late final LinuxPlatformInfoData _platformData;

  bool _initialized = false;

  /// Initializes the manager.
  /// Call this method on application before using the manager further.
  Future<bool> initialize(
    LinuxInitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
  }) async {
    if (_initialized) {
      return _initialized;
    }
    _initialized = true;
    _initializationSettings = initializationSettings;
    _onSelectNotification = onSelectNotification;
    _dbus.build(
      destination: _DBusInterfaceSpec.destination,
      path: _DBusInterfaceSpec.path,
    );
    _platformData = await _platformInfo.getAll();

    await _storage.forceReloadCache();
    _subscribeSignals();
    return _initialized;
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
        // actions
        DBusArray.string(_buildActions(details, _initializationSettings)),
        // hints
        DBusDict.stringVariant(_buildHints(details, _initializationSettings)),
        // expire_timeout
        DBusInt32(
          details?.timeout.value ??
              const LinuxNotificationTimeout.systemDefault().value,
        ),
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

  Map<String, DBusValue> _buildHints(
    LinuxNotificationDetails? details,
    LinuxInitializationSettings initSettings,
  ) {
    final Map<String, DBusValue> hints = <String, DBusValue>{};
    final LinuxNotificationIcon? icon =
        details?.icon ?? initSettings.defaultIcon;
    if (icon?.type == LinuxIconType.byteData) {
      final LinuxRawIconData data = icon!.content as LinuxRawIconData;
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
    final LinuxNotificationSound? sound =
        details?.sound ?? initSettings.defaultSound;
    if (sound != null) {
      switch (sound.type) {
        case LinuxSoundType.assets:
          hints['sound-file'] = DBusString(
            path.join(
              _platformData.assetsPath!,
              sound.content as String,
            ),
          );
          break;
        case LinuxSoundType.theme:
          hints['sound-name'] = DBusString(sound.content as String);
          break;
      }
    }
    if (details?.category != null) {
      hints['category'] = DBusString(details!.category!.name);
    }
    if (details?.urgency != null) {
      hints['urgency'] = DBusByte(details!.urgency!.value);
    }
    if (details?.resident ?? false) {
      hints['resident'] = const DBusBoolean(true);
    }
    final bool? suppressSound =
        details?.suppressSound ?? initSettings.defaultSuppressSound;
    if (suppressSound ?? false) {
      hints['suppress-sound'] = const DBusBoolean(true);
    }
    if (details?.transient ?? false) {
      hints['transient'] = const DBusBoolean(true);
    }
    if (details?.location != null) {
      final LinuxNotificationLocation location = details!.location!;
      hints['x'] = DBusByte(location.x);
      hints['y'] = DBusByte(location.y);
    }
    if (details?.customHints != null) {
      hints.addAll(_buildCustomHints(details!.customHints!));
    }

    return hints;
  }

  Map<String, DBusValue> _buildCustomHints(
    List<LinuxNotificationCustomHint> hints,
  ) =>
      Map<String, DBusValue>.fromEntries(
        hints.map(
          (LinuxNotificationCustomHint hint) => MapEntry<String, DBusValue>(
            hint.name,
            hint.value.toDBusValue(),
          ),
        ),
      );

  // TODO(proninyaroslav): add actions
  List<String> _buildActions(
    LinuxNotificationDetails? details,
    LinuxInitializationSettings initSettings,
  ) =>
      // Add default action, which is triggered when the notification is clicked
      <String>[
        _kDefaultActionName,
        details?.defaultActionName ?? initSettings.defaultActionName,
      ];

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

  /// Returns the system notification server capabilities.
  Future<LinuxServerCapabilities> getCapabilities() async {
    final DBusMethodSuccessResponse result = await _dbus.callMethod(
      _DBusInterfaceSpec.destination,
      _DBusMethodsSpec.getCapabilities,
      <DBusValue>[],
      replySignature: DBusSignature('as'),
    );
    final Set<String> capsSet = (result.returnValues[0] as DBusArray)
        .children
        .map((DBusValue c) => (c as DBusString).value)
        .toSet();

    final LinuxServerCapabilities capabilities = LinuxServerCapabilities(
      otherCapabilities: const <String>{},
      body: capsSet.remove('body'),
      bodyHyperlinks: capsSet.remove('body-hyperlinks'),
      bodyImages: capsSet.remove('body-images'),
      bodyMarkup: capsSet.remove('body-markup'),
      iconMulti: capsSet.remove('icon-multi'),
      iconStatic: capsSet.remove('icon-static'),
      persistence: capsSet.remove('persistence'),
      sound: capsSet.remove('sound'),
    );
    return capabilities.copyWith(otherCapabilities: capsSet);
  }

  /// Returns a [Map] with the specified notification id as the key
  /// and the id, assigned by the system, as the value.
  Future<Map<int, int>> getSystemIdMap() async =>
      Map<int, int>.fromEntries(await _storage.getAll().then(
            (List<LinuxNotificationInfo> list) => list.map(
              (LinuxNotificationInfo notify) => MapEntry<int, int>(
                notify.id,
                notify.systemId,
              ),
            ),
          ));

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
      (DBusSignal s) async {
        if (s.signature != DBusSignature('us')) {
          return;
        }

        final int systemId = (s.values[0] as DBusUint32).value;
        final String actionKey = (s.values[1] as DBusString).value;
        // TODO(proninyaroslav): add actions
        if (actionKey == _kDefaultActionName) {
          final LinuxNotificationInfo? notify =
              await _storage.getBySystemId(systemId);
          _onSelectNotification?.call(notify?.payload);
        }
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

const String _kDefaultActionName = 'default';

class _DBusInterfaceSpec {
  static const String destination = 'org.freedesktop.Notifications';
  static const String path = '/org/freedesktop/Notifications';
}

class _DBusMethodsSpec {
  static const String notify = 'Notify';
  static const String closeNotification = 'CloseNotification';
  static const String actionInvoked = 'ActionInvoked';
  static const String notificationClosed = 'NotificationClosed';
  static const String getCapabilities = 'GetCapabilities';
}
