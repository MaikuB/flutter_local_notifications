# [1.1.7]

* [iOS] Added `requestPermissions()` method to `IOSFlutterLocalNotificationsPlugin` class. This can be used to request notification permissions separately from plugin initialisation. To facilitate this the `IOSFlutterLocalNotificationsPlugin` and `AndroidFlutterLocalNotificationsPlugin` now expose a static `instance` property that can be used obtain the platform-specific implementation of the plugin so that platform-specific methods can be used. Thanks to the PR from [Dariusz Łuksza](https://github.com/dluksza)
* Updated documentation to clarify that `getNotificationAppLaunchDetails()` is intended to be used more on if a notification from this plugin triggered launch an application
* Updated API docs for consistency and to better follow the guidelines on effective Dart documentation.

# [1.1.6]

* [iOS] Added ability to set badge number. Thanks to PR from [FelixYew](https://github.com/FelixYew)
* Fixed a spelling mistake in the 1.1.5+1 changelog entry

# [1.1.5+1]

* No functional changes. Fixed a reported formatting issue.
* Mention removal of named constructor argument in 1.1.0 changelog entry
* Add API docs to `FlutterLocalNotificationsPlugin.private()` on how it could be used for testing
* Update notes on testing to mention that the `FlutterLocalNotificationsPlugin.private()` named constructor may be of use

# [1.1.5]

* [Android] minor optimisation on scheduling related code so that `Gson` instance is reused instead of being rebuilt each time
* Changed plugin to require 1.12.3+hotfix.5 or greater since pub has issues resolving 1.12.3+hotfix.6
* Updated changelog entry for version 1.1.4 to mention removal of upper bound constraint on Flutter SDK requirement

# [1.1.4]

* Support v2 Android embedding. Note that there is currently a [known issue](https://github.com/flutter/flutter/issues/49365) in the Flutter SDK that will cause `onSelectNotification` to fire twice on Android. The fix is in the master channel but hasn't rolled out to other channels. Subscribe to the issue for updates.
* Require Flutter SDK 1.12.3+hotfix.6 or greater. Maximum SDK restraint has also been removed

# [1.1.3]

* Expose `NotificationAppLaunchDetails` via main plugin
* Retroactively updated changelog for 1.1.0 to indicate breaking change on moving to using platform interface
* Made plugin methods be a no-op to fix issue with version 1.1.0 where test code involving the plugin would fail when running on an environment that is neither Android or iOS

# [1.1.2]

* Passing a null notification id now throws an `ArgumentError`. Thanks to PR from [talmor_guy](https://github.com/talmor-guy)
* Slight tweak to message displayed with by `ArgumentError` when notification id is not within range of a 32-bit integer

# [1.1.1]

* [Android] Added ability to specify timeout duration of notification
* [Android] Added ability to specify the notification category

# [1.1.0]

* **BREAKING CHANGE** Updated plugin to make use of `flutter_local_notifications_platform_interface` version 1.0.1. This allows for platform-specific implementations of the platform interface to now be accessible. Note that the plugin will check which platform the plugin is running on.
  *Note*: this may have inadvertently broke some tests for users as the plugin now checks which platform the plugin is executing code on and would throw an `UnimplementedError` since neither iOS or Android can be detected. Another issue is that `NotificationAppLaunchDetails` was no longer exposed via the main plugin. Please upgrade to 1.1.3 to have both of these issues fixed
* **BREAKING CHANGE** Plugin callbacks are no longer publicly accessible
* **BREAKING CHANGE** [iOS] Local notifications that launched the app should now only be processed by the plugin if they were created by the plugin.
* **BREAKING CHANGE** `MethodChannel` argument has been removed from the named constructor that was visible for testing purposes

# [1.0.0]

* **BREAKING CHANGE** [iOS] Added checks to ensure callbacks are only invoked for notifications originating from the plugin to improve compatibility with other notification plugins.
* [Android] Bump Gradle plugin to 3.5.3

# [0.9.1+3]

* Include notes in getting started section to emphasise that the steps in the integration guide for each platform needs to be done.
* Move information in the readme on configuring resources to keep on Android.

# [0.9.1+2]

* Update link to repository due to restructuring.

# [0.9.1+1]

* Update readme with Swift example code on cancelling local notifications using the deprecated `UILocalNotification` iOS APIs when trying to prevent local notifications from appearing in the scenario where user has uninstalled the app whilst there are pending notification requests, reinstalled the app and ran it again.

# [0.9.1]

* Add support for media notification. This currently only supports showing the specified image as album artwork. Thanks to PR by [gianlucaparadise](https://github.com/gianlucaparadise)

# [0.9.0+1]

* Fix readme where Objective-C was written twice

# [0.9.0]

* [Android] Add ability to customise visibility of a notification on the lockscreen. Thanks to PR by [gianlucaparadise](https://github.com/gianlucaparadise)
* [Android] Bumped compile and target SDK to 29
* **BREAKING CHANGE** [iOS] Plugin no longer registers as a `UNUserNotificationCenterDelegate`. This is to enable compatibility with other plugins that display notifications. Developers must now do this themselves. Refer to the updated iOS integration section for more info on this
* Updated info about configuring Proguard configuration rules and included a file that could be used for reference in the example app
* Removed dependency on the `meta` package
* **BREAKING CHANGE** Now requires Flutter SDK 1.10.0 or greater
* Migrate the plugin to the pubspec platforms manifest

# [0.8.4+3]

* Update example to fix issue [372](https://github.com/MaikuB/flutter_local_notifications/issues/372) around app not firing `onSelectNotification` having switched to using streams and initialising the app in the `main` function.

# [0.8.4+2]

* Add note to readme that plugin initialisation be done as part of showing the first page of the app.

# [0.8.4+1]

* Fix typo in readme. Thanks to PR submitted by [Michael Arndt](https://github.com/MeneDev)
* Updated API docs and example around initializing the plugin to make it clearer that `initialize` should only be called once on app startup.

# [0.8.4]

* [iOS] Fix issue [336](https://github.com/MaikuB/flutter_local_notifications/issues/336) where a native crash occurred after creating a notification with a null body

# [0.8.3]

* [Android] Changed intents to use the `FLAG_UPDATE_CURRENT` flag instead of `FLAG_CANCEL_CURRENT` as alarms weren't being cleared out properly when updating or cancel a notification. Thanks to [WJQ](https://github.com/jjs1015) for submitting the PR to address the cancellation issue

# [0.8.2+1]
* Remove `ScheduledAndroidNotificationPrecision` enum that wasn't being used
* Update readme around approach used to develop the plugin

# [0.8.2]

* [iOS] Fix issue [295](https://github.com/MaikuB/flutter_local_notifications/issues/295) where `onSelectNotification` callback wasn't trigger when a notification had been tapped on whilst the app was terminated

# [0.8.1+1]

* Update comment in example around grouped notifications to clarify that the summary notification ia required for all versions of Android
* Update email address in pubspec.yaml

# [0.8.1]

* [iOS] Accepted PR from [Josh Burton](https://github.com/athornz) that improves ability for plugin to work in multiple isolate by moving state to instance variables
* [iOS] Add a guard to prevent a scenario from happening where it may still be possible for the `onDidReceiveLocalNotification` callback to trigger on iOS 10+
* Minor update to readme on raising issues and correction on payload information

# [0.8.0]

* Added an optional parameter named `androidAllowWhileIdle` to `schedule` method. This will allow notifications to still display at the specified time when the Android device is in an low-power idle mode.
* **BREAKING CHANGE** Bump minimum Flutter version to 1.5.0
* **BREAKING CHANGE** Update Flutter dependencies

# [0.7.1+3]

* Fix build status badge

# [0.7.1+2]

* Started adding Cirrus CI configuration and include CI status badge as part of readme

# [0.7.1+1]

* Updated readme to include information about OS limits related to scheduled notifications

# [0.7.1]

* [Android] Added ability to specify the "ticker" text. Thanks to PR submitted by [Zhang Jing](https://github.com/byrdkm17)
* Spelling mistake fixes in readme. Thanks to PR submitted by [Wanbok (Wayne) Choi](https://github.com/wanbok)

# [0.7.0]

* **BREAKING CHANGE** [Android] Updated to Gradle 5.1.1 and Android Gradle plugin has been updated to 3.4.0 (aligns with Android Studio 3.4 release). Example app has also been updated to Gradle 5.1.1. Apps will need to update to use the plugin. Please see [here](https://developer.android.com/studio/releases/gradle-plugin) for more information if you need help on updating
* [Android] Add ability to specify the LED colour of the notification. Updated example app to show this can be done. Note that for Android 8.0+ (i.e. API 26+) that this is tied to the notification channel


# [0.6.1]

* [Android/iOS] Added `pendingNotificationRequests` method. This will return a list of pending notification requests that have been scheduled to be shown in the future. Updated example app to include sample code for calling the method
* [Android] Fix an issue where scheduling a notification (recurring or otherwise) with the same id as another notification that was scheduled with the same id would result in both being stored in shared preferences. The shared preferences were used to reschedule notifications on reboot and shouldn't affect the functionality of displaying the notifications
* Updated plugin methods to return `Future<void>` instead of `Future` as per Dart guidelines
* Updated readme to mention known issue with scheduling notifications and daylight savings
* Refactored widgets in example app

# [0.6.0]

* **BREAKING CHANGE** [Android] Updated Gradle plugin to 3.3.2
* **BREAKING CHANGE** [Android] Changed to store the name of drawable specified as the small icon to be used for Android notifications instead of the resource ID. This should fix the scenario where an app could be updated and the resource IDs got change and cause scheduled notifications to not appear. Believe this fix should retroactively apply for notifications scheduled with an icon specified but won't apply to those that were scheduled to use the default icon specified via the `initialize` method. This is due to the fact the name of the default icon wasn't being cached in previous ones but this has now changed so it's cached in shared preferences from this version onwards

# [0.5.2]

* Fix for when multiple isolates use the plugin. Thanks to PR submitted by [xtelinco](https://github.com/xtelinco)
* Added the `channelAction` field to the `AndroidNotificationDetails` class. This provides options for managing notification channels on Android. Default behaviour is to create the notification channel if it doesn't exist (which was what it it use to do). Another option is to update the details of the notification channel. Example app has been updated to demonstrate how to update a notification channel when sending a notification

# [0.5.1+2]

* Highlight note on migrating to AndroidX more in readme

# [0.5.1+1]

* Readme corrections and add information on migrating to AndroidX

# [0.5.1]

* Updated Gradle plugin of example app to 3.3.1
* Added support for messaging style notifications on Android as requested in issue [159](https://github.com/MaikuB/flutter_local_notifications/issues/159). See example app for some sample code

# [0.5.0]

* **BREAKING CHANGE** Migrated to use AndroidX as the Android support libraries are deprecated. There shouldn't be any functional changes. Developers may require migrating their apps to support this following [this guide](https://developer.android.com/jetpack/androidx/migrate). This addresses issue [162](https://github.com/MaikuB/flutter_local_notifications/issues/162). Thanks to [Jeff Scaturro](https://github.com/JeffScaturro) for submitting the PR for this work. Note that if you don't want to migrate your app to use AndroidX yet then you may need to pin dependencies to a specific version

# [0.4.5]

* Fix issue [160](https://github.com/MaikuB/flutter_local_notifications/issues/160) so that notifications created with the `schedule` on Android will appear at the exact date and time they are scheduled

# [0.4.4+2]

* Fix changelog

# [0.4.4+1]

* **BREAKING CHANGE** Fix naming of `onDidReceiveLocalNotification` property in the `IOSInitializationSettings` class (was previously named `onDidReceiveLocalNotificationCallback` by accident)

# [0.4.4]

*  **BREAKING CHANGE** removed `registerUNNotificationCenterDelegate` argument for the `IOSInitializationSettings` class as it wasn't actually used.
* Plugin can now handle `didReceiveLocalNotification` delegate method in iOS and allow developers to handle the associated callback in Flutter. Added a `onDidReceiveLocalNotificationCallback` argument to the `IOSInitializationSettings` class to enable this and updated the sample code to demonstrate the usage. This should resolve issue [14](https://github.com/MaikuB/flutter_local_notifications/issues/14).

# [0.4.3]

* Merged PR from Aine LLC (ganessaa) to fix issue [140](https://github.com/MaikuB/flutter_local_notifications/issues/140) where scheduled notifications were shown immediately on iOS versions before 10. Note that this issue is likely related to an [known issue in the Flutter engine](https://github.com/flutter/flutter/issues/21313) that may require switching channels to be addressed as the fix isn't on the stable channel yet.
* [Android] Provide a way to hide the large icon when showing an expanded big picture notification via the  `hideExpandedLargeIcon` flag within thr `BigPictureStyleInformation` class. This provides a solution for issue [136](https://github.com/MaikuB/flutter_local_notifications/issues/136). Updated the example to demonstrate
* Merged PR from (riccardoratta) so that sample code is coloured in GitHub to improve readability.

# [0.4.2+1]

* Update changelog to indicate when `MessageHandler` typedef got renamed (in 0.4.1) as raised in issue [132](https://github.com/MaikuB/flutter_local_notifications/issues/132)

# [0.4.2]

* **BREAKING CHANGE** Fix issue [127](https://github.com/MaikuB/flutter_local_notifications/issues/127) by changing plugin to Android Support Library version 27.1.1, compile and target SDK version to 27 due to issues Flutter has with API 28. 

# [0.4.1+1]
* Remove unused code in example app

# [0.4.1]

* **BREAKING CHANGE** renamed the `selectNotification` callback exposed by the `initialize` function to `onSelectNotification`
* **BREAKING CHANGE** renamed the `MessageHandler` typedef to `SelectNotificationCallback`
* **BREAKING CHANGE** updated plugin to Android Support Library version 28.0, compile and target SDK version to 28
* Address issue [115](https://github.com/MaikuB/flutter_local_notifications/issues/115) by adding validation to the notification ID values. This ensure they're within the range of a 32-bit integer as notification IDs on Android need to be within that range. Note that an `ArgumentError` is thrown when a value is out of range. 
* Updated the Android Integration section around registering receivers via the Android manifest as per the suggestion in [116](https://github.com/MaikuB/flutter_local_notifications/issues/116)
* Updated version of the http dependency for used by the example app

# [0.4.0]

* [Android] Fix issue [112](https://github.com/MaikuB/flutter_local_notifications/issues/112) where big picture notifications wouldn't show

# [0.3.9]

* [Android] Added ability to show progress notifications and updated example app to demonstrate how to display them

# [0.3.8]

* Added `getNotificationAppLaunchDetails()` method that could be used to determine if the app was launched via notification (raised in issue [99](https://github.com/MaikuB/flutter_local_notifications/issues/99))
* Added documentation around ProGuard configuration to Android Integration section of the readme

## [0.3.7]

* [Android] Fix issue [88](https://github.com/MaikuB/flutter_local_notifications/issues/88) where cancelled notifications could reappear on reboot.

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

* [iOS] Fixes issue [61](https://github.com/MaikuB/flutter_local_notifications/issues/61) where the `showDailyAtTime` and `showWeeklyAtDayAndTime` methods may not show notifications that should appear the next day. Thanks to [Jeff Scaturro](https://github.com/JeffScaturro) for submitting the PR to fix this.

## [0.3.2]

* No functional changes. Updated the readme around raising issues, recurring Android notifications on Android and a fix in the getting started section (thanks to [ebeem](https://github.com/ebeem) for spotting that).

## [0.3.1]

* No functional changes in this release but removed a class that is no longer used due to changes in 0.3.0
* Updated readme information the example app and configuring Android notification icons
* changelog is now in reverse chronological order so details about the most recent release are at the top
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

* Update dev dependencies required for flutter test to run. This is due to a breaking change in Flutter. See https://github.com/flutter/flutter/wiki/changelog

## [0.2.7]

* [Android] Fix issue with showDailyAtTime and showWeeklyAtDayAndTime where time occurred in the past and caused notification to trigger instantly

## [0.2.6]

* [Android] Fix bug with applying ongoing and autoCancel properties

## [0.2.5]

* [Android] Bug fix for previous release

## [0.2.4]

* [Android] Add ability to set the colour.

## [0.2.3]

* [Android/iOS] Add ability to have a notification shown daily at a specified time. Credits to [Javier Lecuona](https://github.com/javiercbk) for submitting the PR for this.
* [Android/iOS] Add ability to have a notification shown weekly on a specific day and time.

## [0.2.2]

* [Android/iOS] Fix RepeatInterval not being mapped to the correct values on the native side. Thanks to [Thibault Deckers](https://github.com/deckerst) for spotting the issue.

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

* Updated readme

## [0.0.3]

* Fix changelog

## [0.0.2]

* Readme fixes

## [0.0.1]

*  Initial release






















































