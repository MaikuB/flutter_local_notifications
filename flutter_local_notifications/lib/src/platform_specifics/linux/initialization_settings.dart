import 'icon.dart';

/// Notify user when notifications are created and destroyed
///
/// The user can persist this information to track the lifetime of
/// notifications, and pass them to [LinuxInitializationSettings] after
/// a restart, making cancelAll be able to work with notifications created
/// before the restart.
abstract class LinuxNotificationNotifier {
  /// Called when a notification is created.
  void onNewNotificationCreated(int notificationId);

  /// Called when a notification is destroyed.
  void onNotificationDestroyed(int notificationId);
}

/// Plugin initialization settings for Linux.
class LinuxInitializationSettings {
  /// Construct an instance of [LinuxInitializationSettings].
  const LinuxInitializationSettings(
      {this.defaultIcon,
      this.notificationNotifier,
      this.knownShowingNotifications});

  /// Specifies the default icon for notifications.
  final LinuxIcon defaultIcon;

  /// Notification notifier.
  final LinuxNotificationNotifier notificationNotifier;

  /// Known currently showing notifications.
  final Set<int> knownShowingNotifications;
}
