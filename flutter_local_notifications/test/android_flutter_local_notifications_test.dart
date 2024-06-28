// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/platform_specifics/android/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'utils/date_formatter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  group('Android', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'initialize') {
          return true;
        } else if (methodCall.method == 'pendingNotificationRequests') {
          return <Map<String, Object?>>[];
        } else if (methodCall.method == 'getActiveNotifications') {
          return <Map<String, Object?>>[];
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return null;
        }
        return null;
      });
    });

    tearDown(() {
      log.clear();
    });

    test('initialize', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'defaultIcon': 'app_icon',
        })
      ]);
    });

    test('show without Android-specific details', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      await flutterLocalNotificationsPlugin.show(
          1, 'notification title', 'notification body', null);
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object?>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': null,
          }));
    });

    test('show with Android actions', () async {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'action1',
            'Action 1',
            titleColor: Color.fromARGB(255, 0, 127, 16),
            contextual: true,
            showsUserInterface: true,
            allowGeneratedReplies: true,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            'action2',
            'Action 2',
            titleColor: Color.fromARGB(255, 0, 127, 16),
            inputs: <AndroidNotificationActionInput>[
              AndroidNotificationActionInput(
                choices: <String>['choice1', 'choice2'],
                label: 'Select something',
                allowedMimeTypes: <String>{'text/plain'},
              ),
            ],
          )
        ],
      );

      await flutterLocalNotificationsPlugin.show(
        1,
        'notification title',
        'notification body',
        const NotificationDetails(android: androidNotificationDetails),
      );
      expect(
        log.last,
        isMethodCall(
          'show',
          arguments: <String, Object?>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
              'actions': <Map<String, Object>>[
                <String, Object>{
                  'id': 'action1',
                  'title': 'Action 1',
                  'titleColorAlpha': 255,
                  'titleColorRed': 0,
                  'titleColorGreen': 127,
                  'titleColorBlue': 16,
                  'contextual': true,
                  'showsUserInterface': true,
                  'allowGeneratedReplies': true,
                  'inputs': <Object>[],
                  'cancelNotification': false
                },
                <String, Object>{
                  'id': 'action2',
                  'title': 'Action 2',
                  'titleColorAlpha': 255,
                  'titleColorRed': 0,
                  'titleColorGreen': 127,
                  'titleColorBlue': 16,
                  'contextual': false,
                  'showsUserInterface': false,
                  'allowGeneratedReplies': false,
                  'inputs': <Map<String, Object>>[
                    <String, Object>{
                      'choices': <String>['choice1', 'choice2'],
                      'allowFreeFormInput': true,
                      'label': 'Select something',
                      'allowedMimeType': <String>['text/plain']
                    }
                  ],
                  'cancelNotification': true,
                }
              ],
            },
          },
        ),
      );
    });

    test('show with default Android-specific details', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with default Android-specific details and additional flags',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('channelId', 'channelName',
              channelDescription: 'channelDescription',
              additionalFlags: Int32List.fromList(<int>[4, 32]));

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'additionalFlags': <int>[4, 32],
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test(
        'show with default Android-specific details with a timestamp specified',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final int timestamp = clock.now().millisecondsSinceEpoch;

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('channelId', 'channelName',
              channelDescription: 'channelDescription', when: timestamp);
      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': timestamp,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with default Android-specific details with a chronometer',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final int timestamp = clock.now().millisecondsSinceEpoch;

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('channelId', 'channelName',
              channelDescription: 'channelDescription',
              when: timestamp,
              usesChronometer: true);
      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': timestamp,
              'usesChronometer': true,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test(
        'show with default Android-specific details and custom sound from raw '
        'resource', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        sound: RawResourceAndroidNotificationSound('sound.mp3'),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'sound': 'sound.mp3',
              'soundSource': AndroidNotificationSoundSource.rawResource.index,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with default Android-specific details and custom sound from uri',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        sound: UriAndroidNotificationSound('uri'),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'sound': 'uri',
              'soundSource': AndroidNotificationSoundSource.uri.index,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with default Android-specific details and silent enabled',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        silent: true,
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': true,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test(
        'show with default Android-specific details and html formatted title and content/body',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: DefaultStyleInformation(true, true),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test(
        'show with default Android big picture style settings using a drawable '
        'resource', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: BigPictureStyleInformation(
          DrawableResourceAndroidBitmap('bigPictureDrawable'),
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.bigPicture.index,
              'styleInformation': <String, Object?>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'bigPicture': 'bigPictureDrawable',
                'bigPictureBitmapSource': AndroidBitmapSource.drawable.index,
                'contentTitle': null,
                'summaryText': null,
                'htmlFormatContentTitle': false,
                'htmlFormatSummaryText': false,
                'hideExpandedLargeIcon': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test(
        'show with non-default Android big picture style settings using a '
        'drawable resource', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: BigPictureStyleInformation(
          DrawableResourceAndroidBitmap('bigPictureDrawable'),
          contentTitle: 'contentTitle',
          summaryText: 'summaryText',
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
          largeIcon: DrawableResourceAndroidBitmap('largeDrawableIcon'),
          htmlFormatContent: true,
          htmlFormatTitle: true,
          hideExpandedLargeIcon: true,
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.bigPicture.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
                'bigPicture': 'bigPictureDrawable',
                'bigPictureBitmapSource': AndroidBitmapSource.drawable.index,
                'largeIcon': 'largeDrawableIcon',
                'largeIconBitmapSource': AndroidBitmapSource.drawable.index,
                'contentTitle': 'contentTitle',
                'summaryText': 'summaryText',
                'htmlFormatContentTitle': true,
                'htmlFormatSummaryText': true,
                'hideExpandedLargeIcon': true,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test(
        'show with default Android big picture style settings using a file '
        'path', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap('bigPictureFilePath'),
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.bigPicture.index,
              'styleInformation': <String, Object?>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'bigPicture': 'bigPictureFilePath',
                'bigPictureBitmapSource': AndroidBitmapSource.filePath.index,
                'contentTitle': null,
                'summaryText': null,
                'htmlFormatContentTitle': false,
                'htmlFormatSummaryText': false,
                'hideExpandedLargeIcon': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test(
        'show with non-default Android big picture style settings using a file '
        'path', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap('bigPictureFilePath'),
          contentTitle: 'contentTitle',
          summaryText: 'summaryText',
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
          largeIcon: FilePathAndroidBitmap('largeFilePathIcon'),
          htmlFormatContent: true,
          htmlFormatTitle: true,
          hideExpandedLargeIcon: true,
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.bigPicture.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
                'bigPicture': 'bigPictureFilePath',
                'bigPictureBitmapSource': AndroidBitmapSource.filePath.index,
                'largeIcon': 'largeFilePathIcon',
                'largeIconBitmapSource': AndroidBitmapSource.filePath.index,
                'contentTitle': 'contentTitle',
                'summaryText': 'summaryText',
                'htmlFormatContentTitle': true,
                'htmlFormatSummaryText': true,
                'hideExpandedLargeIcon': true,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with default Android inbox style settings', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: InboxStyleInformation(
          <String>['line1'],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.inbox.index,
              'styleInformation': <String, Object?>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'lines': <String>['line1'],
                'contentTitle': null,
                'summaryText': null,
                'htmlFormatContentTitle': false,
                'htmlFormatSummaryText': false,
                'htmlFormatLines': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with non-default Android inbox style settings', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: InboxStyleInformation(
          <String>['line1'],
          htmlFormatLines: true,
          htmlFormatContent: true,
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
          htmlFormatTitle: true,
          contentTitle: 'contentTitle',
          summaryText: 'summaryText',
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.inbox.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
                'lines': <String>['line1'],
                'contentTitle': 'contentTitle',
                'summaryText': 'summaryText',
                'htmlFormatContentTitle': true,
                'htmlFormatSummaryText': true,
                'htmlFormatLines': true,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with default Android media style settings', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: MediaStyleInformation(),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.media.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with non-default Android media style settings', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: MediaStyleInformation(
          htmlFormatTitle: true,
          htmlFormatContent: true,
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          const NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.media.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with default Android messaging style settings', () async {
      final DateTime messageDateTime = clock.now();
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: MessagingStyleInformation(
          const Person(name: 'name'),
          messages: <Message>[
            Message(
              'message 1',
              messageDateTime,
              null,
            ),
          ],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.messaging.index,
              'styleInformation': <String, Object?>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'person': <String, Object?>{
                  'bot': false,
                  'important': false,
                  'key': null,
                  'name': 'name',
                  'uri': null,
                },
                'conversationTitle': null,
                'groupConversation': null,
                'messages': <Map<String, Object?>>[
                  <String, Object?>{
                    'text': 'message 1',
                    'timestamp': messageDateTime.millisecondsSinceEpoch,
                    'person': null,
                    'dataMimeType': null,
                    'dataUri': null,
                  }
                ],
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    test('show with non-default Android messaging style settings', () async {
      final DateTime messageDateTime = clock.now();
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        styleInformation: MessagingStyleInformation(
          const Person(
            bot: true,
            icon: DrawableResourceAndroidIcon('drawablePersonIcon'),
            important: true,
            key: 'key',
            name: 'name',
            uri: 'uri',
          ),
          conversationTitle: 'conversationTitle',
          groupConversation: true,
          messages: <Message>[
            Message(
              'message 1',
              messageDateTime,
              null,
              dataMimeType: 'dataMimeType',
              dataUri: 'dataUri',
            ),
          ],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(android: androidNotificationDetails));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
                  AndroidNotificationChannelAction.createIfNotExists.index,
              'importance': Importance.defaultImportance.value,
              'priority': Priority.defaultPriority.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': false,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': false,
              'silent': false,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
              'chronometerCountDown': false,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'fullScreenIntent': false,
              'shortcutId': null,
              'subText': null,
              'style': AndroidNotificationStyle.messaging.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'person': <String, Object>{
                  'bot': true,
                  'important': true,
                  'key': 'key',
                  'name': 'name',
                  'uri': 'uri',
                  'icon': 'drawablePersonIcon',
                  'iconSource': AndroidIconSource.drawableResource.index,
                },
                'conversationTitle': 'conversationTitle',
                'groupConversation': true,
                'messages': <Map<String, Object?>>[
                  <String, Object?>{
                    'text': 'message 1',
                    'timestamp': messageDateTime.millisecondsSinceEpoch,
                    'person': null,
                    'dataMimeType': 'dataMimeType',
                    'dataUri': 'dataUri',
                  }
                ],
              },
              'tag': null,
              'colorized': false,
              'number': null,
              'audioAttributesUsage': 5,
            },
          }));
    });

    group('periodicallyShow', () {
      final DateTime now = DateTime(2020, 10, 9);
      for (final RepeatInterval repeatInterval in RepeatInterval.values) {
        test('$repeatInterval', () async {
          await withClock(Clock.fixed(now), () async {
            const AndroidInitializationSettings androidInitializationSettings =
                AndroidInitializationSettings('app_icon');
            const InitializationSettings initializationSettings =
                InitializationSettings(android: androidInitializationSettings);
            await flutterLocalNotificationsPlugin
                .initialize(initializationSettings);

            const AndroidNotificationDetails androidNotificationDetails =
                AndroidNotificationDetails('channelId', 'channelName',
                    channelDescription: 'channelDescription');
            await flutterLocalNotificationsPlugin.periodicallyShow(
              1,
              'notification title',
              'notification body',
              repeatInterval,
              const NotificationDetails(android: androidNotificationDetails),
            );

            expect(
                log.last,
                isMethodCall('periodicallyShow', arguments: <String, Object>{
                  'id': 1,
                  'title': 'notification title',
                  'body': 'notification body',
                  'payload': '',
                  'calledAt': now.millisecondsSinceEpoch,
                  'repeatInterval': repeatInterval.index,
                  'platformSpecifics': <String, Object?>{
                    'scheduleMode': 'exact',
                    'icon': null,
                    'channelId': 'channelId',
                    'channelName': 'channelName',
                    'channelDescription': 'channelDescription',
                    'channelShowBadge': true,
                    'channelAction': AndroidNotificationChannelAction
                        .createIfNotExists.index,
                    'importance': Importance.defaultImportance.value,
                    'priority': Priority.defaultPriority.value,
                    'playSound': true,
                    'enableVibration': true,
                    'vibrationPattern': null,
                    'groupKey': null,
                    'setAsGroupSummary': false,
                    'groupAlertBehavior': GroupAlertBehavior.all.index,
                    'autoCancel': true,
                    'ongoing': false,
                    'silent': false,
                    'colorAlpha': null,
                    'colorRed': null,
                    'colorGreen': null,
                    'colorBlue': null,
                    'onlyAlertOnce': false,
                    'showWhen': true,
                    'when': null,
                    'usesChronometer': false,
                    'chronometerCountDown': false,
                    'showProgress': false,
                    'maxProgress': 0,
                    'progress': 0,
                    'indeterminate': false,
                    'enableLights': false,
                    'ledColorAlpha': null,
                    'ledColorRed': null,
                    'ledColorGreen': null,
                    'ledColorBlue': null,
                    'ledOnMs': null,
                    'ledOffMs': null,
                    'ticker': null,
                    'visibility': null,
                    'timeoutAfter': null,
                    'category': null,
                    'additionalFlags': null,
                    'fullScreenIntent': false,
                    'shortcutId': null,
                    'subText': null,
                    'style': AndroidNotificationStyle.defaultStyle.index,
                    'styleInformation': <String, Object>{
                      'htmlFormatContent': false,
                      'htmlFormatTitle': false,
                    },
                    'tag': null,
                    'colorized': false,
                    'number': null,
                    'audioAttributesUsage': 5,
                  },
                }));
          });
        });
      }
    });

    group('periodicallyShowWithDuration', () {
      final DateTime now = DateTime(2023, 12, 29);

      const Duration thirtySeconds = Duration(seconds: 30);
      test('$thirtySeconds', () async {
        await withClock(Clock.fixed(now), () async {
          const AndroidInitializationSettings androidInitializationSettings =
              AndroidInitializationSettings('app_icon');
          const InitializationSettings initializationSettings =
              InitializationSettings(android: androidInitializationSettings);
          await flutterLocalNotificationsPlugin
              .initialize(initializationSettings);

          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails('channelId', 'channelName',
                  channelDescription: 'channelDescription');

          expect(
              () async => await flutterLocalNotificationsPlugin
                      .periodicallyShowWithDuration(
                    1,
                    'notification title',
                    'notification body',
                    thirtySeconds,
                    const NotificationDetails(
                        android: androidNotificationDetails),
                  ),
              throwsA(isA<ArgumentError>()));
        });
      });

      final List<Duration> repeatDurationIntervals = <Duration>[
        const Duration(minutes: 1),
        const Duration(minutes: 15),
        const Duration(hours: 5),
        const Duration(days: 30)
      ];

      for (final Duration repeatDurationInterval in repeatDurationIntervals) {
        test('$repeatDurationInterval', () async {
          await withClock(Clock.fixed(now), () async {
            const AndroidInitializationSettings androidInitializationSettings =
                AndroidInitializationSettings('app_icon');
            const InitializationSettings initializationSettings =
                InitializationSettings(android: androidInitializationSettings);
            await flutterLocalNotificationsPlugin
                .initialize(initializationSettings);

            const AndroidNotificationDetails androidNotificationDetails =
                AndroidNotificationDetails('channelId', 'channelName',
                    channelDescription: 'channelDescription');
            await flutterLocalNotificationsPlugin.periodicallyShowWithDuration(
              1,
              'notification title',
              'notification body',
              repeatDurationInterval,
              const NotificationDetails(android: androidNotificationDetails),
            );

            expect(
                log.last,
                isMethodCall('periodicallyShowWithDuration',
                    arguments: <String, Object>{
                      'id': 1,
                      'title': 'notification title',
                      'body': 'notification body',
                      'payload': '',
                      'calledAt': now.millisecondsSinceEpoch,
                      'repeatIntervalMilliseconds':
                          repeatDurationInterval.inMilliseconds,
                      'platformSpecifics': <String, Object?>{
                        'scheduleMode': 'exact',
                        'icon': null,
                        'channelId': 'channelId',
                        'channelName': 'channelName',
                        'channelDescription': 'channelDescription',
                        'channelShowBadge': true,
                        'channelAction': AndroidNotificationChannelAction
                            .createIfNotExists.index,
                        'importance': Importance.defaultImportance.value,
                        'priority': Priority.defaultPriority.value,
                        'playSound': true,
                        'enableVibration': true,
                        'vibrationPattern': null,
                        'groupKey': null,
                        'setAsGroupSummary': false,
                        'groupAlertBehavior': GroupAlertBehavior.all.index,
                        'autoCancel': true,
                        'ongoing': false,
                        'silent': false,
                        'colorAlpha': null,
                        'colorRed': null,
                        'colorGreen': null,
                        'colorBlue': null,
                        'onlyAlertOnce': false,
                        'showWhen': true,
                        'when': null,
                        'usesChronometer': false,
                        'chronometerCountDown': false,
                        'showProgress': false,
                        'maxProgress': 0,
                        'progress': 0,
                        'indeterminate': false,
                        'enableLights': false,
                        'ledColorAlpha': null,
                        'ledColorRed': null,
                        'ledColorGreen': null,
                        'ledColorBlue': null,
                        'ledOnMs': null,
                        'ledOffMs': null,
                        'ticker': null,
                        'visibility': null,
                        'timeoutAfter': null,
                        'category': null,
                        'additionalFlags': null,
                        'fullScreenIntent': false,
                        'shortcutId': null,
                        'subText': null,
                        'style': AndroidNotificationStyle.defaultStyle.index,
                        'styleInformation': <String, Object>{
                          'htmlFormatContent': false,
                          'htmlFormatTitle': false,
                        },
                        'tag': null,
                        'colorized': false,
                        'number': null,
                        'audioAttributesUsage': 5,
                      },
                    }));
          });
        });
      }
    });

    group('zonedSchedule', () {
      test('no repeat frequency', () async {
        const AndroidInitializationSettings androidInitializationSettings =
            AndroidInitializationSettings('app_icon');
        const InitializationSettings initializationSettings =
            InitializationSettings(android: androidInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const AndroidNotificationDetails androidNotificationDetails =
            AndroidNotificationDetails('channelId', 'channelName',
                channelDescription: 'channelDescription');
        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            const NotificationDetails(android: androidNotificationDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
        expect(
            log.last,
            isMethodCall('zonedSchedule', arguments: <String, Object>{
              'id': 1,
              'title': 'notification title',
              'body': 'notification body',
              'payload': '',
              'timeZoneName': 'Australia/Sydney',
              'scheduledDateTime': convertDateToISO8601String(scheduledDate),
              'scheduledDateTimeISO8601': scheduledDate.toIso8601String(),
              'platformSpecifics': <String, Object?>{
                'scheduleMode': 'exactAllowWhileIdle',
                'icon': null,
                'channelId': 'channelId',
                'channelName': 'channelName',
                'channelDescription': 'channelDescription',
                'channelShowBadge': true,
                'channelAction':
                    AndroidNotificationChannelAction.createIfNotExists.index,
                'importance': Importance.defaultImportance.value,
                'priority': Priority.defaultPriority.value,
                'playSound': true,
                'enableVibration': true,
                'vibrationPattern': null,
                'groupKey': null,
                'setAsGroupSummary': false,
                'groupAlertBehavior': GroupAlertBehavior.all.index,
                'autoCancel': true,
                'ongoing': false,
                'silent': false,
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': false,
                'showWhen': true,
                'when': null,
                'usesChronometer': false,
                'chronometerCountDown': false,
                'showProgress': false,
                'maxProgress': 0,
                'progress': 0,
                'indeterminate': false,
                'enableLights': false,
                'ledColorAlpha': null,
                'ledColorRed': null,
                'ledColorGreen': null,
                'ledColorBlue': null,
                'ledOnMs': null,
                'ledOffMs': null,
                'ticker': null,
                'visibility': null,
                'timeoutAfter': null,
                'category': null,
                'additionalFlags': null,
                'fullScreenIntent': false,
                'shortcutId': null,
                'subText': null,
                'style': AndroidNotificationStyle.defaultStyle.index,
                'styleInformation': <String, Object>{
                  'htmlFormatContent': false,
                  'htmlFormatTitle': false,
                },
                'tag': null,
                'colorized': false,
                'number': null,
                'audioAttributesUsage': 5,
              },
            }));
      });

      test('match time components', () async {
        const AndroidInitializationSettings androidInitializationSettings =
            AndroidInitializationSettings('app_icon');
        const InitializationSettings initializationSettings =
            InitializationSettings(android: androidInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);

        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const AndroidNotificationDetails androidNotificationDetails =
            AndroidNotificationDetails('channelId', 'channelName',
                channelDescription: 'channelDescription');
        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            const NotificationDetails(android: androidNotificationDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time);
        expect(
            log.last,
            isMethodCall('zonedSchedule', arguments: <String, Object>{
              'id': 1,
              'title': 'notification title',
              'body': 'notification body',
              'payload': '',
              'timeZoneName': 'Australia/Sydney',
              'scheduledDateTime': convertDateToISO8601String(scheduledDate),
              'scheduledDateTimeISO8601': scheduledDate.toIso8601String(),
              'matchDateTimeComponents': DateTimeComponents.time.index,
              'platformSpecifics': <String, Object?>{
                'scheduleMode': 'exactAllowWhileIdle',
                'icon': null,
                'channelId': 'channelId',
                'channelName': 'channelName',
                'channelDescription': 'channelDescription',
                'channelShowBadge': true,
                'channelAction':
                    AndroidNotificationChannelAction.createIfNotExists.index,
                'importance': Importance.defaultImportance.value,
                'priority': Priority.defaultPriority.value,
                'playSound': true,
                'enableVibration': true,
                'vibrationPattern': null,
                'groupKey': null,
                'setAsGroupSummary': false,
                'groupAlertBehavior': GroupAlertBehavior.all.index,
                'autoCancel': true,
                'ongoing': false,
                'silent': false,
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': false,
                'showWhen': true,
                'when': null,
                'usesChronometer': false,
                'chronometerCountDown': false,
                'showProgress': false,
                'maxProgress': 0,
                'progress': 0,
                'indeterminate': false,
                'enableLights': false,
                'ledColorAlpha': null,
                'ledColorRed': null,
                'ledColorGreen': null,
                'ledColorBlue': null,
                'ledOnMs': null,
                'ledOffMs': null,
                'ticker': null,
                'visibility': null,
                'timeoutAfter': null,
                'category': null,
                'additionalFlags': null,
                'fullScreenIntent': false,
                'shortcutId': null,
                'subText': null,
                'style': AndroidNotificationStyle.defaultStyle.index,
                'styleInformation': <String, Object>{
                  'htmlFormatContent': false,
                  'htmlFormatTitle': false,
                },
                'tag': null,
                'colorized': false,
                'number': null,
                'audioAttributesUsage': 5,
              },
            }));
      });

      test('match day of week and time components', () async {
        const AndroidInitializationSettings androidInitializationSettings =
            AndroidInitializationSettings('app_icon');
        const InitializationSettings initializationSettings =
            InitializationSettings(android: androidInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);

        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const AndroidNotificationDetails androidNotificationDetails =
            AndroidNotificationDetails('channelId', 'channelName',
                channelDescription: 'channelDescription');
        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            const NotificationDetails(android: androidNotificationDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
        expect(
            log.last,
            isMethodCall('zonedSchedule', arguments: <String, Object>{
              'id': 1,
              'title': 'notification title',
              'body': 'notification body',
              'payload': '',
              'timeZoneName': 'Australia/Sydney',
              'scheduledDateTime': convertDateToISO8601String(scheduledDate),
              'scheduledDateTimeISO8601': scheduledDate.toIso8601String(),
              'matchDateTimeComponents':
                  DateTimeComponents.dayOfWeekAndTime.index,
              'platformSpecifics': <String, Object?>{
                'scheduleMode': 'exactAllowWhileIdle',
                'icon': null,
                'channelId': 'channelId',
                'channelName': 'channelName',
                'channelDescription': 'channelDescription',
                'channelShowBadge': true,
                'channelAction':
                    AndroidNotificationChannelAction.createIfNotExists.index,
                'importance': Importance.defaultImportance.value,
                'priority': Priority.defaultPriority.value,
                'playSound': true,
                'enableVibration': true,
                'vibrationPattern': null,
                'groupKey': null,
                'setAsGroupSummary': false,
                'groupAlertBehavior': GroupAlertBehavior.all.index,
                'autoCancel': true,
                'ongoing': false,
                'silent': false,
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': false,
                'showWhen': true,
                'when': null,
                'usesChronometer': false,
                'chronometerCountDown': false,
                'showProgress': false,
                'maxProgress': 0,
                'progress': 0,
                'indeterminate': false,
                'enableLights': false,
                'ledColorAlpha': null,
                'ledColorRed': null,
                'ledColorGreen': null,
                'ledColorBlue': null,
                'ledOnMs': null,
                'ledOffMs': null,
                'ticker': null,
                'visibility': null,
                'timeoutAfter': null,
                'category': null,
                'additionalFlags': null,
                'fullScreenIntent': false,
                'shortcutId': null,
                'subText': null,
                'style': AndroidNotificationStyle.defaultStyle.index,
                'styleInformation': <String, Object>{
                  'htmlFormatContent': false,
                  'htmlFormatTitle': false,
                },
                'tag': null,
                'colorized': false,
                'number': null,
                'audioAttributesUsage': 5,
              },
            }));
      });
    });

    group('createNotificationChannelGroup', () {
      test('without description', () async {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .createNotificationChannelGroup(
                const AndroidNotificationChannelGroup('groupId', 'groupName'));
        expect(log, <Matcher>[
          isMethodCall('createNotificationChannelGroup',
              arguments: <String, Object?>{
                'id': 'groupId',
                'name': 'groupName',
                'description': null,
              })
        ]);
      });
      test('with description', () async {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .createNotificationChannelGroup(
                const AndroidNotificationChannelGroup('groupId', 'groupName',
                    description: 'groupDescription'));
        expect(log, <Matcher>[
          isMethodCall('createNotificationChannelGroup',
              arguments: <String, Object>{
                'id': 'groupId',
                'name': 'groupName',
                'description': 'groupDescription',
              })
        ]);
      });
    });

    test('createNotificationChannel with default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(const AndroidNotificationChannel(
            'channelId',
            'channelName',
            description: 'channelDescription',
          ));
      expect(log, <Matcher>[
        isMethodCall('createNotificationChannel', arguments: <String, Object?>{
          'id': 'channelId',
          'name': 'channelName',
          'description': 'channelDescription',
          'groupId': null,
          'showBadge': true,
          'importance': Importance.defaultImportance.value,
          'playSound': true,
          'enableVibration': true,
          'vibrationPattern': null,
          'enableLights': false,
          'ledColorAlpha': null,
          'ledColorRed': null,
          'ledColorGreen': null,
          'ledColorBlue': null,
          'audioAttributesUsage': AudioAttributesUsage.notification.value,
          'channelAction':
              AndroidNotificationChannelAction.createIfNotExists.index,
        })
      ]);
    });

    test('createNotificationChannel with non-default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(const AndroidNotificationChannel(
            'channelId',
            'channelName',
            description: 'channelDescription',
            groupId: 'channelGroupId',
            showBadge: false,
            importance: Importance.max,
            playSound: false,
            enableLights: true,
            enableVibration: false,
            ledColor: Color.fromARGB(255, 255, 0, 0),
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ));
      expect(log, <Matcher>[
        isMethodCall('createNotificationChannel', arguments: <String, Object?>{
          'id': 'channelId',
          'name': 'channelName',
          'description': 'channelDescription',
          'groupId': 'channelGroupId',
          'showBadge': false,
          'importance': Importance.max.value,
          'playSound': false,
          'enableVibration': false,
          'vibrationPattern': null,
          'enableLights': true,
          'ledColorAlpha': 255,
          'ledColorRed': 255,
          'ledColorGreen': 0,
          'ledColorBlue': 0,
          'audioAttributesUsage': AudioAttributesUsage.alarm.value,
          'channelAction':
              AndroidNotificationChannelAction.createIfNotExists.index,
        })
      ]);
    });

    test('deleteNotificationChannel', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .deleteNotificationChannel('channelId');
      expect(log, <Matcher>[
        isMethodCall('deleteNotificationChannel', arguments: 'channelId')
      ]);
    });

    test('cancel', () async {
      await flutterLocalNotificationsPlugin.cancel(1);
      expect(log, <Matcher>[
        isMethodCall('cancel', arguments: <String, Object?>{
          'id': 1,
          'tag': null,
        })
      ]);
    });

    test('cancel with tag', () async {
      await flutterLocalNotificationsPlugin.cancel(1, tag: 'tag');
      expect(log, <Matcher>[
        isMethodCall('cancel', arguments: <String, Object>{
          'id': 1,
          'tag': 'tag',
        })
      ]);
    });

    test('cancelAll', () async {
      await flutterLocalNotificationsPlugin.cancelAll();
      expect(log, <Matcher>[isMethodCall('cancelAll', arguments: null)]);
    });

    test('pendingNotificationRequests', () async {
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      expect(log, <Matcher>[
        isMethodCall('pendingNotificationRequests', arguments: null)
      ]);
    });

    test('getActiveNotifications', () async {
      await flutterLocalNotificationsPlugin.getActiveNotifications();
      expect(log,
          <Matcher>[isMethodCall('getActiveNotifications', arguments: null)]);
    });

    test('getNotificationAppLaunchDetails', () async {
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      expect(log, <Matcher>[
        isMethodCall('getNotificationAppLaunchDetails', arguments: null)
      ]);
    });

    test('startForegroundService', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .startForegroundService(1, 'notification title', 'notification body');
      expect(
          log.last,
          isMethodCall('startForegroundService', arguments: <String, Object?>{
            'notificationData': <String, Object?>{
              'id': 1,
              'title': 'notification title',
              'body': 'notification body',
              'payload': '',
              'platformSpecifics': null,
            },
            'startType': AndroidServiceStartType.startSticky.index,
            'foregroundServiceTypes': null
          }));
    });

    test('stopForegroundService', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .stopForegroundService();
      expect(
          log.last,
          isMethodCall(
            'stopForegroundService',
            arguments: null,
          ));
    });

    test('areNotificationsEnabled', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .areNotificationsEnabled();
      expect(
          log.last, isMethodCall('areNotificationsEnabled', arguments: null));
    });

    test('startForegroundServiceWithBlueBackgroundNotification', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'channelDescription',
        color: Colors.blue,
        colorized: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .startForegroundService(1, 'colored background notification title',
              'colored background notification body',
              notificationDetails: androidPlatformChannelSpecifics);
      expect(
          log.last,
          isMethodCall(
            'startForegroundService',
            arguments: <String, Object?>{
              'notificationData': <String, Object?>{
                'id': 1,
                'title': 'colored background notification title',
                'body': 'colored background notification body',
                'payload': '',
                'platformSpecifics': <String, Object?>{
                  'icon': null,
                  'channelId': 'channelId',
                  'channelName': 'channelName',
                  'channelDescription': 'channelDescription',
                  'channelShowBadge': true,
                  'channelAction':
                      AndroidNotificationChannelAction.createIfNotExists.index,
                  'importance': Importance.defaultImportance.value,
                  'priority': Priority.defaultPriority.value,
                  'playSound': true,
                  'enableVibration': true,
                  'vibrationPattern': null,
                  'groupKey': null,
                  'setAsGroupSummary': false,
                  'groupAlertBehavior': GroupAlertBehavior.all.index,
                  'autoCancel': true,
                  'ongoing': false,
                  'silent': false,
                  'colorAlpha': 255,
                  'colorRed': 33,
                  'colorGreen': 150,
                  'colorBlue': 243,
                  'onlyAlertOnce': false,
                  'showWhen': true,
                  'when': null,
                  'usesChronometer': false,
                  'chronometerCountDown': false,
                  'showProgress': false,
                  'maxProgress': 0,
                  'progress': 0,
                  'indeterminate': false,
                  'enableLights': false,
                  'ledColorAlpha': null,
                  'ledColorRed': null,
                  'ledColorGreen': null,
                  'ledColorBlue': null,
                  'ledOnMs': null,
                  'ledOffMs': null,
                  'ticker': null,
                  'visibility': null,
                  'timeoutAfter': null,
                  'category': null,
                  'additionalFlags': null,
                  'fullScreenIntent': false,
                  'shortcutId': null,
                  'subText': null,
                  'style': AndroidNotificationStyle.defaultStyle.index,
                  'styleInformation': <String, Object>{
                    'htmlFormatContent': false,
                    'htmlFormatTitle': false,
                  },
                  'tag': null,
                  'colorized': true,
                  'number': null,
                  'audioAttributesUsage': 5,
                },
              },
              'startType': AndroidServiceStartType.startSticky.index,
              'foregroundServiceTypes': null
            },
          ));
    });

    test('requestNotificationsPermission', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
      expect(log.last,
          isMethodCall('requestNotificationsPermission', arguments: null));
    });

    test('requestExactAlarmsPermission', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestExactAlarmsPermission();
      expect(log.last,
          isMethodCall('requestExactAlarmsPermission', arguments: null));
    });
  });
}
