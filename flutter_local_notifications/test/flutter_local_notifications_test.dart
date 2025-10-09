import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/platform_specifics/darwin/mappers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final MockFlutterLocalNotificationsPlugin mock =
      MockFlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlatform.instance = mock;

  test('Creates DarwinNotificationAttachment when file path is specified', () {
    expect(const DarwinNotificationAttachment(''),
        isA<DarwinNotificationAttachment>());
  });

  group('providesAppNotificationSettings tests', () {
    test('initialization defaults to false', () {
      const DarwinInitializationSettings settings =
          DarwinInitializationSettings();
      expect(settings.requestProvidesAppNotificationSettings, false);
    });

    test('initialization can be set to true', () {
      const DarwinInitializationSettings settings =
          DarwinInitializationSettings(
        requestProvidesAppNotificationSettings: true,
      );
      expect(settings.requestProvidesAppNotificationSettings, true);
    });

    test('maps correctly to platform specific map', () {
      const DarwinInitializationSettings settings =
          DarwinInitializationSettings(
        requestProvidesAppNotificationSettings: true,
      );
      final Map<String, Object> map = settings.toMap();
      expect(map['requestProvidesAppNotificationSettings'], true);
    });

    test(
        'NotificationsEnabledOptions stores '
        'providesAppNotificationSettings value', () async {
      const NotificationsEnabledOptions options = NotificationsEnabledOptions(
        isEnabled: true,
        isSoundEnabled: true,
        isAlertEnabled: true,
        isBadgeEnabled: true,
        isProvisionalEnabled: false,
        isCriticalEnabled: false,
        isProvidesAppNotificationSettingsEnabled: true,
      );
      expect(options.isProvidesAppNotificationSettingsEnabled, true);
    });
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockFlutterLocalNotificationsPlugin extends Mock
    with
        MockPlatformInterfaceMixin // ignore: prefer_mixin
    implements
        FlutterLocalNotificationsPlatform {}
