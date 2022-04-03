import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

// ignore: one_member_abstracts
abstract class _DidReceiveForegroundNotificationResponseCallback {
  Future<dynamic> call(NotificationResponse notificationResponse);
}

class MockDidReceiveForegroundNotificationResponseCallback extends Mock
    implements _DidReceiveForegroundNotificationResponseCallback {}
