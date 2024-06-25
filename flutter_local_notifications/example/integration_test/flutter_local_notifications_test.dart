import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const DarwinInitializationSettings initializationSettingsMacOS =
      DarwinInitializationSettings();
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: initializationSettingsLinux);
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  group('initialize()', () {
    setUpAll(() async {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    });
    testWidgets('can initialise', (WidgetTester tester) async {
      final bool? initialised = await flutterLocalNotificationsPlugin
          .initialize(initializationSettings);
      expect(initialised, isTrue);
    });

    testWidgets(
        'initialize with settings equal to null for the targeting platform '
        'should throw an ArgumentError', (WidgetTester tester) async {
      const InitializationSettings initializationSettings =
          InitializationSettings();
      late Matcher errorMessageMatcher;
      if (Platform.isAndroid) {
        errorMessageMatcher = equals(
            'Android settings must be set when targeting Android platform.');
      } else if (Platform.isIOS) {
        errorMessageMatcher =
            equals('iOS settings must be set when targeting iOS platform.');
      } else if (Platform.isLinux) {
        equals('Linux settings must be set when targeting Linux platform.');
      } else if (Platform.isMacOS) {
        errorMessageMatcher =
            equals('macOS settings must be set when targeting macOS platform.');
      } else {
        errorMessageMatcher = anything;
      }
      expect(
          () async => await flutterLocalNotificationsPlugin
              .initialize(initializationSettings),
          throwsA(isArgumentError.having(
              (ArgumentError e) => e.message, 'message', errorMessageMatcher)));
    });
  });
  group('resolvePlatformSpecificImplementation()', () {
    setUpAll(() async {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    });

    if (Platform.isIOS) {
      testWidgets('Can resolve iOS plugin implementation when running on iOS',
          (WidgetTester tester) async {
        expect(
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>(),
            isA<IOSFlutterLocalNotificationsPlugin>());
      });
    }

    if (Platform.isAndroid) {
      testWidgets(
          'Can resolve Android plugin implementation when running on Android',
          (WidgetTester tester) async {
        expect(
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>(),
            isA<AndroidFlutterLocalNotificationsPlugin>());
      });
    }

    if (Platform.isIOS) {
      testWidgets(
          'Returns null trying to resolve Android plugin implementation when '
          'running on iOS', (WidgetTester tester) async {
        expect(
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>(),
            isNull);
      });
    }
    if (Platform.isAndroid) {
      testWidgets(
          'Returns null trying to resolve iOS plugin implementation when '
          'running on Android', (WidgetTester tester) async {
        expect(
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>(),
            isNull);
      });
    }

    testWidgets('Throws argument error requesting base class type',
        (WidgetTester tester) async {
      expect(
          () => flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation(),
          throwsArgumentError);
    });
  });
}
