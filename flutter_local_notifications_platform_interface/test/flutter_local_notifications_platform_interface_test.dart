import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
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
      }, throwsA(isInstanceOf<AssertionError>()));
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
}
