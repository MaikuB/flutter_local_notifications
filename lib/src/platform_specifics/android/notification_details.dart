import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'enums.dart';
import 'notification_action.dart';
import 'styles/style_information.dart';
import 'styles/default_style_information.dart';

/// Configures the notification on Android
class AndroidNotificationDetails {
  /// The icon that should be used when displaying the notification. When not specified, this will use the default icon that has been configured.
  final String icon;

  /// The channel's id. Required for Android 8.0+
  final String channelId;

  /// The channel's name. Required for Android 8.0+
  final String channelName;

  /// The channel's description. Required for Android 8.0+
  final String channelDescription;

  /// Whether notifications posted to this channel can appear as application icon badges in a Launcher
  final bool channelShowBadge;

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

  /// Indicates if lights should be enabled when the notification is displayed. For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  bool enableLights;

  /// The vibration pattern. Requires setting [enableVibration] to true for it to work. For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  Int64List vibrationPattern;

  /// Defines the notification style
  AndroidNotificationStyle style;

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

  /// Specifics the large icon to use. This will be either the name of the drawable of an actual file path based on the value of [largeIconBitmapSource].
  String largeIcon;

  /// Specifies the source for the large icon
  BitmapSource largeIconBitmapSource;

  /// Specifies if you would only like the sound, vibrate and ticker to be played if the notification is not already showing.
  bool onlyAlertOnce;

  /// Specifies if the notification will be used to show progress
  bool showProgress;

  /// The maximum progress value
  int maxProgress;

  /// The current progress value
  int progress;

  /// Specifies if an indeterminate progress bar will be shown
  bool indeterminate;

  /// Sets the light color of the notification. For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  Color ledColor;

  /// Sets how long the light colour will remain on. Not applicable for Android 8.0+
  int ledOnMs;

  /// Sets how long the light colour will remain off. Not applicable for Android 8.0+
  int ledOffMs;

  /// Set the "ticker" text which is sent to accessibility services.
  String ticker;

  /// The action to take for managing notification channels. Defaults to creating the notification channel using the provided details if it doesn't exist
  AndroidNotificationChannelAction channelAction;

  AndroidNotificationDetails(
      this.channelId, this.channelName, this.channelDescription,
      {this.icon,
      this.importance = Importance.Default,
      this.priority = Priority.Default,
      this.style = AndroidNotificationStyle.Default,
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
      this.color,
      this.largeIcon,
      this.largeIconBitmapSource,
      this.onlyAlertOnce,
      this.channelShowBadge = true,
      this.showProgress = false,
      this.maxProgress = 0,
      this.progress = 0,
      this.indeterminate = false,
      this.channelAction = AndroidNotificationChannelAction.CreateIfNotExists,
      this.enableLights = false,
      this.ledColor,
      this.ledOnMs,
      this.ledOffMs,
      this.ticker});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'icon': icon,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'channelShowBadge': channelShowBadge,
      'channelAction': channelAction?.index,
      'importance': importance.value,
      'priority': priority.value,
      'playSound': playSound,
      'sound': sound,
      'enableVibration': enableVibration,
      'vibrationPattern': vibrationPattern,
      'style': style.index,
      'styleInformation': styleInformation == null
          ? DefaultStyleInformation(false, false).toMap()
          : styleInformation.toMap(),
      'groupKey': groupKey,
      'setAsGroupSummary': setAsGroupSummary,
      'groupAlertBehavior': groupAlertBehavior.index,
      'autoCancel': autoCancel,
      'ongoing': ongoing,
      'colorAlpha': color?.alpha,
      'colorRed': color?.red,
      'colorGreen': color?.green,
      'colorBlue': color?.blue,
      'largeIcon': largeIcon,
      'largeIconBitmapSource': largeIconBitmapSource?.index,
      'onlyAlertOnce': onlyAlertOnce,
      'showProgress': showProgress,
      'maxProgress': maxProgress,
      'progress': progress,
      'indeterminate': indeterminate,
      'enableLights': enableLights,
      'ledColorAlpha': ledColor?.alpha,
      'ledColorRed': ledColor?.red,
      'ledColorGreen': ledColor?.green,
      'ledColorBlue': ledColor?.blue,
      'ledOnMs': ledOnMs,
      'ledOffMs': ledOffMs,
      'ticker': ticker,
    };
  }
}
