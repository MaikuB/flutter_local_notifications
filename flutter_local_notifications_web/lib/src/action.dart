/// The type of action for a web notification.
///
/// This is a non-standard extension of `showNotification()`s `options.actions`
/// parameter that allows for buttons and text inputs.
///
/// The proposal can be found [here](https://github.com/whatwg/notifications/pull/132).
///
/// Web actions themselves are hardly supported at the time of writing. See
/// [WebNotificationAction] for more details.
enum WebNotificationActionType {
  /// This action is a button the user can press.
  button('button'),

  /// This action is an input field the user can type into.
  textInput('text');

  const WebNotificationActionType(this.jsValue);

  /// A string to pass to the JavaScript functions that indicates this type.
  final String jsValue;
}

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
    this.type = WebNotificationActionType.button,
  });

  /// The type of action (button by default).
  final WebNotificationActionType type;

  /// A developer-facing string representing this action.
  final String action;

  /// A user-facing string to be shown next to this action.
  final String title;

  /// An optional icon to display next to the action.
  final Uri? icon;
}
