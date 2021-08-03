import 'dart:async';

/// Signature of the callback that is triggered when a notification is shown
/// whilst the app is in the foreground.
///
/// This property is only applicable to iOS versions older than 10.
typedef DidReceiveLocalNotificationCallback = Future<dynamic> Function(
    int id, String? title, String? body, String? payload);
