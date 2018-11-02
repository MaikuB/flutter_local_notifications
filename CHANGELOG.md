# [0.4.1]
* [Android/iOS] New `onShowNotification` callback for when a notification is shown that can handled when calling the `initialize` function. This uses the latest changes to the Flutter engine that supports headless execution i.e. the ability to execute Dart code without the app running. See [here](https://github.com/flutter/flutter/issues/6192) for a link to the issue in the main Flutter repository about this. Note that the function handling this callback must be top-level function as this is requirement for executing headless Dart code. The example for the plugin has been updated to provide sample code on to handle the callback. **IMPORTANT** the callback only works on Android and iOS 10+. Note support on iOS is difficult to verify at the moment since Flutter engine support for executing headless Dart code on iOS doesn't support plugins at the moment.
* **BREAKING CHANGE** renamed the `selectNotification` callback exposed by the `initialize` function to `onSelectNotification`
* Address issue [115](https://github.com/MaikuB/flutter_local_notifications/issues/115) by adding validation to the notification ID values. This ensure they're within the range of a 32-bit integer as notification IDs on Android need to be within that range. Note that an `ArgumentError` is thrown when a value is out of range. 

# [0.4.0]
* [Android] Fix issue [112](https://github.com/MaikuB/flutter_local_notifications/issues/112) where big picture notifications wouldn't show

# [0.3.9]
* [Android] Added ability to show progress notifications and updated example app to demonstrate how to display them

# [0.3.8]
* Added `getNotificationAppLaunchDetails()` method that could be used to determine if the app was launched via notification (raised in issue [99](https://github.com/MaikuB/flutter_local_notifications/issues/99))
* Added documentation around ProGuard configuration to Android Integration section of the README

## [0.3.7]
* [Android] Fix issues [88](https://github.com/MaikuB/flutter_local_notifications/issues/88) where cancelled notifications could reappear on reboot.

## [0.3.6]
* [Android] Add mapping to the setOnlyAlertOnce method [83](https://github.com/MaikuB/flutter_local_notifications/issues/83). Allows the sound, vibrate and ticker to be played if the notification is not already showing
* [Android] Add mapping to setShowBadge for notification channels that controls if notifications posted to channel can appear as application icon badges in a Launcher

## [0.3.5]
* [Android] Will now throw a PlatformException with a more friendly error message on the Flutter side when a specified resource hasn't been found e.g. when specifying the icon for the notification
* Fix overflow rendering issue in the example app

## [0.3.4]
* [Android] Fix issue [71](https://github.com/MaikuB/flutter_local_notifications/issues/71) where the wrong time on when the notification occurred is being displayed. **BREAKING CHANGE** this involves changing it the receiver for displaying a scheduled notification will only build the notification prior to displaying it. There is a fix applied to existing scheduled notifications in this release that will be eventually be removed as going forward all scheduled notifications will work as just described
* [Android] Fix an issue with serialising and deserialising the notifications so that additional style types (big picture and inbox) would be recognised. This affected scheduled notifications where upon rebooting the device, the plugin would need to reschedule the notifications using information saved in shared preferences.

## [0.3.3]
* [iOS] Fixes issue [61](https://github.com/MaikuB/flutter_local_notifications/issues/61) where the `showDailyAtTime` and `showWeeklyAtDayAndTime` methods may not show notifications that should appear the next day. Thanks to Jeff Scaturro (JeffScaturro) for submitting the PR to fix this.

## [0.3.2]
* No functional changes. Updated the README around raising issues, recurring Android notifications on Android and a fix in the getting started section (thanks to ebeem for spotting that).

## [0.3.1]

* No functional changes in this release but removed a class that is no longer used due to changes in 0.3.0
* Updated README information the example app and configuring Android notification icons
* Changelog is now in reverse chronological order so details about the most recent release are at the top
* Additional comments in the example's main.dart file to refer to downloading the complete example app project from GitHub

## [0.3.0]

* **BREAKING CHANGES** restructured code so that only a single import statement is now needed to use the plugin. Classes that had the platform (Android/iOS) as a suffix are now prefixes to improve readability of code and follow the recommendations for writing Dart code i.e. write code that reads more like a sentence. The following have been renamed

    * InitializationSettingsAndroid -> AndroidInitializationSettings
    * InitializationSettingsIOS -> IOSInitializationSettings
    * NotificationDetailsAndroid -> AndroidNotificationDetails
    * NotificationStyleAndroid -> AndroidNotificationStyle
    * NotificationDetailsIOS -> IOSNotificationDetails

* [Android] Ability to set the large icon used for each notification. See example app for sample code
* [Android] Ability to create a notification with the big picture style. See example app for sample code
* Correct license text

## [0.2.9]

* Fix error in calling initialize error on iOS versions < 9

## [0.2.8]

* Update dev dependencies required for flutter test to run. This is due to a breaking change in Flutter. See https://github.com/flutter/flutter/wiki/Changelog

## [0.2.7]

* [Android] Fix issue with showDailyAtTime and showWeeklyAtDayAndTime where time occurred in the past and caused notification to trigger instantly

## [0.2.6]

* [Android] Fix bug with applying ongoing and autoCancel properties

## [0.2.5]

* [Android] Bug fix for previous release

## [0.2.4]

* [Android] Add ability to set the colour.

## [0.2.3]

* [Android/iOS] Add ability to have a notification shown daily at a specified time. Credits to Javier Lecuona (javiercbk) for submitting the PR for this.
* [Android/iOS] Add ability to have a notification shown weekly on a specific day and time.

## [0.2.2]

* [Android/iOS] Fix RepeatInterval not being mapped to the correct values on the native side. Thanks to Thibault Deckers (deckerst) for spotting the issue.

## [0.2.1]

* [Android/iOS] Add ability to set a notification to be periodically displayed
* [Android] Fix a bug where the small icon could not be be found when loading scheduled notifications from shared preferences to reschedule them on a device reboot
* [Android] Fix example app manifest file

## [0.2.0]

* [Android] Add ability to specify if notifications should automatically be dismissed upon touching them
* [Android] Add ability to specify in notifications are ongoing
* [Android] Fix bug in cancelling all notifications

## [0.1.9]

* [Android/iOS] Add ability to cancel/remove all notifications

## [0.1.8]

* [Android] Bug fix for grouping notifications

## [0.1.7]

* [Android] Add ability to show grouped notifications. Example code has been updated to demonstrate this functionality.
* Fixed the example project so it works with the new release of Cocoapods (1.5.0)
* Fixes for when API methods were called without specifying platform specific settings

## [0.1.6]

* **BREAKING CHANGES** Apologies again, this is another cleanup release. FlutterLocalNotifications class has been renamed to FlutterLocalNotificationsPlugin now as it makes more sense from a readability perspective. More importantly, the class and methods are also no longer static to faciliate mocking and testing. It's something I should've picked up on earlier so sorry once again. Check the source code for an example on how to mock the plugin when testing

## [0.1.5]

* **BREAKING CHANGES** There are no functional changes. This is an API cleanup release where I've reorganised the Dart classes to better separate them by platform. What this means is that the import statements in your coode will need to be fixed. Apologies to anyone using the plugin but I feel that this was necessary as Flutter may target additional platforms in the future. Hopefully you'll agree that the end result looks a better :)

## [0.1.4]

* [Android] Add inbox notification style

## [0.1.3]

* Fix broken example app for iOS due to incorrect reference to custom sound file. Added ability to handle when a notification is tapped. See updated example for details on how to do this and will navigate to another page. Note that the second page isn't rendering full-screen on Android if the notification was tapped on while the app was in the foreground. Suspect that this is Flutter rendering issue and have logged this on the Flutter repository at https://github.com/flutter/flutter/issues/16636

## [0.1.2]

* [Android] Bug fix in calculating when to show a scheduled  notification. Ensure scheduled Android notifications will remain scheduled even after rebooting.

## [0.1.1]

* [Android] Add ability to use HTML markup to format the title and content of notifications

## [0.1.0]

* [Android] Add support for big text style for and being able format the big text style specific content using HTML markup.

## [0.0.9]

* [iOS] Enable ability to customise the sound for notifications (**IMPORTANT** requires testing on older iOS versions < 10)
* [iOS] Can now specify default presentation options (**BREAKING CHANGE** named parameters for iOS initialisation have changed) that can also be overridden at the notification level).
* [iOS] Fixes for reading in specified options

## [0.0.8]

* [Android] Enable ability to customise sound and vibration for notifications.

## [0.0.7]

* [Android] Fix notifications so that tapping on them will remove them and will also start the app if it has been terminated.

## [0.0.6]

* [iOS] Add ability to customise the presentation options when a notification is triggered while the app is in the foreground for notifications presented using the User Notifications Framework (iOS 10+). IMPORTANT: the named parameters for iOS initialisation settings constructor have had to change to differentiate between permission options and presentation options

## [0.0.5]

* [iOS] Updates to code to support both legacy notifications via UILocalNotification (before iOS 10) and the User Notifications framework introduced in iOS 10

## [0.0.4]

* Updated README

## [0.0.3]

* Fix changelog

## [0.0.2]

* README fixes

## [0.0.1]

*  Initial release






















































