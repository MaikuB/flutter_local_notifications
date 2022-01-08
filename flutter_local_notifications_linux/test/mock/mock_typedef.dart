import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

// ignore: one_member_abstracts
abstract class _SelectNotificationCallback {
  Future<dynamic> call(String? payload);
}

// ignore: one_member_abstracts
abstract class _SelectNotificationActionCallback {
  Future<dynamic> call(NotificationActionDetails details);
}

class MockSelectNotificationCallback extends Mock
    implements _SelectNotificationCallback {}

class MockSelectNotificationActionCallback extends Mock
    implements _SelectNotificationActionCallback {}
