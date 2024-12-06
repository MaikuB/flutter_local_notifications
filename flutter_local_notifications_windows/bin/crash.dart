// This file demonstrates how the plugin is _not_ thread safe.
//
// This crash can happen when running `dart test -j 1`, which would otherwise
// fix other concurrency issues with the tests. This crash is not significant
// for users as it depends on having two plugins instantiated at the same time,
// which is not recommended, but I left it here as a demonstration if needed.
//
// The experimental function `enableMultithreading()` can fix the issues
// demonstrated by this file, but when testing with `dart test -j 1`, a crash
// occurs as `XmlDocument doc;`, a seemingly harmless statement. I have not
// been able to deduce the cause, and `enableMultithreading()` does not fix it.
// If we can figure that out, tests can be run with `-j 1` and race conditions
// would be eliminated from the tests.

// ignore_for_file: avoid_print

import 'dart:isolate';

import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:timezone/standalone.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
  appName: 'Test app',
  appUserModelId: 'com.test.test',
  guid: 'a8c22b55-049e-422f-b30f-863694de08c8',
);

void main() async {
  print('Starting tests');
  await Isolate.spawn(bindingsTest, null);
  await Isolate.spawn(scheduledTest, null);

  // This is the critical line. Removing this causes crashes in the Windows SDK
  // ignore: invalid_use_of_visible_for_testing_member
  FlutterLocalNotificationsWindows().enableMultithreading();

  await Future<void>.delayed(const Duration(seconds: 5));
  print('Done. Scheduled and binding tests should have completed');
}

Future<void> scheduledTest(_) async {
  print('Starting scheduled test');
  await Future<void>.delayed(const Duration(seconds: 4));
  final FlutterLocalNotificationsWindows plugin =
      FlutterLocalNotificationsWindows();
  await plugin.initialize(settings);
  await initializeTimeZone();
  final Location location = getLocation('US/Eastern');
  final TZDateTime now = TZDateTime.now(location);
  final TZDateTime later = now.add(const Duration(days: 1));
  await plugin.zonedSchedule(300, null, null, later, null);
  await plugin.zonedSchedule(301, null, null, later, null);
  await plugin.zonedSchedule(302, null, null, later, null);
  print('Scheduled test complete');
}

Future<void> bindingsTest(_) async {
  print('Starting bindings test');
  final Map<String, String> bindings = <String, String>{
    'title': 'Bindings title',
    'body': 'Bindings body'
  };
  await Future<void>.delayed(const Duration(seconds: 1));
  final FlutterLocalNotificationsWindows plugin =
      FlutterLocalNotificationsWindows();
  await plugin.initialize(settings);
  await plugin.show(503, '{title}', '{body}');
  await Future<void>.delayed(const Duration(milliseconds: 100));
  await plugin.updateBindings(id: 503, bindings: bindings);
  await plugin.updateBindings(id: 503, bindings: bindings);
  print('Bindings test complete');
}
