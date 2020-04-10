import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/platform_specifics/android/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  group('android', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    List<MethodCall> log = <MethodCall>[];

    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin.private(
          FakePlatform(operatingSystem: 'android'));
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return Future.value(List<Map<String, Object>>());
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return Future.value(Map<String, Object>());
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
          InitializationSettings(androidInitializationSettings, null);
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
          InitializationSettings(androidInitializationSettings, null);
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
          InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'channelId', 'channelName', 'channelDescription');

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Default.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
            },
          }));
    });

    test(
        'show with default Android-specific details and custom sound from raw resource',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
        sound: RawResourceAndroidNotificationSound('sound.mp3'),
        playSound: true,
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'sound': 'sound.mp3',
              'soundSource': AndroidNotificationSoundSource.RawResource.index,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Default.index,
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
          InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
        sound: UriAndroidNotificationSound('uri'),
        playSound: true,
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'sound': 'uri',
              'soundSource': AndroidNotificationSoundSource.Uri.index,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Default.index,
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
          InitializationSettings(androidInitializationSettings, null);
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Default.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
              },
            },
          }));
    });

    test(
        'show with default Android big picture style settings using a drawable resource',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(androidInitializationSettings, null);
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.BigPicture.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'bigPicture': 'bigPictureDrawable',
                'bigPictureBitmapSource': AndroidBitmapSource.Drawable.index,
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
        'show with non-default Android big picture style settings using a drawable resource',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(androidInitializationSettings, null);
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.BigPicture.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
                'bigPicture': 'bigPictureDrawable',
                'bigPictureBitmapSource': AndroidBitmapSource.Drawable.index,
                'largeIcon': 'largeDrawableIcon',
                'largeIconBitmapSource': AndroidBitmapSource.Drawable.index,
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
        'show with default Android big picture style settings using a file path',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(androidInitializationSettings, null);
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.BigPicture.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'bigPicture': 'bigPictureFilePath',
                'bigPictureBitmapSource': AndroidBitmapSource.FilePath.index,
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
        'show with non-default Android big picture style settings using a file path',
        () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(androidInitializationSettings, null);
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.BigPicture.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
                'bigPicture': 'bigPictureFilePath',
                'bigPictureBitmapSource': AndroidBitmapSource.FilePath.index,
                'largeIcon': 'largeFilePathIcon',
                'largeIconBitmapSource': AndroidBitmapSource.FilePath.index,
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
          InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
        styleInformation: InboxStyleInformation(
          ['line1'],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Inbox.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
                'lines': ['line1'],
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
          InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
        styleInformation: InboxStyleInformation(
          ['line1'],
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Inbox.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': true,
                'htmlFormatTitle': true,
                'lines': ['line1'],
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
          InitializationSettings(androidInitializationSettings, null);
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Media.index,
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
          InitializationSettings(androidInitializationSettings, null);
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Media.index,
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
          InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
        styleInformation: MessagingStyleInformation(
          Person(name: 'name'),
          messages: [
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Messaging.index,
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
                'messages': [
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
          InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
        styleInformation: MessagingStyleInformation(
          Person(
            bot: true,
            icon: DrawableResourceAndroidIcon('drawablePersonIcon'),
            important: true,
            key: 'key',
            name: 'name',
            uri: 'uri',
          ),
          conversationTitle: 'conversationTitle',
          groupConversation: true,
          messages: [
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
          NotificationDetails(androidNotificationDetails, null));
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
                  AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
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
              'style': AndroidNotificationStyle.Messaging.index,
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
                  'iconSource': AndroidIconSource.DrawableResource.index,
                },
                'conversationTitle': 'conversationTitle',
                'groupConversation': true,
                'messages': [
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

    test('createNotificationChannel with default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .createNotificationChannel(AndroidNotificationChannel(
              'channelId', 'channelName', 'channelDescription'));
      expect(log, <Matcher>[
        isMethodCall('createNotificationChannel', arguments: <String, Object>{
          'id': 'channelId',
          'name': 'channelName',
          'description': 'channelDescription',
          'showBadge': true,
          'importance': Importance.Default.value,
          'playSound': true,
          'enableVibration': true,
          'vibrationPattern': null,
          'enableLights': false,
          'ledColorAlpha': null,
          'ledColorRed': null,
          'ledColorGreen': null,
          'ledColorBlue': null,
          'channelAction':
              AndroidNotificationChannelAction.CreateIfNotExists?.index,
        })
      ]);
    });

    test('createNotificationChannel with non-default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .createNotificationChannel(AndroidNotificationChannel(
            'channelId',
            'channelName',
            'channelDescription',
            showBadge: false,
            importance: Importance.Max,
            playSound: false,
            enableLights: true,
            enableVibration: false,
            ledColor: const Color.fromARGB(255, 255, 0, 0),
          ));
      expect(log, <Matcher>[
        isMethodCall('createNotificationChannel', arguments: <String, Object>{
          'id': 'channelId',
          'name': 'channelName',
          'description': 'channelDescription',
          'showBadge': false,
          'importance': Importance.Max.value,
          'playSound': false,
          'enableVibration': false,
          'vibrationPattern': null,
          'enableLights': true,
          'ledColorAlpha': 255,
          'ledColorRed': 255,
          'ledColorGreen': 0,
          'ledColorBlue': 0,
          'channelAction':
              AndroidNotificationChannelAction.CreateIfNotExists?.index,
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

  group('ios', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    List<MethodCall> log = <MethodCall>[];

    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin.private(
          FakePlatform(operatingSystem: 'ios'));
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return Future.value(List<Map<String, Object>>());
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return Future.value(Map<String, Object>());
        }
      });
    });

    tearDown(() {
      log.clear();
    });

    test('initialize with default parameter values', () async {
      const IOSInitializationSettings iosInitializationSettings =
          IOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(null, iosInitializationSettings);
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
          InitializationSettings(null, iosInitializationSettings);
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
          InitializationSettings(null, iosInitializationSettings);
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
          InitializationSettings(null, iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const NotificationDetails notificationDetails = NotificationDetails(
          null,
          IOSNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'sound.mp3',
              badgeNumber: 1,
              attachments: [
                IOSNotificationAttachment('video.mp4',
                    identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
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
              'sound': 'sound.mp3',
              'badgeNumber': 1,
              'attachments': [
                <String, Object>{
                  'filePath': 'video.mp4',
                  'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                }
              ],
            },
          }));
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
}
