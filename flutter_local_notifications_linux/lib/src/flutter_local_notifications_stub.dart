import 'flutter_local_notifications_platform_linux.dart';
import 'model/capabilities.dart';
import 'model/initialization_settings.dart';
import 'model/notification_details.dart';

/// A stub implementation to satisfy compilation of multi-platform packages that
/// depend on flutter_local_notifications_linux.
/// This should never actually be created.
///
/// Notably, because flutter_local_notifications needs to manually register
/// flutter_local_notifications_linux, anything with a transitive dependency on
/// flutter_local_notifications will also depend on
/// flutter_local_notifications_linux, not just at
/// the pubspec level but the code level.
class LinuxFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatformLinux {
  /// Errors on attempted instantiation of the stub. It exists only to satisfy
  /// compile-time dependencies, and should never actually be created.
  LinuxFlutterLocalNotificationsPlugin() : assert(false);

  /// Errors on attempted calling of the stub. It exists only to satisfy
  /// compile-time dependencies, and should never actually be called.
  @override
  Future<bool?> initialize(
    LinuxInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    assert(false);
    return null;
  }

  /// Errors on attempted calling of the stub. It exists only to satisfy
  /// compile-time dependencies, and should never actually be called.
  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    LinuxNotificationDetails? notificationDetails,
    String? payload,
  }) async {
    assert(false);
  }

  /// Errors on attempted calling of the stub. It exists only to satisfy
  /// compile-time dependencies, and should never actually be called.
  @override
  Future<LinuxServerCapabilities> getCapabilities() async {
    assert(false);
    throw UnimplementedError();
  }
}
