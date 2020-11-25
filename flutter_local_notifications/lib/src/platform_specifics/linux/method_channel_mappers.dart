import 'dart:typed_data';

import 'icon.dart';
import 'initialization_settings.dart';
import 'notification_details.dart';

// ignore_for_file: public_member_api_docs

extension LinuxIconMapper on LinuxIcon {
  Map<String, Object> toMap() => <String, Object>{
        'icon': content,
        'iconSource': source.index,
      };
}

extension LinuxInitializationSettingsMapper on LinuxInitializationSettings {
  Map<String, Object> toMap() => <String, Object>{
        'defaultIcon': defaultIcon?.toMap(),
        'knownShowingNotifications':
            Int64List.fromList(knownShowingNotifications?.toList()),
      };
}

extension LinuxNotificationButtonSetMapper on Set<LinuxNotificationButton> {
  List<Map<String, String>> serializeToList() =>
      map((LinuxNotificationButton e) => <String, String>{
            'buttonLabel': e.label,
            'payload': e.payload,
          }).toList(growable: false);
}

extension LinuxNotificationDetailsMapper on LinuxNotificationDetails {
  Map<String, Object> toMap() => <String, Object>{
        'icon': icon?.toMap(),
        'buttons': buttons?.serializeToList(),
      };
}
