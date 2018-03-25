/// The available importance levels for Android notifications.
/// Required for Android 8.0+
class Importance {
  static const Unspecified = const Importance(-1000);
  static const None = const Importance(0);
  static const Min = const Importance(1);
  static const Low = const Importance(2);
  static const Default = const Importance(3);
  static const High = const Importance(4);
  static const Max = const Importance(5);

  static get values => [Unspecified, None, Min, Low, Default, High, Max];

  final int value;

  const Importance(this.value);
}

// Notification priority for Android 7.1 and lower
class Priority {
  static const Min = const Priority(-2);
  static const Low = const Priority(-1);
  static const Default = const Priority(0);
  static const High = const Priority(1);
  static const Max = const Priority(2);

  static get values => [Min, Low, Default, High, Max];

  final int value;

  const Priority(this.value);
}

/// Configures the notification on Android
class NotificationDetailsAndroid {
  /// The icon that should be used when displaying the notification
  final String icon;

  /// The channel's id. Required for Android 8.0+
  final String channelId;

  /// The channel's name. Required for Android 8.0+
  final String channelName;

  /// The channel's description. Required for Android 8.0+
  final String channelDescription;

  /// The importance of the notification
  Importance importance = Importance.Default;

  /// The priority of the notification
  Priority priority = Priority.Default;

  NotificationDetailsAndroid(this.channelId,
      this.channelName, this.channelDescription, {this.icon, this.importance = Importance.Default, this.priority = Priority.Default});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'icon': icon,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'importance': importance.value,
      'priority': priority.value
    };
  }
}
