import 'dart:async';
import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:flutter_local_notifications_linux/src/dbus_wrapper.dart';
import 'package:flutter_local_notifications_linux/src/model/hint.dart';
import 'package:flutter_local_notifications_linux/src/notification_info.dart';
import 'package:flutter_local_notifications_linux/src/notifications_manager.dart';
import 'package:flutter_local_notifications_linux/src/platform_info.dart';
import 'package:flutter_local_notifications_linux/src/storage.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;

import 'mock/mock.dart';

void main() {
  group('Notifications manager |', () {
    late LinuxNotificationManager manager;
    late final DBusWrapper mockDbus;
    late final DBusRemoteObjectSignalStream mockActionInvokedSignal;
    late final DBusRemoteObjectSignalStream mockNotifyClosedSignal;
    late final LinuxPlatformInfo mockPlatformInfo;
    late final NotificationStorage mockStorage;
    late final DidReceiveNotificationResponseCallback
        mockDidReceiveNotificationResponseCallback;

    const LinuxPlatformInfoData platformInfo = LinuxPlatformInfoData(
      appName: 'Test',
      assetsPath: 'assets',
      runtimePath: 'run',
    );

    setUpAll(() {
      registerFallbackValue(
        const NotificationResponse(
          id: 0,
          notificationResponseType:
              NotificationResponseType.selectedNotification,
        ),
      );

      mockDbus = MockDBusWrapper();
      mockActionInvokedSignal = MockDBusRemoteObjectSignalStream();
      mockNotifyClosedSignal = MockDBusRemoteObjectSignalStream();
      mockPlatformInfo = MockLinuxPlatformInfo();
      mockStorage = MockNotificationStorage();
      mockDidReceiveNotificationResponseCallback =
          MockDidReceiveNotificationResponseCallback();

      when(
        () => mockPlatformInfo.getAll(),
      ).thenAnswer((_) async => platformInfo);
      when(
        () => mockStorage.forceReloadCache(),
      ).thenAnswer((_) async => <void>{});
      when(
        () => mockDbus.build(
          destination: 'org.freedesktop.Notifications',
          path: '/org/freedesktop/Notifications',
        ),
      ).thenAnswer((_) => <void>{});
      when(
        () => mockDbus.subscribeSignal('ActionInvoked'),
      ).thenAnswer((_) => mockActionInvokedSignal);
      when(
        () => mockDbus.subscribeSignal('NotificationClosed'),
      ).thenAnswer((_) => mockNotifyClosedSignal);
      when(
        () => mockDidReceiveNotificationResponseCallback.call(any()),
      ).thenAnswer((_) async => <void>{});
    });

    setUp(() {
      manager = LinuxNotificationManager.private(
        dbus: mockDbus,
        platformInfo: mockPlatformInfo,
        storage: mockStorage,
      );

      when(
        () => mockActionInvokedSignal.listen(any()),
      ).thenReturn(FakeStreamSubscription<DBusSignal>());
      when(
        () => mockNotifyClosedSignal.listen(any()),
      ).thenReturn(FakeStreamSubscription<DBusSignal>());
    });

    void mockCloseMethod() => when(
          () => mockDbus.callMethod(
            'org.freedesktop.Notifications',
            'CloseNotification',
            any(),
            replySignature: DBusSignature(''),
          ),
        ).thenAnswer(
          (_) async => DBusMethodSuccessResponse(),
        );

    VerificationResult verifyCloseMethod(int systemId) => verify(
          () => mockDbus.callMethod(
            'org.freedesktop.Notifications',
            'CloseNotification',
            <DBusValue>[DBusUint32(systemId)],
            replySignature: DBusSignature(''),
          ),
        );

    test('Initialize', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: 'test',
      );

      await manager.initialize(initSettings);

      verify(() => mockPlatformInfo.getAll()).called(1);
      verify(() => mockStorage.forceReloadCache()).called(1);
      verify(
        () => mockDbus.build(
          destination: 'org.freedesktop.Notifications',
          path: '/org/freedesktop/Notifications',
        ),
      ).called(1);
      verify(() => mockActionInvokedSignal.listen(any())).called(1);
      verify(() => mockNotifyClosedSignal.listen(any())).called(1);
    });

    const String kDefaultActionName = 'Open notification';

    group('Show |', () {
      List<DBusValue> buildNotifyMethodValues({
        int? replacesId,
        String? appIcon,
        String? title,
        String? body,
        List<String>? actions,
        Map<String, DBusValue>? hints,
        int? expireTimeout,
      }) =>
          <DBusValue>[
            // app_name
            DBusString(platformInfo.appName!),
            // replaces_id
            DBusUint32(replacesId ?? 0),
            // app_icon
            DBusString(appIcon ?? ''),
            // summary
            DBusString(title ?? ''),
            // body
            DBusString(body ?? ''),
            // actions
            DBusArray.string(
                <String>['default', kDefaultActionName, ...?actions]),
            // hints
            DBusDict.stringVariant(hints ?? <String, DBusValue>{}),
            // expire_timeout
            DBusInt32(
              expireTimeout ??
                  const LinuxNotificationTimeout.systemDefault().value,
            ),
          ];

      void mockNotifyMethod(int systemId) => when(
            () => mockDbus.callMethod(
              'org.freedesktop.Notifications',
              'Notify',
              any(),
              replySignature: DBusSignature('u'),
            ),
          ).thenAnswer(
            (_) async => DBusMethodSuccessResponse(
              <DBusValue>[DBusUint32(systemId)],
            ),
          );

      VerificationResult verifyNotifyMethod(List<DBusValue> values) =>
          verify(() => mockDbus.callMethod(
                'org.freedesktop.Notifications',
                'Notify',
                values,
                replySignature: DBusSignature('u'),
              ));

      test('Simple notification', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          title: 'Title',
          body: 'Body',
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, 'Title', 'Body');

        verifyNotifyMethod(values).called(1);
        verify(
          () => mockStorage.insert(notify),
        ).called(1);
      });

      test('Simple notification without title and body', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues();

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null);

        verifyNotifyMethod(values).called(1);
        verify(
          () => mockStorage.insert(notify),
        ).called(1);
      });

      test('Replace previous notification', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo prevNotify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
          payload: 'payload',
        );
        const LinuxNotificationInfo newNotify = LinuxNotificationInfo(
          id: 0,
          systemId: 2,
          payload: 'payload',
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          replacesId: prevNotify.systemId,
          title: 'Title',
          body: 'Body',
        );

        mockNotifyMethod(newNotify.systemId);
        when(
          () => mockStorage.getById(newNotify.id),
        ).thenAnswer((_) async => prevNotify);
        when(
          () => mockStorage.insert(newNotify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(newNotify.id, 'Title', 'Body');

        verifyNotifyMethod(values).called(1);
        verify(
          () => mockStorage.insert(newNotify),
        ).called(1);
      });

      test('Assets details icon', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultIcon: AssetsLinuxIcon('icon.png'),
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          icon: AssetsLinuxIcon('details_icon.png'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          appIcon: path.join(platformInfo.assetsPath!, 'details_icon.png'),
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
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

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'image-data': DBusStruct(
              <DBusValue>[
                DBusInt32(icon.iconData.width),
                DBusInt32(icon.iconData.height),
                DBusInt32(icon.iconData.rowStride),
                DBusBoolean(icon.iconData.hasAlpha),
                DBusInt32(icon.iconData.bitsPerSample),
                DBusInt32(icon.iconData.channels),
                DBusArray.byte(icon.iconData.data),
              ],
            ),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
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

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          appIcon: details.icon!.content as String,
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Default icon', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultIcon: AssetsLinuxIcon('icon.png'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          appIcon: path.join(platformInfo.assetsPath!, 'icon.png'),
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null);

        verifyNotifyMethod(values).called(1);
      });

      test('Timeout', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          timeout: LinuxNotificationTimeout(100),
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          expireTimeout: details.timeout.value,
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Assets sound in details', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultSound: AssetsLinuxSound('default_sound.mp3'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          sound: AssetsLinuxSound('sound.mp3'),
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'sound-file': DBusString(
              path.join(
                platformInfo.assetsPath!,
                details.sound!.content as String,
              ),
            ),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Theme sound in details', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultSound: AssetsLinuxSound('default_sound.mp3'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          sound: ThemeLinuxSound('test'),
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'sound-name': DBusString(details.sound!.content as String),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Default sound', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultSound: AssetsLinuxSound('sound.mp3'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'sound-file': DBusString(
              path.join(
                platformInfo.assetsPath!,
                initSettings.defaultSound!.content as String,
              ),
            ),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null);

        verifyNotifyMethod(values).called(1);
      });

      test('Category', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          category: LinuxNotificationCategory.email,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'category': DBusString(details.category!.name),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Urgency', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'urgency': DBusByte(details.urgency!.value),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Resident notification', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          resident: true,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'resident': DBusBoolean(details.resident),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Suppress sound in details', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          suppressSound: true,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'suppress-sound': DBusBoolean(details.suppressSound),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Default suppress sound', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultSuppressSound: true,
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'suppress-sound': DBusBoolean(initSettings.defaultSuppressSound),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null);

        verifyNotifyMethod(values).called(1);
      });

      test('Transient notification', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          transient: true,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'transient': DBusBoolean(details.transient),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Notification location', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          location: LinuxNotificationLocation(50, 100),
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'x': DBusByte(details.location!.x),
            'y': DBusByte(details.location!.y),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Custom hints', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          customHints: <LinuxNotificationCustomHint>[
            LinuxNotificationCustomHint(
              'array-hint',
              LinuxHintArrayValue<LinuxHintStringValue>(
                <LinuxHintStringValue>[
                  LinuxHintStringValue('1'),
                  LinuxHintStringValue('2'),
                ],
              ),
            ),
            LinuxNotificationCustomHint(
              'bool-hint',
              LinuxHintBoolValue(true),
            ),
            LinuxNotificationCustomHint(
              'byte-hint',
              LinuxHintByteValue(1),
            ),
            LinuxNotificationCustomHint(
              'dict-hint',
              LinuxHintDictValue<LinuxHintByteValue, LinuxHintStringValue>(
                <LinuxHintByteValue, LinuxHintStringValue>{
                  LinuxHintByteValue(1): LinuxHintStringValue('1'),
                  LinuxHintByteValue(2): LinuxHintStringValue('2'),
                },
              ),
            ),
            LinuxNotificationCustomHint(
              'double-hint',
              LinuxHintDoubleValue(1.1),
            ),
            LinuxNotificationCustomHint(
              'int16-hint',
              LinuxHintInt16Value(1),
            ),
            LinuxNotificationCustomHint(
              'int32-hint',
              LinuxHintInt32Value(1),
            ),
            LinuxNotificationCustomHint(
              'int64-hint',
              LinuxHintInt64Value(1),
            ),
            LinuxNotificationCustomHint(
              'string-hint',
              LinuxHintStringValue('test'),
            ),
            LinuxNotificationCustomHint(
              'struct-hint',
              LinuxHintStructValue(
                <LinuxHintValue>[
                  LinuxHintStringValue('test'),
                  LinuxHintBoolValue(true),
                ],
              ),
            ),
            LinuxNotificationCustomHint(
              'uint16-hint',
              LinuxHintUint16Value(1),
            ),
            LinuxNotificationCustomHint(
              'uint32-hint',
              LinuxHintUint32Value(1),
            ),
            LinuxNotificationCustomHint(
              'uint64-hint',
              LinuxHintUint64Value(1),
            ),
            LinuxNotificationCustomHint(
              'variant-hint',
              LinuxHintVariantValue(LinuxHintByteValue(1)),
            ),
          ],
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          hints: <String, DBusValue>{
            'array-hint': DBusArray(
              DBusSignature('s'),
              <DBusValue>[
                const DBusString('1'),
                const DBusString('2'),
              ],
            ),
            'bool-hint': const DBusBoolean(true),
            'byte-hint': const DBusByte(1),
            'dict-hint': DBusDict(
              DBusSignature('y'),
              DBusSignature('s'),
              <DBusValue, DBusValue>{
                const DBusByte(1): const DBusString('1'),
                const DBusByte(2): const DBusString('2'),
              },
            ),
            'double-hint': const DBusDouble(1.1),
            'int16-hint': const DBusInt16(1),
            'int32-hint': const DBusInt32(1),
            'int64-hint': const DBusInt64(1),
            'string-hint': const DBusString('test'),
            'struct-hint': DBusStruct(
              <DBusValue>[
                const DBusString('test'),
                const DBusBoolean(true),
              ],
            ),
            'uint16-hint': const DBusUint16(1),
            'uint32-hint': const DBusUint32(1),
            'uint64-hint': const DBusUint64(1),
            'variant-hint': const DBusVariant(DBusByte(1)),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('File path details icon', () async {
        final LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(
          defaultActionName: kDefaultActionName,
          defaultIcon: FilePathLinuxIcon('/foo/bar/icon.png'),
        );

        final LinuxNotificationDetails details = LinuxNotificationDetails(
          icon: FilePathLinuxIcon('/foo/bar/icon.png'),
        );

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        );

        final List<DBusValue> values =
            buildNotifyMethodValues(appIcon: '/foo/bar/icon.png');

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Notification actions', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
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

        final List<DBusValue> values = buildNotifyMethodValues(
          actions: <String>[
            '1',
            'action1',
            '2',
            'action2',
          ],
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });

      test('Notification action key as icon', () async {
        const LinuxInitializationSettings initSettings =
            LinuxInitializationSettings(defaultActionName: kDefaultActionName);

        const LinuxNotificationInfo notify = LinuxNotificationInfo(
          id: 0,
          systemId: 1,
          actions: <LinuxNotificationActionInfo>[
            LinuxNotificationActionInfo(key: 'media-eject'),
          ],
        );

        const LinuxNotificationDetails details = LinuxNotificationDetails(
          actions: <LinuxNotificationAction>[
            LinuxNotificationAction(
              key: 'media-eject',
              label: 'eject',
            ),
          ],
          actionKeyAsIconName: true,
        );

        final List<DBusValue> values = buildNotifyMethodValues(
          actions: <String>[
            'media-eject',
            'eject',
          ],
          hints: <String, DBusValue>{
            'action-icons': const DBusBoolean(true),
          },
        );

        mockNotifyMethod(notify.systemId);
        when(
          () => mockStorage.getById(notify.id),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.insert(notify),
        ).thenAnswer((_) async => true);

        await manager.initialize(initSettings);
        await manager.show(notify.id, null, null, details: details);

        verifyNotifyMethod(values).called(1);
      });
    });

    test('Cancel', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
        defaultSuppressSound: true,
      );

      const LinuxNotificationInfo notify = LinuxNotificationInfo(
        id: 0,
        systemId: 1,
      );

      mockCloseMethod();

      when(
        () => mockStorage.getById(notify.id),
      ).thenAnswer((_) async => notify);
      when(
        () => mockStorage.removeById(notify.id),
      ).thenAnswer((_) async => true);

      await manager.initialize(initSettings);
      await manager.cancel(notify.id);

      verifyCloseMethod(notify.systemId).called(1);
      verify(
        () => mockStorage.removeById(notify.id),
      ).called(1);
    });

    test('Cancel all', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
      );

      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        ),
        LinuxNotificationInfo(
          id: 1,
          systemId: 2,
        ),
      ];

      mockCloseMethod();

      when(
        () => mockStorage.getAll(),
      ).thenAnswer((_) async => notifications);
      when(
        () => mockStorage.removeByIdList(
          notifications.map((LinuxNotificationInfo n) => n.id).toList(),
        ),
      ).thenAnswer((_) async => true);

      await manager.initialize(initSettings);
      await manager.cancelAll();

      for (final LinuxNotificationInfo notify in notifications) {
        verifyCloseMethod(notify.systemId).called(1);
      }
      verify(
        () => mockStorage.removeByIdList(
          notifications.map((LinuxNotificationInfo n) => n.id).toList(),
        ),
      ).called(1);
    });

    test('Notification closed by system', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
      );

      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        ),
        LinuxNotificationInfo(
          id: 1,
          systemId: 2,
        ),
      ];

      final List<Completer<void>> completers = <Completer<void>>[];
      for (final LinuxNotificationInfo notify in notifications) {
        when(
          () => mockStorage.removeBySystemId(notify.systemId),
        ).thenAnswer((_) async => true);
      }

      when(
        () => mockNotifyClosedSignal.listen(any()),
      ).thenAnswer((Invocation invocation) {
        final Future<void> Function(DBusSignal) callback =
            invocation.positionalArguments.single;
        for (final LinuxNotificationInfo notify in notifications) {
          callback(
            DBusSignal(
              sender: '',
              path: DBusObjectPath('/org/freedesktop/Notifications'),
              interface: 'org.freedesktop.Notifications',
              name: 'NotificationClosed',
              values: <DBusValue>[
                DBusUint32(notify.systemId),
                const DBusUint32(1),
              ],
            ),
          ).then((_) {
            for (final Completer<void> completer in completers) {
              if (!completer.isCompleted) {
                completer.complete();
              }
            }
          });
        }
        return FakeStreamSubscription<DBusSignal>();
      });

      await manager.initialize(initSettings);
      await Future.forEach(
        completers,
        (Completer<void> completer) => completer.future,
      );

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          () => mockStorage.removeBySystemId(notify.systemId),
        ).called(1);
      }
    });

    test('Open notification', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
      );

      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(
          id: 0,
          systemId: 1,
          payload: 'payload1',
        ),
        LinuxNotificationInfo(
          id: 1,
          systemId: 2,
          payload: 'payload2',
        ),
      ];

      final List<Completer<void>> completers = <Completer<void>>[];
      for (final LinuxNotificationInfo notify in notifications) {
        when(
          () => mockStorage.getBySystemId(notify.systemId),
        ).thenAnswer((_) async => notify);
        completers.add(Completer<void>());
      }
      when(
        () => mockActionInvokedSignal.listen(any()),
      ).thenAnswer((Invocation invocation) {
        final Future<void> Function(DBusSignal) callback =
            invocation.positionalArguments.single;
        for (final LinuxNotificationInfo notify in notifications) {
          callback(
            DBusSignal(
              sender: '',
              path: DBusObjectPath('/org/freedesktop/Notifications'),
              interface: 'org.freedesktop.Notifications',
              name: 'ActionInvoked',
              values: <DBusValue>[
                DBusUint32(notify.systemId),
                const DBusString('default'),
              ],
            ),
          ).then((_) {
            for (final Completer<void> completer in completers) {
              if (!completer.isCompleted) {
                completer.complete();
              }
            }
          });
        }
        return FakeStreamSubscription<DBusSignal>();
      });

      await manager.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            mockDidReceiveNotificationResponseCallback,
      );
      await Future.forEach(
        completers,
        (Completer<void> completer) => completer.future,
      );

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          () => mockStorage.getBySystemId(notify.systemId),
        ).called(1);
      }
    });

    test('Notification server capabilities', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(defaultActionName: kDefaultActionName);

      when(
        () => mockDbus.callMethod(
          'org.freedesktop.Notifications',
          'GetCapabilities',
          <DBusValue>[],
          replySignature: DBusSignature('as'),
        ),
      ).thenAnswer(
        (_) async => DBusMethodSuccessResponse(
          <DBusValue>[
            DBusArray(
              DBusSignature('s'),
              <DBusValue>[
                const DBusString('body'),
                const DBusString('body-hyperlinks'),
                const DBusString('body-images'),
                const DBusString('body-markup'),
                const DBusString('icon-multi'),
                const DBusString('icon-static'),
                const DBusString('persistence'),
                const DBusString('sound'),
                const DBusString('test-cap'),
                const DBusString('actions'),
                const DBusString('action-icons'),
              ],
            ),
          ],
        ),
      );

      await manager.initialize(initSettings);
      expect(
        await manager.getCapabilities(),
        const LinuxServerCapabilities(
          otherCapabilities: <String>{'test-cap'},
          body: true,
          bodyHyperlinks: true,
          bodyImages: true,
          bodyMarkup: true,
          iconMulti: true,
          iconStatic: true,
          persistence: true,
          sound: true,
          actions: true,
          actionIcons: true,
        ),
      );
    });

    test('Get system ID map', () async {
      const LinuxInitializationSettings initSettings =
          LinuxInitializationSettings(
        defaultActionName: kDefaultActionName,
      );

      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(
          id: 0,
          systemId: 1,
        ),
        LinuxNotificationInfo(
          id: 1,
          systemId: 2,
        ),
      ];

      when(
        () => mockStorage.getAll(),
      ).thenAnswer((_) async => notifications);

      await manager.initialize(initSettings);
      expect(
        await manager.getSystemIdMap(),
        Map<int, int>.fromEntries(
          notifications.map(
            (LinuxNotificationInfo notify) => MapEntry<int, int>(
              notify.id,
              notify.systemId,
            ),
          ),
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
          systemId: 1,
          actions: <LinuxNotificationActionInfo>[
            LinuxNotificationActionInfo(key: '1'),
          ],
        ),
        LinuxNotificationInfo(
          id: 1,
          systemId: 2,
          actions: <LinuxNotificationActionInfo>[
            LinuxNotificationActionInfo(key: '2'),
          ],
        ),
      ];

      final List<Completer<void>> completers = <Completer<void>>[];
      for (final LinuxNotificationInfo notify in notifications) {
        when(
          () => mockStorage.getBySystemId(notify.systemId),
        ).thenAnswer((_) async => notify);
        completers.add(Completer<void>());
      }
      when(
        () => mockActionInvokedSignal.listen(any()),
      ).thenAnswer((Invocation invocation) {
        final Future<void> Function(DBusSignal) callback =
            invocation.positionalArguments.single;
        for (final LinuxNotificationInfo notify in notifications) {
          callback(
            DBusSignal(
              sender: '',
              path: DBusObjectPath('/org/freedesktop/Notifications'),
              interface: 'org.freedesktop.Notifications',
              name: 'ActionInvoked',
              values: <DBusValue>[
                DBusUint32(notify.systemId),
                DBusString(notify.actions[0].key),
              ],
            ),
          ).then((_) {
            for (final Completer<void> completer in completers) {
              if (!completer.isCompleted) {
                completer.complete();
              }
            }
          });
        }
        return FakeStreamSubscription<DBusSignal>();
      });

      await manager.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            mockDidReceiveNotificationResponseCallback,
      );
      await Future.forEach(
        completers,
        (Completer<void> completer) => completer.future,
      );

      for (final LinuxNotificationInfo notify in notifications) {
        verify(
          () => mockStorage.getBySystemId(notify.systemId),
        ).called(1);
      }
    });
  });
}
