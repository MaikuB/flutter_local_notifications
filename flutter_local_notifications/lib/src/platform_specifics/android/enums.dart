/// Specifies the source for a bitmap used by Android notifications.
enum AndroidBitmapSource {
  /// A drawable.
  drawable,

  /// A file path.
  filePath,

  /// A byte array bitmap.
  byteArray,
}

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

/// The available notification styles on Android.
enum AndroidNotificationStyle {
  /// The default style.
  defaultStyle,

  /// The big picture style.
  bigPicture,

  /// The big text style.
  bigText,

  /// The inbox style.
  inbox,

  /// The messaging style.
  messaging,

  /// The media style.
  media
}

/// Specifies the source for a sound used by Android notifications.
enum AndroidNotificationSoundSource {
  /// A raw resource.
  rawResource,

  /// An URI to a file on the Android device.
  uri,
}

/// The available actions for managing notification channels.
enum AndroidNotificationChannelAction {
  /// Create a channel if it doesn't exist.
  createIfNotExists,

  /// Updates the details of an existing channel. Note that some details can
  /// not be changed once a channel has been created.
  update
}

/// The available foreground types for an Android service.

enum AndroidServiceForegroundType {
  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MANIFEST).
  foregroundServiceTypeManifest(-1),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_NONE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_NONE).
  foregroundServiceTypeNone(0),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_DATA_SYNC).
  foregroundServiceTypeDataSync(1),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK).
  foregroundServiceTypeMediaPlayback(2),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_PHONE_CALL).
  foregroundServiceTypePhoneCall(4),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_LOCATION).
  foregroundServiceTypeLocation(8),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE).
  foregroundServiceTypeConnectedDevice(16),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION).
  foregroundServiceTypeMediaProjection(32),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CAMERA).
  foregroundServiceTypeCamera(64),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MICROPHONE).
  foregroundServiceTypeMicrophone(128),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_HEALTH).
  foregroundServiceTypeHealth(256),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_REMOTE_MESSAGING`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_REMOTE_MESSAGING).

  foregroundServiceTypeRemoteMessaging(512),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED).
  foregroundServiceTypeSystemExempted(1024),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SHORT_SERVICE).
  foregroundServiceTypeShortService(2048),

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SPECIAL_USE).
  foregroundServiceTypeSpecialUse(1073741824);

  /// Constructs an instance of [AndroidServiceForegroundType].
  const AndroidServiceForegroundType(this.value);

  /// The integer representation of [AndroidServiceForegroundType].
  final int value;
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

/// The available importance levels for Android notifications.
///
/// Required for Android 8.0 or newer.
enum Importance {
  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_UNSPECIFIED`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_UNSPECIFIED()).
  unspecified(-1000),

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_NONE](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_NONE()).
  none(0),

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_MIN`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_MIN()).
  min(1),

  /// Corresponds to [`NotificationManagerCompat#IMPORTANCE_LOW`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_LOW()).
  low(2),

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_DEFAULT](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_DEFAULT()).
  defaultImportance(3),

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_HIGH`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_HIGH()).
  high(4),

  /// Corresponds to [`NotificationManagerCompat.IMPORTANCE_MAX](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#IMPORTANCE_MAX()).
  max(5);

  /// Constructs an instance of [Importance].
  const Importance(this.value);

  /// The integer representation of [Importance].
  final int value;
}

/// Priority for notifications on Android 7.1 and lower.
enum Priority {
  /// Corresponds to [`NotificationCompat.PRIORITY_MIN`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_MIN()).
  min(-2),

  /// Corresponds to [`NotificationCompat.PRIORITY_LOW()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_LOW()).
  low(-1),

  /// Corresponds to [`NotificationCompat.PRIORITY_DEFAULT`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_DEFAULT()).
  defaultPriority(0),

  /// Corresponds to [`NotificationCompat.PRIORITY_HIGH`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_HIGH()).
  high(1),

  /// Corresponds to [`NotificationCompat.PRIORITY_MAX`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#PRIORITY_MAX()).
  max(2);

  /// Constructs an instance of [Priority].
  const Priority(this.value);

  /// The integer representation of [Priority].
  final int value;
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

/// The available audio attributes usages for an Android service.
enum AudioAttributesUsage {
  /// Corresponds to [`AudioAttributes.USAGE_ALARM`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ALARM).
  alarm(4),

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANCE_ACCESSIBILITY).
  assistanceAccessibility(11),

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANCE_NAVIGATION_GUIDANCE).
  assistanceNavigationGuidance(12),

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANCE_SONIFICATION`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANCE_SONIFICATION).
  assistanceSonification(13),

  /// Corresponds to [`AudioAttributes.USAGE_ASSISTANT`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_ASSISTANT).
  assistant(16),

  /// Corresponds to [`AudioAttributes.USAGE_GAME`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_GAME).
  game(14),

  /// Corresponds to [`AudioAttributes.USAGE_MEDIA`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_MEDIA).
  media(1),

  /// Corresponds to [`AudioAttributes.USAGE_NOTIFICATION`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_NOTIFICATION).
  notification(5),

  /// Corresponds to [`AudioAttributes.USAGE_NOTIFICATION_EVENT`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_NOTIFICATION_EVENT).
  notificationEvent(10),

  /// Corresponds to [`AudioAttributes.USAGE_NOTIFICATION_RINGTONE`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_NOTIFICATION_RINGTONE).
  notificationRingtone(6),

  /// Corresponds to [`AudioAttributes.USAGE_UNKNOWN`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_UNKNOWN).
  unknown(0),

  /// Corresponds to [`AudioAttributes.USAGE_VOICE_COMMUNICATION`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_VOICE_COMMUNICATION).
  voiceCommunication(2),

  /// Corresponds to [`AudioAttributes.USAGE_VOICE_COMMUNICATION_SIGNALLING`](https://developer.android.com/reference/android/media/AudioAttributes#USAGE_VOICE_COMMUNICATION_SIGNALLING).
  voiceCommunicationSignalling(3);

  /// Constructs an instance of [AudioAttributesUsage].
  const AudioAttributesUsage(this.value);

  /// The integer representation of [AudioAttributesUsage].
  final int value;
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
