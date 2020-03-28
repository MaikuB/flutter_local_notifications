import 'dart:typed_data';
import 'dart:ui';

import 'bitmap.dart';
import 'enums.dart';
import 'notification_sound.dart';
import 'styles/big_picture_style_information.dart';
import 'styles/big_text_style_information.dart';
import 'styles/inbox_style_information.dart';
import 'styles/media_style_information.dart';
import 'styles/messaging_style_information.dart';
import 'styles/style_information.dart';
import 'styles/default_style_information.dart';

/// Configures the notification on Android.
class AndroidNotificationDetails {
  /// The icon that should be used when displaying the notification.
  ///
  /// When not specified, this will use the default icon that has been configured.
  final String icon;

  /// The channel's id.
  ///
  /// Required for Android 8.0+.
  final String channelId;

  /// The channel's name.
  ///
  /// Required for Android 8.0+.
  final String channelName;

  /// The channel's description.
  ///
  /// Required for Android 8.0+.
  final String channelDescription;

  /// Whether notifications posted to this channel can appear as application icon badges in a Launcher
  final bool channelShowBadge;

  /// The importance of the notification.
  final Importance importance;

  /// The priority of the notification
  final Priority priority;

  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool playSound;

  /// The sound to play for the notification.
  ///
  /// Requires setting [playSound] to true for it to work.
  /// If [playSound] is set to true but this is not specified then the default sound is played.
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final AndroidNotificationSound sound;

  /// Indicates if vibration should be enabled when the notification is displayed.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool enableVibration;

  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool enableLights;

  /// Configures the vibration pattern.
  ///
  /// Requires setting [enableVibration] to true for it to work.
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final Int64List vibrationPattern;

  /// Specifies the information of the rich notification style to apply to the notification.
  final StyleInformation styleInformation;

  /// Specifies the group that this notification belongs to.
  ///
  /// For Android 7.0+ (API level 24)
  final String groupKey;

  /// Specifies if this notification will function as the summary for grouped notifications.
  final bool setAsGroupSummary;

  /// Sets the group alert behavior for this notification.
  ///
  /// Default is AlertAll.
  /// See https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#setGroupAlertBehavior(int) for more details.
  final GroupAlertBehavior groupAlertBehavior;

  /// Specifies if the notification should automatically dismissed upon tapping on it.
  final bool autoCancel;

  /// Specifies if the notification will be "ongoing".
  final bool ongoing;

  /// Sets the color.
  final Color color;

  /// Specifics the large icon to use.
  final AndroidBitmap largeIcon;

  /// Specifies if you would only like the sound, vibrate and ticker to be played if the notification is not already showing.
  final bool onlyAlertOnce;

  /// Specifies if the notification should display the timestamp of when it occurred.
  final bool showWhen;

  /// Specifies if the notification will be used to show progress.
  final bool showProgress;

  /// The maximum progress value.
  final int maxProgress;

  /// The current progress value.
  final int progress;

  /// Specifies if an indeterminate progress bar will be shown.
  final bool indeterminate;

  /// Sets the light color of the notification.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final Color ledColor;

  /// Sets how long the light colour will remain on.
  ///
  /// Not applicable for Android 8.0+
  final int ledOnMs;

  /// Sets how long the light colour will remain off.
  ///
  /// Not applicable for Android 8.0+
  final int ledOffMs;

  /// Set the "ticker" text which is sent to accessibility services.
  final String ticker;

  /// The action to take for managing notification channels.
  ///
  /// Defaults to creating the notification channel using the provided details if it doesn't exist
  final AndroidNotificationChannelAction channelAction;

  /// Defines the notification visibility on the lockscreen
  final NotificationVisibility visibility;

  /// The duration in milliseconds after which the notification will be cancelled if it hasn't already
  final int timeoutAfter;

  /// The notification category.
  ///
  /// Refer to Android notification API documentation at https://developer.android.com/reference/androidx/core/app/NotificationCompat.html#constants_2 for the available categories
  final String category;

  AndroidNotificationDetails(
    this.channelId,
    this.channelName,
    this.channelDescription, {
    this.icon,
    this.importance = Importance.Default,
    this.priority = Priority.Default,
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
    this.onlyAlertOnce,
    this.showWhen = true,
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
    this.ticker,
    this.visibility,
    this.timeoutAfter,
    this.category,
  });

  /// Create a [Map] object that describes the [AndroidNotificationDetails] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
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
      'enableVibration': enableVibration,
      'vibrationPattern': vibrationPattern,
      'groupKey': groupKey,
      'setAsGroupSummary': setAsGroupSummary,
      'groupAlertBehavior': groupAlertBehavior.index,
      'autoCancel': autoCancel,
      'ongoing': ongoing,
      'colorAlpha': color?.alpha,
      'colorRed': color?.red,
      'colorGreen': color?.green,
      'colorBlue': color?.blue,
      'onlyAlertOnce': onlyAlertOnce,
      'showWhen': showWhen,
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
      'visibility': visibility?.index,
      'timeoutAfter': timeoutAfter,
      'category': category
    }
      ..addAll(_convertStyleInformationToMap())
      ..addAll(_convertSoundToMap())
      ..addAll(_convertLargeIconToMap());
  }

  Map<String, dynamic> _convertStyleInformationToMap() {
    if (styleInformation is BigPictureStyleInformation) {
      return <String, dynamic>{
        'style': AndroidNotificationStyle.BigPicture.index,
        'styleInformation': styleInformation.toMap(),
      };
    } else if (styleInformation is BigTextStyleInformation) {
      return <String, dynamic>{
        'style': AndroidNotificationStyle.BigText.index,
        'styleInformation': styleInformation.toMap(),
      };
    } else if (styleInformation is InboxStyleInformation) {
      return <String, dynamic>{
        'style': AndroidNotificationStyle.Inbox.index,
        'styleInformation': styleInformation.toMap(),
      };
    } else if (styleInformation is MessagingStyleInformation) {
      return <String, dynamic>{
        'style': AndroidNotificationStyle.Messaging.index,
        'styleInformation': styleInformation.toMap(),
      };
    } else if (styleInformation is MediaStyleInformation) {
      return <String, dynamic>{
        'style': AndroidNotificationStyle.Media.index,
        'styleInformation': styleInformation.toMap(),
      };
    } else if (styleInformation is DefaultStyleInformation) {
      return <String, dynamic>{
        'style': AndroidNotificationStyle.Default.index,
        'styleInformation': styleInformation.toMap(),
      };
    } else {
      return <String, dynamic>{
        'style': AndroidNotificationStyle.Default.index,
        'styleInformation': DefaultStyleInformation(false, false).toMap(),
      };
    }
  }

  Map<String, dynamic> _convertLargeIconToMap() {
    if (largeIcon is DrawableResourceAndroidBitmap) {
      return <String, dynamic>{
        'largeIcon': largeIcon.bitmap,
        'largeIconBitmapSource': AndroidBitmapSource.Drawable.index,
      };
    } else if (largeIcon is FilePathAndroidBitmap) {
      return <String, dynamic>{
        'largeIcon': largeIcon.bitmap,
        'largeIconBitmapSource': AndroidBitmapSource.FilePath.index,
      };
    } else {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic> _convertSoundToMap() {
    if (sound is RawResourceAndroidNotificationSound) {
      return <String, dynamic>{
        'sound': sound.sound,
        'soundSource': AndroidNotificationSoundSource.RawResource.index,
      };
    } else if (sound is UriAndroidNotificationSound) {
      return <String, dynamic>{
        'sound': sound.sound,
        'soundSource': AndroidNotificationSoundSource.Uri.index,
      };
    } else {
      return <String, dynamic>{};
    }
  }
}
