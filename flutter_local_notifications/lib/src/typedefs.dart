import 'dart:async';

/// Signature of callback passed to [initialize] that is triggered when user taps on a notification.
typedef SelectNotificationCallback = Future<dynamic> Function(String payload);

/// Signature of the callback that is triggered when a notification is shown whilst the app is in the foreground.
///
/// Applicable to iOS versions below 10.
typedef DidReceiveLocalNotificationCallback = Future<dynamic> Function(
    int id, String title, String body, String payload);
