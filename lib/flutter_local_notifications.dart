import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/initialization_settings.dart';
import 'package:flutter_local_notifications/notification_details.dart';

typedef Future<dynamic> MessageHandler(String message);

class FlutterLocalNotifications {
  static const MethodChannel _channel =
      const MethodChannel('dexterous.com/flutter/local_notifications');

  static MessageHandler onSelectNotification;

  /// Initializes the plugin. Call this method on application before using the plugin further
  static Future<bool> initialize(InitializationSettings initializationSettings,
      {MessageHandler selectNotification}) async {
    onSelectNotification = selectNotification;
    Map<String, dynamic> serializedPlatformSpecifics;
    if (Platform.isAndroid) {
      serializedPlatformSpecifics = initializationSettings.android.toJson();
    } else if (Platform.isIOS) {
      serializedPlatformSpecifics = initializationSettings.ios.toJson();
    }
    _channel.setMethodCallHandler(_handleMethod);
    var result = await _channel.invokeMethod('initialize',
        <String, dynamic>{'platformSpecifics': serializedPlatformSpecifics});
    return result;
  }

  /// Show a notification with an optional payload that will be passed back to the app when a notification is tapped
  static Future show(int id, String title, String body,
      NotificationDetails notificationDetails,
      {String payload}) async {
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
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  /// Cancel/remove the notificiation with the specified id
  static Future cancel(int id) async {
    await _channel.invokeMethod('cancel', id);
  }

  /// Schedules a notification to be shown at the specified time with an optional payload that is passed through when a notification is tapped
  static Future schedule(int id, String title, String body,
      DateTime scheduledDate, NotificationDetails notificationDetails,
      {String payload}) async {
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
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  static Future _handleMethod(MethodCall call) async {
    return onSelectNotification(call.arguments);
  }
}
