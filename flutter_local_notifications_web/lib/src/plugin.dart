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

  /// Whether the browser supports the Notification API.
  ///
  /// Returns `false` for very old browsers or certain embedded contexts
  /// that don't support notifications.
  static bool get isSupported {
    try {
      return window.hasProperty('Notification'.toJS).toDart;
    } catch (e) {
      return false;
    }
  }

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

    // Warn if actions are used (they may not be supported in all browsers)
    if (details?.actions.isNotEmpty == true) {
      // Note: Notification actions are only supported in Chrome 48+ and Edge 18+.
      // In Firefox and Safari, actions will be silently ignored and the
      // notification will still be shown without action buttons.
      // See: https://caniuse.com/mdn-api_serviceworkerregistration_shownotification_options_actions_parameter
    }

    await _registration!
        .showNotification(
          title ?? '',
          details.toJs(id, body, payload),
        )
        .toDart;
  }

  /// Initializes the plugin.
  ///
  /// Returns `true` if initialization succeeded, `false` if it failed.
  /// Initialization can fail if:
  /// - Service Workers are not supported (older browsers, private mode)
  /// - Service Worker registration fails
  /// - The Notification API is not available
  Future<bool?> initialize({
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    instance = this;
    _userCallback = onDidReceiveNotificationResponse;

    try {
      // Check if the Notification API is supported
      if (!isSupported) {
        throw UnsupportedError(
          'The Notification API is not supported in this browser',
        );
      }

      // Check if service workers are supported
      final JSAny? serviceWorkerProperty = window.navigator['serviceWorker'];
      if (serviceWorkerProperty == null) {
        throw UnsupportedError(
          'Service Workers are not supported in this browser. '
          'Notifications require Service Worker support.',
        );
      }

      // Replace the default Flutter service worker with our own.
      // This isn't supported at build time yet and so must be done at runtime.
      // See: https://github.com/flutter/flutter/issues/145828
      final ServiceWorkerContainer serviceWorker =
          window.navigator.serviceWorker;
      _registration = await serviceWorker.getRegistration().toDart;
      const String jsPath =
          './assets/packages/flutter_local_notifications_web/web/notifications_service_worker.js';
      _registration = await serviceWorker.register(jsPath.toJS).toDart;

      if (_registration == null) {
        throw StateError('Failed to register service worker');
      }

      // Subscribe to messages from the service worker
      serviceWorker.onmessage = _onNotificationClicked.toJS;

      return true;
    } catch (e) {
      // Initialization failed - log error and return false
      // ignore: avoid_print
      print('flutter_local_notifications_web: Failed to initialize: $e');
      return false;
    }
  }

  /// Requests notification permission from the browser.
  ///
  /// Be sure to only request permissions in response to a user gesture, or it
  /// may be automatically rejected.
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  /// If permission was previously denied, this will return `false` without
  /// showing a prompt (browsers typically don't allow re-prompting).
  Future<bool> requestNotificationsPermission() async {
    // Don't request if already denied - browsers won't show prompt again
    if (isPermissionDenied) {
      return false;
    }

    final JSString permissionStatus =
        await Notification.requestPermission().toDart;
    return permissionStatus.toDart == 'granted';
  }

  /// Returns the current permission status as a string.
  ///
  /// Possible values:
  /// - `'granted'`: User explicitly allowed notifications
  /// - `'denied'`: User explicitly blocked notifications (may be permanent)
  /// - `'default'`: User hasn't decided yet
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/permission
  String get permissionStatus => Notification.permission;

  /// Whether the user has granted permission to show notifications.
  ///
  /// If this is false, you must call [requestNotificationsPermission]. Be sure
  /// to only request permissions in response to a user gesture, or it may be
  /// automatically rejected.
  bool get hasPermission => Notification.permission == 'granted';

  /// Whether the user has explicitly denied permission to show notifications.
  ///
  /// When this is `true`, calling [requestNotificationsPermission] will not
  /// show a prompt and will return `false`. Users must manually reset
  /// permissions in their browser settings.
  bool get isPermissionDenied => Notification.permission == 'denied';

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
    // Note: The tag parameter is Android-specific and ignored on web.
    // On web, we only use the notification ID to identify notifications.
    final List<Notification> notifications =
        await _registration!.getDartNotifications();
    final Notification? notification = notifications.firstWhereOrNull(
      (Notification notification) => notification.id == id,
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
  Future<void> cancelAllPendingNotifications() async {
    // Web doesn't support scheduled notifications, so there are no pending
    // notifications to cancel. This is a no-op for web platform.
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

  /// Schedules a notification to be shown at a specific date and time.
  ///
  /// This method is not supported on web as browsers do not provide APIs
  /// for scheduling notifications at specific times. Use server-side push
  /// notifications or implement client-side scheduling with timers instead.
  ///
  /// Throws [UnsupportedError] when called.
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required DateTime scheduledDate,
    String? payload,
  }) {
    throw UnsupportedError(
      'zonedSchedule() is not supported on the web. '
      'Browsers do not provide APIs for scheduling notifications. '
      'Consider using server-side push notifications or client-side timers.',
    );
  }
}
