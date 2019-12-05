import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

final BehaviorSubject<NotificationActionTappedPayload>
    onNotificationActionTappedSubject =
    BehaviorSubject<NotificationActionTappedPayload>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}

class NotificationActionTappedPayload {
  final String actionKey;
  final Map<String, String> extras;

  NotificationActionTappedPayload({
    @required this.actionKey,
    @required this.extras,
  });
}

/// IMPORTANT: running the following code on its own won't work as there is setup required for each platform head project.
/// Please download the complete example app from the GitHub repository where all the setup has been done
Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
  // change the default route of the app
  // var notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
    didReceiveLocalNotificationSubject.add(ReceivedNotification(
        id: id, title: title, body: body, payload: payload));
  });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  }, onNotificationActionTapped:
          (String actionKey, Map<String, String> extras) async {
    onNotificationActionTappedSubject.add(
        NotificationActionTappedPayload(actionKey: actionKey, extras: extras));
  });
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}

class PaddedRaisedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  const PaddedRaisedButton(
      {@required this.buttonText, @required this.onPressed});

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
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');

  var lastTappedAction = "";

  @override
  void initState() {
    super.initState();
    onNotificationActionTappedSubject.stream.listen(onNotificationActionTapped);
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SecondScreen(receivedNotification.payload),
                  ),
                );
              },
            )
          ],
        ),
      );
    });
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SecondScreen(payload)),
      );
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    onNotificationActionTappedSubject.close();
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
                  PaddedRaisedButton(
                    buttonText: 'Show plain notification with payload',
                    onPressed: () async {
                      await _showNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show plain notification that has no body with payload',
                    onPressed: () async {
                      await _showNotificationWithNoBody();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show plain notification with payload and update channel description [Android]',
                    onPressed: () async {
                      await _showNotificationWithUpdatedChannelDescription();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Cancel notification',
                    onPressed: () async {
                      await _cancelNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Schedule notification to appear in 5 seconds, custom sound, red colour, large icon, red LED',
                    onPressed: () async {
                      await _scheduleNotification();
                    },
                  ),
                  Text(
                      'NOTE: red colour, large icon and red LED are Android-specific'),
                  PaddedRaisedButton(
                    buttonText: 'Repeat notification every minute',
                    onPressed: () async {
                      await _repeatNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Repeat notification every day at approximately 10:00:00 am',
                    onPressed: () async {
                      await _showDailyAtTime();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Repeat notification weekly on Monday at approximately 10:00:00 am',
                    onPressed: () async {
                      await _showWeeklyAtDayAndTime();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show notification with no sound',
                    onPressed: () async {
                      await _showNotificationWithNoSound();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show big picture notification [Android]',
                    onPressed: () async {
                      await _showBigPictureNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show big picture notification, hide large icon on expand [Android]',
                    onPressed: () async {
                      await _showBigPictureNotificationHideExpandedLargeIcon();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show big text notification [Android]',
                    onPressed: () async {
                      await _showBigTextNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show inbox notification [Android]',
                    onPressed: () async {
                      await _showInboxNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show messaging notification [Android]',
                    onPressed: () async {
                      await _showMessagingNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show grouped notifications [Android]',
                    onPressed: () async {
                      await _showGroupedNotifications();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show ongoing notification [Android]',
                    onPressed: () async {
                      await _showOngoingNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show notification with no badge, alert only once [Android]',
                    onPressed: () async {
                      await _showNotificationWithNoBadge();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show progress notification - updates every second [Android]',
                    onPressed: () async {
                      await _showProgressNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Show indeterminate progress notification [Android]',
                    onPressed: () async {
                      await _showIndeterminateProgressNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show notification with actions',
                    onPressed: () async {
                      await _showNotificationsWithActions();
                    },
                  ),
                  Text('Last tapped action: $lastTappedAction'),
                  PaddedRaisedButton(
                    buttonText: 'Check pending notifications',
                    onPressed: () async {
                      await _checkPendingNotificationRequests();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Cancel all notifications',
                    onPressed: () async {
                      await _cancelAllNotifications();
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

  Future<void> _showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithNoBody() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', null, platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<void> _scheduleNotification() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 5));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        icon: 'secondary_icon',
        sound: 'slow_spring_board',
        largeIcon: 'sample_large_icon',
        largeIconBitmapSource: BitmapSource.Drawable,
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<void> _showNotificationWithNoSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'silent channel id',
        'silent channel name',
        'silent channel description',
        playSound: false,
        styleInformation: DefaultStyleInformation(true, true));
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, '<b>silent</b> title',
        '<b>silent</b> body', platformChannelSpecifics);
  }

  Future<String> _downloadAndSaveImage(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> _showBigPictureNotification() async {
    var largeIconPath = await _downloadAndSaveImage(
        'http://via.placeholder.com/48x48', 'largeIcon');
    var bigPicturePath = await _downloadAndSaveImage(
        'http://via.placeholder.com/400x800', 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
        bigPicturePath, BitmapSource.FilePath,
        largeIcon: largeIconPath,
        largeIconBitmapSource: BitmapSource.FilePath,
        contentTitle: 'overridden <b>big</b> content title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        style: AndroidNotificationStyle.BigPicture,
        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<void> _showBigPictureNotificationHideExpandedLargeIcon() async {
    var largeIconPath = await _downloadAndSaveImage(
        'http://via.placeholder.com/48x48', 'largeIcon');
    var bigPicturePath = await _downloadAndSaveImage(
        'http://via.placeholder.com/400x800', 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
        bigPicturePath, BitmapSource.FilePath,
        hideExpandedLargeIcon: true,
        contentTitle: 'overridden <b>big</b> content title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        largeIcon: largeIconPath,
        largeIconBitmapSource: BitmapSource.FilePath,
        style: AndroidNotificationStyle.BigPicture,
        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<void> _showBigTextNotification() async {
    var bigTextStyleInformation = BigTextStyleInformation(
        'Lorem <i>ipsum dolor sit</i> amet, consectetur <b>adipiscing elit</b>, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        htmlFormatBigText: true,
        contentTitle: 'overridden <b>big</b> content title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        style: AndroidNotificationStyle.BigText,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<void> _showInboxNotification() async {
    var lines = List<String>();
    lines.add('line <b>1</b>');
    lines.add('line <i>2</i>');
    var inboxStyleInformation = InboxStyleInformation(lines,
        htmlFormatLines: true,
        contentTitle: 'overridden <b>inbox</b> context title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'inbox channel id', 'inboxchannel name', 'inbox channel description',
        style: AndroidNotificationStyle.Inbox,
        styleInformation: inboxStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'inbox title', 'inbox body', platformChannelSpecifics);
  }

  Future<void> _showMessagingNotification() async {
    // use a platform channel to resolve an Android drawable resource to a URI.
    // This is NOT part of the notifications plugin. Calls made over this channel is handled by the app
    String imageUri = await platform.invokeMethod('drawableToUri', 'food');
    var messages = List<Message>();
    // First two person objects will use icons that part of the Android app's drawable resources
    var me = Person(
        name: 'Me',
        key: '1',
        uri: 'tel:1234567890',
        icon: 'me',
        iconSource: IconSource.Drawable);
    var coworker = Person(
        name: 'Coworker',
        key: '2',
        uri: 'tel:9876543210',
        icon: 'coworker',
        iconSource: IconSource.Drawable);
    // download the icon that would be use for the lunch bot person
    var largeIconPath = await _downloadAndSaveImage(
        'http://via.placeholder.com/48x48', 'largeIcon');
    // this person object will use an icon that was downloaded
    var lunchBot = Person(
        name: 'Lunch bot',
        key: 'bot',
        bot: true,
        icon: largeIconPath,
        iconSource: IconSource.FilePath);
    messages.add(Message('Hi', DateTime.now(), null));
    messages.add(Message(
        'What\'s up?', DateTime.now().add(Duration(minutes: 5)), coworker));
    messages.add(Message(
        'Lunch?', DateTime.now().add(Duration(minutes: 10)), null,
        dataMimeType: 'image/png', dataUri: imageUri));
    messages.add(Message('What kind of food would you prefer?',
        DateTime.now().add(Duration(minutes: 10)), lunchBot));
    var messagingStyle = MessagingStyleInformation(me,
        groupConversation: true,
        conversationTitle: 'Team lunch',
        htmlFormatContent: true,
        htmlFormatTitle: true,
        messages: messages);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'message channel id',
        'message channel name',
        'message channel description',
        style: AndroidNotificationStyle.Messaging,
        styleInformation: messagingStyle);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'message title', 'message body', platformChannelSpecifics);

    // wait 10 seconds and add another message to simulate another response
    await Future.delayed(Duration(seconds: 10), () async {
      messages.add(
          Message('Thai', DateTime.now().add(Duration(minutes: 11)), null));
      await flutterLocalNotificationsPlugin.show(
          0, 'message title', 'message body', platformChannelSpecifics);
    });
  }

  Future<void> _showGroupedNotifications() async {
    var groupKey = 'com.android.example.WORK_EMAIL';
    var groupChannelId = 'grouped channel id';
    var groupChannelName = 'grouped channel name';
    var groupChannelDescription = 'grouped channel description';
    // example based on https://developer.android.com/training/notify-user/group.html
    var firstNotificationAndroidSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
    var firstNotificationPlatformSpecifics =
        NotificationDetails(firstNotificationAndroidSpecifics, null);
    await flutterLocalNotificationsPlugin.show(1, 'Alex Faarborg',
        'You will not believe...', firstNotificationPlatformSpecifics);
    var secondNotificationAndroidSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
    var secondNotificationPlatformSpecifics =
        NotificationDetails(secondNotificationAndroidSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        2,
        'Jeff Chang',
        'Please join us to celebrate the...',
        secondNotificationPlatformSpecifics);

    // create the summary notification to support older devices that pre-date Android 7.0 (API level 24).
    // this is required is regardless of which versions of Android your application is going to support
    var lines = List<String>();
    lines.add('Alex Faarborg  Check this out');
    lines.add('Jeff Chang    Launch Party');
    var inboxStyleInformation = InboxStyleInformation(lines,
        contentTitle: '2 messages', summaryText: 'janedoe@example.com');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        style: AndroidNotificationStyle.Inbox,
        styleInformation: inboxStyleInformation,
        groupKey: groupKey,
        setAsGroupSummary: true);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        3, 'Attention', 'Two messages', platformChannelSpecifics);
  }

  Future<void> _checkPendingNotificationRequests() async {
    var pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      debugPrint(
          'pending notification: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}, body: ${pendingNotificationRequest.body}, payload: ${pendingNotificationRequest.payload}]');
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              '${pendingNotificationRequests.length} pending notification requests'),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotificationsWithActions() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'notification with actions title',
      'notification with actions body',
      platformChannelSpecifics,
      actions: [
        NotificationAction(
          icon: 'baseline_play_arrow_black_18dp',
          title: 'Play',
          actionKey: 'PLAY',
          extras: {'extra1': 'play_extra'},
        ),
        NotificationAction(
          icon: 'baseline_pause_black_18dp',
          title: 'Pause',
          actionKey: 'PAUSE',
          extras: {'extra2': 'pause_extra'},
        ),
        NotificationAction(
          icon: 'baseline_stop_black_18dp',
          title: 'Stop',
          actionKey: 'STOP',
        ),
      ],
    );
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _showOngoingNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ongoing: true,
        autoCancel: false);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'ongoing notification title',
        'ongoing notification body', platformChannelSpecifics);
  }

  Future<void> _repeatNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeating channel id',
        'repeating channel name',
        'repeating description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.EveryMinute, platformChannelSpecifics);
  }

  Future<void> _showDailyAtTime() async {
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'show daily title',
        'Daily notification shown at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
        time,
        platformChannelSpecifics);
  }

  Future<void> _showWeeklyAtDayAndTime() async {
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'show weekly channel id',
        'show weekly channel name',
        'show weekly description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'show weekly title',
        'Weekly notification shown on Monday at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
        Day.Monday,
        time,
        platformChannelSpecifics);
  }

  Future<void> _showNotificationWithNoBadge() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'no badge channel', 'no badge name', 'no badge description',
        channelShowBadge: false,
        importance: Importance.Max,
        priority: Priority.High,
        onlyAlertOnce: true);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'no badge title', 'no badge body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showProgressNotification() async {
    var maxProgress = 5;
    for (var i = 0; i <= maxProgress; i++) {
      await Future.delayed(Duration(seconds: 1), () async {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'progress channel',
            'progress channel',
            'progress channel description',
            channelShowBadge: false,
            importance: Importance.Max,
            priority: Priority.High,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: i);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0,
            'progress notification title',
            'progress notification body',
            platformChannelSpecifics,
            payload: 'item x');
      });
    }
  }

  Future<void> _showIndeterminateProgressNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'indeterminate progress channel',
        'indeterminate progress channel',
        'indeterminate progress channel description',
        channelShowBadge: false,
        importance: Importance.Max,
        priority: Priority.High,
        onlyAlertOnce: true,
        showProgress: true,
        indeterminate: true);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'indeterminate progress notification title',
        'indeterminate progress notification body',
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithUpdatedChannelDescription() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        'your updated channel description',
        importance: Importance.Max,
        priority: Priority.High,
        channelAction: AndroidNotificationChannelAction.Update);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'updated notification channel',
        'check settings to see updated channel description',
        platformChannelSpecifics,
        payload: 'item x');
  }

  String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }

  void onNotificationActionTapped(NotificationActionTappedPayload payload) {
    debugPrint("onNotificationActionTapped extras: ${payload.extras}");

    setState(() {
      lastTappedAction = payload.actionKey;
    });
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );
            },
          )
        ],
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
