import 'dart:async';

import 'package:flutter/services.dart';
import 'helpers.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'platform_specifics/android/notification_details.dart';

const MethodChannel _channel =
    MethodChannel('dexterous.com/flutter/local_notifications');

class MethodChannelFlutterLocalNotifications
    extends FlutterLocalNotificationsPlatform {
  @override
  Future<void> cancel(int id) {
    return _channel.invokeMethod('cancel', id);
  }

  @override
  Future<void> cancelAll() {
    return _channel.invokeMethod('cancelAll');
  }
}

class AndroidFlutterLocalNotifications
    extends MethodChannelFlutterLocalNotifications {
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
}

class IOSFlutterLocalNotifications  extends MethodChannelFlutterLocalNotifications {
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
