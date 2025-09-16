import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

import 'details.dart';

extension JSNotificationUtils on Notification {
  /// Gets the ID of the notification.
  int? get id => int.tryParse(tag);
  String? get payload => jsonDecode(data.toString())?['payload'];
}

extension ServiceWorkerUtils on ServiceWorkerRegistration {
  Future<List<Notification>> getDartNotifications() async =>
      (await getNotifications().toDart).toDart;
}

extension WebNotificationDetailsUtils on WebNotificationDetails {
  JSArray<JSNumber>? get vibrationPatternMs => vibrationPattern == null
      ? null
      : <JSNumber>[
          for (final Duration duration in vibrationPattern!)
            duration.inMilliseconds.toJS,
        ].toJS;
}

extension on WebNotificationAction {
  // There is a WHATWG proposal to add text input notifications.
  // Most browsers support this even though it is not standardized.
  // Since it is not standard, the Dart API does not support it.
  // See: https://github.com/whatwg/notifications/pull/132
  NotificationAction toJs() => <String, dynamic>{
    'action': action,
    'title': title,
    'icon': icon?.toString(),
    'type': type.jsValue,
  }.jsify() as NotificationAction;
}

extension NullableWebNotificationDetailsUtils on WebNotificationDetails? {
  List<WebNotificationAction> get _actions =>
    this?.actions ?? <WebNotificationAction>[];

  NotificationOptions toJs(int id, String? payload) {
    final NotificationOptions options = NotificationOptions(
      data: <String, dynamic>{'payload': payload}.jsify(),
      tag: id.toString(),
      // -----------------------------
      actions: <NotificationAction>[
        for (final WebNotificationAction action in _actions)
          action.toJs(),
      ].toJS,
      badge: this?.badgeUrl.toString() ?? '',
      body: this?.body ?? '',
      dir: this?.direction.jsValue ?? WebNotificationDirection.auto.jsValue,
      icon: this?.iconUrl.toString() ?? '',
      image: this?.imageUrl.toString() ?? '',
      lang: this?.lang ?? '',
      renotify: this?.renotify ?? false,
      requireInteraction: this?.requireInteraction ?? false,
      silent: this?.isSilent,
      timestamp: (this?.timestamp ?? DateTime.now()).millisecondsSinceEpoch,
    );

    final JSArray<JSNumber>? vibration = this?.vibrationPatternMs;
    if (vibration != null) {
      options.vibrate = vibration;
    }
    return options;
  }
}

extension WebNotificationEventUtils on NotificationEvent {
  // Support for getting text input.
  // See: https://github.com/whatwg/notifications/pull/132
  String? get reply => (this['reply'] as JSString).toDart;
}
