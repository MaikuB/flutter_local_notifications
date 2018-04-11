import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/platform_specifics/android_styles/default_style_information.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings_android.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings_ios.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details_android.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details_ios.dart';
import 'package:flutter_local_notifications/platform_specifics/android_styles/big_text_style_information.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    InitializationSettingsAndroid initializationSettingsAndroid =
        new InitializationSettingsAndroid('app_icon');
    InitializationSettingsIOS initializationSettingsIOS =
        new InitializationSettingsIOS();
    InitializationSettings initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    FlutterLocalNotifications.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Padding(
          padding: new EdgeInsets.all(8.0),
          child: new Center(
            child: new Column(
              children: <Widget>[
                new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: new RaisedButton(
                        child: new Text('Show plain notification'),
                        onPressed: () async {
                          await showNotification();
                        })),
                new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: new RaisedButton(
                        child: new Text('Cancel notification'),
                        onPressed: () async {
                          await cancelNotification();
                        })),
                new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: new RaisedButton(
                        child: new Text(
                            'Schedule notification to appear in 5 seconds, different sound'),
                        onPressed: () async {
                          await scheduleNotification();
                        })),
                new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: new RaisedButton(
                        child: new Text('Show notification with no sound'),
                        onPressed: () async {
                          await showNotificationWithNoSound();
                        })),
                new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: new RaisedButton(
                        child: new Text('Show big text notification [Android]'),
                        onPressed: () async {
                          await showBigTextNotification();
                        })),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showNotification() async {
    NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.Max, priority: Priority.High);
    NotificationDetailsIOS iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.show(
        0, 'plain title', 'plain body', platformChannelSpecifics);
  }

  cancelNotification() async {
    await FlutterLocalNotifications.cancel(0);
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  scheduleNotification() async {
    var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: 5));
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid('your other channel id',
            'your other channel name', 'your other channel description',
            icon: 'secondary_icon',
            sound: 'slow_spring_board',
            vibrationPattern: vibrationPattern);
    NotificationDetailsIOS iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS(sound: "slow_spring_board.aiff");
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  showNotificationWithNoSound() async {
    NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid('silent channel id',
            'silent channel name', 'silent channel description',
            playSound: false,
            styleInformation: new DefaultStyleInformation(true, true));
    NotificationDetailsIOS iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS(presentSound: false);
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.show(
        0, '<b>silent</b> title', '<b>silent</b> body', platformChannelSpecifics);
  }

  showBigTextNotification() async {
    BigTextStyleInformation bigTextStyleInformation = new BigTextStyleInformation(
        'Lorem <i>ipsum dolor sit</i> amet, consectetur <b>adipiscing elit</b>, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        htmlFormatBigText: true,
        contentTitle: 'overridden <b>big</b> context title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid('big text channel id',
            'big text channel name', 'big text channel description',
            style: NotificationStyleAndroid.BigText,
            styleInformation: bigTextStyleInformation);
    NotificationDetailsIOS iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.show(
        0, 'big text title', 'silent body', platformChannelSpecifics);
  }
}
