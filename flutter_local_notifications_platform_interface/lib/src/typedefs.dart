import 'types.dart';

/// Signature of callback triggered on main isolate when a user taps on a
/// notification or a notification action.
typedef DidReceiveNotificationResponseCallback = void Function(
    NotificationResponse details);

/// Signature of callback triggered on background isolate when a user taps on a
/// notification or  a notification action.
typedef DidReceiveBackgroundNotificationResponseCallback = void Function(
    NotificationResponse details);
