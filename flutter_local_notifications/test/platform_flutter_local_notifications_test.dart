import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  group('ios', () {
    const MethodChannel channel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    List<MethodCall> log = <MethodCall>[];
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });
    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin.private(
          FakePlatform(operatingSystem: 'ios'));
    });
    tearDown(() {
      log.clear();
    });
    test('initialize with default parameter values', () async {
      const IOSInitializationSettings initializationSettingsIOS =
          IOSInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(null, initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': true,
          'requestSoundPermission': true,
          'requestBadgePermission': true,
          'defaultPresentAlert': true,
          'defaultPresentSound': true,
          'defaultPresentBadge': true,
        })
      ]);
    });
    test('initialize with all settings off', () async {
      const IOSInitializationSettings initializationSettingsIOS =
          IOSInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
              defaultPresentAlert: false,
              defaultPresentBadge: false,
              defaultPresentSound: false);
      const InitializationSettings initializationSettings =
          InitializationSettings(null, initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'requestAlertPermission': false,
          'requestSoundPermission': false,
          'requestBadgePermission': false,
          'defaultPresentAlert': false,
          'defaultPresentSound': false,
          'defaultPresentBadge': false,
        })
      ]);
    });
  });
}
