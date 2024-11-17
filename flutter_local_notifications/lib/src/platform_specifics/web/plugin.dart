import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:web/web.dart';

import 'details.dart';

/// Web implementation of the local notifications plugin.
class WebFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  /// Registers the web plugin with the platform interface.
  static void registerWith(_) {
    FlutterLocalNotificationsPlatform.instance =
        WebFlutterLocalNotificationsPlugin();
  }

  ServiceWorkerRegistration? _registration;

  @override
  Future<void> show(int id, String? title, String? body,
      {String? payload, WebNotificationDetails? details}) async {
    if (_registration == null) {
      throw StateError(
        'FlutterLocalNotifications.show(): You must call initialize() before '
        'calling this method',
      );
    } else if (Notification.permission != 'granted') {
      throw StateError(
        'FlutterLocalNotifications.show(): You must request notifications '
        'permissions first',
      );
    } else if (details?.isSilent == true && details?.vibrationPattern != null) {
      throw ArgumentError(
        'WebNotificationDetails: Cannot specify both silent and a vibration '
        'pattern',
      );
    } else if (details?.renotify == true && details?.tag == null) {
      throw ArgumentError(
        'WebNotificationDetails: If you specify renotify, you must also '
        'specify a tag',
      );
    } else if (_registration!.active == null) {
      throw StateError(
        'FlutterLocalNotifications.show(): There is no active service worker. '
        'Call initialize() first',
      );
    }

    await _registration!
        .showNotification(title ?? 'This is a notification', details.toJs(id))
        .toDart;
  }

  /// Initializes the plugin.
  Future<bool?> initialize() async {
    _registration =
        await window.navigator.serviceWorker.getRegistration().toDart;
    return _registration != null;
  }

  /// Requests notification permission from the browser.
  ///
  /// It is highly recommended and sometimes required that this be called only
  /// in response to a user gesture, and not automatically.
  Future<bool> requestNotificationsPermission() async {
    final JSString result = await Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (_registration == null) {
      return <ActiveNotification>[];
    }
    final List<ActiveNotification> result = <ActiveNotification>[];
    final Set<int> ids = <int>{};
    final List<Notification> jsNotifs =
        await _registration!.getDartNotifications();
    for (final Notification jsNotification in jsNotifs) {
      final int? id = jsNotification.id;
      if (id == null) {
        continue;
      }
      final ActiveNotification notif = ActiveNotification(id: id);
      ids.add(id);
      result.add(notif);
    }
    return result;
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    if (_registration == null) {
      return;
    }
    final List<Notification> notifs =
        await _registration!.getDartNotifications();
    for (final Notification notification in notifs) {
      if (notification.id == id || (tag != null && tag == notification.tag)) {
        notification.close();
      }
    }
  }

  @override
  Future<void> cancelAll() async {
    if (_registration == null) {
      return;
    }
    final List<Notification> notifs =
        await _registration!.getDartNotifications();
    for (final Notification notification in notifs) {
      notification.close();
    }
  }

  @override
  Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() async => <PendingNotificationRequest>[];

  @override
  Future<void> periodicallyShow(
      int id, String? title, String? body, RepeatInterval repeatInterval) {
    throw UnsupportedError('periodicallyShow() is not supported on the web');
  }

  @override
  Future<void> periodicallyShowWithDuration(
      int id, String? title, String? body, Duration repeatDurationInterval) {
    throw UnsupportedError(
      'periodicallyShowWithDuration() is not supported '
      'on the web',
    );
  }
}

extension on Notification {
  /// Gets the ID of the notification.
  int? get id => jsonDecode(data.toString())?['id'];
}

extension on ServiceWorkerRegistration {
  Future<List<Notification>> getDartNotifications() async =>
      (await getNotifications().toDart).toDart;
}

extension on WebNotificationDetails {
  JSArray<JSNumber>? get vibrationPatternMs => vibrationPattern == null
      ? null
      : <JSNumber>[
          for (final Duration duration in vibrationPattern!)
            duration.inMilliseconds.toJS,
        ].toJS;
}

extension on WebNotificationDetails? {
  NotificationOptions toJs(int id) {
    final NotificationOptions options = NotificationOptions(
      actions: <NotificationAction>[
        for (final WebNotificationAction action
            in this?.actions ?? <WebNotificationAction>[])
          // THis workaround is here because not all browsers support this
          <String, dynamic>{
            'action': action.action,
            'title': action.title,
            'icon': action.icon?.toString(),
            'type': action.type.jsValue,
          }.jsify() as NotificationAction,
      ].toJS,
      badge: this?.badgeUrl.toString() ?? '',
      body: this?.body ?? '',
      data: jsonEncode(<String, int>{'id': id}).toJS,
      dir: this?.direction.jsValue ?? WebNotificationDirection.auto.jsValue,
      icon: this?.iconUrl.toString() ?? '',
      image: this?.imageUrl.toString() ?? '',
      lang: this?.lang ?? '',
      renotify: this?.renotify ?? false,
      requireInteraction: this?.requireInteraction ?? false,
      silent: this?.isSilent,
      tag: this?.tag ?? '',
      timestamp: (this?.timestamp ?? DateTime.now()).millisecondsSinceEpoch,
    );

    final JSArray<JSNumber>? vibration = this?.vibrationPatternMs;
    if (vibration != null) {
      options.vibrate = vibration;
    }
    return options;
  }
}
