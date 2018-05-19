import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(
    new MaterialApp(home: new MyApp()),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  StreamSubscription<NotificationButton> _buttonSubscription;
  StreamSubscription<String> _notificationSubscription;

  @override
  initState() {
    super.initState();
    // initialise the plugin
    var initializationSettingsAndroid =
        new InitializationSettingsAndroid('app_icon');
    var initializationSettingsIOS = new InitializationSettingsIOS();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _notificationSubscription = flutterLocalNotificationsPlugin
        .onSelectNotificationStream.listen((String payload) {
      onSelectNotification(payload);
    });
    _buttonSubscription = flutterLocalNotificationsPlugin
        .onActionButtonPushedStream.listen((NotificationButton button) {
      onButtonPressed(button);
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _buttonSubscription?.cancel();
    _buttonSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new SingleChildScrollView(
          child: new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Center(
              child: new Column(
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: new Text(
                        'Tap on a notification when it appears to trigger navigation'),
                  ),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child:
                              new Text('Show plain notification with payload'),
                          onPressed: () async {
                            await _showNotification();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child:
                              new Text('Show plain notification with actions'),
                          onPressed: () async {
                            await _showNotificationWithActions();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text('Cancel notification'),
                          onPressed: () async {
                            await _cancelNotification();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text(
                              'Schedule notification to appear in 5 seconds, custom sound'),
                          onPressed: () async {
                            await _scheduleNotification();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text('Repeat notification every minute'),
                          onPressed: () async {
                            await _repeatNotification();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text(
                              'Repeat notification every day at approximately 10:00:00 am'),
                          onPressed: () async {
                            await _showDailyAtTime();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text(
                              'Repeat notification weekly on Monday at approximately 10:00:00 am'),
                          onPressed: () async {
                            await _showWeeklyAtDayAndTime();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text('Show notification with no sound'),
                          onPressed: () async {
                            await _showNotificationWithNoSound();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child:
                              new Text('Show big text notification [Android]'),
                          onPressed: () async {
                            await _showBigTextNotification();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text('Show inbox notification [Android]'),
                          onPressed: () async {
                            await _showInboxNotification();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child:
                              new Text('Show grouped notifications [Android]'),
                          onPressed: () async {
                            await _showGroupedNotifications();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child:
                              new Text('Show ongoing notification [Android]'),
                          onPressed: () async {
                            await _showOngoingNotification();
                          })),
                  new Padding(
                      padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: new RaisedButton(
                          child: new Text('cancel all notifications'),
                          onPressed: () async {
                            await _cancelAllNotifications();
                          })),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _showNotification() async {
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future _showNotificationWithActions() async {
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
        actions: [
          new AndroidNotificationAction(text: 'FLUFF', payload: 'More fluff')
        ]);

    var iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future _scheduleNotification() async {
    var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: 5));
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        icon: 'secondary_icon',
        sound: 'slow_spring_board',
        vibrationPattern: vibrationPattern);
    var iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future _showNotificationWithNoSound() async {
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'silent channel id',
        'silent channel name',
        'silent channel description',
        playSound: false,
        styleInformation: new DefaultStyleInformation(true, true));
    var iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, '<b>silent</b> title',
        '<b>silent</b> body', platformChannelSpecifics);
  }

  Future _showBigTextNotification() async {
    var bigTextStyleInformation = new BigTextStyleInformation(
        'Lorem <i>ipsum dolor sit</i> amet, consectetur <b>adipiscing elit</b>, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        htmlFormatBigText: true,
        contentTitle: 'overridden <b>big</b> context title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        style: NotificationStyleAndroid.BigText,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future _showInboxNotification() async {
    var lines = new List<String>();
    lines.add('line <b>1</b>');
    lines.add('line <i>2</i>');
    var inboxStyleInformation = new InboxStyleInformation(lines,
        htmlFormatLines: true,
        contentTitle: 'overridden <b>inbox</b> context title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'inbox channel id', 'inboxchannel name', 'inbox channel description',
        style: NotificationStyleAndroid.Inbox,
        styleInformation: inboxStyleInformation);
    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'inbox title', 'inbox body', platformChannelSpecifics);
  }

  Future _showGroupedNotifications() async {
    var groupKey = 'com.android.example.WORK_EMAIL';
    var groupChannelId = 'grouped channel id';
    var groupChannelName = 'grouped channel name';
    var groupChannelDescription = 'grouped channel description';
    // example based on https://developer.android.com/training/notify-user/group.html
    var firstNotificationAndroidSpecifics = new NotificationDetailsAndroid(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
    var firstNotificationPlatformSpecifics =
        new NotificationDetails(firstNotificationAndroidSpecifics, null);
    await flutterLocalNotificationsPlugin.show(1, 'Alex Faarborg',
        'You will not believe...', firstNotificationPlatformSpecifics);
    var secondNotificationAndroidSpecifics = new NotificationDetailsAndroid(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
    var secondNotificationPlatformSpecifics =
        new NotificationDetails(secondNotificationAndroidSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        2,
        'Jeff Chang',
        'Please join us to celebrate the...',
        secondNotificationPlatformSpecifics);

    // create the summary notification required for older devices that pre-date Android 7.0 (API level 24)
    var lines = new List<String>();
    lines.add('Alex Faarborg  Check this out');
    lines.add('Jeff Chang    Launch Party');
    var inboxStyleInformation = new InboxStyleInformation(lines,
        contentTitle: '2 new messages', summaryText: 'janedoe@example.com');
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        groupChannelId, groupChannelName, groupChannelDescription,
        style: NotificationStyleAndroid.Inbox,
        styleInformation: inboxStyleInformation,
        groupKey: groupKey,
        setAsGroupSummary: true);
    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        3, 'Attention', 'Two new messages', platformChannelSpecifics);
  }

  Future _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new SecondScreen(payload: payload)),
    );
  }

  Future onButtonPressed(NotificationButton button) async {
    if (button != null) {
      debugPrint('notification payload: ' + button.toString());
    }

    await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new SecondScreen(
                payload: button.payload,
                notificationId: button.notificationId,
              )),
    );
  }

  Future _showOngoingNotification() async {
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ongoing: true);
    var iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'ongoing notification title',
        'ongoing notification body', platformChannelSpecifics);
  }

  Future _repeatNotification() async {
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'repeating channel id',
        'repeating channel name',
        'repeating description');
    var iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.EveryMinute, platformChannelSpecifics);
  }

  Future _showDailyAtTime() async {
    var time = new Time(10, 0, 0);
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'show daily title',
        'Daily notification shown at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
        time,
        platformChannelSpecifics);
  }

  Future _showWeeklyAtDayAndTime() async {
    var time = new Time(10, 0, 0);
    var androidPlatformChannelSpecifics = new NotificationDetailsAndroid(
        'show weekly channel id',
        'show weekly channel name',
        'show weekly description');
    var iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'show weekly title',
        'Weekly notification shown on Monday at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
        Day.Monday,
        time,
        platformChannelSpecifics);
  }

  String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class SecondScreen extends StatelessWidget {
  final String payload;
  final int notificationId;
  SecondScreen({this.payload, this.notificationId});

  @override
  Widget build(BuildContext context) {
    print("$payload $notificationId");
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Second Screen with payload: $payload" +
            (notificationId != null ? " NotificationId: $notificationId" : "")),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              "Payload $payload",
              style: Theme.of(context).textTheme.subhead,
            ),
            new Text(
              notificationId != null ? "Notification id: $notificationId" : "",
              style: Theme.of(context).textTheme.subhead,
            ),
            new SizedBox(height: 10.0),
            new RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}
