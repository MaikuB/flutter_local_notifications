import 'action.dart';
import 'direction.dart';

export 'action.dart';
export 'direction.dart';

/// The web-specific details of a notification.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification
///
/// Note: The `tag` field is reserved for the notification ID.
class WebNotificationDetails {
  /// A const constructor.
  const WebNotificationDetails({
    this.actions = const <WebNotificationAction>[],
    this.direction = WebNotificationDirection.auto,
    this.badgeUrl,
    this.iconUrl,
    this.lang,
    this.requireInteraction = false,
    this.isSilent = false,
    this.imageUrl,
    this.renotify = false,
    this.timestamp,
    this.vibrationPattern,
  });

  /// A list of actions to send with the notification.
  final List<WebNotificationAction> actions;

  /// The text direction of the notification.
  final WebNotificationDirection direction;

  /// An optional URL to a monochrome icon to show next to the title.
  final Uri? badgeUrl;

  /// An optional URL to an image to show as the app icon.
  final Uri? iconUrl;

  /// An optional URL to an image to show in the notification.
  final Uri? imageUrl;

  /// The language code of the notification's content, eg `en-US`.
  ///
  /// This should be a BCP 47 language tag (such as `en-US`, `fr-FR`, or `ja-JP`).
  /// When left null, the notification defaults to using an empty string for the
  /// language, which typically causes the browser to use its default language
  /// settings or infer the language from the notification content and the user's
  /// locale environment.
  final String? lang;

  /// Whether the notification should remain visible until manually dismissed.
  final bool requireInteraction;

  /// Whether the notification should be silent.
  final bool isSilent;

  /// Whether the user should be notified if this notification is replaced.
  ///
  /// If this is false, the new notification will replace this one silently. If
  /// this is true, the device will notify the user any time the notification is
  /// updated.
  ///
  /// For example, when updating a loading notification, you want each update to
  /// occur silently. But if you have a notification that represents a chat
  /// thread, you'd want it to update when a new message is sent.
  final bool renotify;

  /// The timestamp of the event that caused this notification.
  ///
  /// This doesn't always have to be the time the notification was sent. For
  /// exmaple, if the notification represents a message that was sent a while
  /// ago, you can back-date this timestamp to when the message was originally
  /// sent instead of when it was received.
  final DateTime? timestamp;

  /// An optional vibration pattern.
  ///
  /// This should be a list of milliseconds, starting with how long the device
  /// should vibrate for, followed by how long it should pause.
  ///
  /// For examples, see:
  /// - https://developer.mozilla.org/en-US/docs/Web/API/Vibration_API#vibration_patterns
  /// - https://web.dev/articles/push-notifications-display-a-notification#vibrate
  ///
  /// Note: This is not supported on Android as vibration patterns are set by
  /// the notification channel, not an individual notification.
  final List<int>? vibrationPattern;
}
