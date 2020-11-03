import 'package:meta/meta.dart';

import 'icon.dart';

typedef void LinuxNotificationButtonHandler(int id, String buttonId);

class LinuxNotificationButton {
  final String label;
  final String buttonId;
  final LinuxNotificationButtonHandler handler;

  const LinuxNotificationButton({@required this.label, @required this.buttonId, @required this.handler});

  bool operator==(covariant LinuxNotificationButton other) => buttonId == other.buttonId;
}

class LinuxNotificationDetails {
  const LinuxNotificationDetails({this.icon, this.buttons});

  final LinuxIcon icon;
  final Set<LinuxNotificationButton> buttons; 
}
