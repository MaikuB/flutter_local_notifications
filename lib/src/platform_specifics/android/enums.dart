/// Specifies the source for a bitmap used by Android notifications.
enum BitmapSource { Drawable, FilePath }

/// Specifies the source for icons
enum IconSource { Drawable, FilePath, ContentUri }

/// The available notification styles on Android
enum AndroidNotificationStyle { Default, BigPicture, BigText, Inbox, Messaging }

/// The available actions for managing notification channels.
/// [CreateIfNotExists]: will create a channel if it doesn't exist
/// [Update]: will update the details of an existing channel. Note that some details can not be changed once a channel has been created
enum AndroidNotificationChannelAction { CreateIfNotExists, Update }

/// The available importance levels for Android notifications.
/// Required for Android 8.0+
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

/// Priority for notifications on Android 7.1 and lower
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

/// The precision of scheduled notifications
enum ScheduledNotificationPrecision { Exact, ExactAndAllowWhileIdle, Inexact, InexactAndAllowWhileIdle }