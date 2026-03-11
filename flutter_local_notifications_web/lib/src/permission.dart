/// The permission status for web notifications.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/permission
enum WebNotificationPermission {
  /// User explicitly allowed notifications.
  granted('granted'),

  /// User explicitly blocked notifications (may be permanent).
  denied('denied'),

  /// User hasn't decided yet.
  defaultPermissions('default');

  const WebNotificationPermission(this.name);

  /// The string representation of the permission.
  final String name;

  /// Returns the corresponding [WebNotificationPermission] from a string
  /// given by the browser's Notification API.
  static WebNotificationPermission fromString(String status) {
    switch (status) {
      case 'granted':
        return WebNotificationPermission.granted;
      case 'denied':
        return WebNotificationPermission.denied;
      case 'default':
      default:
        return WebNotificationPermission.defaultPermissions;
    }
  }
}
