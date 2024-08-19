import "../details.dart";
import "base.dart";

/// A stub implementation for platforms that don't support FFI.
class FlutterLocalNotificationsWindows extends WindowsNotificationsBase {
  @override
  Future<bool> initialize(
    WindowsInitializationSettings settings, {
    DidReceiveNotificationResponseCallback? onNotificationReceived,
  }) async {
    throw UnsupportedError("This platform does not support Windows notifications");
  }

  @override
  void dispose() { }

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
  Future<void> zonedScheduleRawXml(
    int id,
    String xml,
    TZDateTime scheduledDate,
    WindowsNotificationDetails? details,
  ) async { }

  @override
  Future<NotificationUpdateResult> updateBindings({
    required int id,
    required Map<String, String> bindings,
  }) async => NotificationUpdateResult.success;
}
