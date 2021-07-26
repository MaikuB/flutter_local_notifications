/// Signature of callback passed to [initialize] that is triggered when user
/// taps on a notification.
typedef SelectNotificationCallback = Future<dynamic> Function(String? payload);
