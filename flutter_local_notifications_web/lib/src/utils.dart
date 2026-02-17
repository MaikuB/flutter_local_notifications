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
          for (final int duration in vibrationPattern!) duration.toJS,
        ].toJS;
}

/// Utility methods on [WebNotificationAction] objects.
extension on WebNotificationAction {
  /// Converts this object to the format expected by `showNotifications()`
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/actions.
  NotificationAction toJs() {
    final NotificationAction result = NotificationAction(
      action: action,
      title: title,
    );
    if (icon != null) {
      result.icon = icon.toString();
    }
    return result;
  }
}

/// A useful way to convert a nullable details object to a JS payload.
extension NullableWebNotificationDetailsUtils on WebNotificationDetails? {
  /// Converts the list of actions into a JS array (empty if needed).
  List<WebNotificationAction> get _actions =>
      this?.actions ?? <WebNotificationAction>[];

  /// Converts these nullable details to a JS [NotificationOptions] object.
  NotificationOptions toJs(int id, String? body, String? payload) {
    final NotificationOptions options = NotificationOptions(
      // Note: We use 'tag' to store the notification ID because:
      // 1. The Web Notification API doesn't have a separate 'id' field
      // 2. The 'tag' field is used to identify and replace notifications
      // 3. Multiple notifications with the same tag will replace each other
      // 4. This matches the behavior of notification IDs on other platforms
      data: <String, dynamic>{'payload': payload}.jsify(),
      tag: id.toString(),
      // -----------------------------
      actions: <NotificationAction>[
        for (final WebNotificationAction action in _actions) action.toJs(),
      ].toJS,
      badge: this?.badgeUrl?.toString() ?? '',
      body: body ?? '',
      dir: this?.direction.jsValue ?? WebNotificationDirection.auto.jsValue,
      icon: this?.iconUrl?.toString() ?? '',
      image: this?.imageUrl?.toString() ?? '',
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
  /// Note: This is a Chrome-only feature for text input actions and may not
  /// be available in all browsers or for all notification action types.
  String? get reply {
    final JSAny? replyValue = this['reply'];
    if (replyValue != null && replyValue.typeofEquals('string')) {
      return (replyValue as JSString).toDart;
    }
    return null;
  }
}

/// Helpful methods on strings.
extension StringUtils on String {
  /// Returns null if this string is empty.
  ///
  /// Useful because JavaScript might prefer to represent a blank option with an
  /// empty string, while Dart users would prefer `null` instead.
  String? get nullIfEmpty => isEmpty ? null : this;
}
