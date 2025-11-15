import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:flutter_local_notifications_windows/src/ffi/mock.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/standalone.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
    appName: 'Test app',
    appUserModelId: 'com.test.test',
    guid: 'a8c22b55-049e-422f-b30f-863694de08c8');

void main() => group('Schedules', () {
      final FlutterLocalNotificationsWindows plugin =
          FlutterLocalNotificationsWindows.withBindings(MockBindings());
      setUpAll(initializeTimeZones);
      setUpAll(() => plugin.initialize(settings));
      tearDownAll(() async {
        await plugin.cancelAll();
        plugin.dispose();
      });

      late final Location location = getLocation('US/Eastern');

      test('do not work with earlier time', () async {
        final TZDateTime now = TZDateTime.now(location);
        final TZDateTime earlier = now.subtract(const Duration(days: 1));
        final TZDateTime later = now.add(const Duration(days: 1));
        expect(
          plugin.zonedSchedule(302, null, null, earlier, null),
          throwsArgumentError,
        );
        expect(
          plugin.zonedSchedule(302, null, null, later, null),
          completes,
        );
      });
    });
