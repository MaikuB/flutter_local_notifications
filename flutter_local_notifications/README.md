# flutter_local_notifications

[![pub package](https://img.shields.io/pub/v/flutter_local_notifications.svg)](https://pub.dartlang.org/packages/flutter_local_notifications)
![Build Status](https://github.com/MaikuB/flutter_local_notifications/actions/workflows/validate.yml/badge.svg)

A cross platform plugin for displaying local notifications.

>[!IMPORTANT] 
> Given how both quickly both Flutter ecosystem and Android ecosystem evolves, the minimum Flutter SDK version will be bumped to make it easier to maintain the plugin. Note that official plugins already follow a similar approach e.g. have a minimum Flutter SDK version of 3.13. This is being called out as if this affects your applications (e.g. supported OS versions) then you may need to consider maintaining your own fork in the future

## Table of contents

- **[📱 Supported platforms](#-supported-platforms)**
- **[✨ Features](#-features)**
- **[⚠ Caveats and limitations](#-caveats-and-limitations)**
   - [Compatibility with firebase_messaging](#compatibility-with-firebase_messaging)
   - [Scheduled Android notifications](#scheduled-android-notifications)
   - [iOS pending notifications limit](#ios-pending-notifications-limit)
   - [Scheduled notifications and daylight saving time](#scheduled-notifications-and-daylight-saving-time)
   - [Updating application badge](#updating-application-badge)
   - [Custom notification sounds](#custom-notification-sounds)
   - [macOS differences](#macos-differences)
   - [Linux limitations](#linux-limitations)
   - [Notification payload](#notification-payload)
- **[📷 Screenshots](#-screenshots)**
- **[👏 Acknowledgements](#-acknowledgements)**
- **[Platform Specific Instructions](#platform-specific-instructions)**
- **[❓ Usage](#-usage)**
   - [Notification Actions](#notification-actions)
   - [Example app](#example-app)
   - [API reference](#api-reference)
- **[Initialisation](#initialisation)**
   - [Displaying a notification](#displaying-a-notification)
   - [Scheduling a notification](#scheduling-a-notification)
   - [Periodically show a notification with a specified interval](#periodically-show-a-notification-with-a-specified-interval)
   - [Retrieving pending notification requests](#retrieving-pending-notification-requests)
   - [[Selected OS versions] Retrieving active notifications](#retrieving-active-notifications)
   - [Grouping notifications](#grouping-notifications)
   - [Cancelling/deleting a notification](#cancellingdeleting-a-notification)
   - [Cancelling/deleting all notifications](#cancellingdeleting-all-notifications)
   - [Getting details on if the app was launched via a notification created by this plugin](#getting-details-on-if-the-app-was-launched-via-a-notification-created-by-this-plugin)
   - [[iOS only] Periodic notifications showing up after reinstallation](#ios-only-periodic-notifications-showing-up-after-reinstallation)
- **[📈 Testing](#-testing)**

## 📱 Supported platforms

* **Android 4.1+**. Uses the [NotificationCompat APIs](https://developer.android.com/reference/androidx/core/app/NotificationCompat) so it can be run older Android devices
* **iOS 8.0+**. On iOS versions older than 10, the plugin will use the UILocalNotification APIs. The [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework) is used on iOS 10 or newer. Notification actions only work on iOS 10 or newer.
* **macOS 10.11+**. On macOS versions older than 10.14, the plugin will use the [NSUserNotification APIs](https://developer.apple.com/documentation/foundation/nsusernotification). The [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework) is used on macOS 10.14 or newer. Notification actions only work on macOS 10.14 or newer
* **Linux**. Uses the [Desktop Notifications Specification](https://specifications.freedesktop.org/notification-spec/).

## ✨ Features

* Mockable (plugin and API methods aren't static)
* Display basic notifications
* Scheduling when notifications should appear
* Periodically show a notification (interval based)
* Schedule a notification to be shown daily at a specified time
* Schedule a notification to be shown weekly on a specified day and time
* Retrieve a list of pending notification requests that have been scheduled to be shown in the future
* Cancelling/removing notification by id or all of them
* Specify a custom notification sound
* Ability to handle when a user has tapped on a notification, when the app is in the foreground, background or is terminated
* Determine if an app was launched due to tapping on a notification
* [Android] Request permission to show notifications
* [Android] Configuring the importance level
* [Android] Configuring the priority
* [Android] Customising the vibration pattern for notifications
* [Android] Configure the default icon for all notifications
* [Android] Configure the icon for each notification (overrides the default when specified)
* [Android] Configure the large icon for each notification. The icon can be a drawable or a file on the device
* [Android] Formatting notification content via [HTML markup](https://developer.android.com/guide/topics/resources/string-resource.html#StylingWithHTML)
* [Android] Support for the following notification styles
    * Big picture
    * Big text
    * Inbox
    * Messaging
    * Media
        * While media playback control using a `MediaSession.Token` is not supported, with this style you let Android treat the `largeIcon` bitmap as album artwork
* [Android] Group notifications
* [Android] Show progress notifications
* [Android] Configure notification visibility on the lockscreen
* [Android] Ability to create and delete notification channels
* [Android] Retrieve the list of active notifications
* [Android] Full-screen intent notifications
* [Android] Start a foreground service
* [Android] Ability to check if notifications are enabled
* [iOS (all supported versions) & macOS 10.14+] Request notification permissions and customise the permissions being requested around displaying notifications
* [iOS 10 or newer and macOS 10.14 or newer] Display notifications with attachments
* [iOS and macOS 10.14 or newer] Ability to check if notifications are enabled with specific type check
* [Linux] Ability to to use themed/Flutter Assets icons and sound
* [Linux] Ability to to set the category
* [Linux] Configuring the urgency
* [Linux] Configuring the timeout (depends on system implementation)
* [Linux] Ability to set custom notification location (depends on system implementation)
* [Linux] Ability to set custom hints
* [Linux] Ability to suppress sound
* [Linux] Resident and transient notifications

## ⚠ Caveats and limitations

The cross-platform facing API exposed by the `FlutterLocalNotificationsPlugin` class doesn't expose platform-specific methods as its goal is to provide an abstraction for all platforms. As such, platform-specific configuration is passed in as data. There are platform-specific implementations of the plugin that can be obtained by calling the [`resolvePlatformSpecificImplementation`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/resolvePlatformSpecificImplementation.html). An example of using this is provided in the section on requesting permissions on iOS. In spite of this, there may still be gaps that don't cover your use case and don't make sense to add as they don't fit with the plugin's architecture or goals. Developers can fork or maintain their own code for showing notifications in these situations.

### Compatibility with firebase_messaging

Previously, there were issues that prevented this plugin working properly with the `firebase_messaging` plugin. This meant that callbacks from each plugin might not be invoked. This has been resolved since version 6.0.13 of the `firebase_messaging` plugin so please make sure you are using more recent versions of the  `firebase_messaging` plugin and follow the steps covered in `firebase_messaging`'s readme file located [here](https://pub.dev/packages/firebase_messaging)

### Scheduled Android notifications

Some Android OEMs have their own customised Android OS that can prevent applications from running in the background. Consequently, scheduled notifications may not work when the application is in the background on certain devices (e.g. by Xiaomi, Huawei). If you experience problems like this then this would be the reason why. As it's a restriction imposed by the OS, this is not something that can be resolved by the plugin. Some devices may have setting that lets users control which applications run in the background. The steps for these can vary but it is still up to the users of your application to do given it's a setting on the phone itself. The site https://dontkillmyapp.com provides details on how to do this for various devices.

It has been reported that Samsung's implementation of Android has imposed a maximum of 500 alarms that can be scheduled via the [Alarm Manager](https://developer.android.com/reference/android/app/AlarmManager) API and exceptions can occur when going over the limit.

### iOS pending notifications limit

There is a limit imposed by iOS where it will only keep the 64 notifications that were last set on any iOS versions newer than 9. On iOS versions 9 and older, the 64 notifications that fire soonest are kept. [See here for more details.](http://ileyf.cn.openradar.appspot.com/38065340)

### Scheduled notifications and daylight saving time

The notification APIs used on iOS versions older than 10 (aka the `UILocalNotification` APIs) have limited supported for time zones.

### Updating application badge

This plugin doesn't provide APIs for directly setting the badge count for your application. If you need this for your application, there are other plugins available, such as the [`flutter_app_badger`](https://pub.dev/packages/flutter_app_badger) plugin.

### Custom notification sounds

[iOS and macOS restrictions](https://developer.apple.com/documentation/usernotifications/unnotificationsound?language=objc) apply (e.g. supported file formats).

### macOS differences

Due to limitations currently within the macOS Flutter engine, `getNotificationAppLaunchDetails` will return null on macOS versions older than 10.14. These limitations will mean that conflicts may occur when using this plugin with other notification plugins (e.g. for push notifications).

The `schedule`, `showDailyAtTime` and `showWeeklyAtDayAndTime` methods that were implemented before macOS support was added and have been marked as deprecated aren't implemented on macOS.

### Linux limitations

Capabilities depend on the system notification server implementation, therefore, not all features listed in `LinuxNotificationDetails` may be supported. One of the ways to check some capabilities is to call the `LinuxFlutterLocalNotificationsPlugin.getCapabilities()` method.

Scheduled/pending notifications is currently not supported due to the lack of a scheduler API.

The `onDidReceiveNotificationResponse` callback runs on the main isolate of the running application and cannot be launched in the background if the application is not running. To respond to notification after the application is terminated, your application should be registered as DBus activatable (please see [DBusApplicationLaunching](https://wiki.gnome.org/HowDoI/DBusApplicationLaunching) for more information), and register action before activating the application. This is difficult to do in a plugin because plugins instantiate during application activation, so `getNotificationAppLaunchDetails` can't be implemented without changing the main user application.

### Notification payload

Due to some limitations on iOS with how it treats null values in dictionaries, a null notification payload is coalesced to an empty string behind the scenes on all platforms for consistency.

## 📷 Screenshots

| Platform | Screenshot |
| ------------- | ------------- |
| Android | <img height="480" src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/android_notification.png"> |
| iOS | <img height="414" src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/ios_notification.png"> |
| macOS | <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/macos_notification.png"> |
| Linux | <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/gnome_linux_notification.png"> <img src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/kde_linux_notification.png"> |


## 👏 Acknowledgements

* [Javier Lecuona](https://github.com/javiercbk) for submitting the PR that added the ability to have notifications shown daily
* [Jeff Scaturro](https://github.com/JeffScaturro) for submitting the PR to fix the iOS issue around showing daily and weekly notifications and migrating the plugin to AndroidX
* [Ian Cavanaugh](https://github.com/icavanaugh95) for helping create a sample to reproduce the problem reported in [issue #88](https://github.com/MaikuB/flutter_local_notifications/issues/88)
* [Zhang Jing](https://github.com/byrdkm17) for adding 'ticker' support for Android notifications
* ...and everyone else for their contributions. They are greatly appreciated

## Platform Specific Instructions

Use the following guides for platform specific setup and to learn about the way each platform handles notifications.

* [Android](Android.md)
* [iOS](IOS.md)

## ❓ Usage

Before going on to copy-paste the code snippets in this section, double-check you have configured your application correctly.
If you encounter any issues please refer to the API docs and the sample code in the `example` directory before opening a request on Github.

### Notification Actions

Notifications can now contain actions but note that on Apple's platforms, these work only on iOS 10 or newer and macOS 10.14 or newer.  On macOS and Linux (see [Linux limitations](#linux-limitations) chapter), these will only run on the main isolate by calling the `onDidReceiveNotificationResponse` callback. On iOS and Android, these will run on the main isolate by calling the `onDidReceiveNotificationResponse` callback if the configuration has specified that the app/user interface should be shown i.e. by specifying the `DarwinNotificationActionOption.foreground` option on iOS and the `showsUserInterface` property on Android. If they haven't, then these actions may be selected by the user when an app is sleeping or terminated and will wake up your app. However, it may not wake up the user-visible part of your App; but only the part of it which runs in the background. This is done by spawning a background isolate.

This plugin contains handlers for iOS & Android to handle these background isolate cases and will allow you to specify a Dart entry point (a function).
When the user selects a action, the plugin will start a **separate Flutter Engine** which will then invoke the `onDidReceiveBackgroundNotificationResponse` callback

**Configuration**:

*Android* and *Linux* do not require any configuration.

On Android and Linux, if you want to customize actions, you can put the actions directly in the `AndroidNotificationDetails` and `LinuxNotificationDetails` classes.

On Apple platforms, see [iOS/macOS Specific Configuration](AppleConfiguration)

Developers should also note that whilst accessing plugins will work, on Android there is **no** access to the `Activity` context. This means some plugins (like `url_launcher`) will require additional flags to start the main `Activity` again.

**Specifying actions on notifications**:

The notification actions are platform specific and you have to specify them differently for each platform.

On iOS/macOS, the actions are defined on a category, please see the configuration section for details.

On Android and Linux, the actions are configured directly on the notification.

``` dart
Future<void> _showNotificationWithActions() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    '...',
    '...',
    '...',
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('id_1', 'Action 1'),
      AndroidNotificationAction('id_2', 'Action 2'),
      AndroidNotificationAction('id_3', 'Action 3'),
    ],
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      0, '...', '...', notificationDetails);
}
```

Each notification will have a internal ID & an public action title.

### Example app

The [`example`](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) directory has a sample application that demonstrates the features of this plugin.

### API reference

Checkout the lovely [API documentation](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/flutter_local_notifications-library.html) generated by pub.

## Initialisation

The first step is to create a new instance of the plugin class and then initialise it with the settings to use for each platform

```dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
        defaultActionName: 'Open notification');
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux);
await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
```

Initialisation can be done in the `main` function of your application or can be done within the first page shown in your app. Developers can refer to the example app that has code for the initialising within the `main` function. The code above has been simplified for explaining the concepts. Here we have specified the default icon to use for notifications on Android (refer to the *Android setup* section) and designated the function (`onDidReceiveNotificationResponse`) that should fire when a notification has been tapped on via the `onDidReceiveNotificationResponse` callback. Specifying this callback is entirely optional but here it will trigger navigation to another page and display the payload associated with the notification. This callback **cannot** be used to handle when a notification launched an app. Use the `getNotificationAppLaunchDetails` method when the app starts if you need to handle when a notification triggering the launch for an app e.g. change the home route of the app for deep-linking.

Note that all settings are nullable, because we don't want to force developers so specify settings for platforms they don't target. You will get a runtime ArgumentError Exception if you forgot to pass the settings for the platform you target.

```dart
void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    );
}
```

In the real world, this payload could represent the id of the item you want to display the details of. Once the initialisation is complete, then you can manage the displaying of notifications. Note that this callback is only intended to work when the app is running. For scenarios where your application needs to handle when a notification launched the app refer to [here](#getting-details-on-if-the-app-was-launched-via-a-notification-created-by-this-plugin)

The `DarwinInitializationSettings` class provides default settings on how the notification be presented when it is triggered and the application is in the foreground on iOS/macOS. There are optional named parameters that can be modified to suit your application's purposes. Here, it is omitted and the default values for these named properties is set such that all presentation options (alert, sound, badge) are enabled. 

The `LinuxInitializationSettings` class requires a name for the default action that calls the `onDidReceiveNotificationResponse` callback when the notification is clicked. 

On iOS and macOS, initialisation may show a prompt to requires users to give the application permission to display notifications (note: permissions don't need to be requested on Android). Depending on when this happens, this may not be the ideal user experience for your application. If so, please refer to [iOS/macOS Request Permissions](AppleRequestPermissions.md).

For an explanation of the `onDidReceiveLocalNotification` callback associated with the `DarwinInitializationSettings` class, please read [this](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications#handling-notifications-whilst-the-app-is-in-the-foreground).

### Displaying a notification

```dart
const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
await flutterLocalNotificationsPlugin.show(
    0, 'plain title', 'plain body', notificationDetails,
    payload: 'item x');
```

Here, the first argument is the id of notification and is common to all methods that would result in a notification being shown. This is typically set a unique value per notification as using the same id multiple times would result in a notification being updated/overwritten.

The details specific to the Android platform are also specified. This includes the channel details that is required for Android 8.0+. Whilst not shown, it's possible to specify details for iOS and macOS as well using the optional `iOS` and `macOS` named parameters if needed. The payload has been specified ('item x'), that will passed back through your application when the user has tapped on a notification. Note that for Android devices that notifications will only in appear in the tray and won't appear as a toast aka heads-up notification unless things like the priority/importance has been set appropriately. Refer to the Android docs (https://developer.android.com/guide/topics/ui/notifiers/notifications.html#Heads-up) for additional information. The "ticker" text is passed here is optional and specific to Android. This allows for text to be shown in the status bar on older versions of Android when the notification is shown.

### Scheduling a notification

Starting in version 2.0 of the plugin, scheduling notifications now requires developers to specify a date and time relative to a specific time zone. This is to solve issues with daylight saving time that existed in the `schedule` method that is now deprecated. A new `zonedSchedule` method is provided that expects an instance `TZDateTime` class provided by the [`timezone`](https://pub.dev/packages/timezone) package. Even though the `timezone` package is be a transitive dependency via this plugin, it is recommended based on [this lint rule](https://dart-lang.github.io/linter/lints/depend_on_referenced_packages.html) that you also add the `timezone` package as a direct dependency. 

Once the dependency as been added, usage of the `timezone` package requires initialisation that is covered in the package's readme. For convenience the following are code snippets used by the example app.

Import the `timezone` package

```dart
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
```

Initialise the time zone database

```dart
tz.initializeTimeZones();
```

Once the time zone database has been initialised, developers may optionally want to set a default local location/time zone

```dart
tz.setLocalLocation(tz.getLocation(timeZoneName));
```

The `timezone` package doesn't provide a way to obtain the current time zone on the device so developers will need to use [platform channels](https://flutter.dev/docs/development/platform-integration/platform-channels) or use other packages that may be able to provide the information. [`flutter_timezone`](https://pub.dev/packages/flutter_timezone) is the current version of the original `flutter_native_timezone` plugin used in the example app.

Assuming the local location has been set, the `zonedSchedule` method can then be called in a manner similar to the following code

```dart
await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'scheduled title',
    'scheduled body',
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description')),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
```

On Android, the `androidScheduleMode` is used to determine the precision on when the notification would be delivered. In this example, it's been specified that it should appear at the exact time even when the device has entered a low-powered idle mode. Note that this requires that the exact alarm permission has been granted. If it's been revoked then the plugin will log an error message. Note that if the notification was scheduled to be recurring one but the permission had been revoked then it will no be scheduled as well. In either case, this is where developers may choose to schedule inexact notifications instead via the `androidScheduleMode` parameter.

The `uiLocalNotificationDateInterpretation` is required as on iOS versions older than 10 as time zone support is limited. This means it's not possible schedule a notification for another time zone and have iOS adjust the time the notification will appear when daylight saving time happens. With this parameter, it is used to determine if the scheduled date should be interpreted as absolute time or wall clock time.

There is an optional `matchDateTimeComponents` parameter that can be used to schedule a notification to appear on a daily or weekly basis by telling the plugin to match on the time or a combination of day of the week and time respectively.

If you are trying to update your code so it doesn't use the deprecated methods for showing daily or weekly notifications that occur on a specific day of the week then you'll need to perform calculations that would determine the next instance of a date that meets the conditions for your application. See the example application that shows one of the ways that can be done e.g. how schedule a weekly notification to occur on Monday 10:00AM.

### Periodically show a notification with a specified interval

```dart
const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'repeating channel id', 'repeating channel name',
        channelDescription: 'repeating description');
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
    'repeating body', RepeatInterval.everyMinute, notificationDetails,
    androidAllowWhileIdle: true);
```

### Retrieving pending notification requests

```dart
final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
```

### Retrieving active notifications

```dart
final List<ActiveNotification> activeNotifications =
    await flutterLocalNotificationsPlugin.getActiveNotifications();
```

**Note**: The API only works for the following operating systems and versions
- Android 6.0 or newer
- iOS 10.0 or newer
- macOS 10.14 or newer

### Grouping notifications

iOS and Android have different setup to ensure notifications are grouped. Use the following links respectively.

* [iOS](IOSGrouping.md)
* [Android](AndroidGrouping.md)

### Cancelling/deleting a notification

```dart
// cancel the notification with id value of zero
await flutterLocalNotificationsPlugin.cancel(0);
```

### Cancelling/deleting all notifications

```dart
await flutterLocalNotificationsPlugin.cancelAll();
```

### Getting details on if the app was launched via a notification created by this plugin

```dart
final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
```

### [iOS only] Periodic notifications showing up after reinstallation

If you have set notifications to be shown periodically on older iOS versions (< 10) and the application was uninstalled without cancelling all alarms, then the next time it's installed you may see the "old" notifications being fired. If this is not the desired behaviour then you can add code similar to the following to the `didFinishLaunchingWithOptions` method of your `AppDelegate` class.


Objective-C:

```objc
if(![[NSUserDefaults standardUserDefaults]objectForKey:@"Notification"]){
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Notification"];
}
```

Swift:

```swift
if(!UserDefaults.standard.bool(forKey: "Notification")) {
    UIApplication.shared.cancelAllLocalNotifications()
    UserDefaults.standard.set(true, forKey: "Notification")
}
```

## 📈 Testing

As the plugin class is not static, it is possible to mock and verify its behaviour when writing tests as part of your application.
Check the source code for a sample test suite that has been kindly implemented (_test/flutter_local_notifications_test.dart_) that demonstrates how this can be done.

If you decide to use the plugin class directly as part of your tests, the methods will be mostly no-op and methods that return data will return default values.

Part of this is because the plugin detects if you're running on a supported plugin to determine which platform implementation of the plugin should be used. If the platform isn't supported, it will default to the aforementioned behaviour to reduce friction when writing tests. If this not desired then consider using mocks.

If a platform-specific implementation of the plugin is required for your tests, use the [debugDefaultTargetPlatformOverride](https://api.flutter.dev/flutter/foundation/debugDefaultTargetPlatformOverride.html) property provided by the Flutter framework.
