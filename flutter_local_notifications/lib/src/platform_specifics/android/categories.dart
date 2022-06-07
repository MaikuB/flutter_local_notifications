import 'package:flutter/foundation.dart';

/// The available categories for Android notifications.
@immutable
class AndroidNotificationCategory {
  /// Constructs an instance of [AndroidNotificationCategory]
  /// with a given [name] of category.
  const AndroidNotificationCategory(this.name);

  /// Alarm or timer.
  static const AndroidNotificationCategory alarm =
      AndroidNotificationCategory('alarm');

  /// Incoming call (voice or video) or similar
  /// synchronous communication request.
  static const AndroidNotificationCategory call =
      AndroidNotificationCategory('call');

  /// Asynchronous bulk message (email).
  static const AndroidNotificationCategory email =
      AndroidNotificationCategory('email');

  /// Error in background operation or authentication status.
  static const AndroidNotificationCategory error =
      AndroidNotificationCategory('err');

  /// Calendar event.
  static const AndroidNotificationCategory event =
      AndroidNotificationCategory('event');

  /// Temporarily sharing location.
  static const AndroidNotificationCategory locationSharing =
      AndroidNotificationCategory('location_sharing');

  /// Incoming direct message like SMS and instant message.
  static const AndroidNotificationCategory message =
      AndroidNotificationCategory('msg');

  /// Missed call.
  static const AndroidNotificationCategory missedCall =
      AndroidNotificationCategory('missed_call');

  /// Map turn-by-turn navigation.
  static const AndroidNotificationCategory navigation =
      AndroidNotificationCategory('navigation');

  /// Progress of a long-running background operation.
  static const AndroidNotificationCategory progress =
      AndroidNotificationCategory('progress');

  /// Promotion or advertisement.
  static const AndroidNotificationCategory promo =
      AndroidNotificationCategory('promo');

  /// A specific, timely recommendation for a single thing.
  ///
  /// For example, a news app might want to recommend a
  /// news story it believes the user will want to read next.
  static const AndroidNotificationCategory recommendation =
      AndroidNotificationCategory('recommendation');

  /// User-scheduled reminder.
  static const AndroidNotificationCategory reminder =
      AndroidNotificationCategory('reminder');

  /// Indication of running background service.
  static const AndroidNotificationCategory service =
      AndroidNotificationCategory('service');

  /// Social network or sharing update.
  static const AndroidNotificationCategory social =
      AndroidNotificationCategory('social');

  /// Ongoing information about device or contextual status.
  static const AndroidNotificationCategory status =
      AndroidNotificationCategory('status');

  /// Running stopwatch.
  static const AndroidNotificationCategory stopwatch =
      AndroidNotificationCategory('stopwatch');

  /// System or device status update.
  ///
  /// Reserved for system use.
  static const AndroidNotificationCategory system =
      AndroidNotificationCategory('sys');

  /// Media transport control for playback.
  static const AndroidNotificationCategory transport =
      AndroidNotificationCategory('transport');

  /// Tracking a user's workout.
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
