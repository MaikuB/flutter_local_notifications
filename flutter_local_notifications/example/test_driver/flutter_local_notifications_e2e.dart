import 'dart:io';

import 'package:e2e/e2e.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  setUp(() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  });

  testWidgets(
      'Can resolve platform-specific plugin implementation when run on appropriate platform',
      (WidgetTester tester) async {
    if (Platform.isIOS) {
      expect(
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              .runtimeType,
          IOSFlutterLocalNotificationsPlugin);
    } else if (Platform.isAndroid) {
      expect(
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              .runtimeType,
          AndroidFlutterLocalNotificationsPlugin);
    }
  });
}
