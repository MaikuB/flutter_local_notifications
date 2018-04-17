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

* Add support for big text style for Android notifications and format the big text style specific content using HTML markup.

## [0.1.1]

* Add ability to use HTML markup to format the title and content of Android notifications


## [0.1.2]

* Bug fix in calculating when to show a scheduled Android notification. Ensure scheduled Android notifications will remain scheduled even after rebooting.

## [0.1.3]
* Fix broken example app for iOS due to incorrect reference to custom sound file. Added ability to handle when a notification is tapped. See updated example for details on how to do this and will navigate to another page. Note that the second page isn't rendering full-screen on Android if the notification was tapped on while the app was in the foreground. Suspect that this is Flutter rendering issue and have logged this on the Flutter repository at https://github.com/flutter/flutter/issues/16636

## [0.1.4]
* Add inbox notification style