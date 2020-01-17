import 'dart:async';

import 'package:flutter/services.dart';
import 'helpers.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'platform_specifics/android/initialization_settings.dart';
import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/ios/initialization_settings.dart';
import 'platform_specifics/ios/notification_details.dart';
import 'typedefs.dart';

const MethodChannel _channel =
    MethodChannel('dexterous.com/flutter/local_notifications');

class MethodChannelFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  @override
  Future<void> cancel(int id) {
    validateId(id);
    return _channel.invokeMethod('cancel', id);
  }

  @override
  Future<void> cancelAll() {
    return _channel.invokeMethod('cancelAll');
  }

  @override
  Future<NotificationAppLaunchDetails> getNotificationAppLaunchDetails() async {
    final result =
        await _channel.invokeMethod('getNotificationAppLaunchDetails');
    return NotificationAppLaunchDetails(result['notificationLaunchedApp'],
        result.containsKey('payload') ? result['payload'] : null);
  }
}

class AndroidFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback _onSelectNotification;

  Future<bool> initialize(AndroidInitializationSettings initializationSettings,
      {SelectNotificationCallback onSelectNotification}) async {
    _onSelectNotification = onSelectNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  @override
  Future<void> show(int id, String title, String body,
      {AndroidNotificationDetails notificationDetails, String payload}) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'payload': payload ?? '',
        'platformSpecifics': notificationDetails?.toMap(),
      },
    );
  }

  Future<void> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'selectNotification':
        return _onSelectNotification(call.arguments);
      default:
        return Future.error('method not defined');
    }
  }
}

class IOSFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback _onSelectNotification;

  DidReceiveLocalNotificationCallback _onDidReceiveLocalNotificationCallback;

  Future<bool> initialize(IOSInitializationSettings initializationSettings,
      {SelectNotificationCallback onSelectNotification}) async {
    _onSelectNotification = onSelectNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  @override
  Future<void> show(int id, String title, String body,
      {IOSNotificationDetails notificationDetails, String payload}) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'payload': payload ?? '',
        'platformSpecifics': notificationDetails?.toMap(),
      },
    );
  }

  Future<void> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'selectNotification':
        return _onSelectNotification(call.arguments);

      case 'didReceiveLocalNotification':
        return _onDidReceiveLocalNotificationCallback(
            call.arguments['id'],
            call.arguments['title'],
            call.arguments['body'],
            call.arguments['payload']);
      default:
        return Future.error('method not defined');
    }
  }
}
