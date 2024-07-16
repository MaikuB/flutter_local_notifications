import "dart:isolate";

import "package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart";
import "package:timezone/standalone.dart";

const settings = WindowsInitializationSettings(appName: "Test app", appUserModelId: "com.test.test", guid: "a8c22b55-049e-422f-b30f-863694de08c8");

void main() async {
  await Isolate.spawn(main2, null);
  await Isolate.spawn(main3, null);

  await Future<void>.delayed(const Duration(seconds: 5));
}

Future<void> main3(_) async {
  await Future<void>.delayed(const Duration(seconds: 4));
  // Scheduled:
  final plugin = FlutterLocalNotificationsWindows();
  await plugin.initialize(settings);
  await initializeTimeZone();

  final location = getLocation("US/Eastern");
  final now = TZDateTime.now(location);
  final later = now.add(const Duration(days: 1));
  await plugin.zonedSchedule(300, null, null, later, null);
  await plugin.zonedSchedule(301, null, null, later, null);
  await plugin.zonedSchedule(302, null, null, later, null);
}

Future<void> main2(_) async {
  final bindings = {"title": "Bindings title", "body": "Bindings body"};
  await Future<void>.delayed(const Duration(seconds: 1));
  // Bindings:
  final plugin = FlutterLocalNotificationsWindows();
  await plugin.initialize(settings);
  await plugin.show(503, "{title}", "{body}");
  await Future<void>.delayed(const Duration(milliseconds: 100));
  await plugin.updateBindings(id: 503, bindings: bindings);
  await plugin.updateBindings(id: 503, bindings: bindings);
}
