# flutter_local_notifications_platform_interface

A common platform interface for the [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) plugin.

## Usage

Platform-specific implementations should extend from the `FlutterLocalNotificationsPlatform` class. Upon registering the plugin, the default implementation `FlutterLocalNotificationsPlatform` can be set by calling `FlutterLocalNotificationsPlatform.instance = MyFlutterLocalNotificationsPlatform()` where `MyFlutterLocalNotificationsPlatform()` represents the platform-specific implementation.
