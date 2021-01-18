import 'enums.dart';

/// Settings for Android notification channels.
class AndroidNotificationChannelOutputInfo {
  /// Constructs an instance of [AndroidNotificationChannel].
  const AndroidNotificationChannelOutputInfo(
      this.id, this.name, this.importance);

  /// The channel's id.
  final String id;

  /// The channel's name.
  final String name;

  /// The importance of the notification.
  final Importance importance;
}
