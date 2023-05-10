import 'dart:async';
import 'dart:io';
// dart:typed_data is needed for Uint8List, until the project's minimum
// Flutter SDK constraint is updated beyond 3.0.
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:path/path.dart' as path;
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

import 'model/capabilities.dart';
import 'model/enums.dart';
import 'model/icon.dart';
import 'model/initialization_settings.dart';
import 'model/notification_details.dart';
import 'notification_info.dart';
import 'platform_info.dart';
import 'storage.dart';

/// Linux notification manager and client
class LinuxNotificationManager {
  /// Constructs an instance of of [LinuxNotificationManager]
  LinuxNotificationManager()
      : _portal = XdgDesktopPortalClient().notification,
        _platformInfo = LinuxPlatformInfo(),
        _storage = NotificationStorage();

  /// Constructs an instance of of [LinuxNotificationManager]
  /// with the given class dependencies.
  @visibleForTesting
  LinuxNotificationManager.private({
    XdgNotificationPortal? portal,
    LinuxPlatformInfo? platformInfo,
    NotificationStorage? storage,
  })  : _portal = portal ?? XdgDesktopPortalClient().notification,
        _platformInfo = platformInfo ?? LinuxPlatformInfo(),
        _storage = storage ?? NotificationStorage();

  final XdgNotificationPortal _portal;
  final LinuxPlatformInfo _platformInfo;
  final NotificationStorage _storage;

  late final LinuxInitializationSettings _initializationSettings;
  late final DidReceiveNotificationResponseCallback?
      _onDidReceiveNotificationResponse;
  late final LinuxPlatformInfoData _platformData;

  bool _initialized = false;

  /// Initializes the manager.
  /// Call this method on application before using the manager further.
  Future<bool> initialize(
    LinuxInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    if (_initialized) {
      return _initialized;
    }
    _initialized = true;
    _initializationSettings = initializationSettings;
    _onDidReceiveNotificationResponse = onDidReceiveNotificationResponse;
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

    final XdgNotificationIcon? icon = await _getAppIcon(
      details?.icon ?? defaultIcon,
    );

    final XdgNotificationPriority priority = _getPriority(details);

    final String defaultAction = details?.defaultActionName ?? //
        _kDefaultActionName;

    final List<XdgNotificationButton> actions = _buildActions(details);

    await _portal.addNotification(
      '$id',
      title: title,
      body: body,
      icon: icon,
      priority: priority,
      defaultAction: defaultAction,
      buttons: actions,
    );

    final List<LinuxNotificationActionInfo>? actionsInfo = details?.actions
        .map(
          (LinuxNotificationAction action) => LinuxNotificationActionInfo(
            key: action.key,
          ),
        )
        .toList();

    final LinuxNotificationInfo notify = prevNotify?.copyWith(
          systemId: id,
          payload: payload,
          actions: actionsInfo,
        ) ??
        LinuxNotificationInfo(
          id: id,
          payload: payload,
          actions: actionsInfo ?? <LinuxNotificationActionInfo>[],
        );

    await _storage.insert(notify);
  }

  List<XdgNotificationButton> _buildActions(LinuxNotificationDetails? details) {
    final List<XdgNotificationButton> actions = <XdgNotificationButton>[];

    if (details == null) {
      return actions;
    }

    for (final LinuxNotificationAction action in details.actions) {
      actions.add(
        XdgNotificationButton(action: action.key, label: action.label),
      );
    }

    return actions;
  }

  /// Cancel notification with the given [id].
  Future<void> cancel(int id) async {
    final LinuxNotificationInfo? notify = await _storage.getById(id);
    await _storage.removeById(id);
    if (notify != null) {
      await _portal.removeNotification('$id');
    }
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    final List<LinuxNotificationInfo> notifyList = await _storage.getAll();
    final List<int> idList = <int>[];
    for (final LinuxNotificationInfo notify in notifyList) {
      idList.add(notify.id);
      await _portal.removeNotification('${notify.id}');
    }
    await _storage.removeByIdList(idList);
  }

  /// Returns the system notification server capabilities.
  Future<LinuxServerCapabilities> getCapabilities() async =>
      const LinuxServerCapabilities(
        otherCapabilities: <String>{},
        body: true,
        bodyHyperlinks: true,
        bodyImages: false,
        bodyMarkup: true,
        iconMulti: false,
        iconStatic: false,
        persistence: true,
        sound: false,
        actions: true,
        actionIcons: false,
      );

  /// Returns an icon compatible with the portal.
  ///
  /// The portal requires the icon either a theme name or bytes, so we convert
  /// it if necessary.
  Future<XdgNotificationIcon?> _getAppIcon(LinuxNotificationIcon? icon) async {
    if (icon == null) {
      return null;
    }
    switch (icon.type) {
      case LinuxIconType.assets:
        if (_platformData.assetsPath == null) {
          return null;
        } else {
          final String relativePath = icon.content as String;
          final File file = File(path.join(
            _platformData.assetsPath!,
            relativePath,
          ));
          if (!file.existsSync()) {
            return null;
          }
          final Uint8List bytes = await file.readAsBytes();
          return XdgNotificationIconData(bytes);
        }
      case LinuxIconType.byteData:
        final LinuxRawIconData content = icon.content as LinuxRawIconData;
        final Uint8List bytes = Uint8List.fromList(content.data);
        return XdgNotificationIconData(bytes);
      case LinuxIconType.theme:
        final String content = icon.content as String;
        final List<String> themeNames = <String>[content];
        return XdgNotificationIconThemed(themeNames);
      case LinuxIconType.filePath:
        final File file = File(icon.content as String);
        if (!file.existsSync()) {
          return null;
        }
        final Uint8List bytes = await file.readAsBytes();
        return XdgNotificationIconData(bytes);
    }
  }

  XdgNotificationPriority _getPriority(LinuxNotificationDetails? details) {
    if (details == null) {
      return XdgNotificationPriority.normal;
    }
    switch (details.urgency) {
      case LinuxNotificationUrgency.low:
        return XdgNotificationPriority.low;
      case LinuxNotificationUrgency.normal:
        return XdgNotificationPriority.normal;
      case LinuxNotificationUrgency.critical:
        return XdgNotificationPriority.urgent;
      default:
        return XdgNotificationPriority.normal;
    }
  }

  /// Subscribe to the signals for actions and closing notifications.
  void _subscribeSignals() {
    _portal.actionInvoked.listen(
      (XdgNotificationActionInvokedEvent event) async {
        final LinuxNotificationInfo? notify = await _storage //
            .getById(int.parse(event.id));
        if (notify == null) {
          return;
        }
        if (event.action == _kDefaultActionName) {
          _onDidReceiveNotificationResponse?.call(
            NotificationResponse(
              id: notify.id,
              payload: notify.payload,
              notificationResponseType:
                  NotificationResponseType.selectedNotification,
            ),
          );
        } else {
          final LinuxNotificationActionInfo? actionInfo = notify //
              .actions
              .firstWhereOrNull(
            (LinuxNotificationActionInfo a) => a.key == event.action,
          );
          if (actionInfo == null) {
            return;
          }
          _onDidReceiveNotificationResponse?.call(
            NotificationResponse(
              id: notify.id,
              payload: notify.payload,
              actionId: actionInfo.key,
              notificationResponseType:
                  NotificationResponseType.selectedNotificationAction,
            ),
          );
        }

        await _storage.removeById(notify.id);
      },
    );

    return;
  }
}

const String _kDefaultActionName = 'Open notification';
