import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:path/path.dart' as path;

import 'enums.dart';
import 'icon.dart';
import 'initialization_settings.dart';
import 'notification_details.dart';
import 'platform_info.dart';
import 'typedefs.dart';

const String _kDbusDestination = 'org.freedesktop.Notifications';
const String _kDbusPath = '/org/freedesktop/Notifications';
const String _kDbusMethodNotify = 'Notify';
const String _kDbusMethodClose = 'CloseNotification';

/// Mockable [DBusRemoteObject] builder for
/// Desktop Notifications Specification https://developer.gnome.org/notification-spec/
// ignore: one_member_abstracts
abstract class NotificationDBusBuilder {
  /// Build an instance of [DBusRemoteObject]
  DBusRemoteObject build();
}

/// Real implementation of [NotificationDBusBuilder]
class NotificationDBusBuilderImpl implements NotificationDBusBuilder {
  @override
  DBusRemoteObject build() => DBusRemoteObject(
        DBusClient.session(),
        _kDbusDestination,
        DBusObjectPath(_kDbusPath),
      );
}

/// Linux notification manager and client
class LinuxNotificationManager {
  /// Constructs an instance of of [LinuxNotificationManager]
  LinuxNotificationManager({
    NotificationDBusBuilder? dbusBuilder,
    LinuxPlatformInfo? platformInfo,
  })  : _dbusBuilder = dbusBuilder ?? NotificationDBusBuilderImpl(),
        _platformInfo = platformInfo ?? LinuxPlatformInfoImpl();

  final NotificationDBusBuilder _dbusBuilder;
  final LinuxPlatformInfo _platformInfo;

  late final LinuxInitializationSettings _initializationSettings;
  late final SelectNotificationCallback? _onSelectNotification;
  late final DBusRemoteObject _dbus;
  late final LinuxPlatformInfoData _platformData;

  /// Initializes the manager.
  /// Call this method on application before using the manager further.
  Future<void> initialize(
    LinuxInitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
  }) async {
    _initializationSettings = initializationSettings;
    _onSelectNotification = onSelectNotification;
    _dbus = _dbusBuilder.build();
    _platformData = await _platformInfo.getAll();
  }

  /// Show notification
  Future<void> show(
    int id,
    String? title,
    String? body, {
    LinuxNotificationDetails? details,
    String? payload,
  }) async {
    final LinuxNotificationIcon? defaultIcon =
        _initializationSettings.defaultIcon;
    await _dbus.callMethod(
      _kDbusDestination,
      _kDbusMethodNotify,
      <DBusValue>[
        // app_name
        DBusString(_platformData.appName ?? ''),
        // replaces_id
        DBusUint32(id),
        // app_icon
        DBusString(_getAppIcon(details?.icon ?? defaultIcon) ?? ''),
        // summary
        DBusString(title ?? ''),
        // body
        DBusString(body ?? ''),
        // actions
        DBusArray.string(const <String>[]),
        // hints
        DBusDict.stringVariant(<String, DBusValue>{}),
        // expire_timeout
        DBusInt32(details?.timeout.value ?? 0)
      ],
      replySignature: DBusSignature('u'),
    );
  }

  /// Cancel notification with the given [id].
  Future<void> cancel(int id) async {
    await _dbus.callMethod(
      _kDbusDestination,
      _kDbusMethodClose,
      <DBusValue>[DBusUint32(id)],
      replySignature: DBusSignature(''),
    );
  }

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
}
