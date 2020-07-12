/// Specifies the source for a bitmap used by Android notifications.
enum AndroidBitmapSource { drawable, filePath }

/// Specifies the source for icons.
enum AndroidIconSource {
  drawableResource,
  bitmapFilePath,
  contentUri,
  flutterBitmapAsset
}

/// The available notification styles on Android.
enum AndroidNotificationStyle {
  defaultStyle,
  bigPicture,
  bigText,
  inbox,
  messaging,
  media
}

enum AndroidNotificationSoundSource {
  rawResource,
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
  const Importance(this.value);

  static const Importance unspecified = Importance(-1000);
  static const Importance none = Importance(0);
  static const Importance min = Importance(1);
  static const Importance low = Importance(2);
  static const Importance defaultImportance = Importance(3);
  static const Importance high = Importance(4);
  static const Importance max = Importance(5);

  /// All the possible values for the [Importance] enumeration.
  static List<Importance> get values =>
      <Importance>[unspecified, none, min, low, defaultImportance, high, max];

  final int value;
}

/// Priority for notifications on Android 7.1 and lower.
class Priority {
  const Priority(this.value);

  static const Priority min = Priority(-2);
  static const Priority low = Priority(-1);
  static const Priority defaultPriority = Priority(0);
  static const Priority high = Priority(1);
  static const Priority max = Priority(2);

  /// All the possible values for the [Priority] enumeration.
  static List<Priority> get values =>
      <Priority>[min, low, defaultPriority, high, max];

  final int value;
}

/// The available alert behaviours for grouped notifications.
enum GroupAlertBehavior { all, summary, children }

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
