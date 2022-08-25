## [0.5.1]

* Fixes issue [1656](https://github.com/MaikuB/flutter_local_notifications/issues/1656) where a version constraint issue occurred with the `path` package. The version constraint has been lowered to resolve the issue

## [0.5.0+1]

* Added a note to 0.5.0 changelog to make it clear that the 0.5.0 stable release doesn't have changes from the 0.5.0 pre-releases

## [0.5.0]

* Added support for icons to be specified via file path. Thanks to PR from [Yaroslav Pronin](https://github.com/proninyaroslav)
* **Note**: the 0.5.0 release *does not* have the same as what was on the 0.5.0 pre-releases. Those pre-releases are more closely related to changes being done for the 10.0.0 pre-release of `flutter_local_notifications`. What was in the 0.5.0 pre-releases will be shifted to a 1.0.0 pre-release of `flutter_local_notifications_linux`

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
