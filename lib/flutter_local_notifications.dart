import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details.dart';

class FlutterLocalNotifications {
  static const MethodChannel _channel =
      const MethodChannel('dexterous.com/flutter/local_notifications');

  /// Initializes the plugin. Call this method on application before using the plugin further
  static Future<bool> initialize(
      InitializationSettings initializationSettings) async {
    Map<String, dynamic> serializedPlatformSpecifics;
    if (Platform.isAndroid) {
      serializedPlatformSpecifics = initializationSettings.android.toJson();
    } else if (Platform.isIOS) {
      serializedPlatformSpecifics = initializationSettings.ios.toJson();
    }
    var result = await _channel.invokeMethod('initialize',
        <String, dynamic>{'platformSpecifics': serializedPlatformSpecifics});
    return result;
  }

  /// Show a notification
  static Future show(int id, String title, String body,
      NotificationDetails notificationDetails) async {
    Map<String, dynamic> serializedPlatformSpecifics;
    if (Platform.isAndroid) {
      serializedPlatformSpecifics = notificationDetails.android.toJson();
    } else if (Platform.isIOS) {
      serializedPlatformSpecifics = notificationDetails.iOS.toJson();
    }
    await _channel.invokeMethod('show', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'platformSpecifics': serializedPlatformSpecifics
    });
  }

  /// Cancel/remove the notificiation with the specified id
  static Future cancel(int id) async {
    await _channel.invokeMethod('cancel', id);
  }

  /// Schedules a notification to be shown at the specified time
  static Future schedule(int id, String title, String body,
      DateTime scheduledDate, NotificationDetails notificationDetails) async {
    Map<String, dynamic> serializedPlatformSpecifics;
    if (Platform.isAndroid) {
      serializedPlatformSpecifics = notificationDetails.android.toJson();
    } else if (Platform.isIOS) {
      serializedPlatformSpecifics = notificationDetails.iOS.toJson();
    }
    await _channel.invokeMethod('schedule', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'millisecondsSinceEpoch': scheduledDate.millisecondsSinceEpoch,
      'platformSpecifics': serializedPlatformSpecifics
    });
  }
}
