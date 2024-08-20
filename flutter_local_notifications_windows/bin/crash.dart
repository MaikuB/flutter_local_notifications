// This file demonstrates how the WinRT APIs are _not_ thread safe.
//
// If you debug this code into the C++, you'll see that the crash happens when
// declaring a local variable. A quick google shows that dynamic libraries are
// only loaded *once* into the Dart VM. This leads me to believe that it is an
// issue with sharing address spaces, and the two local variables exist at the
// same time, causing the crash.
//
// This crash can happen when running `dart test -j 1`, which would otherwise
// fix other concurrency issues with the tests. This crash is not significant
// for users as it depends on having two plugins instantiated at the same time,
// which is not recommended, but I left it here as a demonstration if needed.

import 'dart:isolate';

import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:timezone/standalone.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
  appName: 'Test app',
  appUserModelId: 'com.test.test',
  guid: 'a8c22b55-049e-422f-b30f-863694de08c8',
);

void main() async {
  await Isolate.spawn(bindingsTest, null);
  await Isolate.spawn(scheduledTest, null);

  await Future<void>.delayed(const Duration(seconds: 5));
}

Future<void> scheduledTest(_) async {
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
}

Future<void> bindingsTest(_) async {
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
}
