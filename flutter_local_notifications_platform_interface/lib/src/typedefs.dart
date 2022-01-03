import 'types.dart';

/// Signature of callback passed that is triggered when user taps on a
/// notification.
typedef SelectNotificationCallback = void Function(String? payload);

/// Signature of callback triggered when a user taps on a notification action
typedef NotificationActionCallback = void Function(
    NotificationActionDetails details);
