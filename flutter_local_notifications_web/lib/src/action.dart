/// A means for a user to interact with a web notification.
///
/// See: [`options.actions`](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/showNotification#actions)
///
/// Note: This is not standard yet, see: https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/showNotification#browser_compatibility
/// Notably, Firefox and Safari do not support this yet.
class WebNotificationAction {
  /// A const constructor.
  const WebNotificationAction({
    required this.action,
    required this.title,
    this.icon,
  });

  /// A developer-facing string representing this action.
  final String action;

  /// A user-facing string to be shown next to this action.
  final String title;

  /// An optional icon to display next to the action.
  final Uri? icon;
}
