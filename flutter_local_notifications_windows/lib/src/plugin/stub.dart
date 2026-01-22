import '../details.dart';
import 'base.dart';

/// The Windows implementation of `package:flutter_local_notifications`.
class FlutterLocalNotificationsWindows extends WindowsNotificationsBase {
  @override
  Future<bool> initialize({
    required WindowsInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    throw UnsupportedError(
      'This platform does not support Windows notifications',
    );
  }

  @override
  void dispose() {}

  @override
  Future<void> cancel({required int id}) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async =>
      <ActiveNotification>[];

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => null;

  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => <PendingNotificationRequest>[];

  @override
  Future<void> periodicallyShow({
    required int id,
    String? title,
    String? body,
    required RepeatInterval repeatInterval,
  }) async {}

  @override
  Future<void> periodicallyShowWithDuration({
    required int id,
    String? title,
    String? body,
    required Duration repeatDurationInterval,
  }) async {}

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
    WindowsNotificationDetails? notificationDetails,
  }) async {}

  @override
  Future<void> showRawXml({
    required int id,
    required String xml,
    Map<String, String> bindings = const <String, String>{},
  }) async {}

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required TZDateTime scheduledDate,
    WindowsNotificationDetails? notificationDetails,
    String? payload,
  }) async {}

  @override
  Future<void> zonedScheduleRawXml({
    required int id,
    required String xml,
    required TZDateTime scheduledDate,
  }) async {}
  @override
  Future<NotificationUpdateResult> updateBindings({
    required int id,
    required Map<String, String> bindings,
  }) async => NotificationUpdateResult.success;

  @override
  bool isValidXml(String xml) => false;
}
