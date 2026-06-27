import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:test/test.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
  appName: 'Test app',
  appUserModelId: 'com.test.test',
  guid: 'a8c22b55-049e-422f-b30f-863694de08c8',
);

const Map<String, String> bindings = <String, String>{
  'title': 'Bindings title',
  'body': 'Bindings body',
};

void main() => group('Bindings', () {
  final FlutterLocalNotificationsWindows plugin =
      FlutterLocalNotificationsWindows();
  setUpAll(() => plugin.initialize(settings: settings));
  tearDownAll(() async {
    await plugin.cancelAll();
    plugin.dispose();
  });

  test('work in simple cases', () async {
    await plugin.show(id: 500, title: '{title}', body: '{body}');
    final NotificationUpdateResult result = await plugin.updateBindings(
      id: 500,
      bindings: bindings,
    );
    expect(result, NotificationUpdateResult.success);
  });

  test('fail when ID is not found in simple cases', () async {
    await plugin.show(id: 501, title: '{title}', body: '{body}');
    final NotificationUpdateResult result = await plugin.updateBindings(
      id: 599,
      bindings: bindings,
    );
    expect(result, NotificationUpdateResult.notFound);
  });

  test('are included in show()', () async {
    await plugin.show(
      id: 502,
      title: '{title}',
      body: '{body}',
      notificationDetails: const WindowsNotificationDetails(bindings: bindings),
    );
  });

  test('fail when notification has been cancelled', () async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await plugin.show(id: 503, title: '{title}', body: '{body}');
    final NotificationUpdateResult result = await plugin.updateBindings(
      id: 503,
      bindings: bindings,
    );
    expect(result, NotificationUpdateResult.success);
    await plugin.cancelAll();
    final NotificationUpdateResult result2 = await plugin.updateBindings(
      id: 503,
      bindings: bindings,
    );
    expect(result2, NotificationUpdateResult.notFound);
  });
});
