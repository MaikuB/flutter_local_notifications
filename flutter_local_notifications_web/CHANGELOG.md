## 1.0.0-dev.2

* **Breaking change** renamed the `details` parameter associated with the `show()` method to `notificationDetails`. This was done to be consistent with other APIs across all of the platforms
* **Breaking changes** removed the `hasPermission` and `isPermissionDenied` boolean properties associated with the `WebFlutterLocalNotificationsPlugin` class. This was done to simplify the plugin as the `permissionStatus` property already exists and can be used
* Fixed an issue where `isSupported` property in the `WebFlutterLocalNotificationsPlugin` was not exposed
* Updated the readme to reference the web-specific APIs from this plugin instead of the APIs in the cross-platform plugin

## 1.0.0-dev.1

* Initial web platform implementation with support for:
  * Immediate notifications
  * Scheduled notifications
  * Periodic notifications
  * Notification actions
  * Foreground callbacks (`onDidReceiveNotificationResponse`)
  * Launch details support
  * Service worker integration for background handling
* Thanks to [Levi Lesches](https://github.com/Levi-Lesches) for the initial implementation and [Gaurav](https://github.com/Gaurav-CareMonitor) for completing the feature
