import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/types.dart';

export 'src/helpers.dart';
export 'src/typedefs.dart';
export 'src/types.dart';

/// The interface that all implementations of flutter_local_notifications must
/// implement.
abstract class FlutterLocalNotificationsPlatform extends PlatformInterface {
  /// Constructs an instance of [FlutterLocalNotificationsPlatform].
  FlutterLocalNotificationsPlatform() : super(token: _token);

  static late FlutterLocalNotificationsPlatform _instance;

  static final Object _token = Object();

  /// The default instance of [FlutterLocalNotificationsPlatform] to use.
  static FlutterLocalNotificationsPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterLocalNotificationsPlatform] when they register
  /// themselves.
  static set instance(FlutterLocalNotificationsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns info on if a notification had been used to launch the application.
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    throw UnimplementedError(
        'getNotificationAppLaunchDetails() has not been implemented');
  }

  /// Show a notification with an optional payload that will be passed back to
  /// the app when a notification is tapped on.
  Future<void> show(int id, String? title, String? body,
      {String? payload}) async {
    throw UnimplementedError('show() has not been implemented');
  }

  /// Periodically show a notification using the specified interval.
  /// For example, specifying a hourly interval means the first time the
  /// notification will be an hour after the method has been called and then
  /// every hour after that.
  Future<void> periodicallyShow(
      int id, String? title, String? body, RepeatInterval repeatInterval) {
    throw UnimplementedError('periodicallyShow() has not been implemented');
  }

  /// Cancel/remove the notification with the specified id.
  ///
  /// This applies to notifications that have been scheduled and those that
  /// have already been presented.
  Future<void> cancel(int id) async {
    throw UnimplementedError('cancel() has not been implemented');
  }

  /// Cancels/removes all notifications. This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancelAll() async {
    throw UnimplementedError('cancelAll() has not been implemented');
  }

  /// Returns a list of notifications pending to be delivered/shown
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    throw UnimplementedError(
        'pendingNotificationRequest() has not been implemented');
  }

  /// Returns the list of active notifications shown by the application that
  /// haven't been dismissed/removed.
  ///
  /// Throws a [PlatformException] with an `unsupported_os_version` error code
  /// when the OS version is older than what is supported to have results
  /// returned. On platforms that don't support the method at all,
  /// it will throw an [UnimplementedError].
  Future<List<ActiveNotification>> getActiveNotifications() {
    throw UnimplementedError(
        'getActiveNotifications() has not been implemented');
  }
}
