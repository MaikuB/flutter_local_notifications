import 'package:flutter/cupertino.dart';

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
@immutable
class AndroidServiceForegroundType {
  /// Constructs an instance of [AndroidServiceForegroundType].
  const AndroidServiceForegroundType(this.value);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MANIFEST).
  static const AndroidServiceForegroundType foregroundServiceTypeManifest =
      AndroidServiceForegroundType(-1);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_NONE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_NONE).
  static const AndroidServiceForegroundType foregroundServiceTypeNone =
      AndroidServiceForegroundType(0);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_DATA_SYNC).
  static const AndroidServiceForegroundType foregroundServiceTypeDataSync =
      AndroidServiceForegroundType(1);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK).
  static const AndroidServiceForegroundType foregroundServiceTypeMediaPlayback =
      AndroidServiceForegroundType(2);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_PHONE_CALL).
  static const AndroidServiceForegroundType foregroundServiceTypePhoneCall =
      AndroidServiceForegroundType(4);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_LOCATION).
  static const AndroidServiceForegroundType foregroundServiceTypeLocation =
      AndroidServiceForegroundType(8);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE).
  static const AndroidServiceForegroundType
      foregroundServiceTypeConnectedDevice = AndroidServiceForegroundType(16);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION).
  static const AndroidServiceForegroundType
      foregroundServiceTypeMediaProjection = AndroidServiceForegroundType(32);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CAMERA).
  static const AndroidServiceForegroundType foregroundServiceTypeCamera =
      AndroidServiceForegroundType(64);

  /// Corresponds to [`ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE`](https://developer.android.com/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MICROPHONE).
  static const AndroidServiceForegroundType foregroundServiceTypeMicrophone =
      AndroidServiceForegroundType(128);

  /// The integer representation.
  final int value;

  @override
  int get hashCode => value;

  @override
  bool operator ==(Object other) =>
      other is AndroidServiceForegroundType && other.value == value;
}

/// The available start types for an Android service.
@immutable
class AndroidServiceStartType {
  /// Constructs an instance of [AndroidServiceStartType].
  const AndroidServiceStartType(this.value);

  /// Corresponds to [`Service.START_STICKY_COMPATIBILITY`](https://developer.android.com/reference/android/app/Service#START_STICKY_COMPATIBILITY).
  static const AndroidServiceStartType startStickyCompatibility =
      AndroidServiceStartType(0);

  /// Corresponds to [`Service.START_STICKY`](https://developer.android.com/reference/android/app/Service#START_STICKY).
  static const AndroidServiceStartType startSticky = AndroidServiceStartType(1);

  /// Corresponds to [`Service.START_NOT_STICKY`](https://developer.android.com/reference/android/app/Service#START_NOT_STICKY).
  static const AndroidServiceStartType startNotSticky =
      AndroidServiceStartType(2);

  /// Corresponds to [`Service.START_REDELIVER_INTENT`](https://developer.android.com/reference/android/app/Service#START_REDELIVER_INTENT).
  static const AndroidServiceStartType startRedeliverIntent =
      AndroidServiceStartType(3);

  /// The integer representation.
  final int value;

  @override
  int get hashCode => value;

  @override
  bool operator ==(Object other) =>
      other is AndroidServiceStartType && other.value == value;
}

/// The available importance levels for Android notifications.
///
/// Required for Android 8.0 or newer.
@immutable
class Importance {
  /// Constructs an instance of [Importance].
  const Importance(this.value);

  /// Unspecified
  static const Importance unspecified = Importance(-1000);

  /// None.
  static const Importance none = Importance(0);

  /// Min.
  static const Importance min = Importance(1);

  /// Low.
  static const Importance low = Importance(2);

  /// Default.
  static const Importance defaultImportance = Importance(3);

  /// High.
  static const Importance high = Importance(4);

  /// Max.
  static const Importance max = Importance(5);

  /// All the possible values for the [Importance] enumeration.
  static List<Importance> get values =>
      <Importance>[unspecified, none, min, low, defaultImportance, high, max];

  /// The integer representation.
  final int value;

  @override
  int get hashCode => value;

  @override
  bool operator ==(Object other) => other is Importance && other.value == value;
}

/// Priority for notifications on Android 7.1 and lower.
@immutable
class Priority {
  /// Constructs an instance of [Priority].
  const Priority(this.value);

  /// Min.
  static const Priority min = Priority(-2);

  /// Low.
  static const Priority low = Priority(-1);

  /// Default.
  static const Priority defaultPriority = Priority(0);

  /// High.
  static const Priority high = Priority(1);

  /// Max.
  static const Priority max = Priority(2);

  /// All the possible values for the [Priority] enumeration.
  static List<Priority> get values =>
      <Priority>[min, low, defaultPriority, high, max];

  /// The integer representation.
  final int value;

  @override
  int get hashCode => value;

  @override
  bool operator ==(Object other) => other is Priority && other.value == value;
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
