/// The urgency level of the Linux notification.
class LinuxNotificationUrgency {
  /// Constructs an instance of [LinuxNotificationUrgency].
  const LinuxNotificationUrgency(this.value);

  /// Unspecified
  static const LinuxNotificationUrgency unspecified =
      LinuxNotificationUrgency(-1000);

  /// Low urgency. Used for unimportant notifications.
  static const LinuxNotificationUrgency low = LinuxNotificationUrgency(0);

  /// Normal urgency. Used for most standard notifications.
  static const LinuxNotificationUrgency normal = LinuxNotificationUrgency(1);

  /// Critical urgency. Used for very important notifications.
  static const LinuxNotificationUrgency critical = LinuxNotificationUrgency(2);

  /// All the possible values for the [LinuxNotificationUrgency] enumeration.
  static List<LinuxNotificationUrgency> get values =>
      <LinuxNotificationUrgency>[unspecified, low, normal, critical];

  /// The integer representation.
  final int value;
}
