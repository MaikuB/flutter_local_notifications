/// The available importance levels for Android notifications.
/// Required for Android 8.0+

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_local_notifications/platform_specifics/android/styles/default_style_information.dart';
import 'package:flutter_local_notifications/platform_specifics/android/styles/style_information.dart';

/// The available notification styles on Android
enum NotificationStyleAndroid { Default, BigText, Inbox }

/// Defines the available importance levels for Android notifications
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

// Priority for notifications on Android 7.1 and lower
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

/// The available alert behaviours for grouped notifications
enum GroupAlertBehavior { All, Summary, Children }

/// Configures the notification on Android
class NotificationDetailsAndroid {
  /// The icon that should be used when displaying the notification. When not specified, this will use the default icon that has been configured.
  final String icon;

  /// The channel's id. Required for Android 8.0+
  final String channelId;

  /// The channel's name. Required for Android 8.0+
  final String channelName;

  /// The channel's description. Required for Android 8.0+
  final String channelDescription;

  /// The importance of the notification
  Importance importance;

  /// The priority of the notification
  Priority priority;

  /// Indicates if a sound should be played when the notification is displayed. For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  bool playSound;

  /// The sound to play for the notification. Requires setting [playSound] to true for it to work. If [playSound] is set to true but this is not specified then the default sound is played. For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  String sound;

  /// Indicates if vibration should be enabled when the notification is displayed. For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  bool enableVibration;

  /// The vibration pattern. Requires setting [enableVibration] to true for it to work. For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  Int64List vibrationPattern;

  /// Defines the notification style
  NotificationStyleAndroid style;

  /// Contains extra information for the specified notification [style]
  StyleInformation styleInformation;

  /// Specifies the group that this notification belongs to. For Android 7.0+ (API level 24)
  String groupKey;

  /// Specifies if this notification will function as the summary for grouped notifications
  bool setAsGroupSummary;

  /// Sets the group alert behavior for this notification. Default is AlertAll. See https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#setGroupAlertBehavior(int)
  GroupAlertBehavior groupAlertBehavior;

  /// Specifies if the notification should automatically dismissed upon tapping on it
  bool autoCancel;

  /// Specifies if the notification will be "ongoing".
  bool ongoing;

  /// Sets the color
  Color color;

  NotificationDetailsAndroid(
      this.channelId, this.channelName, this.channelDescription,
      {this.icon,
      this.importance = Importance.Default,
      this.priority = Priority.Default,
      this.style = NotificationStyleAndroid.Default,
      this.styleInformation,
      this.playSound = true,
      this.sound,
      this.enableVibration = true,
      this.vibrationPattern,
      this.groupKey,
      this.setAsGroupSummary,
      this.groupAlertBehavior = GroupAlertBehavior.All,
      this.autoCancel = true,
      this.ongoing,
      this.color});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'icon': icon,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'importance': importance.value,
      'priority': priority.value,
      'playSound': playSound,
      'sound': sound,
      'enableVibration': enableVibration,
      'vibrationPattern': vibrationPattern,
      'style': style.index,
      'styleInformation': styleInformation == null
          ? new DefaultStyleInformation(false, false).toMap()
          : styleInformation.toMap(),
      'groupKey': groupKey,
      'setAsGroupSummary': setAsGroupSummary,
      'groupAlertBehavior': groupAlertBehavior.index,
      'autoCancel': autoCancel,
      'ongoing': ongoing,
      'colorAlpha': color?.alpha,
      'colorRed': color?.red,
      'colorGreen': color?.green,
      'colorBlue': color?.blue
    };
  }
}
