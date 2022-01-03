import 'types.dart';

/// Signature of callback passed that is triggered when user selects a
/// notification.
typedef SelectNotificationCallback = void Function(String? payload);

/// Signature of callback triggered when a user selects on a notification action
typedef SelectNotificationActionCallback = void Function(
    NotificationActionDetails details);
