import 'dart:js_interop';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:web/web.dart';

import 'details.dart';
import 'handler.dart';
import 'utils.dart';

void onNotificationClicked(MessageEvent event) {
  final JSNotificationData data = event.data as JSNotificationData;
  final NotificationResponse response = data.response;
  WebFlutterLocalNotificationsPlugin.instance
    ?._userCallback?.call(response);
}

/// Web implementation of the local notifications plugin.
class WebFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {

  /// Registers the web plugin with the platform interface.
  static void registerWith(_) {
    FlutterLocalNotificationsPlatform.instance =
        WebFlutterLocalNotificationsPlugin();
  }

  static WebFlutterLocalNotificationsPlugin? instance;

  DidReceiveNotificationResponseCallback? _userCallback;
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
        .showNotification(
          title ?? 'This is a notification',
          details.toJs(id, payload),
        )
        .toDart;
  }

  /// Initializes the plugin.
  Future<bool?> initialize({
    DidReceiveNotificationResponseCallback? onNotificationReceived,
  }) async {
    instance = this;
    _userCallback = onNotificationReceived;

    // Replace the default Flutter service worker with our own.
    // This isn't supported at build time yet and so must be done at runtime.
    // See: https://github.com/flutter/flutter/issues/145828
    final ServiceWorkerContainer serviceWorker = window.navigator.serviceWorker;
    _registration = await serviceWorker.getRegistration().toDart;
    await _registration?.unregister().toDart;
    const String jsPath = './assets/packages/flutter_local_notifications_web/web/notifications_service_worker.js';
    _registration = await serviceWorker.register(jsPath.toJS).toDart;

    // Subscribe to messages from the service worker
    serviceWorker.onmessage = onNotificationClicked.toJS;

    return true;
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
