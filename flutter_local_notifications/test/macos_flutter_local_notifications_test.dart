import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'utils/date_formatter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  group('macOS', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      // ignore: always_specify_types
      channel.setMockMethodCallHandler((methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return <Map<String, Object>?>[];
        } else if (methodCall.method == 'getActiveNotifications') {
          return <Map<String, Object>?>[];
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return null;
        }
      });
    });

    tearDown(() {
      log.clear();
    });

    test('initialize with default parameter values', () async {
      const DarwinInitializationSettings macOSInitializationSettings =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': true,
          'requestSoundPermission': true,
          'requestBadgePermission': true,
          'requestCriticalPermission': false,
          'defaultPresentAlert': true,
          'defaultPresentSound': true,
          'defaultPresentBadge': true,
          'notificationCategories': <Map<String, String>>[],
        })
      ]);
    });

    test('initialize with all settings off', () async {
      const DarwinInitializationSettings macOSInitializationSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: false,
        defaultPresentBadge: false,
        defaultPresentSound: false,
      );
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': false,
          'requestSoundPermission': false,
          'requestBadgePermission': false,
          'requestCriticalPermission': false,
          'defaultPresentAlert': false,
          'defaultPresentSound': false,
          'defaultPresentBadge': false,
          'notificationCategories': <Map<String, String>>[],
        })
      ]);
    });

    test('show without macOS-specific details', () async {
      const DarwinInitializationSettings macOSInitializationSettings =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
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

    test('show with macOS-specific details', () async {
      const DarwinInitializationSettings macOSInitializationSettings =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(macOS: macOSInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const NotificationDetails notificationDetails = NotificationDetails(
        macOS: DarwinNotificationDetails(
          subtitle: 'a subtitle',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'sound.mp3',
          badgeNumber: 1,
          threadIdentifier: 'thread',
          attachments: <DarwinNotificationAttachment>[
            DarwinNotificationAttachment(
              'video.mp4',
              identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373',
            ),
          ],
          categoryIdentifier: 'category1',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        1,
        'notification title',
        'notification body',
        notificationDetails,
      );

      expect(
        log.last,
        isMethodCall(
          'show',
          arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object?>{
              'subtitle': 'a subtitle',
              'presentAlert': true,
              'presentBadge': true,
              'presentSound': true,
              'sound': 'sound.mp3',
              'badgeNumber': 1,
              'threadIdentifier': 'thread',
              'attachments': <Map<String, Object?>>[
                <String, Object?>{
                  'filePath': 'video.mp4',
                  'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  'hideThumbnail': null,
                  'thumbnailClippingRect': null,
                }
              ],
              'categoryIdentifier': 'category1',
              'interruptionLevel': 2,
            },
          },
        ),
      );
    });

    group('periodicallyShow', () {
      final DateTime now = DateTime(2020, 10, 9);
      for (final RepeatInterval repeatInterval in RepeatInterval.values) {
        test('$repeatInterval', () async {
          await withClock(Clock.fixed(now), () async {
            const DarwinInitializationSettings macOSInitializationSettings =
                DarwinInitializationSettings();
            const InitializationSettings initializationSettings =
                InitializationSettings(macOS: macOSInitializationSettings);
            await flutterLocalNotificationsPlugin
                .initialize(initializationSettings);

            const NotificationDetails notificationDetails = NotificationDetails(
              macOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'sound.mp3',
                badgeNumber: 1,
                attachments: <DarwinNotificationAttachment>[
                  DarwinNotificationAttachment(
                    'video.mp4',
                    identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373',
                  )
                ],
              ),
            );

            await flutterLocalNotificationsPlugin.periodicallyShow(
              1,
              'notification title',
              'notification body',
              repeatInterval,
              notificationDetails,
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
                    'presentAlert': true,
                    'presentBadge': true,
                    'presentSound': true,
                    'subtitle': null,
                    'sound': 'sound.mp3',
                    'badgeNumber': 1,
                    'threadIdentifier': null,
                    'attachments': <Map<String, Object?>>[
                      <String, Object?>{
                        'filePath': 'video.mp4',
                        'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                        'hideThumbnail': null,
                        'thumbnailClippingRect': null,
                      }
                    ],
                    'categoryIdentifier': null,
                    'interruptionLevel': null,
                  },
                }));
          });
        });
      }
    });

    group('zonedSchedule', () {
      test('no repeat frequency', () async {
        const DarwinInitializationSettings macOSInitializationSettings =
            DarwinInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(macOS: macOSInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'sound.mp3',
            badgeNumber: 1,
            attachments: <DarwinNotificationAttachment>[
              DarwinNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ],
          ),
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          'notification title',
          'notification body',
          scheduledDate,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        expect(
            log.last,
            isMethodCall('zonedSchedule', arguments: <String, Object>{
              'id': 1,
              'title': 'notification title',
              'body': 'notification body',
              'payload': '',
              'scheduledDateTime': convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'platformSpecifics': <String, Object?>{
                'subtitle': null,
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'threadIdentifier': null,
                'attachments': <Map<String, Object?>>[
                  <String, Object?>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                    'hideThumbnail': null,
                    'thumbnailClippingRect': null,
                  }
                ],
                'categoryIdentifier': null,
                'interruptionLevel': null,
              },
            }));
      });

      test('match time components', () async {
        const DarwinInitializationSettings macOSInitializationSettings =
            DarwinInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(macOS: macOSInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'sound.mp3',
            badgeNumber: 1,
            attachments: <DarwinNotificationAttachment>[
              DarwinNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ],
          ),
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          'notification title',
          'notification body',
          scheduledDate,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        expect(
          log.last,
          isMethodCall(
            'zonedSchedule',
            arguments: <String, Object>{
              'id': 1,
              'title': 'notification title',
              'body': 'notification body',
              'payload': '',
              'scheduledDateTime': convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'matchDateTimeComponents': DateTimeComponents.time.index,
              'platformSpecifics': <String, Object?>{
                'subtitle': null,
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'threadIdentifier': null,
                'attachments': <Map<String, Object?>>[
                  <String, Object?>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                    'hideThumbnail': null,
                    'thumbnailClippingRect': null,
                  }
                ],
                'categoryIdentifier': null,
                'interruptionLevel': null,
              },
            },
          ),
        );
      });

      test('weekly repeat frequency', () async {
        const DarwinInitializationSettings macOSInitializationSettings =
            DarwinInitializationSettings();
        const InitializationSettings initializationSettings =
            InitializationSettings(macOS: macOSInitializationSettings);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Australia/Sydney'));
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
        const NotificationDetails notificationDetails = NotificationDetails(
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'sound.mp3',
            badgeNumber: 1,
            attachments: <DarwinNotificationAttachment>[
              DarwinNotificationAttachment('video.mp4',
                  identifier: '2b3f705f-a680-4c9f-8075-a46a70e28373')
            ],
          ),
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          'notification title',
          'notification body',
          scheduledDate,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        expect(
          log.last,
          isMethodCall(
            'zonedSchedule',
            arguments: <String, Object>{
              'id': 1,
              'title': 'notification title',
              'body': 'notification body',
              'payload': '',
              'scheduledDateTime': convertDateToISO8601String(scheduledDate),
              'timeZoneName': 'Australia/Sydney',
              'matchDateTimeComponents':
                  DateTimeComponents.dayOfWeekAndTime.index,
              'platformSpecifics': <String, Object?>{
                'subtitle': null,
                'presentAlert': true,
                'presentBadge': true,
                'presentSound': true,
                'sound': 'sound.mp3',
                'badgeNumber': 1,
                'threadIdentifier': null,
                'attachments': <Map<String, Object?>>[
                  <String, Object?>{
                    'filePath': 'video.mp4',
                    'identifier': '2b3f705f-a680-4c9f-8075-a46a70e28373',
                    'hideThumbnail': null,
                    'thumbnailClippingRect': null,
                  }
                ],
                'categoryIdentifier': null,
                'interruptionLevel': null,
              },
            },
          ),
        );
      });
    });

    test('requestPermissions with default settings', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions();
      expect(log, <Matcher>[
        isMethodCall('requestPermissions', arguments: <String, Object?>{
          'sound': false,
          'badge': false,
          'alert': false,
          'critical': false,
        })
      ]);
    });
    test('requestPermissions with all settings requested', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
            sound: true,
            badge: true,
            alert: true,
            critical: true,
          );
      expect(log, <Matcher>[
        isMethodCall('requestPermissions', arguments: <String, Object>{
          'sound': true,
          'badge': true,
          'alert': true,
          'critical': true,
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
  });
}
