import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';
import 'package:flutter_local_notifications/src/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/initialization_settings.dart';
import 'package:flutter_local_notifications/src/notification_details.dart';
import 'package:flutter_local_notifications/platform_specifics/android/initialization_settings_android.dart';
import 'package:flutter_local_notifications/platform_specifics/android/notification_details_android.dart';
import 'package:flutter_local_notifications/platform_specifics/ios/initialization_settings_ios.dart';
import 'package:flutter_local_notifications/platform_specifics/ios/notification_details_ios.dart';

void main() {
  MockMethodChannel mockChannel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  const id = 0;
  const title = 'title';
  const body = 'body';
  const payload = 'payload';

  group('ios', () {
    setUp(() {
      mockChannel = new MockMethodChannel();
      flutterLocalNotificationsPlugin =
          new FlutterLocalNotificationsPlugin.private(
              mockChannel, new FakePlatform(operatingSystem: 'ios'));
    });
    test('initialise plugin on iOS', () async {
      const InitializationSettingsIOS initializationSettingsIOS =
          InitializationSettingsIOS();
      const InitializationSettings initializationSettings =
          InitializationSettings(null, initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      verify(mockChannel.invokeMethod(
          'initialize', initializationSettingsIOS.toMap()));
    });
    test('show notification on iOS', () async {
      NotificationDetailsIOS iOSPlatformChannelSpecifics =
          new NotificationDetailsIOS();
      NotificationDetails platformChannelSpecifics =
          new NotificationDetails(null, iOSPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin
          .show(0, title, body, platformChannelSpecifics, payload: payload);
      verify(mockChannel.invokeMethod('show', <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'platformSpecifics': iOSPlatformChannelSpecifics.toMap(),
        'payload': payload
      }));
    });
    test('schedule notification on iOS', () async {
      var scheduledNotificationDateTime =
          new DateTime.now().add(new Duration(seconds: 5));
      NotificationDetailsIOS iOSPlatformChannelSpecifics =
          new NotificationDetailsIOS();
      NotificationDetails platformChannelSpecifics =
          new NotificationDetails(null, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.schedule(id, title, body,
          scheduledNotificationDateTime, platformChannelSpecifics);
      verify(mockChannel.invokeMethod('schedule', <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'millisecondsSinceEpoch':
            scheduledNotificationDateTime.millisecondsSinceEpoch,
        'platformSpecifics': iOSPlatformChannelSpecifics.toMap(),
        'payload': ''
      }));
    });

    test('delete notification on ios', () async {
      await flutterLocalNotificationsPlugin.cancel(id);
      verify(mockChannel.invokeMethod('cancel', id));
    });
  });

  group('android', () {
    setUp(() {
      mockChannel = new MockMethodChannel();
      flutterLocalNotificationsPlugin =
          new FlutterLocalNotificationsPlugin.private(
              mockChannel, new FakePlatform(operatingSystem: 'android'));
    });
    test('initialise plugin on Android', () async {
      const InitializationSettingsAndroid initializationSettingsAndroid =
          InitializationSettingsAndroid('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(initializationSettingsAndroid, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      verify(mockChannel.invokeMethod(
          'initialize', initializationSettingsAndroid.toMap()));
    });
    test('show notification on Android', () async {
      NotificationDetailsAndroid androidPlatformChannelSpecifics =
          new NotificationDetailsAndroid('your channel id', 'your channel name',
              'your channel description',
              importance: Importance.Max, priority: Priority.High);

      NotificationDetails platformChannelSpecifics =
          new NotificationDetails(androidPlatformChannelSpecifics, null);

      await flutterLocalNotificationsPlugin
          .show(0, title, body, platformChannelSpecifics, payload: payload);
      verify(mockChannel.invokeMethod('show', <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'platformSpecifics': androidPlatformChannelSpecifics.toMap(),
        'payload': payload
      }));
    });
    test('schedule notification on Android', () async {
      var scheduledNotificationDateTime =
          new DateTime.now().add(new Duration(seconds: 5));

      NotificationDetailsAndroid androidPlatformChannelSpecifics =
          new NotificationDetailsAndroid('your other channel id',
              'your other channel name', 'your other channel description');

      NotificationDetails platformChannelSpecifics =
          new NotificationDetails(androidPlatformChannelSpecifics, null);
      await flutterLocalNotificationsPlugin.schedule(id, title, body,
          scheduledNotificationDateTime, platformChannelSpecifics);
      verify(mockChannel.invokeMethod('schedule', <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'millisecondsSinceEpoch':
            scheduledNotificationDateTime.millisecondsSinceEpoch,
        'platformSpecifics': androidPlatformChannelSpecifics.toMap(),
        'payload': ''
      }));
    });

    test('delete notification on android', () async {
      await flutterLocalNotificationsPlugin.cancel(id);
      verify(mockChannel.invokeMethod('cancel', id));
    });
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
