import 'types.dart';

/// Signature of callback triggered when a user taps on a notification or
/// a notification action
typedef DidReceiveForegroundNotificationResponseCallback = void Function(
    NotificationResponse details);

/// Signature of callback triggered when a user taps on a notification or
/// a notification action
typedef DidReceiveBackgroundNotificationResponseCallback = void Function(
    NotificationResponse details);
