import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:flutter_local_notifications_linux/src/notification_info.dart';
import 'package:flutter_local_notifications_linux/src/notifications_manager.dart';
import 'package:flutter_local_notifications_linux/src/platform_info.dart';
import 'package:flutter_local_notifications_linux/src/storage.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<LinuxPlatformInfo>(),
  MockSpec<NotificationStorage>(),
  MockSpec<DidReceiveNotificationResponseCallback>(),
  MockSpec<XdgNotificationPortal>(),
])
import 'notifications_manager_test.mocks.dart';

// ignore: one_member_abstracts
abstract class DidReceiveNotificationResponseCallback {
  Future<dynamic> call(NotificationResponse notificationResponse);
}

const String kDefaultActionName = 'Open notification';

void main() {
  group('Notifications manager |', () {
    late LinuxNotificationManager manager;
    late final MockLinuxPlatformInfo mockPlatformInfo;
    late final MockNotificationStorage mockStorage;
    late final MockDidReceiveNotificationResponseCallback
        mockDidReceiveNotificationResponseCallback;
    late final MockXdgNotificationPortal mockXdgNotificationPortal;

    const LinuxPlatformInfoData platformInfo = LinuxPlatformInfoData(
      appName: 'Test',
      assetsPath: 'assets',
      runtimePath: 'run',
    );

    setUpAll(() {
      mockPlatformInfo = MockLinuxPlatformInfo();
      mockStorage = MockNotificationStorage();
      mockDidReceiveNotificationResponseCallback =
          MockDidReceiveNotificationResponseCallback();
      mockXdgNotificationPortal = MockXdgNotificationPortal();

      when(
        mockPlatformInfo.getAll(),
      ).thenAnswer((_) async => platformInfo);
      when(
        mockStorage.forceReloadCache(),
      ).thenAnswer((_) async => <void>{});
      when(
        mockDidReceiveNotificationResponseCallback.call(any),
      ).thenAnswer((_) async => <void>{});
      when(mockXdgNotificationPortal.addNotification(any)).thenAnswer(
        (_) async => 0,
      );
      when(mockXdgNotificationPortal.removeNotification(any)).thenAnswer(
        (_) async => <void>{},
      );
      when(mockXdgNotificationPortal.actionInvoked).thenAnswer(
        (_) => Stream<XdgNotificationActionInvokedEvent>.fromIterable(
          <XdgNotificationActionInvokedEvent>[],
        ),
      );
    });

    setUp(() {
      manager = LinuxNotificationManager.private(
        portal: mockXdgNotificationPortal,
        platformInfo: mockPlatformInfo,
        storage: mockStorage,
      );

      reset(mockStorage);
    });

    test('Initialize', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: 'test',
      );

      await manager.initialize(initSettings);

      verify(mockPlatformInfo.getAll()).called(1);
      verify(mockStorage.forceReloadCache()).called(1);
      verify(mockXdgNotificationPortal.actionInvoked).called(1);
    });

    group('Show |', () {
      test('Simple notification', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
        );

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        const String title = 'Title';
        const String body = 'Body';
        await manager.initialize(initSettings);
        await manager.show(notify.id, title, body);

        verify(
          mockXdgNotificationPortal.addNotification(
            '${notify.id}',
            title: title,
            body: body,
            priority: XdgNotificationPriority.normal,
            defaultAction: kDefaultActionName,
            buttons: List<XdgNotificationButton>.empty(),
          ),
        ).called(1);

        verify(mockStorage.insert(notify)).called(1);
      });

      test('Simple notification without title and body', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
        );

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null);

        verify(
          mockXdgNotificationPortal.addNotification(
            '${notify.id}',
            priority: XdgNotificationPriority.normal,
            defaultAction: kDefaultActionName,
            buttons: List<XdgNotificationButton>.empty(),
          ),
        ).called(1);

        verify(mockStorage.insert(notify)).called(1);
      });

      test('Assets details icon', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultIcon: AssetsLinuxIcon('icon.png'),
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          icon: AssetsLinuxIcon('icons/app_icon.png'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(id: 0);

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        final File iconFile = File(path.join(
          'assets',
          details.icon!.content as String,
        ));

        final Uint8List iconBytes = await iconFile.readAsBytes();

        expect(
          verify(
            mockXdgNotificationPortal.addNotification(
              '${notify.id}',
              priority: XdgNotificationPriority.normal,
              defaultAction: kDefaultActionName,
              buttons: List<XdgNotificationButton>.empty(),
              icon: captureAnyNamed('icon'),
            ),
          ).captured.cast<XdgNotificationIconData>().single.data,
          iconBytes,
        );
      });

      test('Byte details icon', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultIcon: AssetsLinuxIcon('icon.png'),
        );

        final ByteDataLinuxIcon icon = ByteDataLinuxIcon(
          LinuxRawIconData(
            data: Uint8List(64),
            width: 8,
            height: 8,
          ),
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          icon: icon,
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(id: 0);

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        expect(
          verify(
            mockXdgNotificationPortal.addNotification(
              '${notify.id}',
              priority: XdgNotificationPriority.normal,
              defaultAction: kDefaultActionName,
              buttons: List<XdgNotificationButton>.empty(),
              icon: captureAnyNamed('icon'),
            ),
          ).captured.cast<XdgNotificationIconData>().single.data,
          icon.iconData.data,
        );
      });

      test('Theme details icon', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultIcon: AssetsLinuxIcon('icon.png'),
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          icon: ThemeLinuxIcon('test'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(id: 0);

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        expect(
          verify(
            mockXdgNotificationPortal.addNotification(
              '${notify.id}',
              priority: XdgNotificationPriority.normal,
              defaultAction: kDefaultActionName,
              buttons: List<XdgNotificationButton>.empty(),
              icon: captureAnyNamed('icon'),
            ),
          ).captured.cast<XdgNotificationIconThemed>().single.names,
          <String>[details.icon!.content as String],
        );
      });

      test('Urgency default', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(id: 0);

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        );

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verify(
          mockXdgNotificationPortal.addNotification(
            '${notify.id}',
            priority: XdgNotificationPriority.normal,
            defaultAction: kDefaultActionName,
            buttons: List<XdgNotificationButton>.empty(),
          ),
        ).called(1);
      });

      test('Urgency high', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(id: 0);

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.critical,
        );

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verify(
          mockXdgNotificationPortal.addNotification(
            '${notify.id}',
            priority: XdgNotificationPriority.urgent,
            defaultAction: kDefaultActionName,
            buttons: List<XdgNotificationButton>.empty(),
          ),
        ).called(1);
      });

      test('Notification actions', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          actions: <LinuxNotificationActionInfo>[
            LinuxNotificationActionInfo(key: '1'),
            LinuxNotificationActionInfo(key: '2'),
          ],
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          actions: <LinuxNotificationAction>[
            LinuxNotificationAction(
              key: '1',
              label: 'action1',
            ),
            LinuxNotificationAction(
              key: '2',
              label: 'action2',
            ),
          ],
        );

        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        expect(
          verify(
            mockXdgNotificationPortal.addNotification(
              '${notify.id}',
              priority: XdgNotificationPriority.normal,
              defaultAction: kDefaultActionName,
              buttons: captureAnyNamed('buttons'),
            ),
          )
              .captured
              .cast<List<XdgNotificationButton>>()
              .map((List<XdgNotificationButton> buttons) => buttons
                  .map((XdgNotificationButton button) => <String, String>{
                        'action': button.action,
                        'label': button.label,
                      })
                  .toList()),
          <List<Map<String, String>>>[
            <Map<String, String>>[
              <String, String>{
                'action': '1',
                'label': 'action1',
              },
              <String, String>{
                'action': '2',
                'label': 'action2',
              },
            ],
          ],
        );
      });
    });

    test('Cancel', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
        defaultSuppressSound: true,
      );

      const LinuxNotificationInfo notify = LinuxNotificationInfo(id: 0);

      when(
        mockStorage.getById(notify.id),
      ).thenAnswer((_) async => notify);
      when(
        mockStorage.removeById(notify.id),
      ).thenAnswer((_) async => true);

      await manager.initialize(initSettings);
      await manager.cancel(notify.id);

      verify(
        mockXdgNotificationPortal.removeNotification('${notify.id}'),
      ).called(1);

      verify(
        mockStorage.removeById(notify.id),
      ).called(1);
    });

    test('Cancel all', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
      );

      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(id: 0),
        LinuxNotificationInfo(id: 1),
      ];

      when(
        mockStorage.getAll(),
      ).thenAnswer((_) async => notifications);
      when(
        mockStorage.removeByIdList(
          notifications.map((LinuxNotificationInfo n) => n.id).toList(),
        ),
      ).thenAnswer((_) async => true);

      await manager.initialize(initSettings);
      await manager.cancelAll();

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          mockXdgNotificationPortal.removeNotification('${notify.id}'),
        ).called(1);
      }

      verify(
        mockStorage.removeByIdList(
          notifications.map((LinuxNotificationInfo n) => n.id).toList(),
        ),
      ).called(1);
    });

    /// When a notification is invoked, the notification is removed from the
    /// storage and the callback is called.
    test('Open notification', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
      );

      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(
          id: 0,
          payload: 'payload1',
        ),
        LinuxNotificationInfo(
          id: 1,
          payload: 'payload2',
        ),
      ];

      for (final LinuxNotificationInfo notify in notifications) {
        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => notify);
      }

      final StreamController<XdgNotificationActionInvokedEvent> controller =
          StreamController<XdgNotificationActionInvokedEvent>.broadcast();

      when(mockXdgNotificationPortal.actionInvoked)
          .thenAnswer((_) => controller.stream);

      await manager.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            mockDidReceiveNotificationResponseCallback,
      );

      for (final LinuxNotificationInfo notify in notifications) {
        controller.add(
          XdgNotificationActionInvokedEvent(
            '${notify.id}',
            'Open notification',
          ),
        );
      }

      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          mockStorage.getById(notify.id),
        ).called(1);
      }

      verify(
        mockDidReceiveNotificationResponseCallback.call(captureAny),
      ).called(notifications.length);

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          mockStorage.removeById(notify.id),
        ).called(1);
      }

      await controller.close();
    });

    test('Notification server capabilities', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(defaultActionName: kDefaultActionName);

      await manager.initialize(initSettings);
      expect(
        await manager.getCapabilities(),
        const LinuxServerCapabilities(
          otherCapabilities: <String>{},
          body: true,
          bodyHyperlinks: true,
          bodyImages: false,
          bodyMarkup: true,
          iconMulti: false,
          iconStatic: false,
          persistence: true,
          sound: false,
          actions: true,
          actionIcons: false,
        ),
      );
    });

    test('Open notification action', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
      );

      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(
          id: 0,
          actions: <LinuxNotificationActionInfo>[
            LinuxNotificationActionInfo(key: '1'),
          ],
        ),
        LinuxNotificationInfo(
          id: 1,
          actions: <LinuxNotificationActionInfo>[
            LinuxNotificationActionInfo(key: '2'),
          ],
        ),
      ];

      for (final LinuxNotificationInfo notify in notifications) {
        when(
          mockStorage.getById(notify.id),
        ).thenAnswer((_) async => notify);
      }

      final StreamController<XdgNotificationActionInvokedEvent> controller =
          StreamController<XdgNotificationActionInvokedEvent>.broadcast();

      when(mockXdgNotificationPortal.actionInvoked)
          .thenAnswer((_) => controller.stream);

      await manager.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            mockDidReceiveNotificationResponseCallback,
      );

      for (final LinuxNotificationInfo notify in notifications) {
        controller.add(
          XdgNotificationActionInvokedEvent(
            '${notify.id}',
            notify.actions.first.key,
          ),
        );
      }

      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          mockStorage.getById(notify.id),
        ).called(1);
      }

      verify(
        mockDidReceiveNotificationResponseCallback.call(captureAny),
      ).called(notifications.length);

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          mockStorage.removeById(notify.id),
        ).called(1);
      }

      await controller.close();
    });
  });
}
