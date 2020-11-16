/// Specifies the source for a bitmap used by Android notifications.
enum AndroidBitmapSource {
  /// A drawable.
  drawable,

  /// A file path.
  filePath
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
  flutterBitmapAsset
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

/// The available importance levels for Android notifications.
///
/// Required for Android 8.0 or newer.
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
}

/// Priority for notifications on Android 7.1 and lower.
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
