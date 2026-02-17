import 'dart:developer' as developer;
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
      developer.log(
        'Notification actions are only supported in Chrome 48+ and Edge 18+. '
        'In Firefox and Safari, actions will be silently ignored.',
        name: 'flutter_local_notifications_web',
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
      developer.log(
        'Failed to initialize: $e',
        name: 'flutter_local_notifications_web',
      );
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
  Future<bool?> requestNotificationsPermission() async {
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
    final String? idString = query['notification_id'];
    if (idString == null) {
      return null;
    }

    // Safely parse the notification ID — return null for non-numeric values
    final int? id = int.tryParse(idString);
    if (id == null) {
      return null;
    }

    final String? payload = query['notification_payload'];
    final String? action = query['notification_action'];
    final String? reply = query['notification_reply'];

    // Clean up only notification-related query parameters while preserving
    // the current path and any other query parameters
    final Map<String, String> cleanedQuery = Map<String, String>.from(query)
      ..remove('notification_id')
      ..remove('notification_payload')
      ..remove('notification_action')
      ..remove('notification_reply');
    final Uri cleanedUri = uri.replace(
        queryParameters: cleanedQuery.isEmpty ? null : cleanedQuery);
    // Use pathOnly (path + remaining query + fragment) to avoid pushing a
    // full absolute URI which would fail for cross-origin scenarios
    final String cleanedUrl = cleanedQuery.isEmpty
        ? '${cleanedUri.path}${cleanedUri.hasFragment ? '#${cleanedUri.fragment}' : ''}'
        : '${cleanedUri.path}?${cleanedUri.query}${cleanedUri.hasFragment ? '#${cleanedUri.fragment}' : ''}';
    window.history.replaceState(null, '', cleanedUrl);

    return NotificationAppLaunchDetails(
      true,
      notificationResponse: NotificationResponse(
        notificationResponseType: (action == null || action.isEmpty)
            ? NotificationResponseType.selectedNotification
            : NotificationResponseType.selectedNotificationAction,
        id: id,
        input: reply?.nullIfEmpty,
        payload: payload?.nullIfEmpty,
        actionId: action?.nullIfEmpty,
      ),
    );
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

      // Extract payload from the data object with comprehensive type checking
      final String? payload = _extractPayloadFromNotificationData(
        notification.data,
      );

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

  /// Safely extracts the payload string from notification data.
  ///
  /// Handles various edge cases:
  /// - Null or undefined data
  /// - Non-object data types
  /// - Missing payload field
  /// - Non-string payload values (converts numbers/booleans to strings)
  ///
  /// Returns null if the payload cannot be extracted or is empty.
  String? _extractPayloadFromNotificationData(JSAny? data) {
    // Check if data exists and is an object
    if (data == null || !data.typeofEquals('object')) {
      return null;
    }

    // Extract the payload field
    final JSAny? payloadValue = (data as JSObject)['payload'];
    if (payloadValue == null) {
      return null;
    }

    // Handle string payloads (most common case)
    if (payloadValue.typeofEquals('string')) {
      return (payloadValue as JSString).toDart.nullIfEmpty;
    }

    // Handle number payloads (convert to string)
    if (payloadValue.typeofEquals('number')) {
      final num value = (payloadValue as JSNumber).toDartDouble;
      // Check if it's an integer to avoid unnecessary decimal points
      if (value == value.toInt()) {
        return value.toInt().toString();
      }
      return value.toString();
    }

    // Handle boolean payloads (convert to string)
    if (payloadValue.typeofEquals('boolean')) {
      return (payloadValue as JSBoolean).toDart.toString();
    }

    // For other types (objects, arrays, functions), return null
    // We don't attempt to serialize complex types as they weren't
    // intended to be used as payloads
    return null;
  }

  @override
  Future<void> cancel({required int id}) async {
    if (_registration == null) {
      return;
    }

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
}
