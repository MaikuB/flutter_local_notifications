import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_example/notification_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

NotificationAppLaunchDetails notificationAppLaunchDetails;

final NotificationHelper notificationHelper = NotificationHelper();

/// IMPORTANT: running the following code on its own won't work as there is setup required for each platform head project.
/// Please download the complete example app from the GitHub repository where all the setup has been done
Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  await notificationHelper
      .initializeNotification(flutterLocalNotificationsPlugin);

  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}

class PaddedRaisedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const PaddedRaisedButton({
    @required this.buttonText,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: RaisedButton(child: Text(buttonText), onPressed: onPressed),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    notificationHelper.requestIOSPermissions(flutterLocalNotificationsPlugin);
    notificationHelper.configureDidReceiveLocalNotificationSubject(
        flutterLocalNotificationsPlugin, context);
    notificationHelper.configureSelectNotificationSubject(
        flutterLocalNotificationsPlugin, context);
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: Text(
                        'Tap on a notification when it appears to trigger navigation'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Did notification launch app? ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '${notificationAppLaunchDetails?.didNotificationLaunchApp ?? false}',
                          )
                        ],
                      ),
                    ),
                  ),
                  if (notificationAppLaunchDetails?.didNotificationLaunchApp ??
                      false)
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Launch notification payload: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: notificationAppLaunchDetails.payload,
                            )
                          ],
                        ),
                      ),
                    ),
                  PaddedRaisedButton(
                    buttonText: 'Show plain notification with payload',
                    onPressed: () async {
                      await notificationHelper
                          .showNotification(flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show plain notification that has no body with payload',
                    onPressed: () async {
                      await notificationHelper.showNotificationWithNoBody(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show plain notification with payload and update channel description [Android]',
                    onPressed: () async {
                      await notificationHelper
                          .showNotificationWithUpdatedChannelDescription(
                              flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show plain notification as public on every lockscreen [Android]',
                    onPressed: () async {
                      await notificationHelper.showPublicNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Cancel notification',
                    onPressed: () async {
                      await notificationHelper
                          .cancelNotification(flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Schedule notification to appear in 5 seconds, custom sound, red colour, large icon, red LED',
                    onPressed: () async {
                      await notificationHelper.scheduleNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  Text(
                      'NOTE: red colour, large icon and red LED are Android-specific'),
                  PaddedRaisedButton(
                    buttonText: 'Repeat notification every minute',
                    onPressed: () async {
                      await notificationHelper
                          .repeatNotification(flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Repeat notification every day at approximately 10:00:00 am',
                    onPressed: () async {
                      await notificationHelper
                          .showDailyAtTime(flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Repeat notification weekly on Monday at approximately 10:00:00 am',
                    onPressed: () async {
                      await notificationHelper.showWeeklyAtDayAndTime(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show notification with no sound',
                    onPressed: () async {
                      await notificationHelper.showNotificationWithNoSound(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show notification using Android Uri sound [Android]',
                    onPressed: () async {
                      await notificationHelper.showSoundUriNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show notification that times out after 3 seconds [Android]',
                    onPressed: () async {
                      await notificationHelper.showTimeoutNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show insistent notification [Android]',
                    onPressed: () async {
                      await notificationHelper.showInsistentNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show big picture notification [Android]',
                    onPressed: () async {
                      await notificationHelper.showBigPictureNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show big picture notification, hide large icon on expand [Android]',
                    onPressed: () async {
                      await notificationHelper
                          .showBigPictureNotificationHideExpandedLargeIcon(
                              flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show media notification [Android]',
                    onPressed: () async {
                      await notificationHelper.showNotificationMediaStyle(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show big text notification [Android]',
                    onPressed: () async {
                      await notificationHelper.showBigTextNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show inbox notification [Android]',
                    onPressed: () async {
                      await notificationHelper.showInboxNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show messaging notification [Android]',
                    onPressed: () async {
                      await notificationHelper.showMessagingNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show grouped notifications [Android]',
                    onPressed: () async {
                      await notificationHelper.showGroupedNotifications(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show ongoing notification [Android]',
                    onPressed: () async {
                      await notificationHelper.showOngoingNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show notification with no badge, alert only once [Android]',
                    onPressed: () async {
                      await notificationHelper.showNotificationWithNoBadge(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show progress notification - updates every second [Android]',
                    onPressed: () async {
                      await notificationHelper.showProgressNotification(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show indeterminate progress notification [Android]',
                    onPressed: () async {
                      await notificationHelper
                          .showIndeterminateProgressNotification(
                              flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Check pending notifications',
                    onPressed: () async {
                      await notificationHelper.checkPendingNotificationRequests(
                          flutterLocalNotificationsPlugin, context);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Cancel all notifications',
                    onPressed: () async {
                      await notificationHelper.cancelAllNotifications(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show notification with icon badge [iOS]',
                    onPressed: () async {
                      await notificationHelper.showNotificationWithIconBadge(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show notification without timestamp [Android]',
                    onPressed: () async {
                      await notificationHelper.showNotificationWithoutTimestamp(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show notification with custom timestamp [Android]',
                    onPressed: () async {
                      await notificationHelper
                          .showNotificationWithCustomTimestamp(
                              flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show notification with attachment [iOS]',
                    onPressed: () async {
                      await notificationHelper.showNotificationWithAttachment(
                          flutterLocalNotificationsPlugin);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Create notification channel [Android]',
                    onPressed: () async {
                      await notificationHelper.createNotificationChannel(
                          flutterLocalNotificationsPlugin, context);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Delete notification channel [Android]',
                    onPressed: () async {
                      await notificationHelper.deleteNotificationChannel(
                          flutterLocalNotificationsPlugin, context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  SecondScreen(this.payload);

  final String payload;

  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen with payload: ${(_payload ?? '')}'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
