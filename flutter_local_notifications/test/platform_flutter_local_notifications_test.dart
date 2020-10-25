import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/platform_specifics/android/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  // TODO(maikub): add tests for `periodicallyShow` after https://github.com/dart-lang/sdk/issues/28985 is resolved
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  group('Android', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin.private(
          FakePlatform(operatingSystem: 'android'));
      // ignore: always_specify_types
      channel.setMockMethodCallHandler((methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return Future<List<Map<String, Object>>>.value(
              <Map<String, Object>>[]);
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return Future<Map<String, Object>>.value(<String, Object>{});
        } else if (methodCall.method == 'getActiveNotifications') {
          return Future<List<Map<String, Object>>>.value(
              <Map<String, Object>>[]);
        }
        return Future<void>.value();
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
          isMethodCall('show', arguments: <String, Object>{
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
          AndroidNotificationDetails(
              'channelId', 'channelName', 'channelDescription');

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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
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
          AndroidNotificationDetails(
              'channelId', 'channelName', 'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'additionalFlags': <int>[4, 32],
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
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
      final int timestamp = DateTime.now().millisecondsSinceEpoch;

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'channelId', 'channelName', 'channelDescription',
              when: timestamp);
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': timestamp,
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
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.defaultStyle.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
              },
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.bigPicture.index,
              'styleInformation': <String, Object>{
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.bigPicture.index,
              'styleInformation': <String, Object>{
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.inbox.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'lines': <String>['line1'],
                'contentTitle': null,
                'summaryText': null,
                'htmlFormatContentTitle': false,
                'htmlFormatSummaryText': false,
                'htmlFormatLines': false,
              },
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.media.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
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
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.media.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
              },
            },
          }));
    });

    test('show with default Android messaging style settings', () async {
      final DateTime messageDateTime = DateTime.now();
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
              'style': AndroidNotificationStyle.messaging.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'person': <String, Object>{
                  'bot': null,
                  'important': null,
                  'key': null,
                  'name': 'name',
                  'uri': null,
                },
                'conversationTitle': null,
                'groupConversation': null,
                'messages': <Map<String, Object>>[
                  <String, Object>{
                    'text': 'message 1',
                    'timestamp': messageDateTime.millisecondsSinceEpoch,
                    'person': null,
                    'dataMimeType': null,
                    'dataUri': null,
                  }
                ],
              },
            },
          }));
    });

    test('show with non-default Android messaging style settings', () async {
      final DateTime messageDateTime = DateTime.now();
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
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
            'platformSpecifics': <String, Object>{
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
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.all.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
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
                'messages': <Map<String, Object>>[
                  <String, Object>{
                    'text': 'message 1',
                    'timestamp': messageDateTime.millisecondsSinceEpoch,
                    'person': null,
                    'dataMimeType': 'dataMimeType',
                    'dataUri': 'dataUri',
                  }
                ],
              },
            },
          }));
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
            AndroidNotificationDetails(
                'channelId', 'channelName', 'channelDescription');
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
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'platformSpecifics': <String, Object>{
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
                'setAsGroupSummary': null,
                'groupAlertBehavior': GroupAlertBehavior.all.index,
                'autoCancel': true,
                'ongoing': null,
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': null,
                'showWhen': true,
                'when': null,
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
                'style': AndroidNotificationStyle.defaultStyle.index,
                'styleInformation': <String, Object>{
                  'htmlFormatContent': false,
                  'htmlFormatTitle': false,
                },
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
            AndroidNotificationDetails(
                'channelId', 'channelName', 'channelDescription');
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
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'matchDateTimeComponents': DateTimeComponents.time.index,
              'platformSpecifics': <String, Object>{
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
                'setAsGroupSummary': null,
                'groupAlertBehavior': GroupAlertBehavior.all.index,
                'autoCancel': true,
                'ongoing': null,
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': null,
                'showWhen': true,
                'when': null,
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
                'style': AndroidNotificationStyle.defaultStyle.index,
                'styleInformation': <String, Object>{
                  'htmlFormatContent': false,
                  'htmlFormatTitle': false,
                },
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
            AndroidNotificationDetails(
                'channelId', 'channelName', 'channelDescription');
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
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'matchDateTimeComponents':
                  DateTimeComponents.dayOfWeekAndTime.index,
              'platformSpecifics': <String, Object>{
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
                'setAsGroupSummary': null,
                'groupAlertBehavior': GroupAlertBehavior.all.index,
                'autoCancel': true,
                'ongoing': null,
                'colorAlpha': null,
                'colorRed': null,
                'colorGreen': null,
                'colorBlue': null,
                'onlyAlertOnce': null,
                'showWhen': true,
                'when': null,
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
                'style': AndroidNotificationStyle.defaultStyle.index,
                'styleInformation': <String, Object>{
                  'htmlFormatContent': false,
                  'htmlFormatTitle': false,
                },
              },
            }));
      });
    });

    group('createNotificationChannelGroup', () {
      test('without description', () async {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            .createNotificationChannelGroup(
                const AndroidNotificationChannelGroup('groupId', 'groupName'));
        expect(log, <Matcher>[
          isMethodCall('createNotificationChannelGroup',
              arguments: <String, Object>{
                'id': 'groupId',
                'name': 'groupName',
                'description': null,
              })
        ]);
      });
      test('with description', () async {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
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
              AndroidFlutterLocalNotificationsPlugin>()
          .createNotificationChannel(const AndroidNotificationChannel(
              'channelId', 'channelName', 'channelDescription'));
      expect(log, <Matcher>[
        isMethodCall('createNotificationChannel', arguments: <String, Object>{
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
              AndroidNotificationChannelAction.createIfNotExists?.index,
        })
      ]);
    });

    test('createNotificationChannel with non-default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .createNotificationChannel(const AndroidNotificationChannel(
            'channelId',
            'channelName',
            'channelDescription',
            groupId: 'channelGroupId',
            showBadge: false,
            importance: Importance.max,
            playSound: false,
            enableLights: true,
            enableVibration: false,
            ledColor: Color.fromARGB(255, 255, 0, 0),
          ));
      expect(log, <Matcher>[
        isMethodCall('createNotificationChannel', arguments: <String, Object>{
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
              AndroidNotificationChannelAction.createIfNotExists?.index,
        })
      ]);
    });

    test('deleteNotificationChannel', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .deleteNotificationChannel('channelId');
      expect(log, <Matcher>[
        isMethodCall('deleteNotificationChannel', arguments: 'channelId')
      ]);
    });

    test('getActiveNotifications', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .getActiveNotifications();
      expect(log,
          <Matcher>[isMethodCall('getActiveNotifications', arguments: null)]);
    });

    test('cancel', () async {
      await flutterLocalNotificationsPlugin.cancel(1);
      expect(log, <Matcher>[isMethodCall('cancel', arguments: 1)]);
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
              AndroidFlutterLocalNotificationsPlugin>()
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
  });

  group('iOS', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin.private(
          FakePlatform(operatingSystem: 'ios'));
      // ignore: always_specify_types
      channel.setMockMethodCallHandler((methodCall) {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return Future<List<Map<String, Object>>>.value(
              <Map<String, Object>>[]);
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return Future<Map<String, Object>>.value(<String, Object>{});
        }
        return Future<void>.value();
      });
    });

    tearDown(() {
      log.clear();
    });

    test('initialize with default parameter values', () async {
      const IOSInitializationSettings iosInitializationSettings =
          IOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': true,
          'requestSoundPermission': true,
          'requestBadgePermission': true,
          'defaultPresentAlert': true,
          'defaultPresentSound': true,
          'defaultPresentBadge': true,
        })
      ]);
    });

    test('initialize with all settings off', () async {
      const IOSInitializationSettings iosInitializationSettings =
          IOSInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
              defaultPresentAlert: false,
              defaultPresentBadge: false,
              defaultPresentSound: false);
      const InitializationSettings initializationSettings =
          InitializationSettings(iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': false,
          'requestSoundPermission': false,
          'requestBadgePermission': false,
          'defaultPresentAlert': false,
          'defaultPresentSound': false,
          'defaultPresentBadge': false,
        })
      ]);
    });

    test('show without iOS-specific details', () async {
      const IOSInitializationSettings iosInitializationSettings =
          IOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      await flutterLocalNotificationsPlugin.show(
          1, 'notification title', 'notification body', null);
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': null,
          }));
    });

    test('show with iOS-specific details', () async {
      const IOSInitializationSettings iosInitializationSettings =
          IOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const NotificationDetails notificationDetails = NotificationDetails(
          iOS: IOSNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              subtitle: 'a subtitle',
              sound: 'sound.mp3',
              badgeNumber: 1,
              attachments: <IOSNotificationAttachment>[
            IOSNotificationAttachment('video.mp4',
                identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373'),
          ]));

      await flutterLocalNotificationsPlugin.show(
          1, 'notification title', 'notification body', notificationDetails);

      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object>{
              'presentAlert': true,
              'presentBadge': true,
              'presentSound': true,
              'subtitle': 'a subtitle',
              'sound': 'sound.mp3',
              'badgeNumber': 1,
              'attachments': <Map<String, Object>>[
                <String, Object>{
                  'filePath': 'video.mp4',
                  'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                }
              ],
            },
          }));
    });

    group('zonedSchedule', () {
      test('no repeat frequency', () async {
        const IOSInitializationSettings iosInitializationSettings =
            IOSInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(iOS: iosInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
            iOS: IOSNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'sound.mp3',
                badgeNumber: 1,
                attachments: <IOSNotificationAttachment>[
              IOSNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ]));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            notificationDetails,
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
              'uiLocalNotificationDateInterpretation':
                  UILocalNotificationDateInterpretation.absoluteTime.index,
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'platformSpecifics': <String, Object>{
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'subtitle': null,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'attachments': <Map<String, Object>>[
                  <String, Object>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  }
                ],
              },
            }));
      });

      test('match time components', () async {
        const IOSInitializationSettings iosInitializationSettings =
            IOSInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(iOS: iosInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
            iOS: IOSNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'sound.mp3',
                badgeNumber: 1,
                attachments: <IOSNotificationAttachment>[
              IOSNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ]));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            notificationDetails,
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
              'uiLocalNotificationDateInterpretation':
                  UILocalNotificationDateInterpretation.absoluteTime.index,
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'matchDateTimeComponents': DateTimeComponents.time.index,
              'platformSpecifics': <String, Object>{
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'subtitle': null,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'attachments': <Map<String, Object>>[
                  <String, Object>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  }
                ],
              },
            }));
      });

      test('match day of week and time components', () async {
        const IOSInitializationSettings iosInitializationSettings =
            IOSInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(iOS: iosInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
            iOS: IOSNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'sound.mp3',
                badgeNumber: 1,
                attachments: <IOSNotificationAttachment>[
              IOSNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ]));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            notificationDetails,
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
              'uiLocalNotificationDateInterpretation':
                  UILocalNotificationDateInterpretation.absoluteTime.index,
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'matchDateTimeComponents':
                  DateTimeComponents.dayOfWeekAndTime.index,
              'platformSpecifics': <String, Object>{
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'subtitle': null,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'attachments': <Map<String, Object>>[
                  <String, Object>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  }
                ],
              },
            }));
      });
    });
    test('requestPermissions with default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          .requestPermissions();
      expect(log, <Matcher>[
        isMethodCall('requestPermissions', arguments: <String, Object>{
          'sound': null,
          'badge': null,
          'alert': null,
        })
      ]);
    });
    test('requestPermissions with all settings requested', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          .requestPermissions(sound: true, badge: true, alert: true);
      expect(log, <Matcher>[
        isMethodCall('requestPermissions', arguments: <String, Object>{
          'sound': true,
          'badge': true,
          'alert': true,
        })
      ]);
    });
    test('cancel', () async {
      await flutterLocalNotificationsPlugin.cancel(1);
      expect(log, <Matcher>[isMethodCall('cancel', arguments: 1)]);
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

    test('getNotificationAppLaunchDetails', () async {
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      expect(log, <Matcher>[
        isMethodCall('getNotificationAppLaunchDetails', arguments: null)
      ]);
    });
  });

  group('macOS', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin.private(
          FakePlatform(operatingSystem: 'macos'));
      // ignore: always_specify_types
      channel.setMockMethodCallHandler((methodCall) {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return Future<List<Map<String, Object>>>.value(
              <Map<String, Object>>[]);
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return Future<Map<String, Object>>.value(<String, Object>{});
        }
        return Future<void>.value();
      });
    });

    tearDown(() {
      log.clear();
    });

    test('initialize with default parameter values', () async {
      const MacOSInitializationSettings macOSInitializationSettings =
          MacOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': true,
          'requestSoundPermission': true,
          'requestBadgePermission': true,
          'defaultPresentAlert': true,
          'defaultPresentSound': true,
          'defaultPresentBadge': true,
        })
      ]);
    });

    test('initialize with all settings off', () async {
      const MacOSInitializationSettings macOSInitializationSettings =
          MacOSInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
              defaultPresentAlert: false,
              defaultPresentBadge: false,
              defaultPresentSound: false);
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': false,
          'requestSoundPermission': false,
          'requestBadgePermission': false,
          'defaultPresentAlert': false,
          'defaultPresentSound': false,
          'defaultPresentBadge': false,
        })
      ]);
    });

    test('show without macOS-specific details', () async {
      const MacOSInitializationSettings macOSInitializationSettings =
          MacOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      await flutterLocalNotificationsPlugin.show(
          1, 'notification title', 'notification body', null);
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': null,
          }));
    });

    test('show with macOS-specific details', () async {
      const MacOSInitializationSettings macOSInitializationSettings =
          MacOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const NotificationDetails notificationDetails = NotificationDetails(
          macOS: MacOSNotificationDetails(
              subtitle: 'a subtitle',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'sound.mp3',
              badgeNumber: 1,
              attachments: <MacOSNotificationAttachment>[
            MacOSNotificationAttachment('video.mp4',
                identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373'),
          ]));

      await flutterLocalNotificationsPlugin.show(
          1, 'notification title', 'notification body', notificationDetails);

      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object>{
              'subtitle': 'a subtitle',
              'presentAlert': true,
              'presentBadge': true,
              'presentSound': true,
              'sound': 'sound.mp3',
              'badgeNumber': 1,
              'attachments': <Map<String, Object>>[
                <String, Object>{
                  'filePath': 'video.mp4',
                  'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                }
              ],
            },
          }));
    });

    group('zonedSchedule', () {
      test('no repeat frequency', () async {
        const MacOSInitializationSettings macOSInitializationSettings =
            MacOSInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(macOS: macOSInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
            macOS: MacOSNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'sound.mp3',
                badgeNumber: 1,
                attachments: <MacOSNotificationAttachment>[
              MacOSNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ]));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            notificationDetails,
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
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'platformSpecifics': <String, Object>{
                'subtitle': null,
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'attachments': <Map<String, Object>>[
                  <String, Object>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  }
                ],
              },
            }));
      });

      test('match time components', () async {
        const MacOSInitializationSettings macOSInitializationSettings =
            MacOSInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(macOS: macOSInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
            macOS: MacOSNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'sound.mp3',
                badgeNumber: 1,
                attachments: <MacOSNotificationAttachment>[
              MacOSNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ]));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            notificationDetails,
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
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'matchDateTimeComponents': DateTimeComponents.time.index,
              'platformSpecifics': <String, Object>{
                'subtitle': null,
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'attachments': <Map<String, Object>>[
                  <String, Object>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  }
                ],
              },
            }));
      });

      test('weekly repeat frequency', () async {
        const MacOSInitializationSettings macOSInitializationSettings =
            MacOSInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(macOS: macOSInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
            macOS: MacOSNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'sound.mp3',
                badgeNumber: 1,
                attachments: <MacOSNotificationAttachment>[
              MacOSNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ]));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'notification title',
            'notification body',
            scheduledDate,
            notificationDetails,
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
              'scheduledDateTime': _convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'matchDateTimeComponents':
                  DateTimeComponents.dayOfWeekAndTime.index,
              'platformSpecifics': <String, Object>{
                'subtitle': null,
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'attachments': <Map<String, Object>>[
                  <String, Object>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  }
                ],
              },
            }));
      });
    });

    test('requestPermissions with default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          .requestPermissions();
      expect(log, <Matcher>[
        isMethodCall('requestPermissions', arguments: <String, Object>{
          'sound': null,
          'badge': null,
          'alert': null,
        })
      ]);
    });
    test('requestPermissions with all settings requested', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          .requestPermissions(sound: true, badge: true, alert: true);
      expect(log, <Matcher>[
        isMethodCall('requestPermissions', arguments: <String, Object>{
          'sound': true,
          'badge': true,
          'alert': true,
        })
      ]);
    });
    test('cancel', () async {
      await flutterLocalNotificationsPlugin.cancel(1);
      expect(log, <Matcher>[isMethodCall('cancel', arguments: 1)]);
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

    test('getNotificationAppLaunchDetails', () async {
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      expect(log, <Matcher>[
        isMethodCall('getNotificationAppLaunchDetails', arguments: null)
      ]);
    });
  });
}

String _convertDateToISO8601String(tz.TZDateTime dateTime) {
  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  String _fourDigits(int n) {
    final int absN = n.abs();
    final String sign = n < 0 ? '-' : '';
    if (absN >= 1000) {
      return '$n';
    }
    if (absN >= 100) {
      return '${sign}0$absN';
    }
    if (absN >= 10) {
      return '${sign}00$absN';
    }
    return '${sign}000$absN';
  }

  return '${_fourDigits(dateTime.year)}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}T${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}'; // ignore: lines_longer_than_80_chars
}
