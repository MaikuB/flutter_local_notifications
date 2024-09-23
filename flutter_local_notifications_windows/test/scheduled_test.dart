import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/standalone.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
    appName: 'Test app',
    appUserModelId: 'com.test.test',
    guid: 'a8c22b55-049e-422f-b30f-863694de08c8');

void main() => group('Schedules', () {
      FlutterLocalNotificationsWindows().enableMultithreading();
      final FlutterLocalNotificationsWindows plugin =
          FlutterLocalNotificationsWindows();
      setUpAll(initializeTimeZones);
      setUpAll(() => plugin.initialize(settings));
      tearDownAll(() async {
        await plugin.cancelAll();
        plugin.dispose();
      });

      Future<int> countPending() async =>
          (await plugin.pendingNotificationRequests()).length;
      late final Location location = getLocation('US/Eastern');

      test('work with basic times', () async {
        await plugin.cancelAll();
        expect(await countPending(), 0);
        final TZDateTime now = TZDateTime.now(location);
        final TZDateTime later = now.add(const Duration(days: 1));
        expect(plugin.zonedSchedule(300, null, null, later, null), completes);
        expect(await countPending(), 1);
        expect(plugin.zonedSchedule(301, null, null, later, null), completes);
        expect(await countPending(), 2);
        expect(plugin.zonedSchedule(302, null, null, later, null), completes);
        expect(await countPending(), 3);
      });

      test('do not work with earlier time', () async {
        final TZDateTime now = TZDateTime.now(location);
        final TZDateTime earlier = now.subtract(const Duration(days: 1));
        await plugin.cancelAll();
        expect(await countPending(), 0);
        expect(plugin.zonedSchedule(302, null, null, now, null),
            throwsArgumentError);
        expect(plugin.zonedSchedule(302, null, null, earlier, null),
            throwsArgumentError);
      });
    });
