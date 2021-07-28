import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

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
    extends FlutterLocalNotificationsPlatform {
  /// Errors on attempted instantiation of the stub. It exists only to satisfy
  /// compile-time dependencies, and should never actually be created.
  LinuxFlutterLocalNotificationsPlugin() : assert(false);
}
