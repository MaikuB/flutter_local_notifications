import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/standalone.dart';

const WindowsInitializationSettings goodSettings =
    WindowsInitializationSettings(
      appName: 'test',
      appUserModelId: 'com.test.test',
      guid: 'a8c22b55-049e-422f-b30f-863694de08c8',
    );

const WindowsInitializationSettings badSettings = WindowsInitializationSettings(
  appName: 'test',
  appUserModelId: 'com.test.test',
  guid: '123',
);

void main() => group('Plugin', () {
  setUpAll(initializeTimeZones);

  test('initializes safely', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    final bool result = await plugin.initialize(settings: goodSettings);
    expect(result, isTrue);
    plugin.dispose();
  });

  test('catches bad GUIDs', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    expect(plugin.initialize(settings: badSettings), throwsArgumentError);
    plugin.dispose();
  });

  test('cannot be used before initializing', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    final WindowsProgressBar progress = WindowsProgressBar(
      id: 'progress',
      status: 'Testing',
      value: 0,
    );
    final TZDateTime now = TZDateTime.local(2024, 7, 18);
    expect(plugin.cancel(id: 0), throwsStateError);
    expect(plugin.cancelAll(), throwsStateError);
    expect(plugin.getActiveNotifications(), throwsStateError);
    expect(plugin.getNotificationAppLaunchDetails(), throwsStateError);
    expect(plugin.pendingNotificationRequests(), throwsStateError);
    expect(plugin.show(id: 0, title: 'Title', body: 'Body'), throwsStateError);
    expect(plugin.showRawXml(id: 0, xml: ''), throwsStateError);
    expect(
      plugin.updateBindings(id: 0, bindings: <String, String>{}),
      throwsStateError,
    );
    expect(
      plugin.updateProgressBar(progressBar: progress, notificationId: 0),
      throwsStateError,
    );
    expect(
      plugin.zonedSchedule(
        id: 0,
        title: null,
        body: null,
        scheduledDate: now,
        payload: null,
      ),
      throwsStateError,
    );
    plugin.dispose();
  });

  test('cannot be used after disposed', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    final WindowsProgressBar progress = WindowsProgressBar(
      id: 'progress',
      status: 'Testing',
      value: 0,
    );
    final TZDateTime now = TZDateTime.local(2024, 7, 18);
    await plugin.initialize(settings: goodSettings);
    plugin.dispose();
    expect(plugin.cancel(id: 0), throwsStateError);
    expect(plugin.cancelAll(), throwsStateError);
    expect(plugin.getActiveNotifications(), throwsStateError);
    expect(plugin.getNotificationAppLaunchDetails(), throwsStateError);
    expect(plugin.pendingNotificationRequests(), throwsStateError);
    expect(plugin.show(id: 0, title: 'Title', body: 'Body'), throwsStateError);
    expect(plugin.showRawXml(id: 0, xml: ''), throwsStateError);
    expect(
      plugin.updateBindings(id: 0, bindings: <String, String>{}),
      throwsStateError,
    );
    expect(
      plugin.updateProgressBar(progressBar: progress, notificationId: 0),
      throwsStateError,
    );
    expect(
      plugin.zonedSchedule(
        id: 0,
        title: null,
        body: null,
        scheduledDate: now,
        payload: null,
      ),
      throwsStateError,
    );
    plugin.dispose();
  });

  test('does not support repeating notifications', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    await plugin.initialize(settings: goodSettings);
    expect(
      plugin.periodicallyShow(
        id: 0,
        title: null,
        body: null,
        repeatInterval: RepeatInterval.everyMinute,
      ),
      throwsUnsupportedError,
    );
    expect(
      plugin.periodicallyShowWithDuration(
        id: 0,
        title: null,
        body: null,
        repeatDurationInterval: Duration.zero,
      ),
      throwsUnsupportedError,
    );
    plugin.dispose();
  });
});
