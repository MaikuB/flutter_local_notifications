# [4.0.1+2]

* [iOS/macOS] fixed issue where not requesting any permissions (i.e. all the boolean flags were set to false) would still cause a permissions prompt to appear. Thanks to the PR from [Andrey Parvatkin](https://github.com/badver)

# [4.0.1+1]

* Fixed typo in readme around the note relating to version 4.0 of the plugin where `onSelectNotification` will not be triggered when an app is launched by tapping on a notification.

# [4.0.1]

* [Android] added the `getNotificationChannels` method to the `AndroidFlutterLocalNotificationsPlugin` class. This can be used to a get list of all the notification channels on devices with Android 8.0 or newer. Thanks to the PR from [Shapovalova Vera](https://github.com/VAShapovalova)

# [4.0.0]

* **Breaking change** calling `initialize` will no longer trigger the `onSelectNotification` if a notification was tapped on prior to calling `initialize`. This was done as the `getNotificationAppLaunchDetails` method already provided a way to handle when an application was launched by a notification. Furthermore, calling `initialize` multiple times (e.g. on different pages) would have previously caused the `onSelectNotification` callback multiples times as well. This potentially results in the same notification being processed again
* **Breaking change** the `matchDateComponents` parameter has been renamed to `matchDateTimeComponents`
* Dates in the past can now be used with `zonedSchedule` when a value for the `matchDateTimeComponents` parameter has been specified to create recurring notifications. Thanks to the PR from [Erlend](https://github.com/erf) for implementing this and the previous change
* [Android] notification data is now saved to shared preferences in a background thread to minimise jank. Thanks to the PR from [davidlepilote](https://github.com/davidlepilote)
* [Android] the `tag` property has been added to the `AndroidNotificationDetails` class. This allows notifications on Android to be uniquely identifier through the use of the value of the `tag` and the `id` passed to the method for show/schedule the notification
* [Android] the optional `tag` argument has been added to the `cancel` method for the `FlutterLocalNotificationsPlugin` and `AndroidFlutterLocalNotificationsPlugin` classes. This can be used to cancel notifications where the `tag` has been specified
* [iOS][macOS] the `threadIdentifier` property has been added to the `IOSNotificationDetails` and `MacOSNotificationDetails` classes. This can be used to group notifications on iOS 10.0 or newer, and macOS 10.14 or newer. Thanks to the PR from [Marcin Chudy](https://github.com/mchudy) for adding this and the `tag` property for Android notifications
* The Android and iOS example applications have been recreated in Kotlin and Swift respectively
* Updated example application's dev dependency on the deprecated `e2e` for integration tests to use `integration_test` instead
* Bumped Flutter dependencies
* Example app cleanup including updating Proguard rules as specifying the rules for Flutter were no longer needed

# [3.0.3]

* [Android] added support for showing subtext in the notification. Thanks to the PR from [sidlatau](https://github.com/sidlatau)

# [3.0.2]

* [Android] added support for showing the notification timestamp as a stopwatch instead via the `usesChronometer` argument added to the constructor of the `AndroidNotificationDetails` class. Thanks to the PR from [andymstone](https://github.com/andymstone)
* Updated readme to add more clarity on the compatibility with `firebase_messaging` plugin and iOS setup sections
* Updated changelog entry for the 2.0.0 release around support for full-screen intents to clarify that the `fullScreenIntent` was added to the constructor of the `AndroidNotificationDetails` class.

# [3.0.1+7]

* [Android] fixed issue [935](https://github.com/MaikuB/flutter_local_notifications/issues/935) where scheduling a notification on Android devices running Android versions older than 4.4 (API 19) could cause a crash from using an API that isn't available

# [3.0.1+6]

* [Android] change how the intent that associated with the notification is determined so that the plugin. This is to allow the plugin to work with applications that use activity aliases as per issue [92](https://github.com/MaikuB/flutter_local_notifications/issues/912). Thanks the PR from  [crazecoder](https://github.com/crazecoder)
* Fixed issue [924](https://github.com/MaikuB/flutter_local_notifications/issues/924), where example app will now use https URLs for downloading placeholder images. These images were used when displaying some of the notifications. Thanks to the PR from [Fareez](https://github.com/iqfareez)

# [3.0.1+5]

* Fixed links in table of contents in the readme. Thanks to the PR from [Dihak](https://github.com/dihak)
* Added a note in the readme to indicate changes were done in version 3.0.1+4 to reduce the setup to ensure readers have updated their application to use the latest version of the plugin
* Added a note around setting the application badge with a link to a plugin that supports this functionality

# [3.0.1+4]

* [Android] made changes so that the plugin will now register the receivers and permissions needed. This reduces the amount of setup needed as developers will no longer need to update their AndroidManifest.xml to do so. The section of the readme on the Android setup for scheduled notifications has been removed as a result
* [Android] fixed an issue where notifications may not appear after rebooting
* [Android] made changes so that the plugin itself specifies which classes should be kept when minified. This means developers should no longer need to add a rule for this plugin in their application's Proguard rules file. Note that rules for GSON will still be needed. The release build configuration section related to the Android setup has been updated to reflect this change
* Bump dependency on `flutter_local_notifications_platform_interface`
* Updated API docs

# [3.0.1+3]

* [Android] Fixed issue [898](https://github.com/MaikuB/flutter_local_notifications/issues/898) around duplicate pending notifications
* Updated example app to more clearly indicate which button will demonstrate an Android notification with a different coloured icon and LED

# [3.0.1+2]

* [Android] additional fix for issue [871](https://github.com/MaikuB/flutter_local_notifications/issues/871) by switching the implementation of `deleteNotificationChannel` to use the `NotificationManager` APIs instead of the `NotificationManagerCompat` APIs

# [3.0.1+1]

* Updated API docs for the `UriAndroidNotificationSound` class to further clarify that developers may need to write code that makes use of platform channels
* [Android] fix issue [881](https://github.com/MaikuB/flutter_local_notifications/issues/881) where recurring notifications may fail to schedule the next occurrence on older Android versions as the ThreeTen Android Backport library hadn't been initialised yet
* [Android] switched implementation of `createNotificationChannelGroup` and `deleteNotificationChannelGroup` methods to use the `NotificationManager` APIs instead of the `NotificationManagerCompat` APIs. If you had issues with 3.0.1 then this should fix the issue (e.g. as reported in issue [871](https://github.com/MaikuB/flutter_local_notifications/issues/871)) as the the APIs that were previously being called would've required apps to use more recent versions of the AndroidX libraries

# [3.0.1]

* [Android] Added the `createNotificationChannelGroup` and `deleteNotificationChannelGroup` methods to the `AndroidFluttterLocalNotificationsPlugin` class that can be used to create and delete notification channel groups. The optional `groupId` parameter has been added to the `AndroidNotificationChannel` class that can be used to associated notification channels to a particular group. Example app has been updated to include code snippets for this.

# [3.0.0+1]

* [iOS] Fixed issue [865](https://github.com/MaikuB/flutter_local_notifications/issues/865) where notifications with no title weren't behaving properly
* Updated API docs and readme around handling when full-screen intent notifications occur
* Updated API docs around notification channel management

# [3.0.0]

* **Breaking change** The `scheduledNotificationRepeatFrequency` parameter of the `zonedSchedule` method has been removed. This has been replaced by `matchDateTimeComponents` parameter that can be used to schedule a recurring notification. This was done to better indicate that this is used to schedule recurring daily of weekly notifications based on the specified date components. This is more inline with how the calendar trigger works for notifications for iOS and macOS. Given a date (e.g. Monday 2020-10-19 10:00 AM), specifying to match on the time component of would result in a notification occurring daily at the same time (10:00 AM). Specifying to match on the day of the week and time allows for a weekly notification to occur (Monday 10:00 AM), The deprecation warnings for the `showDailyAtTime()` and `showWeeklyAtDayAndTime()` methods have been updated to give a brief description along the same lines.

# [2.0.2]

* [iOS][macOS] fixed issue [860](https://github.com/MaikuB/flutter_local_notifications/issues/860) where notifications may fail to be scheduled to an error parsing the specified date that could occur for some users depending on their locale and if they had turned off the setting for showing 24 hour time on their device. Thanks to the PR from [Eugene Alitz](https://github.com/psycura)

# [2.0.1+1]

* Updated example application to demonstrate how to use the schedule notifications to occur on particular weekday using `zonedSchedule` method
* Added a note on migrating away from the deprecated methods for scheduling daily/weekly notifications

# [2.0.1]

* [Android] updated plugin and steps in the readme to ensure notifications remain scheduled after a HTC device restarts. Thanks to the PR from [Le Liam](https://github.com/nghenglim)

# [2.0.0+1]

* Fixed code snippet in readme around initialisation and configuring the `onDidReceiveLocalNotification` callback specific to iOS. Thanks to the PR from [Mike Truso](https://github.com/mftruso)

# [2.0.0]

* Added macOS implementation of the plugin
* The `schedule`, `showDailyAtTime` and `showWeeklyAtDayAndTime` methods has been marked as a deprecated due to problems with time zones, particularly when it comes to daylight savings.
* Added the `zonedSchedule` method to the plugin that allows for scheduling notifications to occur on a specific date and time relative a specific time zone. This can be used to schedule daily and weekly notifications as well. The example app has been updated to demonstrate its usage. Applications will need to retrieve the device's local IANA timezone ID via native code or a plugin (e.g. [`flutter_native_timezone`](https://pub.dev/packages/flutter_native_timezone)). Note that to support time zone-based scheduling, the plugin now depends on the `timezone` package so that an instance of the `TZDateTime` class is required to the specify the time the notification should occur. This should work in most cases as it is IANA-based and native platforms have time zones that are IANA-based as well. To support time zone aware dates on older versions of Android (which use older Java APIs), the plugin depends on the [ThreeTen Android Backport library](https://github.com/JakeWharton/ThreeTenABP). Once Flutter's support for Android Studio 4.0 and Android Gradle plugin 4.0 has stabilised, the plugin will be updated to make use of [desugaring](https://developer.android.com/studio/releases/gradle-plugin#j8-library-desugaring) instead of relying on the ThreeTen Android Backport library.
* [Android] Fixed issue [670] where `getNotificationAppLaunchDetails()` behaved inconsistently depending on if it was called before or after `initialize()`
* [Android] Added the `getActiveNotifications()` method to the `AndroidFlutterLocalNotificationsPlugin` class thanks to the PR from [Vincent Kammerer](https://github.com/vkammerer). This can be used to query the active notifications and is only applicable to Android 6.0 or newer
* [Android] Fixed an issue where the error message for an invalid source resource wasn't formatted correctly to include the name of the specified resource
* [Android] Added `androidAllowWhileIdle` boolean argument to the `periodicallyShow` method. When set to true, this changes how recurring notifications are shown so that the Android `AlarmManager` API is used to schedule a notification with exact timing. When the notification appears, the next one is scheduled after that. This is get around the limitations where the `AlarmManager` APIs don't provide a way for work to be repeated with precising timing regardless of the power mode.
  The example app has been updated to include these changes so that it can be used as a reference as well
* [Android] Added support for full-screen notifications via the `fullScreenIntent` argument that has been added to the constructor of the `AndroidNotificationDetails` class. Thanks to the PR from [Nadav Fima](https://github.com/nadavfima)
* [Android] Bumped compile SDK to 30 (Android 11)
* [Android] Added ability to specify shortcut id that can be used for conversations. See https://developer.android.com/guide/topics/ui/conversations for more info. Note the plugin doesn't provide the ability to publish shortcuts so developers will likely need to look into writing their own code to do so and save the shortcut id so that it can be linked to notifications
* [iOS] Updated the details in the plugin's podspec file
* [iOS] Added ability to specify a subtitle for a notification via the `subtitle` property of the `IOSNotificationDetails` class. This property is only application to iOS versions 10 or newer
* **Breaking change** The `InitializationSettings` and `NotificationDetails` classes no longer have positional parameters but now have named parameters called `android` and `iOS` for passing in data specific to Android and iOS. There `macOS` named parameter has also been added for passing data specific to macOS
* **Breaking change** The `toMap` method that was used internally to transfer data over platform channels is no longer publicly accessible
* **Breaking change** All enum values have been renamed to follow lower camel case convention. This affects the following enums
  * `Day`
  * `AndroidNotificationChannelAction`
  * `Importance` (note: as `default` is a keyword, what use to be `Default` is now `defaultImportance`)
  * `Priority` (note: as `default` is a keyword, what use to be `Default` is now `defaultPriority`)
  * `GroupAlertBehavior`
  * `NotificationVisibility`
  * `RepeatInterval`
* **Breaking change** assertions have been added to the `IOSInitializationSettings` constructor to prevent null values being passed in
* Updated example app so that code for demonstrating functionality that is specific to a platform are only visible when running on the appropriate platform
* Bumped Android dependencies
* Updated example app's Proguard rules file to match latest configuration required by GSON
* Bumped lower bound of Dart SDK dependency to 2.6
* Updated and fixed wording in API docs
* Readme now has a table of contents. Thanks to the PR from [Ascênio](https://github.com/Ascenio)

This was incorrectly published in the 1.5.0 update

# [1.5.0+1]

* Revert the breaking 1.5.0 update as that should have been published with the major version incremented

# [1.5.0]

* **BAD** This was a breaking change that was published as a minor version update. This has been reverted by [1.5.0+1]

* Added macOS implementation of the plugin
* The `schedule`, `showDailyAtTime` and `showWeeklyAtDayAndTime` methods has been marked as a deprecated due to problems with time zones, particularly when it comes to daylight savings.
* Added the `zonedSchedule` method to the plugin that allows for scheduling notifications to occur on a specific date and time relative a specific time zone. This can be used to schedule daily and weekly notifications as well. The example app has been updated to demonstrate its usage. Note that to support time zone-based scheduling, the plugin now depends on the `timezone` package so that an instance of the `TZDateTime` class is required to the specify the time the notification should occur. This should work in most cases as it is IANA-based and native platforms have time zones that are IANA-based as well. To support time zone aware dates on older versions of Android (which use older Java APIs), the plugin depends on the [ThreeTen Android Backport library](https://github.com/JakeWharton/ThreeTenABP). Once Flutter's support for Android Studio 4.0 and Android Gradle plugin 4.0 has stabilised, the plugin will be updated to make use of [desugaring](https://developer.android.com/studio/releases/gradle-plugin#j8-library-desugaring) instead of relying on the ThreeTen Android Backport library.
* [Android] Fixed issue [670] where `getNotificationAppLaunchDetails()` behaved inconsistently depending on if it was called before or after `initialize()`
* [Android] Added the `getActiveNotifications()` method to the `AndroidFlutterLocalNotificationsPlugin` class thanks to the PR from [Vincent Kammerer](https://github.com/vkammerer). This can be used to query the active notifications and is only applicable to Android 6.0 or newer
* [Android] Fixed an issue where the error message for an invalid source resource wasn't formatted correctly to include the name of the specified resource
* [Android] Added `androidAllowWhileIdle` boolean argument to the `periodicallyShow` method. When set to true, this changes how recurring notifications are shown so that the Android `AlarmManager` API is used to schedule a notification with exact timing. When the notification appears, the next one is scheduled after that. This is get around the limitations where the `AlarmManager` APIs don't provide a way for work to be repeated with precising timing regardless of the power mode.
  The example app has been updated to include these changes so that it can be used as a reference as well
* [Android] Added support for full-screen notifications via the `fullScreenIntent` argument that has been added to the `AndroidNotificationDetails` class. Thanks to the PR from [Nadav Fima](https://github.com/nadavfima)
* [Android] Bumped compile SDK to 30 (Android 11)
* [Android] Added ability to specify shortcut id that can be used for conversations. See https://developer.android.com/guide/topics/ui/conversations for more info. Note the plugin doesn't provide the ability to publish shortcuts so developers will likely need to look into writing their own code to do so and save the shortcut id so that it can be linked to notifications
* [iOS] Updated the details in the plugin's podspec file
* [iOS] Added ability to specify a subtitle for a notification via the `subtitle` property of the `IOSNotificationDetails` class. This property is only application to iOS versions 10 or newer
* **Breaking change** The `InitializationSettings` and `NotificationDetails` classes no longer have positional parameters but now have named parameters called `android` and `iOS` for passing in data specific to Android and iOS. There `macOS` named parameter has also been added for passing data specific to macOS
* **Breaking change** The `toMap` method that was used internally to transfer data over platform channels is no longer publicly accessible
* **Breaking change** All enum values have been renamed to follow lower camel case convention. This affects the following enums
  * `Day`
  * `AndroidNotificationChannelAction`
  * `Importance` (note: as `default` is a keyword, what use to be `Default` is now `defaultImportance`)
  * `Priority` (note: as `default` is a keyword, what use to be `Default` is now `defaultPriority`)
  * `GroupAlertBehavior`
  * `NotificationVisibility`
  * `RepeatInterval`
* **Breaking change** assertions have been added to the `IOSInitializationSettings` constructor to prevent null values being passed in
* Updated example app so that code for demonstrating functionality that is specific to a platform are only visible when running on the appropriate platform
* Bumped Android dependencies
* Updated example app's Proguard rules file to match latest configuration required by GSON
* Bumped lower bound of Dart SDK dependency to 2.6
* Updated and fixed wording in API docs
* Readme now has a table of contents. Thanks to the PR from [Ascênio](https://github.com/Ascenio)


# [1.4.4+5]

* Updated the `platform` package version range constraint so that 3.x null safety releases could be used (currently used in Flutter 1.22 stable)

# [1.4.4+4]

* [Android] Fix issue [759](https://github.com/MaikuB/flutter_local_notifications/issues/759) by guarding code on getting the intent from the activity in case there isn't an activity that could cause `initialize()` and `getNotificationAppLaunchDetails()` to fail when called from the background

# [1.4.4+3]

* [Android] Fix issue [751](https://github.com/MaikuB/flutter_local_notifications/issues/751) where the `onSelectNotification` callback could be called again after the user has tapped on a notification, sent the application to the background and returned to the app via the Recents screen. This issue could have previously called `getNotificationAppLaunchDetails()` to mistakenly report that a notification launched the app when it's called again as part of the application being resumed

# [1.4.4+2]

* [Android] Updated readme and plugin to fix issue [689](https://github.com/MaikuB/flutter_local_notifications/issues/689) where plugin needs to ensure notifications stay scheduled after an application update
* Removed `e2e` dependency

# [1.4.4+1]

* Added details that platform-specific implementations can be obtained to the _Caveats and limitations_ section
* Added a note on restrictions imposed by the OS by Android OEMs that may be prevent scheduled notifications appearing
* _Release configurations_ section of the readme renamed to _Release build configuration_

# [1.4.4]

* [iOS] Fixes to ensure that the native completion handlers were called appropriately. If you had some issues using this plugin combined with push notifications (e.g. via `firebase_messaging`) when the app was in the foreground then I would recommend updating to this version. Thanks to [Paweł Szot](https://github.com/szotp) for picking up the gap in the code in handling the native `willPresentNotification` call
* The readme has been been touched up and had some sections rearranged. Thanks to the PR from [psyanite](https://github.com/psyanite)
* Bumped lower bound of Dart SDK dependency to 2.0

# [1.4.3]

* [Android] added the ability to specify additional flags for the notification. For example, this could be used to allow the audio to repeat. See the API docs and update example app for more details. Thanks to the PR from [andylei](https://github.com/andylei)
* Minor cleanup of API docs

# [1.4.2]

* [Android] added the ability to specify the timestamp shown in the notification (issue [596](https://github.com/MaikuB/flutter_local_notifications/issues/596)). Thanks to the PR from [Nicolas Schneider](https://github.com/nioncode).
* Fixed API docs for `showWeeklyAtDayAndTime`

# [1.4.1]

* [Android] added the ability to create notification channels before a notification is shown. This can be done by calling the `createNotificationChannel` within the `AndroidFlutterLocalNotificationsPlugin` class. This allows applications to create notification channels before a notification is shown. Thanks to the PR from [Vladimir Gerashchenko](https://github.com/ZaarU).
* [Android] added the ability to delete notification channels. This can be done by calling `deleteNotificationChannel`  within `AndroidFlutterLocalNotificationsPlugin` class.

# [1.4.0]

Please note that there are a number of breaking changes in this release to improve the developer experience when using the plugin APIs. The changes should hopefully be straightforward but please through the changelog carefully just in case. The steps migrate your code has been covered below but the Git history of the example application's `main.dart` file can also be used as reference.

* [Android] **Breaking change** The `style` property of the `AndroidNotificationDetails` class has been removed as it was redundant. No changes are needed unless your application was displaying media notifications (i.e. `style` was set to `AndroidNotificationStyle.Media`). If this is the case, you can migrate your code by setting the `styleInformation` property of the `AndroidNotificationDetails` to an instance of the `MediaNotificationStyleInformation` class. This class is a new addition in this release
* [Android] **Breaking change** The `AndroidNotificationSound` abstract class has been introduced to represent Android notification sounds. The `sound` property of the `AndroidNotificationDetails` class has changed from being a `String` type to an `AndroidNotificationSound` type. In this release, the `AndroidNotificationSound` has the following subclasses

  * `RawResourceAndroidNotificationSound`: use this when the sound is raw resource associated with the Android application. Previously, this was the only type of sound supported so applications using the plugin prior to 1.4.0 can migrate their application by using this class. For example, if your previous code was

    ```dart
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description',
      sound: 'slow_spring_board');
    ```

    Replace it with

    ```dart
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description',
      sound: RawResourceAndroidNotificationSound('slow_spring_board');
    ```

  * `UriAndroidNotificationSound`: use this when a URI refers to the sound on the Android device. This is a new feature being supported as part of this release. Developers may need to write their code to access native Android APIs (e.g. the `RingtoneManager` APIs) to obtain the URIs they need.
* [Android] **Breaking change** The `BitmapSource` enum has been replaced by the newly `AndroidBitmap` abstract class and its subclasses. This removes the need to specify the name/path of the bitmap and the source of the bitmap as two separate properties (e.g. the `largeIcon` and `largeIconBitmapSource` properties of the `AndroidNotificationDetails` class). This change affects the following classes

  * `AndroidNotificationDetails`: the `largeIcon` is now an `AndroidBitmap` type instead of a `String` and the `largeIconBitmapSource` property has been removed
  * `BigPictureStyleInformation`: the `largeIcon` is now an `AndroidBitmap` type instead of a `String` and the `largeIconBitmapSource` property has been removed. The `bigPicture` is now a `AndroidBitmap` type instead of a `String` and the `bigPictureBitmapSource` property has been removed

  The following describes how each `BitmapSource` value maps to the `AndroidBitmap` subclasses

  * `BitmapSource.Drawable` -> `DrawableResourceAndroidBitmap`
  * `BitmapSource.FilePath` -> `FilePathAndroidBitmap`

  Each of these subclasses has a constructor that an argument referring to the bitmap itself. For example, if you previously had the following code 

    ```dart
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description',
      largeIcon: 'sample_large_icon',
      largeIconBitmapSource: BitmapSource.Drawable,
    )
    ```

    This would now be replaced with

    ```dart
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description',
      largeIcon: DrawableResourceAndroidBitmap('sample_large_icon'),
    )
    ```
* [Android] **Breaking change** The `IconSource` enum has been replaced by the newly added `AndroidIcon` abstract class and its subclasses. This change was done for similar reasons in replacing the `BitmapSource` enum. This only affects the `Person` class, which is used when displaying each person in a messaging-style notification. Here the `icon` property is now an `AndroidIcon` type instead of a `String` and the `iconSource` property has been removed.

  The following describes how each `IconSource` value maps to the `AndroidIcon` subclasses

    * `IconSource.Drawable` -> `DrawableResourceAndroidIcon`
    * `IconSource.FilePath` -> `BitmapFilePathAndroidIcon`
    * `IconSource.ContentUri` -> `ContentUriAndroidIcon`

  Each of these subclasses has a constructor that accepts an argument referring to the icon itself. For example, if you previously had the following code

  ```dart
  Person(
    icon: 'me',
    iconSource: IconSource.Drawable,
  )
  ```

  This would now be replaced with

  ```dart
  Person(
    icon: DrawableResourceAndroidIcon('me'),
  )
  ```

  The `AndroidIcon` also has a `BitmapAssetAndroidIcon` subclass to enables the usage of bitmap icons that have been registered as a Flutter asset via the `pubspec.yaml` file.
* [Android] **Breaking change** All properties in the `AndroidNotificationDetails`, `DefaultStyleInformation` and `InboxStyleInformation` classes have been made `final`
* The `DefaultStyleInformation` class now implements the `StyleInformation` class instead of extending it
* Where possible, classes in the plugins have been updated to provide `const` constructors
* Updates to API docs and readme
* Bump Android dependencies 
* Fixed a grammar issue 0.9.1 changelog entry

# [1.3.0]

* [iOS] **Breaking change** Plugin will now throw a `PlatformException` if there was an error returned upon calling the native [`addNotificationRequest`](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649508-addnotificationrequest) method. Previously the error was logged on the native side the using [`NSLog`](https://developer.apple.com/documentation/foundation/1395275-nslog) function.
* [iOS] Added ability to associate notifications with attachments. Only applicable to iOS 10+ where the UserNotification APIs are used. Thanks to the PR from [Pavel Sipaylo](https://github.com/psipaylo)
* Updated readme on using `firebase_messaging` together with `flutter_local_notifications` to let the community that `firebase_messaging` 6.0.13 can be used to resolve compatibility issues around callbacks when both plugins are used together

# [1.2.2]

* [Android] Added ability to specify if the timestamp for when a notification occurred should be displayed. Thanks to the PR from [mojtabaghiasi](https://github.com/mojtabaghiasi)

# [1.2.1]

* [Android] Fixed issue [512](https://github.com/MaikuB/flutter_local_notifications/issues/512) where calling `getNotificationAppLaunchDetails()` within the `onSelectNotification` callback could indicating that the app was launched by tapping on a notification when it wasn't the case
* Update example app to indicate if a notification launched the app and include the launch notification payload

# [1.2.0+4]

* Title at the top of the readme is now the same name as the plugin
* Updated readme to add subsections under the Android and iOS integration guide
* Added links in the readme under the Android release build configuration section that point to the configuration files used by the example app

# [1.2.0+3]

* Updated API docs for `resolvePlatformSpecificImplementation()` method

# [1.2.0+2]

* Make the static `values` propeerty of the `Priority` class return `List<Priority>` instead of being dynamic and added API docs for the property.

# [1.2.0+1]

* The static `values` properties for the `Day` and `Importance` classes now return `List<Day>` and `List<Importance>` respectively instead of being dynamic
* Added more public API documentation
* Updated readme to move issues and contributions section to the readme within the repository
* Added screenshots to readme
* Updated how breaking changes are highlighted in changelog to all the letters aren't capitalised

# [1.2.0]

* Added the `resolvePlatformSpecificImplementation()` method to the `FlutterLocalNotificationsPlugin` class. This can be used to resolve the underlying platform implementation in order to access platform-specific APIs.
* **Breaking change** the static `instance` properties in the `IOSFlutterLocalNotificationsPlugin` and `AndroidFlutterLocalNotificationsPlugin` classes have been removed due to addition of the `resolvePlatformSpecificImplementation()`
* Updated readme to remove use of `new` keyword in code snippets
* Bumped e2e dependency
* Bumped example app dependencies
* Make the pedantic dev_dependency explicit

# [1.1.7+1]

* Minor update to readme on description around requesting notification permissions
* Add link to forked `firebase_messaging` plugin to readme for those that want to use it whilst the PR to fix the compatibility issues with this plugin is waiting to be reviewed

# [1.1.7]

* [iOS] Added `requestPermissions()` method to `IOSFlutterLocalNotificationsPlugin` class. This can be used to request notification permissions separately from plugin initialisation. To facilitate this the `IOSFlutterLocalNotificationsPlugin` and `AndroidFlutterLocalNotificationsPlugin` now expose a static `instance` property that can be used obtain the platform-specific implementation of the plugin so that platform-specific methods can be used. Thanks to the PR from [Dariusz Łuksza](https://github.com/dluksza)
* Updated documentation to clarify that `getNotificationAppLaunchDetails()` is intended to be used more on if a notification from this plugin triggered launch an application
* Updated API docs for consistency and to better follow the guidelines on effective Dart documentation

# [1.1.6]

* [iOS] Added ability to set badge number. Thanks to PR from [FelixYew](https://github.com/FelixYew)
* Fixed a spelling mistake in the 1.1.5+1 changelog entry

# [1.1.5+1]

* No functional changes. Fixed a reported formatting issue
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

* **Breaking change** Updated plugin to make use of `flutter_local_notifications_platform_interface` version 1.0.1. This allows for platform-specific implementations of the platform interface to now be accessible. Note that the plugin will check which platform the plugin is running on.
  *Note*: this may have inadvertently broke some tests for users as the plugin now checks which platform the plugin is executing code on and would throw an `UnimplementedError` since neither iOS or Android can be detected. Another issue is that `NotificationAppLaunchDetails` was no longer exposed via the main plugin. Please upgrade to 1.1.3 to have both of these issues fixed
* **Breaking change** Plugin callbacks are no longer publicly accessible
* **Breaking change** [iOS] Local notifications that launched the app should now only be processed by the plugin if they were created by the plugin.
* **Breaking change** `MethodChannel` argument has been removed from the named constructor that was visible for testing purposes

# [1.0.0]

* **Breaking change** [iOS] Added checks to ensure callbacks are only invoked for notifications originating from the plugin to improve compatibility with other notification plugins.
* [Android] Bump Gradle plugin to 3.5.3

# [0.9.1+3]

* Include notes in getting started section to emphasise that the steps in the integration guide for each platform needs to be done.
* Move information in the readme on configuring resources to keep on Android.

# [0.9.1+2]

* Update link to repository due to restructuring.

# [0.9.1+1]

* Update readme with Swift example code on cancelling local notifications using the deprecated `UILocalNotification` iOS APIs when trying to prevent local notifications from appearing in the scenario where user has uninstalled the app whilst there are pending notification requests, reinstalled the app and ran it again.

# [0.9.1]

* Added support for media notifications. This currently only supports showing the specified image as album artwork. Thanks to the PR by [gianlucaparadise](https://github.com/gianlucaparadise)

# [0.9.0+1]

* Fix readme where Objective-C was written twice

# [0.9.0]

* [Android] Add ability to customise visibility of a notification on the lockscreen. Thanks to PR by [gianlucaparadise](https://github.com/gianlucaparadise)
* [Android] Bumped compile and target SDK to 29
* **Breaking change** [iOS] Plugin no longer registers as a `UNUserNotificationCenterDelegate`. This is to enable compatibility with other plugins that display notifications. Developers must now do this themselves. Refer to the updated iOS integration section for more info on this
* Updated info about configuring Proguard configuration rules and included a file that could be used for reference in the example app
* Removed dependency on the `meta` package
* **Breaking change** Now requires Flutter SDK 1.10.0 or greater
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
* **Breaking change** Bump minimum Flutter version to 1.5.0
* **Breaking change** Update Flutter dependencies

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

* **Breaking change** [Android] Updated to Gradle 5.1.1 and Android Gradle plugin has been updated to 3.4.0 (aligns with Android Studio 3.4 release). Example app has also been updated to Gradle 5.1.1. Apps will need to update to use the plugin. Please see [here](https://developer.android.com/studio/releases/gradle-plugin) for more information if you need help on updating
* [Android] Add ability to specify the LED colour of the notification. Updated example app to show this can be done. Note that for Android 8.0+ (i.e. API 26+) that this is tied to the notification channel


# [0.6.1]

* [Android/iOS] Added `pendingNotificationRequests` method. This will return a list of pending notification requests that have been scheduled to be shown in the future. Updated example app to include sample code for calling the method
* [Android] Fix an issue where scheduling a notification (recurring or otherwise) with the same id as another notification that was scheduled with the same id would result in both being stored in shared preferences. The shared preferences were used to reschedule notifications on reboot and shouldn't affect the functionality of displaying the notifications
* Updated plugin methods to return `Future<void>` instead of `Future` as per Dart guidelines
* Updated readme to mention known issue with scheduling notifications and daylight savings
* Refactored widgets in example app

# [0.6.0]

* **Breaking change** [Android] Updated Gradle plugin to 3.3.2
* **Breaking change** [Android] Changed to store the name of drawable specified as the small icon to be used for Android notifications instead of the resource ID. This should fix the scenario where an app could be updated and the resource IDs got change and cause scheduled notifications to not appear. Believe this fix should retroactively apply for notifications scheduled with an icon specified but won't apply to those that were scheduled to use the default icon specified via the `initialize` method. This is due to the fact the name of the default icon wasn't being cached in previous ones but this has now changed so it's cached in shared preferences from this version onwards

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

* **Breaking change** Migrated to use AndroidX as the Android support libraries are deprecated. There shouldn't be any functional changes. Developers may require migrating their apps to support this following [this guide](https://developer.android.com/jetpack/androidx/migrate). This addresses issue [162](https://github.com/MaikuB/flutter_local_notifications/issues/162). Thanks to [Jeff Scaturro](https://github.com/JeffScaturro) for submitting the PR for this work. Note that if you don't want to migrate your app to use AndroidX yet then you may need to pin dependencies to a specific version

# [0.4.5]

* Fix issue [160](https://github.com/MaikuB/flutter_local_notifications/issues/160) so that notifications created with the `schedule` on Android will appear at the exact date and time they are scheduled

# [0.4.4+2]

* Fix changelog

# [0.4.4+1]

* **Breaking change** Fix naming of `onDidReceiveLocalNotification` property in the `IOSInitializationSettings` class (was previously named `onDidReceiveLocalNotificationCallback` by accident)

# [0.4.4]

*  **Breaking change** removed `registerUNNotificationCenterDelegate` argument for the `IOSInitializationSettings` class as it wasn't actually used.
* Plugin can now handle `didReceiveLocalNotification` delegate method in iOS and allow developers to handle the associated callback in Flutter. Added a `onDidReceiveLocalNotificationCallback` argument to the `IOSInitializationSettings` class to enable this and updated the sample code to demonstrate the usage. This should resolve issue [14](https://github.com/MaikuB/flutter_local_notifications/issues/14).

# [0.4.3]

* Merged PR from Aine LLC (ganessaa) to fix issue [140](https://github.com/MaikuB/flutter_local_notifications/issues/140) where scheduled notifications were shown immediately on iOS versions before 10. Note that this issue is likely related to an [known issue in the Flutter engine](https://github.com/flutter/flutter/issues/21313) that may require switching channels to be addressed as the fix isn't on the stable channel yet.
* [Android] Provide a way to hide the large icon when showing an expanded big picture notification via the  `hideExpandedLargeIcon` flag within thr `BigPictureStyleInformation` class. This provides a solution for issue [136](https://github.com/MaikuB/flutter_local_notifications/issues/136). Updated the example to demonstrate
* Merged PR from (riccardoratta) so that sample code is coloured in GitHub to improve readability.

# [0.4.2+1]

* Update changelog to indicate when `MessageHandler` typedef got renamed (in 0.4.1) as raised in issue [132](https://github.com/MaikuB/flutter_local_notifications/issues/132)

# [0.4.2]

* **Breaking change** Fix issue [127](https://github.com/MaikuB/flutter_local_notifications/issues/127) by changing plugin to Android Support Library version 27.1.1, compile and target SDK version to 27 due to issues Flutter has with API 28. 

# [0.4.1+1]
* Remove unused code in example app

# [0.4.1]

* **Breaking change** renamed the `selectNotification` callback exposed by the `initialize` function to `onSelectNotification`
* **Breaking change** renamed the `MessageHandler` typedef to `SelectNotificationCallback`
* **Breaking change** updated plugin to Android Support Library version 28.0, compile and target SDK version to 28
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

* [Android] Fix issue [71](https://github.com/MaikuB/flutter_local_notifications/issues/71) where the wrong time on when the notification occurred is being displayed. **Breaking change** this involves changing it the receiver for displaying a scheduled notification will only build the notification prior to displaying it. There is a fix applied to existing scheduled notifications in this release that will be eventually be removed as going forward all scheduled notifications will work as just described
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

* [Android] Bug fix in calculating when to show a scheduled notification. Ensure scheduled Android notifications will remain scheduled even after rebooting.

## [0.1.1]

* [Android] Add ability to use HTML markup to format the title and content of notifications

## [0.1.0]

* [Android] Add support for big text style for and being able format the big text style specific content using HTML markup.

## [0.0.9]

* [iOS] Enable ability to customise the sound for notifications (**Important** requires testing on older iOS versions < 10)
* [iOS] Can now specify default presentation options (**Breaking change** named parameters for iOS initialisation have changed) that can also be overridden at the notification level).
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






















































