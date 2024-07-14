## [vNext]

* Bumped minimum Flutter SDK requirement to 3.13

## [4.0.1]

* Fixed issue [#2368](https://github.com/MaikuB/flutter_local_notifications/issues/2368). This involved updating pubspec so it defines that it implements the Linux implementation of `flutter_local_notifications` and updating the code so it registers the Linux implementation

## [4.0.0+1]

* Bumped maximum Dart SDK constraint

## [4.0.0]

* **Breaking change** the `id` property of the `ActiveNotification` class is now nullable to help indicate that the notification may not have been created by the plugin e.g. it was from Firebase Cloud Messaging. Thanks to the PR from [frankvollebregt](https://github.com/frankvollebregt)
* **Breaking change** the following classes are now enums
    * `LinuxNotificationCategory`
    * `LinuxNotificationUrgency`
* Switched from using `mocktail` to `mockito` for consistency and with it getting more updates as a first-party package

## [3.0.0+1]

* Bumped `xdg_directories` dependency constraints

## [3.0.0]

* Updated minimum Flutter version to 3.0.0. Note that technically this was already a requirement by `flutter_local_notifications_linux` 2.0.0 as `ffi` 2.0.0 requires Dart 2.17 at a minimum and that shipped with Flutter 3.0.0
* Added explicit `ffi` dependency that plugin was already using

## [2.0.0]

* Bumped `dbus` dependency

## [1.0.0]

* **Breaking change** The linux notification categories defined by `LinuxNotificationCategory` no longer has factory constructors but has static constant fields instead to make the semantics more similar to access enum values
* Updated minimum Flutter version to 2.8 to align with the minimum Dart SDK version of 2.1.5 required by the `dbus` package


## [0.5.1]

* Fixes issue [1656](https://github.com/MaikuB/flutter_local_notifications/issues/1656) where a version constraint issue occurred with the `path` package. The version constraint has been lowered to resolve the issue

## [0.5.0+1]

* Added a note to 0.5.0 changelog to make it clear that the 0.5.0 stable release doesn't have changes from the 0.5.0 pre-releases

## [0.5.0]

* Added support for icons to be specified via file path. Thanks to PR from [Yaroslav Pronin](https://github.com/proninyaroslav)
* **Note**: the 0.5.0 release *does not* have the same as what was on the 0.5.0 pre-releases. Those pre-releases are more closely related to changes being done for the 10.0.0 pre-release of `flutter_local_notifications`. What was in the 0.5.0 pre-releases will be shifted to a 1.0.0 pre-release of `flutter_local_notifications_linux`

## [0.5.0-dev.4]

* **Breaking change** callbacks have now been reworked. `onDidReceiveNotificationResponse` is invoked only when the app is running. This works for when a user has selected a notification or notification action. This replaces the `onSelectNotification` callback that existed before
* **Breaking change** the `NotificationAppLaunchDetails` has been updated to contain an instance `NotificationResponse` class with the `payload` belonging to the `NotificationResponse` class. This is to allow knowing more details about what caused the app to launch e.g. if a notification action was used to do so

## [0.5.0-dev.3]

* Includes changes from 0.4.2

## [0.5.0-dev.2]

* Added support for notification actions

## [0.5.0-dev.1]

* Bumped `flutter_local_notifications_platform_interface` dependency

## [0.4.2]

* Bumped dependencies. Thanks to PR from [Guy Luz](https://github.com/guyluz11)

## [0.4.1+1]

* Fixed minor casing error in 0.4.1 changelog entry

## [0.4.1]

* Fix `initialize()` returning null all the time instead of returning an appropriate boolean value to indicate if plugin has been initialised

## [0.4.0]

*  Bumped `dbus` dependency.

## [0.3.0]

* **Breaking change** the `SelectNotificationCallback` typedef now maps to a function that returns `void` instead of a `Future<dynamic>`. This change was done to better communicate the plugin doesn't actually await any asynchronous computation and is similar to how button pressed callbacks work for Flutter where they are typically use [`VoidCallback`](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html)

## [0.2.0+1]

* Fixed links to GNOME developer documentation referenced in API docs

## [0.2.0]

* Fixed issue when an app using the plugin is built on the web by using conditional imports
* Changed the logic where notification IDs are saved so that `$XDG_RUNTIME_DIR` environment variable is not set but `$TMPDIR` is set, then they are saved to a file within the `/$TMPDIR/APP_NAME/USER_ID/SESSION_ID` directory. If `$TMPDIR` is not set then, it would save to `/tmp/APP_NAME/USER_ID/SESSION_ID`
* Fixed an issue where errors would occur if the plugin was initialised multiple times

## [0.1.0+1]

*  Point to types within platform interface

## [0.1.0]

* Initial version for Linux
