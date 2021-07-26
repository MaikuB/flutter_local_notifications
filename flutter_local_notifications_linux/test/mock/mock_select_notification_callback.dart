import 'package:mocktail/mocktail.dart';

// ignore: one_member_abstracts
abstract class _SelectNotificationCallback {
  Future<dynamic> call(String? payload);
}

class MockSelectNotificationCallback extends Mock
    implements _SelectNotificationCallback {}
