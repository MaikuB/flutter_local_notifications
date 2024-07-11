import "../details.dart";
import "base.dart";

class FlutterLocalNotificationsWindows extends WindowsNotificationsBase {
  FlutterLocalNotificationsWindows() {
    throw UnimplementedError("This is just the stub implementation. Do not use this");
  }

  @override
  Future<bool> initialize(
    WindowsInitializationSettings settings, {
    DidReceiveNotificationResponseCallback? onNotificationReceived,
  }) async => false;

  @override
  Future<void> cancel(int id) async { }

  @override
  Future<void> cancelAll() async { }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => [];

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async => null;

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async => [];

  @override
  Future<void> periodicallyShow(int id, String? title, String? body, RepeatInterval repeatInterval) async { }

  @override
  Future<void> periodicallyShowWithDuration(int id, String? title, String? body, Duration repeatDurationInterval) async { }

  @override
  Future<void> show(int id, String? title, String? body, {String? payload, WindowsNotificationDetails? details}) async { }

  @override
  Future<void> showRawXml({required int id, required String xml, Map<String, String> bindings = const {}}) async { }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    WindowsNotificationDetails? details, {
    String? payload,
  }) async { }

  @override
  Future<NotificationUpdateResult> updateBindings({
    required int id,
    required Map<String, String> bindings,
  }) async => NotificationUpdateResult.success;
}
