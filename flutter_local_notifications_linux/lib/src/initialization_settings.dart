import 'icon.dart';
import 'sound.dart';

/// Plugin initialization settings for Linux.
class LinuxInitializationSettings {
  /// Constructs an instance of [LinuxInitializationSettings]
  const LinuxInitializationSettings({
    this.defaultIcon,
    this.defaultSound,
  });

  /// Specifies the default icon for notifications.
  final LinuxNotificationIcon? defaultIcon;

  /// Specifies the default sound for notifications.
  final LinuxNotificationSound? defaultSound;
}
