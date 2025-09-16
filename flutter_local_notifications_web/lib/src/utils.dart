import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

import 'details.dart';

/// Utility methods on JavaScript [Notification] objects.
extension JSNotificationUtils on Notification {
  /// The ID of the notification.
  int? get id => int.tryParse(tag);
}

/// Utility methods on [ServiceWorkerRegistration] objects.
extension ServiceWorkerUtils on ServiceWorkerRegistration {
  /// Gets a list of notifications (as Dart objects).
  Future<List<Notification>> getDartNotifications() async =>
      (await getNotifications().toDart).toDart;
}

/// Utility methods on [WebNotificationDetails] objects.
extension WebNotificationDetailsUtils on WebNotificationDetails {
  /// A JavaScript array with the number of milliseconds in between vibrations.
  JSArray<JSNumber>? get vibrationPatternMs => vibrationPattern == null
      ? null
      : <JSNumber>[
          for (final Duration duration in vibrationPattern!)
            duration.inMilliseconds.toJS,
        ].toJS;
}

/// Utility methods on [WebNotificationAction] objects.
extension on WebNotificationAction {
  /// Converts this object to the format expected by `showNotifications()`
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/actions.
  ///
  /// Note: There is a WHATWG proposal to add button and text input actions.
  /// This requires setting an additional `type` parameter, which is not yet
  /// standardized, so is not a part of the Dart APIs. That's why we cannot rely
  /// on `NotificationAction.toJs` for this function.
  ///
  /// The proposal can be found here: https://github.com/whatwg/notifications/pull/132
  NotificationAction toJs() => <String, dynamic>{
        'action': action,
        'title': title,
        'icon': icon?.toString(),
        'type': type.jsValue,
      }.jsify() as NotificationAction;
}

/// A useful way to convert a nullable details object to a JS payload.
extension NullableWebNotificationDetailsUtils on WebNotificationDetails? {
  /// Converts the list of actions into a JS array (empty if needed).
  List<WebNotificationAction> get _actions =>
      this?.actions ?? <WebNotificationAction>[];

  /// Converts these nullable details to a JS [NotificationOptions] object.
  NotificationOptions toJs(int id, String? payload) {
    final NotificationOptions options = NotificationOptions(
      data: <String, dynamic>{'payload': payload}.jsify(),
      tag: id.toString(),
      // -----------------------------
      actions: <NotificationAction>[
        for (final WebNotificationAction action in _actions) action.toJs(),
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

/// Utility methods on JavaScript [NotificationEvent] objects.
extension WebNotificationEventUtils on NotificationEvent {
  /// Gets text input from the action, if any.
  ///
  /// See [WebNotificationActionType] for details.
  String? get reply => (this['reply'] as JSString).toDart;
}
