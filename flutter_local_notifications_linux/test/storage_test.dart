import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications_linux/src/file_system.dart';
import 'package:flutter_local_notifications_linux/src/notification_info.dart';
import 'package:flutter_local_notifications_linux/src/platform_info.dart';
import 'package:flutter_local_notifications_linux/src/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<LinuxPlatformInfo>(),
  MockSpec<FileSystem>(),
  MockSpec<File>(),
])
import 'storage_test.mocks.dart';

void main() {
  group('Notification storage |', () {
    late NotificationStorage storage;
    late final MockLinuxPlatformInfo mockPlatformInfo;
    late final MockFileSystem mockFs;
    late final MockFile mockStorageFile;

    const LinuxPlatformInfoData platformInfo = LinuxPlatformInfoData(
      appName: 'Test',
      assetsPath: 'assets',
      runtimePath: 'run',
    );

    final String fileStoragePath = path.join(
      platformInfo.runtimePath!,
      'notification_plugin_cache.json',
    );

    setUpAll(() {
      mockPlatformInfo = MockLinuxPlatformInfo();
      mockFs = MockFileSystem();
      mockStorageFile = MockFile();

      when(
        mockPlatformInfo.getAll(),
      ).thenAnswer((_) async => platformInfo);
      when(mockFs.open(fileStoragePath)).thenReturn(mockStorageFile);
    });

    setUp(() {
      storage = NotificationStorage(
        platformInfo: mockPlatformInfo,
        fs: mockFs,
      );
    });

    test('Insert', () async {
      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(id: 1),
        LinuxNotificationInfo(id: 2, payload: 'test'),
        LinuxNotificationInfo(
          id: 3,
          payload: 'test',
          actions: <LinuxNotificationActionInfo>[
            LinuxNotificationActionInfo(key: '1'),
            LinuxNotificationActionInfo(key: '2'),
          ],
        ),
      ];

      when(mockStorageFile.existsSync()).thenReturn(false);
      when(
        mockStorageFile.createSync(recursive: true),
      ).thenAnswer((_) => <void>{});
      when(
        mockStorageFile.writeAsStringSync(any),
      ).thenAnswer((_) => <void>{});
      when(mockStorageFile.readAsStringSync()).thenReturn('');

      expect(await storage.insert(notifications[0]), isTrue);
      expect(await storage.insert(notifications[1]), isTrue);
      expect(await storage.insert(notifications[2]), isTrue);

      verify(
        mockStorageFile.createSync(recursive: true),
      ).called(3);
      verify(
        mockStorageFile.writeAsStringSync(
          jsonEncode(<LinuxNotificationInfo>[notifications[0]]),
        ),
      ).called(1);
      verify(
        mockStorageFile.writeAsStringSync(jsonEncode(notifications)),
      ).called(1);
    });

    test('Remove', () async {
      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(id: 1),
        LinuxNotificationInfo(id: 2, payload: 'test'),
      ];

      when(mockStorageFile.existsSync()).thenReturn(true);
      when(
        mockStorageFile.writeAsStringSync(any),
      ).thenAnswer((_) => <void>{});
      when(mockStorageFile.readAsStringSync()).thenReturn('');

      await storage.insert(notifications[0]);
      await storage.insert(notifications[1]);

      expect(await storage.removeById(notifications[0].id), isTrue);
      expect(await storage.removeById(notifications[1].id), isTrue);

      verify(
        mockStorageFile.writeAsStringSync(
          jsonEncode(<LinuxNotificationInfo>[notifications[1]]),
        ),
      ).called(1);
      verify(
        mockStorageFile.writeAsStringSync(
          jsonEncode(<LinuxNotificationInfo>[]),
        ),
      ).called(1);
    });

    test('Get all', () async {
      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(id: 1),
        LinuxNotificationInfo(id: 2, payload: 'test'),
        LinuxNotificationInfo(
            id: 3,
            payload: 'test',
            actions: <LinuxNotificationActionInfo>[
              LinuxNotificationActionInfo(key: '1'),
              LinuxNotificationActionInfo(key: '2'),
            ]),
      ];

      when(mockStorageFile.existsSync()).thenReturn(true);
      when(
        mockStorageFile.writeAsStringSync(any),
      ).thenAnswer((_) => <void>{});

      when(mockStorageFile.readAsStringSync()).thenReturn('');
      expect(await storage.getAll(), <LinuxNotificationInfo>[]);

      when(
        mockStorageFile.readAsStringSync(),
      ).thenReturn(jsonEncode(<LinuxNotificationInfo>[]));
      expect(await storage.getAll(), <LinuxNotificationInfo>[]);

      when(
        mockStorageFile.readAsStringSync(),
      ).thenReturn(jsonEncode(notifications));
      await storage.insert(notifications[0]);
      await storage.insert(notifications[1]);
      await storage.insert(notifications[2]);

      expect(
        await storage.getAll(),
        notifications,
      );
    });

    test('Get by ID', () async {
      const LinuxNotificationInfo notification = LinuxNotificationInfo(
        id: 1,
      );

      when(mockStorageFile.existsSync()).thenReturn(true);
      when(
        mockStorageFile.writeAsStringSync(any),
      ).thenAnswer((_) => <void>{});

      when(mockStorageFile.readAsStringSync()).thenReturn('');
      expect(await storage.getAll(), <LinuxNotificationInfo>[]);

      when(
        mockStorageFile.readAsStringSync(),
      ).thenReturn(jsonEncode(<LinuxNotificationInfo>[]));
      expect(await storage.getAll(), <LinuxNotificationInfo>[]);

      when(
        mockStorageFile.readAsStringSync(),
      ).thenReturn(jsonEncode(notification));
      await storage.insert(notification);

      expect(await storage.getById(2), isNull);
      expect(await storage.getById(notification.id), notification);
    });

    test('Get all, file does not exist', () async {
      when(mockStorageFile.existsSync()).thenReturn(false);
      expect(await storage.getAll(), <LinuxNotificationInfo>[]);
    });

    test('Remove by ID list', () async {
      const List<LinuxNotificationInfo> notifications = <LinuxNotificationInfo>[
        LinuxNotificationInfo(id: 1),
        LinuxNotificationInfo(id: 2, payload: 'test'),
      ];

      when(mockStorageFile.existsSync()).thenReturn(true);
      when(
        mockStorageFile.writeAsStringSync(any),
      ).thenAnswer((_) => <void>{});
      when(mockStorageFile.readAsStringSync()).thenReturn('');

      await storage.insert(notifications[0]);
      await storage.insert(notifications[1]);

      expect(
        await storage.removeByIdList(
          notifications.map((LinuxNotificationInfo n) => n.id).toList(),
        ),
        isTrue,
      );
      expect(await storage.getAll(), <LinuxNotificationInfo>[]);

      verify(
        mockStorageFile.writeAsStringSync(
          jsonEncode(<LinuxNotificationInfo>[]),
        ),
      ).called(1);
    });
  });
}
