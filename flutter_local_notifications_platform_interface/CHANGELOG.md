## [6.0.0-dev.2]

* Added `NotificationActionDetails` class and `NotificationActionCallback` typedef for dealing with notification actions

## [6.0.0-dev.1]

* **Breaking change** the parameters of `ActiveNotification`'s constructor are now are named instead of positional
* [Android] `groupKey` has been added to `ActiveNotification`. This was previously available in version `9.1.0` of the `flutter_local_notifications` plugin but then removed as it should've been part of a major release instead of a minor one

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
