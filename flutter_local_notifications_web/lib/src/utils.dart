import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';

import 'details.dart';

extension JSNotificationUtils on Notification {
  /// Gets the ID of the notification.
  int? get id => jsonDecode(data.toString())?['id'];
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

extension NullableWebNotificationDetailsUtils on WebNotificationDetails? {
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
