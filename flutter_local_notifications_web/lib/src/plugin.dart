import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:web/web.dart';

import 'details.dart';
import 'handler.dart';
import 'utils.dart';

/// Called when a notification has been clicked.
///
/// Notification clicks are handled by service workers. See `web/notification_service_worker.js`
/// for the source code there. When the service worker receives the
/// [NotificationEvent], it uses [Client.postMessage] to send a message back to
/// the currently open window/tab, if there is any.
///
/// This function creates a [NotificationResponse] object and calls the user's
/// callback they provided to [WebFlutterLocalNotificationsPlugin.initialize].
void _onNotificationClicked(MessageEvent event) {
  final JSNotificationData data = event.data as JSNotificationData;
  final NotificationResponse response = data.response;
  WebFlutterLocalNotificationsPlugin.instance?._userCallback?.call(response);
}

/// Web implementation of the local notifications plugin.
class WebFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  /// Registers the web plugin with the platform interface.
  static void registerWith(Object _) {
    FlutterLocalNotificationsPlatform.instance =
        WebFlutterLocalNotificationsPlugin();
  }

  /// The currently loaded web plugin object, if any.
  static WebFlutterLocalNotificationsPlugin? instance;

  DidReceiveNotificationResponseCallback? _userCallback;
  ServiceWorkerRegistration? _registration;

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
    WebNotificationDetails? details,
  }) async {
    if (_registration == null) {
      throw StateError(
        'FlutterLocalNotifications.show(): You must call initialize() before '
        'calling this method',
      );
    } else if (!hasPermission) {
      throw StateError(
        'FlutterLocalNotifications.show(): You must request notifications '
        'permissions first',
      );
    } else if (details?.isSilent == true && details?.vibrationPattern != null) {
      throw ArgumentError(
        'WebNotificationDetails: Cannot specify both silent and a vibration '
        'pattern',
      );
    } else if (_registration!.active == null) {
      throw StateError(
        'FlutterLocalNotifications.show(): There is no active service worker. '
        'Call initialize() first',
      );
    }

    await _registration!
        .showNotification(
          title ?? '',
          details.toJs(id, body, payload),
        )
        .toDart;
  }

  /// Initializes the plugin.
  Future<bool?> initialize({
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    instance = this;
    _userCallback = onDidReceiveNotificationResponse;

    // Replace the default Flutter service worker with our own.
    // This isn't supported at build time yet and so must be done at runtime.
    // See: https://github.com/flutter/flutter/issues/145828
    final ServiceWorkerContainer serviceWorker = window.navigator.serviceWorker;
    _registration = await serviceWorker.getRegistration().toDart;
    const String jsPath =
        './assets/packages/flutter_local_notifications_web/web/notifications_service_worker.js';
    _registration = await serviceWorker.register(jsPath.toJS).toDart;

    // Subscribe to messages from the service worker
    serviceWorker.onmessage = _onNotificationClicked.toJS;

    return true;
  }

  /// Requests notification permission from the browser.
  ///
  /// Be sure to only request permissions in response to a user gesture, or it
  /// may be automatically rejected.
  Future<bool> requestNotificationsPermission() async {
    final JSString permissionStatus = await Notification.requestPermission().toDart;
    return permissionStatus.toDart == 'granted';
  }

  /// Whether the user has granted permission to show notifications.
  ///
  /// If this is false, you must call [requestNotificationsPermission]. Be sure
  /// to only request permissions in response to a user gesture, or it may be
  /// automatically rejected.
  bool get hasPermission => Notification.permission == 'granted';

  @override
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    final Uri uri = Uri.parse(window.location.toString());
    final Map<String, String> query = uri.queryParameters;
    final String? id = query['notification_id'];
    final String? payload = query['notification_payload'];
    final String? action = query['notification_action'];
    final String? reply = query['notification_reply'];
    window.history.replaceState(null, '', '/');
    if (id == null || payload == null || action == null || reply == null) {
      return null;
    } else {
      return NotificationAppLaunchDetails(
        true,
        notificationResponse: NotificationResponse(
          notificationResponseType: action.isEmpty
              ? NotificationResponseType.selectedNotification
              : NotificationResponseType.selectedNotificationAction,
          id: int.parse(id),
          input: reply.nullIfEmpty,
          payload: payload.nullIfEmpty,
          actionId: action.nullIfEmpty,
        ),
      );
    }
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (_registration == null) {
      return <ActiveNotification>[];
    }
    final List<ActiveNotification> activeNotifications = <ActiveNotification>[];
    final Set<int> ids = <int>{};
    final List<Notification> notifications =
        await _registration!.getDartNotifications();
    for (final Notification notification in notifications) {
      final int? id = notification.id;
      if (id == null) {
        continue;
      }
      
      // Extract additional notification details from the web Notification API
      final String? title = notification.title.nullIfEmpty;
      final String? body = notification.body.nullIfEmpty;
      final String? tag = notification.tag.nullIfEmpty;
      
      // Extract payload from the data object
      String? payload;
      final JSAny? data = notification.data;
      if (data != null && data.typeofEquals('object')) {
        final JSAny? payloadValue = (data as JSObject)['payload'];
        if (payloadValue != null && payloadValue.typeofEquals('string')) {
          payload = (payloadValue as JSString).toDart.nullIfEmpty;
        }
      }
      
      final ActiveNotification activeNotification = ActiveNotification(
        id: id,
        title: title,
        body: body,
        tag: tag,
        payload: payload,
      );
      ids.add(id);
      activeNotifications.add(activeNotification);
    }
    return activeNotifications;
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    if (_registration == null) {
      return;
    }
    final List<Notification> notifications =
        await _registration!.getDartNotifications();
    final Notification? notification = notifications.firstWhereOrNull(
      (Notification notification) =>
          notification.id == id && (tag == null || notification.tag == tag),
    );
    notification?.close();
  }

  @override
  Future<void> cancelAll() async {
    if (_registration == null) {
      return;
    }
    final List<Notification> notifications =
        await _registration!.getDartNotifications();
    for (final Notification notification in notifications) {
      notification.close();
    }
  }

  @override
  Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() async => <PendingNotificationRequest>[];

  @override
  Future<void> periodicallyShow({
    required int id,
    String? title,
    String? body,
    required RepeatInterval repeatInterval,
  }) {
    throw UnsupportedError('periodicallyShow() is not supported on the web');
  }

  @override
  Future<void> periodicallyShowWithDuration({
    required int id,
    String? title,
    String? body,
    required Duration repeatDurationInterval,
  }) {
    throw UnsupportedError(
      'periodicallyShowWithDuration() is not supported '
      'on the web',
    );
  }
}
