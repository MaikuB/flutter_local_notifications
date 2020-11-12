import 'icon.dart';
import 'initialization_settings.dart';
import 'notification_details.dart';

extension LinuxIconMapper on LinuxIcon {
  Map<String, Object> toMap() {
    return <String, Object> {
      'icon': content,
      'iconSource': source.index,
    };
  }
}

extension LinuxInitializationSettingsMapper on LinuxInitializationSettings {
  Map<String, Object> toMap() {
    return <String, Object> {
      'defaultIcon': defaultIcon?.toMap(),
    };
  }
}

extension LinuxNotificationButtonSetMapper on Set<LinuxNotificationButton> {
  List<Map<String, String>> serializeToList() =>
    map((LinuxNotificationButton e) => <String, String>{
      'buttonLabel': e.label,
      'buttonId': e.buttonId,
    }).toList(growable: false);
}

extension LinuxNotificationDetailsMapper on LinuxNotificationDetails {
  Map<String, Object> toMap() {
    return <String, Object> {
      'icon': icon?.toMap(),
      'buttons': buttons?.serializeToList(),
    };
  }
}
