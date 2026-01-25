## [2.0.0]

* **Breaking change** bumped minimum Flutter SDK requirement to 3.32.0 and Dart SDK requirement to 3.8.0
* **Breaking changes** the positional parameters in the following methods have now been converted to named parameters
  * `initialize()`
  * `show()`
  * `showRawXml()`
  * `periodicallyShow()`
  * `periodicallyShowWithDuration()`
  * `cancel()`
  * `zonedSchedule()`
  * `zonedScheduleRawXml()`
* **Breaking changes** to align with the main the plugin, the following parameters have been renamed
  * the `details` parameter in the `show()` and `zonedSchedule()` methods has been renamed to `notificationDetails`
  * the `onNotificationReceived` in the `initialize()` method has been renamed to `onDidReceiveNotificationResponse`
* **Breaking change** removed the `details` parameter from the `zonedScheduleRawXml()` method as it was not actually used. Thanks to the PR from [Levi Lesches](https://github.com/Levi-Lesches)
* Bumped `ffigen` and regenerated bindings. Credits to [Levi Lesches](https://github.com/Levi-Lesches) who originally looked at this before the plugin had its minimum Flutter version bumped
* Added `flutter_lints` to apply linter rules

## [1.0.3]

* Fixed issue where non-ASCII characters for the notification [application name](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsInitializationSettings/appName.html) weren't being displayed properly. Thanks to the PR from [yoyoIU](https://github.com/yoyo930021)

## [1.0.2]

* Fixed issue [#2648](https://github.com/MaikuB/flutter_local_notifications/issues/2648) where non-ASCII characters in the notification payload were not being handled properly. Thanks to the PR from [yoyoIU](https://github.com/yoyo930021)

## [1.0.1]

* Fixed issue [#2651](https://github.com/MaikuB/flutter_local_notifications/issues/2651) where unresolved symbols occurred with changes in introduced in newer Windows SDKs. Thanks to the PR from [Sebastien](https://github.com/Sebastien-VZN)

## [1.0.0]

* Initial release for Windows. Thanks to PR [Levi Lesches](https://github.com/Levi-Lesches) that continued the work done initially done by [Kenneth](https://github.com/kennethnym) and [lightrabbit](https://github.com/lightrabbit)