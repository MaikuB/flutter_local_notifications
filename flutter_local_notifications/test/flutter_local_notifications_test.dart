import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const int id = 0;
  const String title = 'title';
  const String body = 'body';
  const String payload = 'payload';
  TestWidgetsFlutterBinding.ensureInitialized();
  final MockFlutterLocalNotificationsPlugin mock =
      MockFlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlatform.instance = mock;

  test('show', () async {
    await mock.show(id, title, body, payload: payload);
    verify(mock.show(id, title, body, payload: captureAnyNamed('payload')));
  });

  test('cancel', () async {
    await mock.cancel(id);
    verify(mock.cancel(id));
  });

  test('cancelAll', () async {
    await mock.cancelAll();
    verify(mock.cancelAll());
  });

  test('pendingNotificationRequests', () async {
    await mock.pendingNotificationRequests();
    verify(mock.pendingNotificationRequests());
  });

  test('getNotificationAppLaunchDetails', () async {
    await mock.getNotificationAppLaunchDetails();
    verify(mock.getNotificationAppLaunchDetails());
  });

  test(
      'Throws assertion error when creating an IOSNotificationAttachment with '
      'no file path', () {
    expect(() => IOSNotificationAttachment(null), throwsAssertionError);
  });

  test('Creates IOSNotificationAttachment when file path is specified', () {
    expect(
        const IOSNotificationAttachment(''), isA<IOSNotificationAttachment>());
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockFlutterLocalNotificationsPlugin extends Mock
    with
        MockPlatformInterfaceMixin // ignore: prefer_mixin
    implements
        FlutterLocalNotificationsPlatform {}
