import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

// ignore: one_member_abstracts
abstract class _DidReceiveNotificationResponseCallback {
  Future<dynamic> call(NotificationResponse notificationResponse);
}

class MockDidReceiveNotificationResponseCallback extends Mock
    implements _DidReceiveNotificationResponseCallback {}
