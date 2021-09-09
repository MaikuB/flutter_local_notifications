import 'icon.dart';
import 'sound.dart';

/// Plugin initialization settings for Linux.
class LinuxInitializationSettings {
  /// Constructs an instance of [LinuxInitializationSettings]
  const LinuxInitializationSettings({
    required this.defaultActionName,
    this.defaultIcon,
    this.defaultSound,
    this.defaultSuppressSound = false,
  });

  /// Name of the default action (usually triggered by clicking
  /// the notification).
  /// The name can be anything, though implementations are free not to
  /// display it.
  final String defaultActionName;

  /// Specifies the default icon for notifications.
  final LinuxNotificationIcon? defaultIcon;

  /// Specifies the default sound for notifications.
  /// Typical value is `ThemeLinuxSound('message')`
  final LinuxNotificationSound? defaultSound;

  /// Causes the server to suppress playing any sounds, if it has that ability.
  /// This is usually set when the client itself is going to play its own sound.
  final bool defaultSuppressSound;
}
