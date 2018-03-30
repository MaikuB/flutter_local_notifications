## [0.0.1]

*  Initial release

## [0.0.2]

* README fixes

## [0.0.3]

* Fix changelog


## [0.0.4]

* Updated README

## [0.0.5]

* Updates to iOS code to support both legacy notifications via UILocalNotification (before iOS 10) and the User Notifications framework introduced in iOS 10

## [0.0.6]

* Add ability to customise the presentation options when a notification is triggered while the app is in the foreground for iOS notifications presented using the User Notifications Framework (iOS 10+). IMPORTANT: the named parameters for iOS initialisation settings constructor have had to change to differentiate between permission options and presentation options

## [0.0.7]

* Fix notifications on Android so tapping on them will remove them and will also start the app if it has been terminated.

## [0.0.8]

* Enable ability to customise sound and vibration for Android notifications.

## [0.0.9]

* Enable ability to customise the sound for iOS notifications (**IMPORTANT** requires testing on older iOS versions < 10). Can now specify default presentation options for iOS (**BREAKING CHANGE** named parameters for iOS initialisation have changed) that can also be overridden at the notification level). Fixes for reading in specified options in iOS.

## [0.1.0]

* Add support for big text style for Android notifications
