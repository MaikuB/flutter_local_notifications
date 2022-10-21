import 'package:flutter/foundation.dart';

/// The available categories for Android notifications.
@immutable
class AndroidNotificationCategory {
  /// Constructs an instance of [AndroidNotificationCategory]
  /// with a given [name] of category.
  const AndroidNotificationCategory(this.name);

  /// Alarm or timer.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_ALARM`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_ALARM%28%29).
  static const AndroidNotificationCategory alarm =
      AndroidNotificationCategory('alarm');

  /// Incoming call (voice or video) or similar
  /// synchronous communication request.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_CALL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_CALL%28%29).
  static const AndroidNotificationCategory call =
      AndroidNotificationCategory('call');

  /// Asynchronous bulk message (email).
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_EMAIL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_EMAIL%28%29).
  static const AndroidNotificationCategory email =
      AndroidNotificationCategory('email');

  /// Error in background operation or authentication status.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_ERROR`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_ERROR%28%29).
  static const AndroidNotificationCategory error =
      AndroidNotificationCategory('err');

  /// Calendar event.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_EVENT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_EVENT%28%29).
  static const AndroidNotificationCategory event =
      AndroidNotificationCategory('event');

  /// Temporarily sharing location.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_LOCATION_SHARING`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_LOCATION_SHARING%28%29).
  static const AndroidNotificationCategory locationSharing =
      AndroidNotificationCategory('location_sharing');

  /// Incoming direct message like SMS and instant message.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_MESSAGE`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_MESSAGE%28%29).
  static const AndroidNotificationCategory message =
      AndroidNotificationCategory('msg');

  /// Missed call.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_MISSED_CALL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_MISSED_CALL%28%29).
  static const AndroidNotificationCategory missedCall =
      AndroidNotificationCategory('missed_call');

  /// Map turn-by-turn navigation.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_NAVIGATION`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_NAVIGATION%28%29).
  static const AndroidNotificationCategory navigation =
      AndroidNotificationCategory('navigation');

  /// Progress of a long-running background operation.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_PROGRESS`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_PROGRESS%28%29).
  static const AndroidNotificationCategory progress =
      AndroidNotificationCategory('progress');

  /// Promotion or advertisement.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_PROMO`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_PROMO%28%29).
  static const AndroidNotificationCategory promo =
      AndroidNotificationCategory('promo');

  /// A specific, timely recommendation for a single thing.
  ///
  /// For example, a news app might want to recommend a
  /// news story it believes the user will want to read next.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_RECOMMENDATION`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_RECOMMENDATION%28%29).
  static const AndroidNotificationCategory recommendation =
      AndroidNotificationCategory('recommendation');

  /// User-scheduled reminder.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_REMINDER`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_REMINDER%28%29).
  static const AndroidNotificationCategory reminder =
      AndroidNotificationCategory('reminder');

  /// Indication of running background service.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_SERVICE`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_SERVICE%28%29).
  static const AndroidNotificationCategory service =
      AndroidNotificationCategory('service');

  /// Social network or sharing update.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_SOCIAL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_SOCIAL%28%29).
  static const AndroidNotificationCategory social =
      AndroidNotificationCategory('social');

  /// Ongoing information about device or contextual status.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_STATUS`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_STATUS%28%29).
  static const AndroidNotificationCategory status =
      AndroidNotificationCategory('status');

  /// Running stopwatch.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_STOPWATCH`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_STOPWATCH%28%29).
  static const AndroidNotificationCategory stopwatch =
      AndroidNotificationCategory('stopwatch');

  /// System or device status update.
  ///
  /// Reserved for system use.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_SYSTEM`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_SYSTEM%28%29).
  static const AndroidNotificationCategory system =
      AndroidNotificationCategory('sys');

  /// Media transport control for playback.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_TRANSPORT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_TRANSPORT%28%29).
  static const AndroidNotificationCategory transport =
      AndroidNotificationCategory('transport');

  /// Tracking a user's workout.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_WORKOUT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_WORKOUT%28%29).
  static const AndroidNotificationCategory workout =
      AndroidNotificationCategory('workout');

  /// Name of category.
  final String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AndroidNotificationCategory && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'AndroidNotificationCategory(name: $name)';
}
