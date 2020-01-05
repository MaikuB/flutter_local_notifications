import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/notification_app_launch_details.dart';

export 'src/notification_app_launch_details.dart';

abstract class FlutterLocalNotificationsPlatform extends PlatformInterface {
  FlutterLocalNotificationsPlatform() : super(token: _token);

  static final Object _token = Object();

  /// Returns info on if a notification had been used to launch the application.
  Future<NotificationAppLaunchDetails> getNotificationAppLaunchDetails() async {
    throw UnimplementedError(
        'getNotificationAppLaunchDetails() has not been implemented');
  }

  /// Show a notification with an optional payload that will be passed back to the app when a notification is tapped on.
  Future<void> show(int id, String title, String body, {String payload}) async {
    throw UnimplementedError('show() has not been implemented');
  }

  /// Cancel/remove the notification with the specified id. This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancel(int id) async {
    throw UnimplementedError('cancel() has not been implemented');
  }

  /// Cancels/removes all notifications. This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancelAll() async {
    throw UnimplementedError('cancelAll() has not been implemented');
  }
}
