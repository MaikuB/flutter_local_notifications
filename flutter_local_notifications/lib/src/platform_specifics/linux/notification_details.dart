import 'package:meta/meta.dart';

import 'icon.dart';

/// Signature of callback which triggered when user taps 
/// a button of a notification.
typedef LinuxNotificationButtonHandler = void Function(int id, String buttonId);

/// Details of notification button on Linux.
@immutable
class LinuxNotificationButton {
  const LinuxNotificationButton(
    {@required this.label, @required this.buttonId, @required this.handler});

  /// Label of this button
  final String label;
  /// Identifier of this button, will be passed to callback
  final String buttonId;
  final LinuxNotificationButtonHandler handler;

  @override
  bool operator==(covariant LinuxNotificationButton other) =>
    buttonId == other.buttonId;

  @override
  int get hashCode => buttonId.hashCode;
}

/// Configures notification details specific to Linux.
class LinuxNotificationDetails {
  const LinuxNotificationDetails({this.icon, this.buttons});

  final LinuxIcon icon;
  final Set<LinuxNotificationButton> buttons; 
}
