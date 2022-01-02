import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_example/navigation_event_listener.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String iosNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String iosNotificationCategoryPlain = 'plainCategory';

void notificationTapBackground(NotificationActionDetails details) {
  print(
      'notification(${details.id}) action tapped: ${details.actionId} with payload: ${details.payload}');
  if (details.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${details.input}');
  }

  final SendPort? send = IsolateNameServer.lookupPortByName(portName);
  send?.send(details);
}

/// IMPORTANT: running the following code on its own won't work as there is
/// setup required for each platform head project.
///
/// Please download the complete example app from the GitHub repository where
/// all the setup has been done
Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = HomePage.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    initialRoute = SecondPage.routeName;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      iosNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
          options: const <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
    ),
    DarwinNotificationCategory(
      iosNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationSubject.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    notificationCategories: darwinNotificationCategories,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
    },
    backgroundHandler: notificationTapBackground,
  );
  runApp(
    MaterialApp(
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        HomePage.routeName: (_) => HomePage(notificationAppLaunchDetails),
        SecondPage.routeName: (_) => SecondPage(selectedNotificationPayload)
      },
    ),
  );
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      );
}

class HomePage extends StatefulWidget {
  const HomePage(
    this.notificationAppLaunchDetails, {
    Key? key,
  }) : super(key: key);

  static const String routeName = '/';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SecondPage(payload),
      ));
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: NavigationEventListener(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Text(
                          'Tap on a notification when it appears to trigger'
                          ' navigation'),
                    ),
                    _InfoValueString(
                      title: 'Did notification launch app?',
                      value: widget.didNotificationLaunchApp,
                    ),
                    if (widget.didNotificationLaunchApp)
                      _InfoValueString(
                        title: 'Launch notification payload:',
                        value: widget.notificationAppLaunchDetails!.payload,
                      ),
                    PaddedElevatedButton(
                      buttonText: 'Show plain notification with payload',
                      onPressed: () async {
                        await _showNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show plain notification that has no title with '
                          'payload',
                      onPressed: () async {
                        await _showNotificationWithNoTitle();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show plain notification that has no body with '
                          'payload',
                      onPressed: () async {
                        await _showNotificationWithNoBody();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with custom sound',
                      onPressed: () async {
                        await _showNotificationCustomSound();
                      },
                    ),
                    if (kIsWeb || !Platform.isLinux) ...<Widget>[
                      PaddedElevatedButton(
                        buttonText:
                            'Schedule notification to appear in 5 seconds '
                            'based on local time zone',
                        onPressed: () async {
                          await _zonedScheduleNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Repeat notification every minute',
                        onPressed: () async {
                          await _repeatNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Schedule daily 10:00:00 am notification in your '
                            'local time zone',
                        onPressed: () async {
                          await _scheduleDailyTenAMNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Schedule daily 10:00:00 am notification in your '
                            "local time zone using last year's date",
                        onPressed: () async {
                          await _scheduleDailyTenAMLastYearNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Schedule weekly 10:00:00 am notification in your '
                            'local time zone',
                        onPressed: () async {
                          await _scheduleWeeklyTenAMNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Schedule weekly Monday 10:00:00 am notification '
                            'in your local time zone',
                        onPressed: () async {
                          await _scheduleWeeklyMondayTenAMNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Check pending notifications',
                        onPressed: () async {
                          await _checkPendingNotificationRequests();
                        },
                      ),
                    ],
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule monthly Monday 10:00:00 am notification in '
                          'your local time zone',
                      onPressed: () async {
                        await _scheduleMonthlyMondayTenAMNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule yearly Monday 10:00:00 am notification in '
                          'your local time zone',
                      onPressed: () async {
                        await _scheduleYearlyMondayTenAMNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with no sound',
                      onPressed: () async {
                        await _showNotificationWithNoSound();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Cancel latest notification',
                      onPressed: () async {
                        await _cancelNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Cancel all notifications',
                      onPressed: () async {
                        await _cancelAllNotifications();
                      },
                    ),
                    const Divider(),
                    const Text(
                      'Notifications with actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with plain actions',
                      onPressed: () async {
                        await _showNotificationWithActions();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with text actions',
                      onPressed: () async {
                        await _showNotificationWithTextAction();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with text choice',
                      onPressed: () async {
                        await _showNotificationWithTextChoice();
                      },
                    ),
                    const Divider(),
                    if (Platform.isAndroid) ...<Widget>[
                      const Text(
                        'Android-specific examples',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Check if notifications are enabled for this app',
                        onPressed: _areNotifcationsEnabledOnAndroid,
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show plain notification with payload and update '
                            'channel description',
                        onPressed: () async {
                          await _showNotificationUpdateChannelDescription();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show plain notification as public on every '
                            'lockscreen',
                        onPressed: () async {
                          await _showPublicNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show notification with custom vibration pattern, '
                            'red LED and red icon',
                        onPressed: () async {
                          await _showNotificationCustomVibrationIconLed();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification using Android Uri sound',
                        onPressed: () async {
                          await _showSoundUriNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show notification that times out after 3 seconds',
                        onPressed: () async {
                          await _showTimeoutNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show insistent notification',
                        onPressed: () async {
                          await _showInsistentNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show big picture notification using local images',
                        onPressed: () async {
                          await _showBigPictureNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show big picture notification using base64 String '
                            'for images',
                        onPressed: () async {
                          await _showBigPictureNotificationBase64();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show big picture notification using URLs for '
                            'Images',
                        onPressed: () async {
                          await _showBigPictureNotificationURL();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show big picture notification, hide large icon '
                            'on expand',
                        onPressed: () async {
                          await _showBigPictureNotificationHiddenLargeIcon();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show media notification',
                        onPressed: () async {
                          await _showNotificationMediaStyle();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show big text notification',
                        onPressed: () async {
                          await _showBigTextNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show inbox notification',
                        onPressed: () async {
                          await _showInboxNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show messaging notification',
                        onPressed: () async {
                          await _showMessagingNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show grouped notifications',
                        onPressed: () async {
                          await _showGroupedNotifications();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with tag',
                        onPressed: () async {
                          await _showNotificationWithTag();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Cancel notification with tag',
                        onPressed: () async {
                          await _cancelNotificationWithTag();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show ongoing notification',
                        onPressed: () async {
                          await _showOngoingNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show notification with no badge, alert only once',
                        onPressed: () async {
                          await _showNotificationWithNoBadge();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText:
                            'Show progress notification - updates every second',
                        onPressed: () async {
                          await _showProgressNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show indeterminate progress notification',
                        onPressed: () async {
                          await _showIndeterminateProgressNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification without timestamp',
                        onPressed: () async {
                          await _showNotificationWithoutTimestamp();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with custom timestamp',
                        onPressed: () async {
                          await _showNotificationWithCustomTimestamp();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with custom sub-text',
                        onPressed: () async {
                          await _showNotificationWithCustomSubText();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with chronometer',
                        onPressed: () async {
                          await _showNotificationWithChronometer();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show full-screen notification',
                        onPressed: () async {
                          await _showFullScreenNotification();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Create grouped notification channels',
                        onPressed: () async {
                          await _createNotificationChannelGroup();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Delete notification channel group',
                        onPressed: () async {
                          await _deleteNotificationChannelGroup();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Create notification channel',
                        onPressed: () async {
                          await _createNotificationChannel();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Delete notification channel',
                        onPressed: () async {
                          await _deleteNotificationChannel();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Get notification channels',
                        onPressed: () async {
                          await _getNotificationChannels();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Get active notifications',
                        onPressed: () async {
                          await _getActiveNotifications();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Start foreground service',
                        onPressed: () async {
                          await _startForegroundService();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Stop foreground service',
                        onPressed: () async {
                          await _stopForegroundService();
                        },
                      ),
                    ],
                    if (!kIsWeb &&
                        (Platform.isIOS || Platform.isMacOS)) ...<Widget>[
                      const Text(
                        'iOS and macOS-specific examples',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with subtitle',
                        onPressed: () async {
                          await _showNotificationWithSubtitle();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with icon badge',
                        onPressed: () async {
                          await _showNotificationWithIconBadge();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with attachment',
                        onPressed: () async {
                          await _showNotificationWithAttachment();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notifications with thread identifier',
                        onPressed: () async {
                          await _showNotificationsWithThreadIdentifier();
                        },
                      ),
                    ],
                    if (!kIsWeb && Platform.isLinux) ...<Widget>[
                      const Text(
                        'Linux-specific examples',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FutureBuilder<LinuxServerCapabilities>(
                        future: getLinuxCapabilities(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<LinuxServerCapabilities> snapshot,
                        ) {
                          if (snapshot.hasData) {
                            final LinuxServerCapabilities caps = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Capabilities of the current system:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoValueString(
                                    title: 'Body text:',
                                    value: caps.body,
                                  ),
                                  _InfoValueString(
                                    title: 'Hyperlinks in body text:',
                                    value: caps.bodyHyperlinks,
                                  ),
                                  _InfoValueString(
                                    title: 'Images in body:',
                                    value: caps.bodyImages,
                                  ),
                                  _InfoValueString(
                                    title: 'Markup in the body text:',
                                    value: caps.bodyMarkup,
                                  ),
                                  _InfoValueString(
                                    title: 'Animated icons:',
                                    value: caps.iconMulti,
                                  ),
                                  _InfoValueString(
                                    title: 'Static icons:',
                                    value: caps.iconStatic,
                                  ),
                                  _InfoValueString(
                                    title: 'Notification persistence:',
                                    value: caps.persistence,
                                  ),
                                  _InfoValueString(
                                    title: 'Sound:',
                                    value: caps.sound,
                                  ),
                                  _InfoValueString(
                                    title: 'Other capabilities:',
                                    value: caps.otherCapabilities,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with body markup',
                        onPressed: () async {
                          await _showLinuxNotificationWithBodyMarkup();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with category',
                        onPressed: () async {
                          await _showLinuxNotificationWithCategory();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with byte data icon',
                        onPressed: () async {
                          await _showLinuxNotificationWithByteDataIcon();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with theme icon',
                        onPressed: () async {
                          await _showLinuxNotificationWithThemeIcon();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with theme sound',
                        onPressed: () async {
                          await _showLinuxNotificationWithThemeSound();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with critical urgency',
                        onPressed: () async {
                          await _showLinuxNotificationWithCriticalUrgency();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification with timeout',
                        onPressed: () async {
                          await _showLinuxNotificationWithTimeout();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Suppress notification sound',
                        onPressed: () async {
                          await _showLinuxNotificationSuppressSound();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Transient notification',
                        onPressed: () async {
                          await _showLinuxNotificationTransient();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Resident notification',
                        onPressed: () async {
                          await _showLinuxNotificationResident();
                        },
                      ),
                      PaddedElevatedButton(
                        buttonText: 'Show notification on '
                            'different screen location',
                        onPressed: () async {
                          await _showLinuxNotificationDifferentLocation();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithActions() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'id_1',
          'Action 1',
          icon: DrawableResourceAndroidBitmap('food'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'id_2',
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('secondary_icon'),
        ),
        AndroidNotificationAction(
          navigationActionId,
          'Action 3',
          icon: DrawableResourceAndroidBitmap('secondary_icon'),

          // By default, Android plugin will dismiss the notification when the
          // user tapped on a action (this mimics the behavior on iOS).
          cancelNotification: false,
        ),
      ],
    );

    const IOSNotificationDetails iosNotificationDetails =
        IOSNotificationDetails(
      categoryIdentifier: iosNotificationCategoryPlain,
    );

    const MacOSNotificationDetails macOSNotificationDetails =
        MacOSNotificationDetails(
      categoryIdentifier: iosNotificationCategoryPlain,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails,
      macOS: macOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item z');
  }

  Future<void> _showNotificationWithTextAction() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'text_id_1',
          'Enter Text',
          icon: DrawableResourceAndroidBitmap('food'),
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(
              label: 'Enter a message',
            ),
          ],
        ),
      ],
    );

    const IOSNotificationDetails iosNotificationDetails =
        IOSNotificationDetails(
      categoryIdentifier: iosNotificationCategoryText,
    );

    const MacOSNotificationDetails macOSNotificationDetails =
        MacOSNotificationDetails(
      categoryIdentifier: iosNotificationCategoryText,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails,
      macOS: macOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(id++, 'Text Input Notification',
        'Expand to see input action', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithTextChoice() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'text_id_2',
          'Action 2',
          icon: DrawableResourceAndroidBitmap('food'),
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(
              choices: <String>['ABC', 'DEF'],
              allowFreeFormInput: false,
            ),
          ],
          contextual: true,
        ),
      ],
    );

    const IOSNotificationDetails iosNotificationDetails =
        IOSNotificationDetails(
      categoryIdentifier: iosNotificationCategoryText,
    );
    const MacOSNotificationDetails macOSNotificationDetails =
        MacOSNotificationDetails(
      categoryIdentifier: iosNotificationCategoryText,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails,
      macOS: macOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showFullScreenNotification() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Turn off your screen'),
        content: const Text(
            'to see the full-screen intent in 5 seconds, press OK and TURN '
            'OFF your screen'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                  0,
                  'scheduled title',
                  'scheduled body',
                  tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
                  const NotificationDetails(
                      android: AndroidNotificationDetails(
                          'full screen channel id', 'full screen channel name',
                          channelDescription: 'full screen channel description',
                          priority: Priority.high,
                          importance: Importance.high,
                          fullScreenIntent: true)),
                  androidAllowWhileIdle: true,
                  uiLocalNotificationDateInterpretation:
                      UILocalNotificationDateInterpretation.absoluteTime);

              Navigator.pop(context);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _showNotificationWithNoBody() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', null, platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithNoTitle() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
        id++, null, 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(--id);
  }

  Future<void> _cancelNotificationWithTag() async {
    await flutterLocalNotificationsPlugin.cancel(--id, tag: 'tag');
  }

  Future<void> _showNotificationCustomSound() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      channelDescription: 'your other channel description',
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
    );
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring_board.aiff');
    const MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(sound: 'slow_spring_board.aiff');
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      sound: AssetsLinuxSound('sound/slow_spring_board.mp3'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: macOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'custom sound notification title',
      'custom sound notification body',
      platformChannelSpecifics,
    );
  }

  Future<void> _showNotificationCustomVibrationIconLed() async {
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'other custom channel id', 'other custom channel name',
            channelDescription: 'other custom channel description',
            icon: 'secondary_icon',
            largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
            vibrationPattern: vibrationPattern,
            enableLights: true,
            color: const Color.fromARGB(255, 255, 0, 0),
            ledColor: const Color.fromARGB(255, 255, 0, 0),
            ledOnMs: 1000,
            ledOffMs: 500);

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'title of notification with custom vibration pattern, LED and icon',
        'body of notification with custom vibration pattern, LED and icon',
        platformChannelSpecifics);
  }

  Future<void> _zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _showNotificationWithNoSound() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('silent channel id', 'silent channel name',
            channelDescription: 'silent channel description',
            playSound: false,
            styleInformation: DefaultStyleInformation(true, true));
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentSound: false);
    const MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(presentSound: false);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
        macOS: macOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, '<b>silent</b> title',
        '<b>silent</b> body', platformChannelSpecifics);
  }

  Future<void> _showSoundUriNotification() async {
    /// this calls a method over a platform channel implemented within the
    /// example app to return the Uri for the default alarm sound and uses
    /// as the notification sound
    final String? alarmUri = await platform.invokeMethod<String>('getAlarmUri');
    final UriAndroidNotificationSound uriSound =
        UriAndroidNotificationSound(alarmUri!);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('uri channel id', 'uri channel name',
            channelDescription: 'uri channel description',
            sound: uriSound,
            styleInformation: const DefaultStyleInformation(true, true));
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'uri sound title', 'uri sound body', platformChannelSpecifics);
  }

  Future<void> _showTimeoutNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('silent channel id', 'silent channel name',
            channelDescription: 'silent channel description',
            timeoutAfter: 3000,
            styleInformation: DefaultStyleInformation(true, true));
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, 'timeout notification',
        'Times out after 3 seconds', platformChannelSpecifics);
  }

  Future<void> _showInsistentNotification() async {
    // This value is from: https://developer.android.com/reference/android/app/Notification.html#FLAG_INSISTENT
    const int insistentFlag = 4;
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            additionalFlags: Int32List.fromList(<int>[insistentFlag]));
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'insistent title', 'insistent body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> _showBigPictureNotification() async {
    final String largeIconPath = await _downloadAndSaveFile(
        'https://via.placeholder.com/48x48', 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/400x800', 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'big text channel id', 'big text channel name',
            channelDescription: 'big text channel description',
            styleInformation: bigPictureStyleInformation);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<String> _base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }

  Future<void> _showBigPictureNotificationBase64() async {
    final String largeIcon =
        await _base64encodedImage('https://via.placeholder.com/48x48');
    final String bigPicture =
        await _base64encodedImage('https://via.placeholder.com/400x800');

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
            ByteArrayAndroidBitmap.fromBase64String(
                bigPicture), //Base64AndroidBitmap(bigPicture),
            largeIcon: ByteArrayAndroidBitmap.fromBase64String(largeIcon),
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'big text channel id', 'big text channel name',
            channelDescription: 'big text channel description',
            styleInformation: bigPictureStyleInformation);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<void> _showBigPictureNotificationURL() async {
    final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(
        await _getByteArrayFromUrl('https://via.placeholder.com/48x48'));
    final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
        await _getByteArrayFromUrl('https://via.placeholder.com/400x800'));

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(bigPicture,
            largeIcon: largeIcon,
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'big text channel id', 'big text channel name',
            channelDescription: 'big text channel description',
            styleInformation: bigPictureStyleInformation);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<void> _showBigPictureNotificationHiddenLargeIcon() async {
    final String largeIconPath = await _downloadAndSaveFile(
        'https://via.placeholder.com/48x48', 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/400x800', 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
            hideExpandedLargeIcon: true,
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'big text channel id', 'big text channel name',
            channelDescription: 'big text channel description',
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            styleInformation: bigPictureStyleInformation);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<void> _showNotificationMediaStyle() async {
    final String largeIconPath = await _downloadAndSaveFile(
        'https://via.placeholder.com/128x128/00FF00/000000', 'largeIcon');
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'media channel id',
      'media channel name',
      channelDescription: 'media channel description',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: const MediaStyleInformation(),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, 'notification title',
        'notification body', platformChannelSpecifics);
  }

  Future<void> _showBigTextNotification() async {
    const BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      'Lorem <i>ipsum dolor sit</i> amet, consectetur <b>adipiscing elit</b>, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      htmlFormatBigText: true,
      contentTitle: 'overridden <b>big</b> content title',
      htmlFormatContentTitle: true,
      summaryText: 'summary <i>text</i>',
      htmlFormatSummaryText: true,
    );
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'big text channel id', 'big text channel name',
            channelDescription: 'big text channel description',
            styleInformation: bigTextStyleInformation);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'big text title', 'silent body', platformChannelSpecifics);
  }

  Future<void> _showInboxNotification() async {
    final List<String> lines = <String>['line <b>1</b>', 'line <i>2</i>'];
    final InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        lines,
        htmlFormatLines: true,
        contentTitle: 'overridden <b>inbox</b> context title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('inbox channel id', 'inboxchannel name',
            channelDescription: 'inbox channel description',
            styleInformation: inboxStyleInformation);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'inbox title', 'inbox body', platformChannelSpecifics);
  }

  Future<void> _showMessagingNotification() async {
    // use a platform channel to resolve an Android drawable resource to a URI.
    // This is NOT part of the notifications plugin. Calls made over this
    /// channel is handled by the app
    final String? imageUri =
        await platform.invokeMethod('drawableToUri', 'food');

    /// First two person objects will use icons that part of the Android app's
    /// drawable resources
    const Person me = Person(
      name: 'Me',
      key: '1',
      uri: 'tel:1234567890',
      icon: DrawableResourceAndroidIcon('me'),
    );
    const Person coworker = Person(
      name: 'Coworker',
      key: '2',
      uri: 'tel:9876543210',
      icon: FlutterBitmapAssetAndroidIcon('icons/coworker.png'),
    );
    // download the icon that would be use for the lunch bot person
    final String largeIconPath = await _downloadAndSaveFile(
        'https://via.placeholder.com/48x48', 'largeIcon');
    // this person object will use an icon that was downloaded
    final Person lunchBot = Person(
      name: 'Lunch bot',
      key: 'bot',
      bot: true,
      icon: BitmapFilePathAndroidIcon(largeIconPath),
    );
    final Person chef = Person(
        name: 'Master Chef',
        key: '3',
        uri: 'tel:111222333444',
        icon: ByteArrayAndroidIcon.fromBase64String(
            await _base64encodedImage('https://placekitten.com/48/48')));

    final List<Message> messages = <Message>[
      Message('Hi', DateTime.now(), null),
      Message("What's up?", DateTime.now().add(const Duration(minutes: 5)),
          coworker),
      Message('Lunch?', DateTime.now().add(const Duration(minutes: 10)), null,
          dataMimeType: 'image/png', dataUri: imageUri),
      Message('What kind of food would you prefer?',
          DateTime.now().add(const Duration(minutes: 10)), lunchBot),
      Message('You do not have time eat! Keep working!',
          DateTime.now().add(const Duration(minutes: 11)), chef),
    ];
    final MessagingStyleInformation messagingStyle = MessagingStyleInformation(
        me,
        groupConversation: true,
        conversationTitle: 'Team lunch',
        htmlFormatContent: true,
        htmlFormatTitle: true,
        messages: messages);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('message channel id', 'message channel name',
            channelDescription: 'message channel description',
            category: 'msg',
            styleInformation: messagingStyle);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'message title', 'message body', platformChannelSpecifics);

    // wait 10 seconds and add another message to simulate another response
    await Future<void>.delayed(const Duration(seconds: 10), () async {
      messages.add(Message("I'm so sorry!!! But I really like thai food ...",
          DateTime.now().add(const Duration(minutes: 11)), null));
      await flutterLocalNotificationsPlugin.show(
          id++, 'message title', 'message body', platformChannelSpecifics);
    });
  }

  Future<void> _showGroupedNotifications() async {
    const String groupKey = 'com.android.example.WORK_EMAIL';
    const String groupChannelId = 'grouped channel id';
    const String groupChannelName = 'grouped channel name';
    const String groupChannelDescription = 'grouped channel description';
    // example based on https://developer.android.com/training/notify-user/group.html
    const AndroidNotificationDetails firstNotificationAndroidSpecifics =
        AndroidNotificationDetails(groupChannelId, groupChannelName,
            channelDescription: groupChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: groupKey);
    const NotificationDetails firstNotificationPlatformSpecifics =
        NotificationDetails(android: firstNotificationAndroidSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, 'Alex Faarborg',
        'You will not believe...', firstNotificationPlatformSpecifics);
    const AndroidNotificationDetails secondNotificationAndroidSpecifics =
        AndroidNotificationDetails(groupChannelId, groupChannelName,
            channelDescription: groupChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: groupKey);
    const NotificationDetails secondNotificationPlatformSpecifics =
        NotificationDetails(android: secondNotificationAndroidSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'Jeff Chang',
        'Please join us to celebrate the...',
        secondNotificationPlatformSpecifics);

    // Create the summary notification to support older devices that pre-date
    /// Android 7.0 (API level 24).
    ///
    /// Recommended to create this regardless as the behaviour may vary as
    /// mentioned in https://developer.android.com/training/notify-user/group
    const List<String> lines = <String>[
      'Alex Faarborg  Check this out',
      'Jeff Chang    Launch Party'
    ];
    const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        lines,
        contentTitle: '2 messages',
        summaryText: 'janedoe@example.com');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(groupChannelId, groupChannelName,
            channelDescription: groupChannelDescription,
            styleInformation: inboxStyleInformation,
            groupKey: groupKey,
            setAsGroupSummary: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'Attention', 'Two messages', platformChannelSpecifics);
  }

  Future<void> _showNotificationWithTag() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            tag: 'tag');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
        id++, 'first notification', null, platformChannelSpecifics);
  }

  Future<void> _checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content:
            Text('${pendingNotificationRequests.length} pending notification '
                'requests'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _showOngoingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
            autoCancel: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'ongoing notification title',
        'ongoing notification body',
        platformChannelSpecifics);
  }

  Future<void> _repeatNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        id++,
        'repeating title',
        'repeating body',
        RepeatInterval.everyMinute,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'daily scheduled notification title',
        'daily scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id',
              'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  /// To test we don't validate past dates when using `matchDateTimeComponents`
  Future<void> _scheduleDailyTenAMLastYearNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'daily scheduled notification title',
        'daily scheduled notification body',
        _nextInstanceOfTenAMLastYear(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id',
              'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> _scheduleWeeklyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id',
              'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleWeeklyMondayTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id',
              'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleMonthlyMondayTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'monthly scheduled notification title',
        'monthly scheduled notification body',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('monthly notification channel id',
              'monthly notification channel name',
              channelDescription: 'monthly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
  }

  Future<void> _scheduleYearlyMondayTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'yearly scheduled notification title',
        'yearly scheduled notification body',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('yearly notification channel id',
              'yearly notification channel name',
              channelDescription: 'yearly notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTenAMLastYear() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(tz.local, now.year - 1, now.month, now.day, 10);
  }

  tz.TZDateTime _nextInstanceOfMondayTenAM() {
    tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _showNotificationWithNoBadge() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('no badge channel', 'no badge name',
            channelDescription: 'no badge description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'no badge title', 'no badge body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showProgressNotification() async {
    const int maxProgress = 5;
    for (int i = 0; i <= maxProgress; i++) {
      await Future<void>.delayed(const Duration(seconds: 1), () async {
        final AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails('progress channel', 'progress channel',
                channelDescription: 'progress channel description',
                channelShowBadge: false,
                importance: Importance.max,
                priority: Priority.high,
                onlyAlertOnce: true,
                showProgress: true,
                maxProgress: maxProgress,
                progress: i);
        final NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            id++,
            'progress notification title',
            'progress notification body',
            platformChannelSpecifics,
            payload: 'item x');
      });
    }
  }

  Future<void> _showIndeterminateProgressNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'indeterminate progress channel', 'indeterminate progress channel',
            channelDescription: 'indeterminate progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            indeterminate: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'indeterminate progress notification title',
        'indeterminate progress notification body',
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationUpdateChannelDescription() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your updated channel description',
            importance: Importance.max,
            priority: Priority.high,
            channelAction: AndroidNotificationChannelAction.update);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'updated notification channel',
        'check settings to see updated channel description',
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showPublicNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            visibility: NotificationVisibility.public);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'public notification title',
        'public notification body',
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithSubtitle() async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(subtitle: 'the subtitle');
    const MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(subtitle: 'the subtitle');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics, macOS: macOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'title of notification with a subtitle',
        'body of notification with a subtitle',
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithIconBadge() async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(badgeNumber: 1);
    const MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(badgeNumber: 1);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics, macOS: macOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'icon badge title', 'icon badge body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationsWithThreadIdentifier() async {
    NotificationDetails buildNotificationDetailsForThread(
      String threadIdentifier,
    ) {
      final IOSNotificationDetails iOSPlatformChannelSpecifics =
          IOSNotificationDetails(threadIdentifier: threadIdentifier);
      final MacOSNotificationDetails macOSPlatformChannelSpecifics =
          MacOSNotificationDetails(threadIdentifier: threadIdentifier);
      return NotificationDetails(
          iOS: iOSPlatformChannelSpecifics,
          macOS: macOSPlatformChannelSpecifics);
    }

    final NotificationDetails thread1PlatformChannelSpecifics =
        buildNotificationDetailsForThread('thread1');
    final NotificationDetails thread2PlatformChannelSpecifics =
        buildNotificationDetailsForThread('thread2');

    await flutterLocalNotificationsPlugin.show(id++, 'thread 1',
        'first notification', thread1PlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, 'thread 1',
        'second notification', thread1PlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, 'thread 1',
        'third notification', thread1PlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(id++, 'thread 2',
        'first notification', thread2PlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, 'thread 2',
        'second notification', thread2PlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id++, 'thread 2',
        'third notification', thread2PlatformChannelSpecifics);
  }

  Future<void> _showNotificationWithoutTimestamp() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithCustomTimestamp() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      when: DateTime.now().millisecondsSinceEpoch - 120 * 1000,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithCustomSubText() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      subText: 'custom subtext',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithChronometer() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      when: DateTime.now().millisecondsSinceEpoch - 120 * 1000,
      usesChronometer: true,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithAttachment() async {
    final String bigPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/600x200', 'bigPicture.jpg');
    final IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(attachments: <IOSNotificationAttachment>[
      IOSNotificationAttachment(bigPicturePath)
    ]);
    final MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(attachments: <MacOSNotificationAttachment>[
      MacOSNotificationAttachment(bigPicturePath)
    ]);
    final NotificationDetails notificationDetails = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics, macOS: macOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id++,
        'notification with attachment title',
        'notification with attachment body',
        notificationDetails);
  }

  Future<void> _createNotificationChannelGroup() async {
    const String channelGroupId = 'your channel group id';
    // create the group first
    const AndroidNotificationChannelGroup androidNotificationChannelGroup =
        AndroidNotificationChannelGroup(
            channelGroupId, 'your channel group name',
            description: 'your channel group description');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannelGroup(androidNotificationChannelGroup);

    // create channels associated with the group
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(const AndroidNotificationChannel(
            'grouped channel id 1', 'grouped channel name 1',
            description: 'grouped channel description 1',
            groupId: channelGroupId));

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(const AndroidNotificationChannel(
            'grouped channel id 2', 'grouped channel name 2',
            description: 'grouped channel description 2',
            groupId: channelGroupId));

    await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Text('Channel group with name '
                  '${androidNotificationChannelGroup.name} created'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<void> _deleteNotificationChannelGroup() async {
    const String channelGroupId = 'your channel group id';
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup(channelGroupId);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Channel group with id $channelGroupId deleted'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _startForegroundService() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.startForegroundService(1, 'plain title', 'plain body',
            notificationDetails: androidPlatformChannelSpecifics,
            payload: 'item x');
  }

  Future<void> _stopForegroundService() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.stopForegroundService();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'your channel id 2',
      'your channel name 2',
      description: 'your channel description 2',
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content:
                  Text('Channel with name ${androidNotificationChannel.name} '
                      'created'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<void> _areNotifcationsEnabledOnAndroid() async {
    final bool? areEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Text(areEnabled == null
                  ? 'ERROR: received null'
                  : (areEnabled
                      ? 'Notifications are enabled'
                      : 'Notifications are NOT enabled')),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<void> _deleteNotificationChannel() async {
    const String channelId = 'your channel id 2';
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Channel with id $channelId deleted'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _getActiveNotifications() async {
    final Widget activeNotificationsDialogContent =
        await _getActiveNotificationsDialogContent();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: activeNotificationsDialogContent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Widget> _getActiveNotificationsDialogContent() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (!(androidInfo.version.sdkInt >= 23)) {
      return const Text(
        '"getActiveNotifications" is available only for Android 6.0 or newer',
      );
    }

    try {
      final List<ActiveNotification>? activeNotifications =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getActiveNotifications();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Active Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.black),
          if (activeNotifications!.isEmpty)
            const Text('No active notifications'),
          if (activeNotifications.isNotEmpty)
            for (ActiveNotification activeNotification in activeNotifications)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'id: ${activeNotification.id}\n'
                    'channelId: ${activeNotification.channelId}\n'
                    'title: ${activeNotification.title}\n'
                    'body: ${activeNotification.body}',
                  ),
                  const Divider(color: Colors.black),
                ],
              ),
        ],
      );
    } on PlatformException catch (error) {
      return Text(
        'Error calling "getActiveNotifications"\n'
        'code: ${error.code}\n'
        'message: ${error.message}',
      );
    }
  }

  Future<void> _getNotificationChannels() async {
    final Widget notificationChannelsDialogContent =
        await _getNotificationChannelsDialogContent();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: notificationChannelsDialogContent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Widget> _getNotificationChannelsDialogContent() async {
    try {
      final List<AndroidNotificationChannel>? channels =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getNotificationChannels();

      return Container(
        width: double.maxFinite,
        child: ListView(
          children: <Widget>[
            const Text(
              'Notifications Channels',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.black),
            if (channels?.isEmpty ?? true)
              const Text('No notification channels')
            else
              for (AndroidNotificationChannel channel in channels!)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('id: ${channel.id}\n'
                        'name: ${channel.name}\n'
                        'description: ${channel.description}\n'
                        'groupId: ${channel.groupId}\n'
                        'importance: ${channel.importance.value}\n'
                        'playSound: ${channel.playSound}\n'
                        'sound: ${channel.sound?.sound}\n'
                        'enableVibration: ${channel.enableVibration}\n'
                        'vibrationPattern: ${channel.vibrationPattern}\n'
                        'showBadge: ${channel.showBadge}\n'
                        'enableLights: ${channel.enableLights}\n'
                        'ledColor: ${channel.ledColor}\n'),
                    const Divider(color: Colors.black),
                  ],
                ),
          ],
        ),
      );
    } on PlatformException catch (error) {
      return Text(
        'Error calling "getNotificationChannels"\n'
        'code: ${error.code}\n'
        'message: ${error.message}',
      );
    }
  }
}

Future<void> _showLinuxNotificationWithBodyMarkup() async {
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification with body markup',
    '<b>bold text</b>\n'
        '<i>italic text</i>\n'
        '<u>underline text</u>\n'
        'https://example.com\n'
        '<a href="https://example.com">example.com</a>',
    null,
  );
}

Future<void> _showLinuxNotificationWithCategory() async {
  final LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    category: LinuxNotificationCategory.emailArrived(),
  );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification with category',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationWithByteDataIcon() async {
  final ByteData assetIcon = await rootBundle.load(
    'icons/app_icon_density.png',
  );
  final image.Image? iconData = image.decodePng(
    assetIcon.buffer.asUint8List().toList(),
  );
  final Uint8List iconBytes = iconData!.getBytes();
  final LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    icon: ByteDataLinuxIcon(
      LinuxRawIconData(
        data: iconBytes,
        width: iconData.width,
        height: iconData.height,
        channels: 4, // The icon has an alpha channel
        hasAlpha: true,
      ),
    ),
  );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification with byte data icon',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationWithThemeIcon() async {
  final LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    icon: ThemeLinuxIcon('media-eject'),
  );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification with theme icon',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationWithThemeSound() async {
  final LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    sound: ThemeLinuxSound('message-new-email'),
  );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification with theme sound',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationWithCriticalUrgency() async {
  const LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    urgency: LinuxNotificationUrgency.critical,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification with critical urgency',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationWithTimeout() async {
  final LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    timeout: LinuxNotificationTimeout.fromDuration(
      const Duration(seconds: 1),
    ),
  );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification with timeout',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationSuppressSound() async {
  const LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    suppressSound: true,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'suppress notification sound',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationTransient() async {
  const LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    transient: true,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'transient notification',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationResident() async {
  const LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(
    resident: true,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'resident notification',
    null,
    platformChannelSpecifics,
  );
}

Future<void> _showLinuxNotificationDifferentLocation() async {
  const LinuxNotificationDetails linuxPlatformChannelSpecifics =
      LinuxNotificationDetails(location: LinuxNotificationLocation(10, 10));
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    linux: linuxPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'notification on different screen location',
    null,
    platformChannelSpecifics,
  );
}

Future<LinuxServerCapabilities> getLinuxCapabilities() =>
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            LinuxFlutterLocalNotificationsPlugin>()!
        .getCapabilities();

class SecondPage extends StatefulWidget {
  const SecondPage(
    this.payload, {
    Key? key,
  }) : super(key: key);

  static const String routeName = '/secondPage';

  final String? payload;

  @override
  State<StatefulWidget> createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  String? _payload;

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Second Screen with payload: ${_payload ?? ''}'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go back!'),
          ),
        ),
      );
}

class _InfoValueString extends StatelessWidget {
  const _InfoValueString({
    required this.title,
    required this.value,
    Key? key,
  }) : super(key: key);

  final String title;
  final Object? value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: '$title ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '$value',
              )
            ],
          ),
        ),
      );
}
