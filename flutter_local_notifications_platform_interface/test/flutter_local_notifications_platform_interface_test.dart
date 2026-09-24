import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FlutterLocalNotificationsPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterLocalNotificationsPlatform {}

class ImplementsFlutterLocalNotificationsPlatform extends Mock
    implements FlutterLocalNotificationsPlatform {}

class ExtendsFlutterLocalNotificationsPlatform
    extends FlutterLocalNotificationsPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('$FlutterLocalNotificationsPlatform', () {
    test('Cannot be implemented with `implements`', () {
      expect(() {
        FlutterLocalNotificationsPlatform.instance =
            ImplementsFlutterLocalNotificationsPlatform();
      }, throwsAssertionError);
    });

    test('Can be mocked with `implements`', () {
      final FlutterLocalNotificationsPlatformMock mock =
          FlutterLocalNotificationsPlatformMock();
      FlutterLocalNotificationsPlatform.instance = mock;
    });

    test('Can be extended', () {
      FlutterLocalNotificationsPlatform.instance =
          ExtendsFlutterLocalNotificationsPlatform();
    });
  });

  group('$NotificationResponse', () {
    test('supports notification response timestamps', () {
      final DateTime notificationDeliveredAt = DateTime.utc(2026);
      final DateTime responseReceivedAt = DateTime.utc(
        2026,
        DateTime.january,
        2,
      );

      final NotificationResponse response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        notificationDeliveredAt: notificationDeliveredAt,
        responseReceivedAt: responseReceivedAt,
      );

      expect(response.notificationDeliveredAt, notificationDeliveredAt);
      expect(response.responseReceivedAt, responseReceivedAt);
    });
  });
}
