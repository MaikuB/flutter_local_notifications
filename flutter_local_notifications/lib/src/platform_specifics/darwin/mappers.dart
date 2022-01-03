import 'package:flutter/foundation.dart';

import 'darwin_notification_action.dart';
import 'darwin_notification_category.dart';

// ignore_for_file: public_member_api_docs

extension DarwinNotificationActionMapper on DarwinNotificationAction {
  Map<String, Object> toMap() => <String, Object>{
        'identifier': identifier,
        'title': title,
        'options': options
            .map((e) => 1 << e.index) // ignore: always_specify_types
            .toList(),
        'type': describeEnum(type),
        if (buttonTitle != null) 'buttonTitle': buttonTitle!,
        if (placeholder != null) 'placeholder': placeholder!,
      };
}

extension DarwinNotificationCategoryMapper on DarwinNotificationCategory {
  Map<String, Object> toMap() => <String, Object>{
        'identifier': identifier,
        'actions': actions
            .map((e) => e.toMap()) // ignore: always_specify_types
            .toList(),
        'options': options
            .map((e) => 1 << e.index) // ignore: always_specify_types
            .toList(),
      };
}
