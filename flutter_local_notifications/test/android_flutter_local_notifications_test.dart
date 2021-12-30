import 'dart:typed_data';
import 'dart:ui';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
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
      // ignore: always_specify_types
      channel.setMockMethodCallHandler((methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return <Map<String, Object?>>[];
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return null;
        } else if (methodCall.method == 'getActiveNotifications') {
          return <Map<String, Object?>>[];
        }
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

    test('show with default Android-specific details', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('channelId', 'channelName',
              channelDescription: 'channelDescription');

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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': timestamp,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': timestamp,
              'usesChronometer': true,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': false,
              'showWhen': true,
              'when': null,
              'usesChronometer': false,
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
                    'allowWhileIdle': false,
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
                    'colorAlpha': null,
                    'colorRed': null,
                    'colorGreen': null,
                    'colorBlue': null,
                    'onlyAlertOnce': false,
                    'showWhen': true,
                    'when': null,
                    'usesChronometer': false,
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
            androidAllowWhileIdle: true,
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
              'platformSpecifics': <String, Object?>{
                'allowWhileIdle': true,
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
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': false,
                'showWhen': true,
                'when': null,
                'usesChronometer': false,
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
            androidAllowWhileIdle: true,
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
              'matchDateTimeComponents': DateTimeComponents.time.index,
              'platformSpecifics': <String, Object?>{
                'allowWhileIdle': true,
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
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': false,
                'showWhen': true,
                'when': null,
                'usesChronometer': false,
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
            androidAllowWhileIdle: true,
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
              'matchDateTimeComponents':
                  DateTimeComponents.dayOfWeekAndTime.index,
              'platformSpecifics': <String, Object?>{
                'allowWhileIdle': true,
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
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': false,
                'showWhen': true,
                'when': null,
                'usesChronometer': false,
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
              'channelId', 'channelName',
              description: 'channelDescription'));
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

    test('getActiveNotifications', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .getActiveNotifications();
      expect(log,
          <Matcher>[isMethodCall('getActiveNotifications', arguments: null)]);
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
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .getActiveNotifications();
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
            'startType': AndroidServiceStartType.startSticky.value,
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
  });
}
