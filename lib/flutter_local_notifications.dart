import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/initialization_settings.dart';
import 'package:flutter_local_notifications/notification_details.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

typedef Future<dynamic> MessageHandler(String message);

class FlutterLocalNotificationsPlugin {
  factory FlutterLocalNotificationsPlugin() => _instance;

  @visibleForTesting
  FlutterLocalNotificationsPlugin.private(
      MethodChannel channel, Platform platform)
      : _channel = channel,
        _platform = platform;

  static final FlutterLocalNotificationsPlugin _instance =
      new FlutterLocalNotificationsPlugin.private(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          const LocalPlatform());

  final MethodChannel _channel;
  final Platform _platform;

  MessageHandler onSelectNotification;

  /// Initializes the plugin. Call this method on application before using the plugin further
  Future<bool> initialize(InitializationSettings initializationSettings,
      {MessageHandler selectNotification}) async {
    onSelectNotification = selectNotification;
    Map<String, dynamic> serializedPlatformSpecifics;
    if (_platform.isAndroid) {
      serializedPlatformSpecifics = initializationSettings.android.toMap();
    } else if (_platform.isIOS) {
      serializedPlatformSpecifics = initializationSettings.ios.toMap();
    }
    _channel.setMethodCallHandler(_handleMethod);
    var result =
        await _channel.invokeMethod('initialize', serializedPlatformSpecifics);
    return result;
  }

  /// Show a notification with an optional payload that will be passed back to the app when a notification is tapped
  Future show(int id, String title, String body,
      NotificationDetails notificationDetails,
      {String payload}) async {
    Map<String, dynamic> serializedPlatformSpecifics;
    if (_platform.isAndroid) {
      serializedPlatformSpecifics = notificationDetails.android.toMap();
    } else if (_platform.isIOS) {
      serializedPlatformSpecifics = notificationDetails.iOS.toMap();
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
  Future cancel(int id) async {
    await _channel.invokeMethod('cancel', id);
  }

  /// Schedules a notification to be shown at the specified time with an optional payload that is passed through when a notification is tapped
  Future schedule(int id, String title, String body, DateTime scheduledDate,
      NotificationDetails notificationDetails,
      {String payload}) async {
    Map<String, dynamic> serializedPlatformSpecifics;
    if (_platform.isAndroid) {
      serializedPlatformSpecifics = notificationDetails.android.toMap();
    } else if (_platform.isIOS) {
      serializedPlatformSpecifics = notificationDetails.iOS.toMap();
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

  Future _handleMethod(MethodCall call) async {
    return onSelectNotification(call.arguments);
  }
}
