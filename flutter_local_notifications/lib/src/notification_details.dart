import 'dart:io';

import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/ios/notification_details.dart';

/// Contains notification settings for each platform
class NotificationDetails {
  /// Notification details for Android
  final AndroidNotificationDetails android;

  /// Notification details for iOS
  final IOSNotificationDetails iOS;

  const NotificationDetails(this.android, this.iOS);
}

class NotificationData {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final NotificationDetails platformSpecifics;
  final String payload;
  final bool allowWhileIdle;

  NotificationData(
    this.id,
    this.title,
    this.body,
    this.scheduledDate,
    this.platformSpecifics, {
    this.payload,
    this.allowWhileIdle = false,
  });

  Map<String, dynamic> get _platformSpecifics {
    return Platform.isAndroid
        ? platformSpecifics?.android?.toMap() ?? Map<String, dynamic>()
        : platformSpecifics?.iOS?.toMap();
  }

  Map<String, dynamic> toMap() {
    final _m = <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'millisecondsSinceEpoch': scheduledDate.millisecondsSinceEpoch,
      'platformSpecifics': _platformSpecifics,
      'payload': payload ?? '',
    };

    if (Platform.isAndroid) {
      _m['allowWhileIdle'] = allowWhileIdle;
    }

    return _m;
  }
}
