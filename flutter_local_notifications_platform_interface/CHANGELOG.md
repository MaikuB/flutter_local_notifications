## [9.0.0]

*  **Breaking change** bumped minimum Flutter SDK requirement to 3.22.0 and Dart SDK requirement to 3.4.0
*  Bumped minimum `plugin_platform_interface` version to 2.1.8
* Added `data` property to `NotificationResponse` class to support notification actions on Windows. Thanks to the PR from [Levi Lesches](https://github.com/Levi-Lesches)

## [8.0.0]

* **Breaking change** Bumped minimum Flutter SDK requirement to 3.13

## [7.2.0]

* Added `periodicallyShowWithDuration()` and corresponding `validateRepeatDurationInterval()` helper method to ensure duration is at least a minute

## [7.1.0]

* [Android] `bigText` has added to `ActiveNotification` that allows getting information about the longer text associated with a notification displayed using the big text style. Thanks to the PR from [vulpeep](https://github.com/vulpeep)

## [7.0.0+1]

* Bumped maximum Dart SDK constraint

## [7.0.0]

* **Breaking change** the `id` property of the `ActiveNotification` class is now nullable to help indicate that the notification may not have been created by the plugin e.g. it was from Firebase Cloud Messaging. Thanks to the PR from [frankvollebregt](https://github.com/frankvollebregt)
* Updated minimum Flutter SDK constraint to 3.0 and minimum Dart SDK constraint to 2.17 to align with versions used by actual plugin implementation
* Bumped `mockito` dev dependency

## [6.0.0]

* **Breaking change** the parameters of `ActiveNotification`'s constructor are now are named instead of positional
* **Breaking change** removed `SelectNotificationCallback` typedefs. The `DidReceiveNotificationResponseCallback` and `DidReceiveBackgroundNotificationResponseCallback` are the new typedefs for notification callbacks that run on the main isolate and background isolate respectively. Both of these pass an instance of the `NotificationResponse` class
* **Breaking change** the `NotificationAppLaunchDetails` has been updated to contain an instance `NotificationResponse` class with the `payload` belonging to the `NotificationResponse` class. This is to allow knowing more details about what caused the app to launch e.g. if a notification action was used to do so
* [Android] `groupKey` has been added to `ActiveNotification`. This was previously available in version `9.1.0` of the `flutter_local_notifications` plugin but then removed as it should've been part of a major release instead of a minor one
* [Android] `tag` has been added to `ActiveNotification`. This was available in version `9.4.0` of the `flutter_local_notifications` plugin but has been brought here since `ActiveNotification` is now part of this package's APIs

## [5.0.0]

* **Breaking change** the `SelectNotificationCallback` typedef now maps to a function that returns `void` instead of a `Future<dynamic>`. This change was done to better communicate the plugin doesn't actually await any asynchronous computation and is similar to how button pressed callbacks work for Flutter where they are typically use [`VoidCallback`](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html)

## [4.0.1]

* Moved the `SelectNotificationCallback` typedef and `validateId` method previously defined in the plugin to the platform interface. This is so they could be reused by platform implementations

## [4.0.0]

* Updated Flutter SDK constraint
* Updated Dart SDK constraint
* Bumped mockito dependency

## [3.0.0]

* Migrated to null safety

## [2.0.0+1]

* Added more API docs

## [2.0.0]

* **BREAKING CHANGE** renamed `RepeatInterval` enum values to use lower camel casing
* Bump `plugin_platform_interface` dependency

## [1.0.1]

* Add `pendingNotificationRequests()`

## [1.0.0+1]

* Fix link to repo in pubspec
* Update readme

## [1.0.0]

* Initial release of platform interface
