@ConfigurePigeon(PigeonOptions(
  dartPackageName: 'flutter_local_notifications',
  dartOut: 'lib/src/platform_specifics/android.g.dart',
  dartOptions: DartOptions(),
  javaOptions: JavaOptions(),
  javaOut: 'android/src/main/java/com/dexterous/flutterlocalnotifications/models/Messages.g.java',
))
library;

import 'package:pigeon/pigeon.dart';

// ================== Person ==================

/// Specifies the source for icons.
enum AndroidIconSource {
  /// A drawable resource.
  drawableResource,

  /// A file path to a bitmap.
  bitmapFilePath,

  /// A content URI.
  contentUri,

  /// A Flutter asset that is a bitmap.
  flutterBitmapAsset,

  /// A byte array bitmap.
  byteArray,
}

/// Represents an icon on Android.
class AndroidIcon {
  AndroidIcon({
    required this.data,
    required this.source,
  });

  /// The location to the icon;
  Object data;

  /// The subclass source type
  AndroidIconSource source;
}

/// Details of a person e.g. someone who sent a message.
class Person {
  /// Constructs an instance of [Person].
  const Person({
    this.bot = false,
    this.icon,
    this.important = false,
    this.key,
    this.name,
    this.uri,
  });

  /// Whether or not this person represents a machine rather than a human.
  final bool bot;

  /// Icon for this person.
  final AndroidIcon? icon;

  /// Whether or not this is an important person.
  final bool important;

  /// Unique identifier for this person.
  final String? key;

  /// Name of this person.
  final String? name;

  /// Uri for this person.
  final String? uri;
}

// ================== Message ==================

/// Represents a message used in Android messaging style notifications.
class Message {
  /// Constructs an instance of [Message].
  const Message(
    this.text,
    this.timestamp,
    this.person, {
    this.dataMimeType,
    this.dataUri,
  });

  /// The message text
  final String text;

  /// Time at which the message arrived.
  ///
  /// Note that this is eventually converted to milliseconds since epoch as
  /// required by Android.
  final int timestamp;

  /// Person that sent this message.
  ///
  /// When this is set to `null` the `Person` given to
  /// [MessagingStyleInformation.person] i.e. this would indicate that the
  /// message was sent from the user.
  final Person? person;

  /// MIME type for this message context when the [dataUri] is provided.
  final String? dataMimeType;

  /// Uri containing the content.
  ///
  /// The original text will be used if the content or MIME type isn't supported
  final String? dataUri;
}

// ================== Initialization Settings ==================

/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  /// Constructs an instance of [AndroidInitializationSettings].
  const AndroidInitializationSettings(this.defaultIcon);

  /// Specifies the default icon for notifications.
  final String defaultIcon;
}

// ================== Notification Channel Group ==================

/// A group of related Android notification channels.
class AndroidNotificationChannelGroup {
  /// Constructs an instance of [AndroidNotificationChannelGroup].
  const AndroidNotificationChannelGroup(
    this.id,
    this.name, {
    this.description,
  });

  /// The id of this group.
  final String id;

  /// The name of this group.
  final String name;

  /// The description of this group.
  ///
  /// Only applicable to Android 9.0 or newer.
  final String? description;
}

// ================== Notification Channel ==================

/// The available importance levels for Android notifications.
///
/// Required for Android 8.0 or newer.
enum Importance {
  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_UNSPECIFIED`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_UNSPECIFIED()).
  unspecified,

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_NONE](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_NONE()).
  none,

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_MIN`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_MIN()).
  min,

  /// Corresponds to [`NotificationManagerCompat#IMPORTANCE_LOW`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_LOW()).
  low,

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_DEFAULT](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_DEFAULT()).
  defaultImportance,

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_HIGH`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_HIGH()).
  high,

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_MAX](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_MAX()).
  max;
}

/// The available audio attributes usages for an Android service.
enum AudioAttributesUsage {
  /// Corresponds to [`AudioAttributes.USAGE_ALARM`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ALARM).
  alarm,

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANCE_ACCESSIBILITY).
  assistanceAccessibility,

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANCE_NAVIGATION_GUIDANCE).
  assistanceNavigationGuidance,

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANCE_SONIFICATION`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANCE_SONIFICATION).
  assistanceSonification,

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANT`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANT).
  assistant,

  /// Corresponds to [`AudioAttributes.USAGE_GAME`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_GAME).
  game,

  /// Corresponds to [`AudioAttributes.USAGE_MEDIA`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_MEDIA).
  media,

  /// Corresponds to [`AudioAttributes.USAGE_NOTIFICATION`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_NOTIFICATION).
  notification,

  /// Corresponds to [`AudioAttributes.USAGE_NOTIFICATION_EVENT`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_NOTIFICATION_EVENT).
  notificationEvent,

  /// Corresponds to [`AudioAttributes.USAGE_NOTIFICATION_RINGTONE`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_NOTIFICATION_RINGTONE).
  notificationRingtone,

  /// Corresponds to [`AudioAttributes.USAGE_UNKNOWN`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_UNKNOWN).
  unknown,

  /// Corresponds to [`AudioAttributes.USAGE_VOICE_COMMUNICATION`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_VOICE_COMMUNICATION).
  voiceCommunication,

  /// Corresponds to [`AudioAttributes.USAGE_VOICE_COMMUNICATION_SIGNALLING`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_VOICE_COMMUNICATION_SIGNALLING).
  voiceCommunicationSignalling;
}

/// Represents an Android notification sound.
class AndroidNotificationSound {
  AndroidNotificationSound(this.sound);

  /// The location of the sound.
  final String sound;
}

/// A color on Android.
class AndroidColor {
  AndroidColor.fromARGB(this.a, this.r, this.g, this.b);

  final int a;
  final int r;
  final int g;
  final int b;
}

/// Settings for Android notification channels.
class AndroidNotificationChannel {
  /// Constructs an instance of [AndroidNotificationChannel].
  const AndroidNotificationChannel(
    this.id,
    this.name, {
    this.description,
    this.groupId,
    this.importance = Importance.defaultImportance,
    this.playSound = true,
    this.sound,
    this.enableVibration = true,
    this.vibrationPattern,
    this.showBadge = true,
    this.enableLights = false,
    this.ledColor,
    this.audioAttributesUsage = AudioAttributesUsage.notification,
  });

  /// The channel's id.
  final String id;

  /// The channel's name.
  final String name;

  /// The channel's description.
  final String? description;

  /// The id of the group that the channel belongs to.
  final String? groupId;

  /// The importance of the notification.
  final Importance importance;

  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final bool playSound;

  /// The sound to play for the notification.
  ///
  /// Requires setting [playSound] to true for it to work.
  /// If [playSound] is set to true but this is not specified then the default
  /// sound is played. Tied to the specified channel and cannot be changed
  /// after the channel has been created for the first time.
  final AndroidNotificationSound? sound;

  /// Indicates if vibration should be enabled when the notification is
  /// displayed.
  //
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final bool enableVibration;

  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final bool enableLights;

  /// Configures the vibration pattern.
  ///
  /// Requires setting [enableVibration] to true for it to work.
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final Int64List? vibrationPattern;

  /// Specifies the light color of the notification.
  ///
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final AndroidColor? ledColor;

  /// Whether notifications posted to this channel can appear as application
  /// icon badges in a Launcher
  final bool showBadge;

  /// The attribute describing what is the intended use of the audio signal,
  /// such as alarm or ringtone set in [`AudioAttributes.Builder`](https://developer.android.com/reference/android/media/AudioAttributes.Builder#setUsage(int))
  /// https://developer.android.com/reference/android/media/AudioAttributes
  final AudioAttributesUsage audioAttributesUsage;
}

// ================== Notification Styles ==================

sealed class StyleInformation {
  const StyleInformation();
}

/// Used to pass the content for an Android notification displayed using the
/// big picture style.
class BigPictureStyleInformation extends StyleInformation {
  /// Constructs an instance of [BigPictureStyleInformation].
  const BigPictureStyleInformation(
    this.bigPicture, {
    this.contentTitle,
    this.summaryText,
    this.htmlFormatContentTitle = false,
    this.htmlFormatSummaryText = false,
    this.largeIcon,
    this.htmlFormatContent = false,
    this.htmlFormatTitle = false,
    this.hideExpandedLargeIcon = false,
  });

  /// Specifies if formatting should be applied to the content through HTML
  /// markup.
  final bool htmlFormatContent;

  /// Specifies if formatting should be applied to the title through HTML
  /// markup.
  final bool htmlFormatTitle;

  /// Overrides ContentTitle in the big form of the template.
  final String? contentTitle;

  /// Set the first line of text after the detail section in the big form of
  /// the template.
  final String? summaryText;

  /// Specifies if the overridden ContentTitle should have formatting applied
  /// through HTML markup.
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after
  ///  the detail section in the big form of the template.
  final bool htmlFormatSummaryText;

  /// The bitmap that will override the large icon when the big notification is
  ///  shown.
  final AndroidIcon? largeIcon;

  /// The bitmap to be used as the payload for the BigPicture notification.
  final AndroidIcon bigPicture;

  /// Hides the large icon when showing the expanded notification.
  final bool hideExpandedLargeIcon;
}

/// Used to pass the content for an Android notification displayed using the
/// big text style.
class BigTextStyleInformation extends StyleInformation {
  /// Constructs an instance of [BigTextStyleInformation].
  const BigTextStyleInformation(
    this.bigText, {
    this.htmlFormatBigText = false,
    this.contentTitle,
    this.htmlFormatContentTitle = false,
    this.summaryText,
    this.htmlFormatSummaryText = false,
    this.htmlFormatContent = false,
    this.htmlFormatTitle = false,
  });

  /// Specifies if formatting should be applied to the content through HTML
  /// markup.
  final bool htmlFormatContent;

  /// Specifies if formatting should be applied to the title through HTML
  /// markup.
  final bool htmlFormatTitle;

  /// Provide the longer text to be displayed in the big form of the template
  /// in place of the content text.
  final String bigText;

  /// Overrides ContentTitle in the big form of the template.
  final String? contentTitle;

  /// Set the first line of text after the detail section in the big form of
  /// the template.
  final String? summaryText;

  /// Specifies if formatting should be applied to the longer text through
  /// HTML markup.
  final bool htmlFormatBigText;

  /// Specifies if the overridden ContentTitle should have formatting applies
  /// through HTML markup.
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text
  /// after the detail section in the big form of the template.
  final bool htmlFormatSummaryText;
}

/// Used to pass the content for an Android notification displayed using the
/// inbox style.
class InboxStyleInformation extends StyleInformation {
  /// Constructs an instance of [InboxStyleInformation].
  const InboxStyleInformation(
    this.lines, {
    this.htmlFormatLines = false,
    this.contentTitle,
    this.htmlFormatContentTitle = false,
    this.summaryText,
    this.htmlFormatSummaryText = false,
    this.htmlFormatContent = false,
    this.htmlFormatTitle = false,
  });

  /// Specifies if formatting should be applied to the content through HTML
  /// markup.
  final bool htmlFormatContent;

  /// Specifies if formatting should be applied to the title through HTML
  /// markup.
  final bool htmlFormatTitle;

  /// Overrides ContentTitle in the big form of the template.
  final String? contentTitle;

  /// Set the first line of text after the detail section in the big form of
  /// the template.
  final String? summaryText;

  /// The lines that form part of the digest section for inbox-style
  /// notifications.
  final List<String> lines;

  /// Specifies if the lines should have formatting applied through HTML markup.
  final bool htmlFormatLines;

  /// Specifies if the overridden ContentTitle should have formatting applied
  /// through HTML markup.
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after
  /// the detail section in the big form of the template.
  final bool htmlFormatSummaryText;
}

/// Used to pass the content for an Android notification displayed using the
/// messaging style.
class MessagingStyleInformation extends StyleInformation {
  /// Constructs an instance of [MessagingStyleInformation].
  MessagingStyleInformation(
    this.person, {
    this.conversationTitle,
    this.groupConversation,
    this.messages,
    this.htmlFormatContent = false,
    this.htmlFormatTitle = false,
  });

  /// Specifies if formatting should be applied to the content through HTML
  /// markup.
  final bool htmlFormatContent;

  /// Specifies if formatting should be applied to the title through HTML
  /// markup.
  final bool htmlFormatTitle;

  /// The person displayed for any messages that are sent by the user.
  final Person person;

  /// The title to be displayed on this conversation.
  final String? conversationTitle;

  /// Whether this conversation notification represents a group.
  final bool? groupConversation;

  /// Messages to be displayed by this notification
  final List<Message>? messages;
}

// ================== Notification Details ==================

/// Priority for notifications on Android 7.1 and lower.
enum Priority {
  /// Corresponds to [`NotificationCompat.PRIORITY_MIN`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_MIN()).
  min,

  /// Corresponds to [`NotificationCompat.PRIORITY_LOW()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_LOW()).
  low,

  /// Corresponds to [`NotificationCompat.PRIORITY_DEFAULT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_DEFAULT()).
  defaultPriority,

  /// Corresponds to [`NotificationCompat.PRIORITY_HIGH`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_HIGH()).
  high,

  /// Corresponds to [`NotificationCompat.PRIORITY_MAX`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_MAX()).
  max;
}

/// The available alert behaviours for grouped notifications.
enum GroupAlertBehavior {
  /// All notifications in a group with sound or vibration ought to make
  /// sound or vibrate.
  all,

  /// All children notification in a group should be silenced
  summary,

  /// The summary notification in a group should be silenced.
  children
}

/// Mirrors the `RemoteInput` functionality available in NotificationCompat.
///
/// See the official docs at
/// https://developer.android.com/reference/kotlin/androidx/core/app/RemoteInput?hl=en
/// for details.
class AndroidNotificationActionInput {
  /// Constructs a [AndroidNotificationActionInput]. The platform will create
  /// this object using `RemoteInput.Builder`. See the official docs
  /// https://developer.android.com/reference/kotlin/androidx/core/app/RemoteInput.Builder?hl=en
  /// for details.
  const AndroidNotificationActionInput({
    this.choices = const <String>[],
    this.allowFreeFormInput = true,
    this.label,
    this.allowedMimeTypes = const <String>[],
  });

  /// Specifies choices available to the user to satisfy this input.
  final List<String> choices;

  /// Specifies whether the user can provide arbitrary text values.
  final bool allowFreeFormInput;

  /// Set a label to be displayed to the user when collecting this input.
  final String? label;

  /// Specifies whether the user can provide arbitrary values.
  final List<String> allowedMimeTypes;
}

/// Mirrors the `Action` class in AndroidX.
///
/// See the offical docs at
/// https://developer.android.com/reference/kotlin/androidx/core/app/NotificationCompat.Action?hl=en
/// for details.
class AndroidNotificationAction {
  /// Constructs a [AndroidNotificationAction] object. The platform will create
  /// this object using `Action.Builder`. See the offical docs
  /// https://developer.android.com/reference/kotlin/androidx/core/app/NotificationCompat.Action.Builder?hl=en
  /// for details.
  const AndroidNotificationAction(
    this.id,
    this.title, {
    this.titleColor,
    this.icon,
    this.contextual = false,
    this.showsUserInterface = false,
    this.allowGeneratedReplies = false,
    this.inputs = const <AndroidNotificationActionInput>[],
    this.cancelNotification = true,
  });

  /// This ID will be sent back in the action handler defined in
  /// [FlutterLocalNotificationsPlugin].
  final String id;

  /// The title of the action
  final String title;

  /// The color of the title of the action
  final AndroidColor? titleColor;

  /// Icon to show for this action.
  final AndroidIcon? icon;

  /// Sets whether this Action is a contextual action, i.e. whether the action
  /// is dependent on the notification message body. An example of a contextual
  /// action could be an action opening a map application with an address shown
  /// in the notification.
  final bool contextual;

  /// Set whether or not this Action's PendingIntent will open a user interface.
  final bool showsUserInterface;

  /// Set whether the platform should automatically generate possible replies to
  /// add to RemoteInput#getChoices(). If the Action doesn't have a RemoteInput,
  /// this has no effect.
  ///
  /// You need to specify [inputs] for this property to work.
  final bool allowGeneratedReplies;

  /// Add an input to be collected from the user when this action is sent.
  final List<AndroidNotificationActionInput> inputs;

  /// Set whether the notification should be canceled when this action is
  /// selected.
  final bool cancelNotification;
}

/// Defines the notification visibility on the lockscreen.
enum NotificationVisibility {
  /// Show this notification on all lockscreens, but conceal sensitive
  /// or private information on secure lockscreens.
  private,

  /// Show this notification in its entirety on all lockscreens.
  public,

  /// Do not reveal any part of this notification on a secure lockscreen.
  secret,
}

/// The available actions for managing notification channels.
enum AndroidNotificationChannelAction {
  /// Create a channel if it doesn't exist.
  createIfNotExists,

  /// Updates the details of an existing channel. Note that some details can
  /// not be changed once a channel has been created.
  update
}

/// The available categories for Android notifications.
enum AndroidNotificationCategory {
  /// Alarm or timer.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_ALARM`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_ALARM%28%29).
  alarm('alarm'),

  /// Incoming call (voice or video) or similar
  /// synchronous communication request.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_CALL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_CALL%28%29).
  call('call'),

  /// Asynchronous bulk message (email).
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_EMAIL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_EMAIL%28%29).
  email('email'),

  /// Error in background operation or authentication status.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_ERROR`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_ERROR%28%29).
  error('err'),

  /// Calendar event.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_EVENT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_EVENT%28%29).
  event('event'),

  /// Temporarily sharing location.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_LOCATION_SHARING`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_LOCATION_SHARING%28%29).
  locationSharing('location_sharing'),

  /// Incoming direct message like SMS and instant message.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_MESSAGE`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_MESSAGE%28%29).
  message('msg'),

  /// Missed call.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_MISSED_CALL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_MISSED_CALL%28%29).
  missedCall('missed_call'),

  /// Map turn-by-turn navigation.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_NAVIGATION`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_NAVIGATION%28%29).
  navigation('navigation'),

  /// Progress of a long-running background operation.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_PROGRESS`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_PROGRESS%28%29).
  progress('progress'),

  /// Promotion or advertisement.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_PROMO`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_PROMO%28%29).
  promo('promo'),

  /// A specific, timely recommendation for a single thing.
  ///
  /// For example, a news app might want to recommend a
  /// news story it believes the user will want to read next.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_RECOMMENDATION`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_RECOMMENDATION%28%29).
  recommendation('recommendation'),

  /// User-scheduled reminder.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_REMINDER`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_REMINDER%28%29).
  reminder('reminder'),

  /// Indication of running background service.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_SERVICE`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_SERVICE%28%29).
  service('service'),

  /// Social network or sharing update.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_SOCIAL`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_SOCIAL%28%29).
  social('social'),

  /// Ongoing information about device or contextual status.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_STATUS`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_STATUS%28%29).
  status('status'),

  /// Running stopwatch.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_STOPWATCH`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_STOPWATCH%28%29).
  stopwatch('stopwatch'),

  /// System or device status update.
  ///
  /// Reserved for system use.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_SYSTEM`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_SYSTEM%28%29).
  system('sys'),

  /// Media transport control for playback.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_TRANSPORT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_TRANSPORT%28%29).
  transport('transport'),

  /// Tracking a user's workout.
  ///
  /// Corresponds to [`NotificationCompat.CATEGORY_WORKOUT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#CATEGORY_WORKOUT%28%29).
  workout('workout');

  /// Constructs an instance of [AndroidNotificationCategory]
  /// with a given [name] of category.
  const AndroidNotificationCategory(this.name);

  /// The name of category.
  final String name;
}

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
    this.silent = false,
    this.color,
    this.largeIcon,
    this.onlyAlertOnce = false,
    this.showWhen = true,
    this.when,
    this.usesChronometer = false,
    this.chronometerCountDown = false,
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
    this.actions,
    this.colorized = false,
    this.number,
    this.audioAttributesUsage = AudioAttributesUsage.notification,
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

  /// Specifies if the notification will be "silent".
  final bool silent;

  /// Specifies the color.
  final AndroidColor? color;

  /// Specifics the large icon to use.
  final AndroidIcon? largeIcon;

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

  /// Sets the chronometer to count down instead of counting up.
  ///
  /// This property is only applicable to Android 7.0 and newer versions.
  final bool chronometerCountDown;

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
  final AndroidColor? ledColor;

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
  final AndroidNotificationCategory? category;

  /// Specifies whether the notification should launch a full-screen intent as
  /// soon as it triggers.
  ///
  /// Note: The system UI may choose to display a heads-up notification,
  /// instead of launching your full-screen intent. This can occur while the
  /// user is using the device or due the full-screen intent not being granted.
  /// When the full-screen intent occurs, the plugin will act as though
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

  /// Specify a list of actions associated with this notifications.
  ///
  /// Users will be able tap on the actions without actually launching the App.
  /// Note that tapping a action will spawn a separate isolate that runs
  /// **independently** from the main app.
  final List<AndroidNotificationAction>? actions;

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

  /// Specify coloring background should be enabled, if false, color will be
  /// applied to app icon.
  ///
  /// For most styles, the coloring will only be applied if the notification is
  /// or a foreground service notification.
  final bool colorized;

  /// Set custom notification count.
  ///
  /// Numbers are only displayed if the launcher application supports the
  /// display of badges and numbers. If not supported, this value is ignored.
  /// See https://developer.android.com/training/notify-user/badges#set_custom_notification_count
  final int? number;

  /// The attribute describing what is the intended use of the audio signal,
  /// such as alarm or ringtone set in [`AudioAttributes.Builder`](https://developer.android.com/reference/android/media/AudioAttributes.Builder#setUsage(int))
  /// https://developer.android.com/reference/android/media/AudioAttributes
  final AudioAttributesUsage audioAttributesUsage;
}

// ================== Notification Responses ==================

/// The possible notification response types
enum AndroidNotificationResponseType {
  /// Indicates that a user has selected a notification.
  selectedNotification,

  /// Indicates the a user has selected a notification action.
  selectedNotificationAction,
}

/// Details of a Notification Action that was triggered.
class AndroidNotificationResponse {
  /// Constructs an instance of [AndroidNotificationResponse]
  const AndroidNotificationResponse({
    required this.notificationResponseType,
    this.id,
    this.actionId,
    this.input,
    this.payload,
    this.data = const <String, dynamic>{},
  });

  /// The notification's id.
  ///
  /// This is nullable as support for this only supported for notifications
  /// created using version 10 or newer of this plugin.
  final int? id;

  /// The id of the action that was triggered.
  final String? actionId;

  /// The value of the input field if the notification action had an input
  /// field.
  ///
  /// On Windows, this is always null. Instead, [data] holds the values of
  /// each input with the input's ID as the key.
  final String? input;

  /// The notification's payload.
  final String? payload;

  /// Any other data returned by the platform.
  ///
  /// Returned only on Windows.
  final Map<String, dynamic> data;

  /// The notification response type.
  final AndroidNotificationResponseType notificationResponseType;
}

/// Contains details on the notification that launched the application.
class AndroidNotificationAppLaunchDetails {
  /// Constructs an instance of [AndroidNotificationAppLaunchDetails].
  const AndroidNotificationAppLaunchDetails(
    this.didNotificationLaunchApp, {
    this.notificationResponse,
  });

  /// Indicates if the app was launched via notification.
  final bool didNotificationLaunchApp;

  /// Contains details of the notification that launched the app.
  final AndroidNotificationResponse? notificationResponse;
}

// ================== Notification Plugin ==================

/// Details of a pending notification that has not been delivered.
class AndroidPendingNotificationRequest {
  /// Constructs an instance of [AndroidPendingNotificationRequest].
  const AndroidPendingNotificationRequest(this.id, this.title, this.body, this.payload);

  /// The notification's id.
  final int id;

  /// The notification's title.
  final String? title;

  /// The notification's body.
  final String? body;

  /// The notification's payload.
  final String? payload;
}

/// Details of an active notification.
class AndroidActiveNotification {
  /// Constructs an instance of [AndroidActiveNotification].
  const AndroidActiveNotification({
    this.id,
    this.groupKey,
    this.channelId,
    this.title,
    this.body,
    this.payload,
    this.tag,
    this.bigText,
  });

  /// The notification's id.
  ///
  /// This will be null if the notification was outsided of the plugin's
  /// control e.g. on iOS and via Firebase Cloud Messaging.
  final int? id;

  /// The notification's channel id.
  ///
  /// Returned only on Android 8.0 or newer.
  final String? channelId;

  /// The notification's group.
  ///
  /// Returned only on Android.
  final String? groupKey;

  /// The notification's title.
  final String? title;

  /// The notification's body.
  final String? body;

  /// The notification's payload.
  ///
  /// Returned only on iOS and macOS.
  final String? payload;

  /// The notification's tag.
  ///
  /// Returned only on Android.
  final String? tag;

  /// The notification's longer text displayed using big text style.
  ///
  /// Returned only on Android.
  final String? bigText;
}

class AndroidNotificationData {
  const AndroidNotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.details,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
  final AndroidNotificationDetails? details;
}

/// The available start types for an Android service.
enum AndroidServiceStartType {
  /// Corresponds to [`Service.START_STICKY_COMPATIBILITY`](https://developer.android.com/reference/android/app/Service#START_STICKY_COMPATIBILITY).
  startStickyCompatibility,

  /// Corresponds to [`Service.START_STICKY`](https://developer.android.com/reference/android/app/Service#START_STICKY).
  startSticky,

  /// Corresponds to [`Service.START_NOT_STICKY`](https://developer.android.com/reference/android/app/Service#START_NOT_STICKY).
  startNotSticky,

  /// Corresponds to [`Service.START_REDELIVER_INTENT`](https://developer.android.com/reference/android/app/Service#START_REDELIVER_INTENT).
  startRedeliverIntent
}

enum AndroidServiceForegroundType {
  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MANIFEST).
  foregroundServiceTypeManifest,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_NONE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_NONE).
  foregroundServiceTypeNone,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_DATA_SYNC).
  foregroundServiceTypeDataSync,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK).
  foregroundServiceTypeMediaPlayback,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_PHONE_CALL).
  foregroundServiceTypePhoneCall,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_LOCATION).
  foregroundServiceTypeLocation,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE).
  foregroundServiceTypeConnectedDevice,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION).
  foregroundServiceTypeMediaProjection,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CAMERA).
  foregroundServiceTypeCamera,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MICROPHONE).
  foregroundServiceTypeMicrophone,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_HEALTH).
  foregroundServiceTypeHealth,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_REMOTE_MESSAGING`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_REMOTE_MESSAGING).

  foregroundServiceTypeRemoteMessaging,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED).
  foregroundServiceTypeSystemExempted,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SHORT_SERVICE).
  foregroundServiceTypeShortService,

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SPECIAL_USE).
  foregroundServiceTypeSpecialUse;
}

class AndroidDateTime {
  const AndroidDateTime({
    required this.scheduledDateTime,
    required this.scheduledDateTimeIso8601,
    required this.timezoneName,
  });

  final String timezoneName;
  final String scheduledDateTime;
  final String scheduledDateTimeIso8601;
}

/// The components of a date and time representations.
enum AndroidDateTimeComponents {
  /// The time.
  time,

  /// The day of the week and time.
  dayOfWeekAndTime,

  /// The day of the month and time.
  dayOfMonthAndTime,

  /// The date and time.
  dateAndTime,
}

/// The available intervals for periodically showing notifications.
enum AndroidRepeatInterval {
  /// An interval for every minute.
  everyMinute,

  /// Hourly interval.
  hourly,

  /// Daily interval.
  daily,

  /// Weekly interval.
  weekly
}

/// Used to specify how notifications should be scheduled on Android.
///
/// This leverages the use of alarms to schedule notifications as described
/// at https://developer.android.com/training/scheduling/alarms
enum AndroidScheduleMode {
  /// Used to specify that the notification should be scheduled to be shown at
  /// the exact time specified AND will execute whilst device is in
  /// low-power idle mode. Requires SCHEDULE_EXACT_ALARM permission.
  alarmClock,

  /// Used to specify that the notification should be scheduled to be shown at
  /// the exact time specified but may not execute whilst device is in
  /// low-power idle mode.
  exact,

  /// Used to specify that the notification should be scheduled to be shown at
  /// the exact time specified and will execute whilst device is in
  /// low-power idle mode.
  exactAllowWhileIdle,

  /// Used to specify that the notification should be scheduled to be shown at
  /// at roughly specified time but may not execute whilst device is in
  /// low-power idle mode.
  inexact,

  /// Used to specify that the notification should be scheduled to be shown at
  /// at roughly specified time and will execute whilst device is in
  /// low-power idle mode.
  inexactAllowWhileIdle,
}

/// The Android implementation of the plugin.
@HostApi()
abstract class AndroidNotificationsPlugin {
  // ================== Common APIs ==================

  void cancel(int id);
  void cancelAll();

  AndroidNotificationAppLaunchDetails getNotificationAppLaunchDetails();
  AndroidPendingNotificationRequest pendingNotificationRequests();
  List<AndroidActiveNotification> getActiveNotifications();

  // ================== Android-Specific ==================
  void stopForegroundService();

  bool initialize(AndroidInitializationSettings settings);
  bool? requestExactAlarmsPermission();
  bool? requestFullScreenIntentPermission();
  bool? requestNotificationsPermission();
  bool? areNotificationsEnabled();
  bool? canScheduleExactNotifications();

  List<AndroidNotificationChannel>? getNotificationChannels();

  void createNotificationChannelGroup(AndroidNotificationChannelGroup notificationChannelGroup);
  void deleteNotificationChannelGroup(String groupId);
  void createNotificationChannel(AndroidNotificationChannel notificationChannel);
  void deleteNotificationChannel(String channelId);

  void show(AndroidNotificationData data);

  void periodicallyShow({
    required AndroidNotificationData data,
    required AndroidRepeatInterval repeatInterval,
    required int calledAtMillisecondsSinceEpoch,
    required AndroidScheduleMode scheduleMode,
  });

  void periodicallyShowWithDuration({
    required AndroidNotificationData data,
    required int calledAtMillisecondsSinceEpoch,
    required int repeatIntervalMilliseconds,
    required AndroidScheduleMode scheduleMode,
  });

  void zonedSchedule({
    required AndroidNotificationData data,
    required AndroidDateTime scheduledDate,
    AndroidDateTimeComponents? matchDateTimeComponents,
  });

  void startForegroundService({
    required AndroidNotificationData data,
    AndroidServiceStartType startType = AndroidServiceStartType.startSticky,
    List<AndroidServiceForegroundType>? foregroundServiceTypes,
  });

  MessagingStyleInformation? getActiveNotificationMessagingStyle({
    required int id,
    String? tag,
  });
}
