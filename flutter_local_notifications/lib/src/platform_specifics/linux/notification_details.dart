import 'package:meta/meta.dart';

import 'icon.dart';

/// Signature of callback which triggered when user taps a button of a notification.
typedef void LinuxNotificationButtonHandler(int id, String buttonId);

/// Details of notification button on Linux.
class LinuxNotificationButton {
  const LinuxNotificationButton({@required this.label, @required this.buttonId, @required this.handler});

  /// Label of this button
  final String label;
  /// Identifier of this button, will be passed to callback when tapped
  final String buttonId;
  final LinuxNotificationButtonHandler handler;

  bool operator==(covariant LinuxNotificationButton other) => buttonId == other.buttonId;
}

/// Configures notification details specific to Linux.
class LinuxNotificationDetails {
  const LinuxNotificationDetails({this.icon, this.buttons});

  final LinuxIcon icon;
  final Set<LinuxNotificationButton> buttons; 
}
