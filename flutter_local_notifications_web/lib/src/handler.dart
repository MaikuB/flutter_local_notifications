@JS()
library;

import 'dart:js_interop';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:web/web.dart';

import 'utils.dart';

/// An object representing a clicked notification.
///
/// Notification clicks are handled by service workers. See `web/notification_service_worker.js`
/// for the source code there. When the service worker receives the
/// [NotificationEvent], it uses [Client.postMessage] to send a message back to
/// the currently open window/tab, if there is any.
///
/// This is the object sent by the service worker via [Client.postMessage].
extension type JSNotificationData(JSObject _) implements JSObject {
  /// A string rperesenting the [NotificationAction.action], if any.
  external String? action;

  /// A string representing the [Notification.tag];
  external String id;

  /// The original payload passed to [FlutterLocalNotificationsPlatform.show].
  external String? payload;

  /// The reply entered by the user in the text field, if any.
  external String? reply;

  /// The [NotificationResponse] that corresponds to this object.
  NotificationResponse get response {
    final NotificationResponseType type = (action?.isEmpty ?? true)
        ? NotificationResponseType.selectedNotification
        : NotificationResponseType.selectedNotificationAction;

    return NotificationResponse(
      id: int.parse(id),
      input: reply?.nullIfEmpty,
      payload: payload?.nullIfEmpty,
      actionId: action?.nullIfEmpty,
      notificationResponseType: type,
    );
  }
}
