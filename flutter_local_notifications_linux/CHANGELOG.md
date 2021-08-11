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
