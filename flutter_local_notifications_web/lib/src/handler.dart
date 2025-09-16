@JS()
library;

import 'dart:js_interop';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

extension StringUtils on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

extension type JSNotificationData(JSObject _) implements JSObject {
  external String action;
  external String id;
  external String? payload;
  external String? reply;

  NotificationResponse get response {
    final NotificationResponseType type = action.isEmpty
        ? NotificationResponseType.selectedNotification
        : NotificationResponseType.selectedNotificationAction;

    return NotificationResponse(
      id: int.parse(id),
      input: reply?.nullIfEmpty,
      payload: payload?.nullIfEmpty,
      actionId: action.nullIfEmpty,
      notificationResponseType: type,
    );
  }
}
