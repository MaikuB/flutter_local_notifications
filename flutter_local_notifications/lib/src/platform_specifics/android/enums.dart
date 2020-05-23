/// Specifies the source for a bitmap used by Android notifications.
enum AndroidBitmapSource { Drawable, FilePath }

/// Specifies the source for icons.
enum AndroidIconSource {
  DrawableResource,
  BitmapFilePath,
  ContentUri,
  FlutterBitmapAsset
}

/// The available notification styles on Android.
enum AndroidNotificationStyle {
  Standard,
  BigPicture,
  BigText,
  Inbox,
  Messaging,
  Media
}

enum AndroidNotificationSoundSource {
  RawResource,
  Uri,
}

/// The available actions for managing notification channels.
enum AndroidNotificationChannelAction {
  /// Create a channel if it doesn't exist.
  CreateIfNotExists,

  /// Updates the details of an existing channel. Note that some details can
  /// not be changed once a channel has been created.
  Update
}

/// The available importance levels for Android notifications.
///
/// Required for Android 8.0+
class Importance {
  const Importance(this.value);

  static const Importance Unspecified = Importance(-1000);
  static const Importance None = Importance(0);
  static const Importance Min = Importance(1);
  static const Importance Low = Importance(2);
  static const Importance Default = Importance(3);
  static const Importance High = Importance(4);
  static const Importance Max = Importance(5);

  /// All the possible values for the [Importance] enumeration.
  static List<Importance> get values =>
      <Importance>[Unspecified, None, Min, Low, Default, High, Max];

  final int value;
}

/// Priority for notifications on Android 7.1 and lower.
class Priority {
  const Priority(this.value);

  static const Priority Min = Priority(-2);
  static const Priority Low = Priority(-1);
  static const Priority Default = Priority(0);
  static const Priority High = Priority(1);
  static const Priority Max = Priority(2);

  /// All the possible values for the [Priority] enumeration.
  static List<Priority> get values => <Priority>[Min, Low, Default, High, Max];

  final int value;
}

/// The available alert behaviours for grouped notifications.
enum GroupAlertBehavior { All, Summary, Children }

/// Defines the notification visibility on the lockscreen.
enum NotificationVisibility {
  /// Show this notification on all lockscreens, but conceal sensitive
  /// or private information on secure lockscreens.
  Private,

  /// Show this notification in its entirety on all lockscreens.
  Public,

  /// Do not reveal any part of this notification on a secure lockscreen.
  Secret,
}
