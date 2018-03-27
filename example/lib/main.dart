import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings_android.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings_ios.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details_android.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details_ios.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState(){
    super.initState();
    InitializationSettingsAndroid initializationSettingsAndroid = new InitializationSettingsAndroid('app_icon');
    InitializationSettingsIOS initializationSettingsIOS = new InitializationSettingsIOS(requestAlertPermission: false);
    InitializationSettings initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
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
                            'Schedule notification to appear in 5 seconds'),
                        onPressed: () async {
                          await scheduleNotification();
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

  scheduleNotification() async {
    var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: 5));
    NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid(
            'your channel id', 'your channel name', 'your channel description',
            icon: 'secondary_icon');
    NotificationDetailsIOS iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.schedule(0, 'scheduled title', 'scheduled body',
        scheduledNotificationDateTime, platformChannelSpecifics);
  }
}
