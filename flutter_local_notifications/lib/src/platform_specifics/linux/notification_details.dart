import 'package:meta/meta.dart';

import 'icon.dart';

/// Details of notification button on Linux.
@immutable
class LinuxNotificationButton {
  /// Construct an instance of [LinuxNotificationButton].
  const LinuxNotificationButton(
      {@required this.label,
      @required this.payload});

  /// Label of this button.
  final String label;

  /// Payload which will be passed to callback
  final String payload;
}

/// Configures notification details specific to Linux.
class LinuxNotificationDetails {
  /// Construct an instance of [LinuxNotificationDetails].
  const LinuxNotificationDetails({this.icon, this.buttons});

  /// The icon used by this notification.
  final LinuxIcon icon;

  /// The buttons of this notification.
  final Set<LinuxNotificationButton> buttons;
}
