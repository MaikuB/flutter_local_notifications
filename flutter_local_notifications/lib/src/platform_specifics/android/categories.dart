import 'package:flutter/foundation.dart';

/// The available categories for Android notifications.
@immutable
class AndroidNotificationCategory {
  /// Constructs an instance of [AndroidNotificationCategory]
  /// with a given [name] of category.
  const AndroidNotificationCategory(this.name);

  /// Alarm or timer.
  factory AndroidNotificationCategory.alarm() =>
      const AndroidNotificationCategory('alarm');

  /// Incoming call (voice or video) or similar 
  /// synchronous communication request.
  factory AndroidNotificationCategory.call() =>
      const AndroidNotificationCategory('call');

  /// Asynchronous bulk message (email).
  factory AndroidNotificationCategory.email() =>
      const AndroidNotificationCategory('email');

  /// Error in background operation or authentication status.
  factory AndroidNotificationCategory.error() =>
      const AndroidNotificationCategory('err');

  /// Calendar event.
  factory AndroidNotificationCategory.event() =>
      const AndroidNotificationCategory('event');

  /// Temporarily sharing location.
  factory AndroidNotificationCategory.locationSharing() =>
      const AndroidNotificationCategory('location_sharing');

  /// Incoming direct message like SMS and instant message.
  factory AndroidNotificationCategory.message() =>
      const AndroidNotificationCategory('msg');

  /// Missed call.
  factory AndroidNotificationCategory.missedCall() =>
      const AndroidNotificationCategory('missed_call');

  /// Map turn-by-turn navigation.
  factory AndroidNotificationCategory.navigation() =>
      const AndroidNotificationCategory('navigation');

  /// Progress of a long-running background operation.
  factory AndroidNotificationCategory.progress() =>
      const AndroidNotificationCategory('progress');

  /// Promotion or advertisement.
  factory AndroidNotificationCategory.promo() =>
      const AndroidNotificationCategory('promo');

  /// A specific, timely recommendation for a single thing.
  ///
  /// For example, a news app might want to recommend a
  /// news story it believes the user will want to read next.
  factory AndroidNotificationCategory.recommendation() =>
      const AndroidNotificationCategory('recommendation');

  /// User-scheduled reminder.
  factory AndroidNotificationCategory.reminder() =>
      const AndroidNotificationCategory('reminder');

  /// Indication of running background service.
  factory AndroidNotificationCategory.service() =>
      const AndroidNotificationCategory('service');

  /// Social network or sharing update.
  factory AndroidNotificationCategory.social() =>
      const AndroidNotificationCategory('social');

  /// Ongoing information about device or contextual status.
  factory AndroidNotificationCategory.status() =>
      const AndroidNotificationCategory('status');

  /// Running stopwatch.
  factory AndroidNotificationCategory.stopwatch() =>
      const AndroidNotificationCategory('stopwatch');

  /// System or device status update.
  ///
  /// Reserved for system use.
  factory AndroidNotificationCategory.system() =>
      const AndroidNotificationCategory('sys');

  /// Media transport control for playback.
  factory AndroidNotificationCategory.transport() =>
      const AndroidNotificationCategory('transport');

  /// Tracking a user's workout.
  factory AndroidNotificationCategory.workout() =>
      const AndroidNotificationCategory('workout');

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
