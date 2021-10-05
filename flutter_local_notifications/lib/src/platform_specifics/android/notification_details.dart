import 'dart:typed_data';
import 'dart:ui';

import 'bitmap.dart';
import 'enums.dart';
import 'notification_sound.dart';
import 'styles/style_information.dart';

/// Contains notification details specific to Android.
class AndroidNotificationDetails {
  /// Constructs an instance of [AndroidNotificationDetails].
  const AndroidNotificationDetails(
    this.channelId,
    this.channelName, {
    this.channelDescription,
    this.icon,
    this.importance = Importance.defaultImportance,
    this.priority = Priority.defaultPriority,
    this.styleInformation,
    this.playSound = true,
    this.sound,
    this.enableVibration = true,
    this.vibrationPattern,
    this.groupKey,
    this.setAsGroupSummary = false,
    this.groupAlertBehavior = GroupAlertBehavior.all,
    this.autoCancel = true,
    this.ongoing = false,
    this.color,
    this.largeIcon,
    this.onlyAlertOnce = false,
    this.showWhen = true,
    this.when,
    this.usesChronometer = false,
    this.channelShowBadge = true,
    this.showProgress = false,
    this.maxProgress = 0,
    this.progress = 0,
    this.indeterminate = false,
    this.channelAction = AndroidNotificationChannelAction.createIfNotExists,
    this.enableLights = false,
    this.ledColor,
    this.ledOnMs,
    this.ledOffMs,
    this.ticker,
    this.visibility,
    this.timeoutAfter,
    this.category,
    this.fullScreenIntent = false,
    this.shortcutId,
    this.additionalFlags,
    this.subText,
    this.tag,
  });

  /// The icon that should be used when displaying the notification.
  ///
  /// When this is set to `null`, the default icon given to
  /// [AndroidInitializationSettings.defaultIcon] will be used.
  final String? icon;

  /// The channel's id.
  ///
  /// Required for Android 8.0 or newer.
  final String channelId;

  /// The channel's name.
  ///
  /// Required for Android 8.0 or newer.
  final String channelName;

  /// The channel's description.
  ///
  /// This property is only applicable to Android versions 8.0 or newer.
  final String? channelDescription;

  /// Whether notifications posted to this channel can appear as application
  /// icon badges in a Launcher
  final bool channelShowBadge;

  /// The importance of the notification.
  final Importance importance;

  /// The priority of the notification
  final Priority priority;

  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  final bool playSound;

  /// The sound to play for the notification.
  ///
  /// Requires setting [playSound] to true for it to work.
  /// If [playSound] is set to true but this is not specified then the default
  /// sound is played.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  final AndroidNotificationSound? sound;

  /// Indicates if vibration should be enabled when the notification is
  /// displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  final bool enableVibration;

  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  final bool enableLights;

  /// Configures the vibration pattern.
  ///
  /// Requires setting [enableVibration] to true for it to work.
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  final Int64List? vibrationPattern;

  /// Specifies the information of the rich notification style to apply to the
  /// notification.
  final StyleInformation? styleInformation;

  /// Specifies the group that this notification belongs to.
  ///
  /// For Android 7.0 or newer.
  final String? groupKey;

  /// Specifies if this notification will function as the summary for grouped
  /// notifications.
  final bool setAsGroupSummary;

  /// Specifies the group alert behavior for this notification.
  ///
  /// Default is AlertAll.
  /// See https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#setGroupAlertBehavior(int) for more details.
  final GroupAlertBehavior groupAlertBehavior;

  /// Specifies if the notification should automatically dismissed upon tapping
  /// on it.
  final bool autoCancel;

  /// Specifies if the notification will be "ongoing".
  final bool ongoing;

  /// Specifies the color.
  final Color? color;

  /// Specifics the large icon to use.
  final AndroidBitmap<Object>? largeIcon;

  /// Specifies if you would only like the sound, vibrate and ticker to be
  /// played if the notification is not already showing.
  final bool onlyAlertOnce;

  /// Specifies if the notification should display the timestamp of when it
  ///  occurred.
  ///
  /// To control the actual timestamp of the notification, use [when].
  final bool showWhen;

  /// Specifies the timestamp of the notification.
  ///
  /// To control whether the timestamp is shown in the notification, use
  /// [showWhen].
  ///
  /// The timestamp is expressed as the number of milliseconds since the
  /// "Unix epoch" 1970-01-01T00:00:00Z (UTC). If it's not specified but a
  /// timestamp should be shown (i.e. [showWhen] is set to `true`),
  /// then Android will default to showing when the notification occurred.
  final int? when;

  /// Show [when] as a stopwatch.
  ///
  /// Instead of presenting [when] as a timestamp, the notification will show an
  /// automatically updating display of the minutes and seconds since [when].
  /// Useful when showing an elapsed time (like an ongoing phone call).
  final bool usesChronometer;

  /// Specifies if the notification will be used to show progress.
  final bool showProgress;

  /// The maximum progress value.
  final int maxProgress;

  /// The current progress value.
  final int progress;

  /// Specifies if an indeterminate progress bar will be shown.
  final bool indeterminate;

  /// Specifies the light color of the notification.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  final Color? ledColor;

  /// Specifies how long the light colour will remain on.
  ///
  /// This property is only applicable to Android versions older than 8.0.
  final int? ledOnMs;

  /// Specifies how long the light colour will remain off.
  ///
  /// This property is only applicable to Android versions older than 8.0.
  final int? ledOffMs;

  /// Specifies the "ticker" text which is sent to accessibility services.
  final String? ticker;

  /// The action to take for managing notification channels.
  ///
  /// Defaults to creating the notification channel using the provided details
  /// if it doesn't exist
  final AndroidNotificationChannelAction channelAction;

  /// Defines the notification visibility on the lockscreen.
  final NotificationVisibility? visibility;

  /// The duration in milliseconds after which the notification will be
  /// cancelled if it hasn't already.
  final int? timeoutAfter;

  /// The notification category.
  ///
  /// Refer to Android notification API documentation at https://developer.android.com/reference/androidx/core/app/NotificationCompat.html#constants_2 for the available categories
  final String? category;

  /// Specifies whether the notification should launch a full-screen intent as
  /// soon as it triggers.
  ///
  /// Note: The system UI may choose to display a heads-up notification,
  /// instead of launching your full-screen intent, while the user is using the
  /// device. When the full-screen intent occurs, the plugin will act as though
  /// the user has tapped on a notification so handle it the same way
  /// (e.g. via `onSelectNotification` callback) to display the appropriate
  /// page for your application.
  final bool fullScreenIntent;

  /// Specifies the id of a published, long-lived sharing that the notification
  /// will be linked to.
  ///
  /// From Android 11, this affects if a messaging-style notification appears
  /// in the conversation space.
  final String? shortcutId;

  /// Specifies the additional flags.
  ///
  /// These flags will get added to the native Android notification's flags field: https://developer.android.com/reference/android/app/Notification#flags
  /// For a list of a values, refer to the documented constants prefixed with "FLAG_" (without the quotes) at https://developer.android.com/reference/android/app/Notification.html#constants_1.
  /// For example, use a value of 4 to allow the audio to repeat as documented at https://developer.android.com/reference/android/app/Notification.html#FLAG_INSISTEN
  final Int32List? additionalFlags;

  /// Provides some additional information that is displayed in the
  /// notification.
  ///
  /// No guarantees are given where exactly it is displayed. This information
  /// should only be provided if it provides an essential  benefit to the
  /// understanding of the notification. The more text you provide the less
  /// readable it becomes. For example, an email client should only provide the
  /// account name here if more than one email account has been added.
  ///
  /// As of Android 7.0 this information is displayed in the notification header
  /// area. On Android versions before 7.0 this will be shown in the third line
  /// of text in the platform notification template. You should not be using
  /// setProgress(int, int, boolean) at the same time on those versions; they
  /// occupy the same place.
  final String? subText;

  /// The notification tag.
  ///
  /// Showing notification with the same (tag, id) pair as a currently visible
  /// notification will replace the old notification with the new one, provided
  /// the old notification was one that was not one that was scheduled. In other
  /// words, the (tag, id) pair is only applicable for notifications that were
  /// requested to be shown immediately. This is because the Android
  /// AlarmManager APIs used for scheduling notifications only allow for using
  /// the id to uniquely identify alarms.
  final String? tag;
}
