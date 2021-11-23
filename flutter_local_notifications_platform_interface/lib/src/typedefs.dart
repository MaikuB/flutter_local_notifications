/// Signature of callback passed to [initialize] that is triggered when user
/// taps on a notification.
typedef SelectNotificationCallback = void Function(String? payload);

/// Callback function when a notification is received.
typedef NotificationActionCallback = void Function(
    String id, String? input, String? payload);
