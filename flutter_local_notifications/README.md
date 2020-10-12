# flutter_local_notifications

[![pub package](https://img.shields.io/pub/v/flutter_local_notifications.svg)](https://pub.dartlang.org/packages/flutter_local_notifications)
[![Build Status](https://api.cirrus-ci.com/github/MaikuB/flutter_local_notifications.svg)](https://cirrus-ci.com/github/MaikuB/flutter_local_notifications/master)

A cross platform plugin for displaying local notifications. 

## Table of contents
- **[📱 Supported platforms](#-supported-platforms)**
- **[✨ Features](#-features)**
- **[⚠ Caveats and limitations](#-caveats-and-limitations)**
   - [Compatibility with firebase_messaging](#compatibility-with-firebase_messaging)
   - [Scheduled Android notifications](#scheduled-android-notifications)
   - [Recurring Android notifications](#recurring-android-notifications)
   - [iOS pending notifications limit](#ios-pending-notifications-limit)
   - [Scheduled notifications and daylight savings](#scheduled-notifications-and-daylight-savings)
   - [Custom notification sounds](#custom-notification-sounds)
   - [macOS differences](#macos-differences)
- **[📷 Screenshots](#-screenshots)**
- **[👏 Acknowledgements](#-acknowledgements)**
- **[⚙️ Android Setup](#️-android-setup)**
   - [Custom notification icons and sounds](#custom-notification-icons-and-sounds)
   - [Scheduled notifications](#scheduled-notifications)
   - [Fullscreen intent notifications](#fullscreen-intent-notifications)
   - [Release build configuration](#release-build-configuration)
- **[⚙️ iOS setup](#️-ios-setup)**
   - [General setup](#general-setup)
   - [Handling notifications whilst the app is in the foreground](#handling-notifications-whilst-the-app-is-in-the-foreground)
- **[❓ Usage](#-usage)**
   - [Example app](#example-app)
   - [API reference](#api-reference)
- **[Initialisation](#initialisation)**
   - [[iOS (all supported versions) and macOS 10.14+] Requesting notification permissions](#ios-all-supported-versions-and-macos-1014-requesting-notification-permissions)
   - [Displaying a notification](#displaying-a-notification)
   - [Scheduling a notification](#scheduling-a-notification)
   - [Periodically show a notification with a specified interval](#periodically-show-a-notification-with-a-specified-interval)
   - [Retrieveing pending notification requests](#retrieveing-pending-notification-requests)
   - [[Android only] Retrieving active notifications](#android-only-retrieving-active-notifications)
   - [[Android only] Grouping notifications](#android-only-grouping-notifications)
   - [Cancelling/deleting a notification](#cancellingdeleting-a-notification)
   - [Cancelling/deleting all notifications](#cancellingdeleting-all-notifications)
   - [Getting details on if the app was launched via a notification created by this plugin](#getting-details-on-if-the-app-was-launched-via-a-notification-created-by-this-plugin)
   - [[iOS only] Periodic notifications showing up after reinstallation](#ios-only-periodic-notifications-showing-up-after-reinstallation)
- **[📈 Testing](#-testing)**

## 📱 Supported platforms
* **Android 4.1+**. Uses the [NotificationCompat APIs](https://developer.android.com/reference/androidx/core/app/NotificationCompat) so it can be run older Android devices
* **iOS 8.0+**. On iOS versions older than 10, the plugin will use the UILocalNotification APIs. The [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework) is used on iOS 10 or newer.
* **macOS 10.11+**. On macOS versions older than 10.14, the plugin will use the [NSUserNotification APIs](https://developer.apple.com/documentation/foundation/nsusernotification). The [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework) is used on macOS 10.14 or newer.

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
* Ability to handle when a user has tapped on a notification, when the app is the foreground, background or terminated
* Determine if an app was launched due to tapping on a notification
* [Android] Configuring the importance level
* [Android] Configuring the priority
* [Android] Customising the vibration pattern for notifications
* [Android] Configure the default icon for all notifications
* [Android] Configure the icon for each notification (overrides the default when specified)
* [Android] Configure the large icon for each notification. The icon can be a drawable or a file on the device
* [Android] Formatting notification content via ([HTML markup](https://developer.android.com/guide/topics/resources/string-resource.html#StylingWithHTML))
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
* [iOS (all supported versions) & macOS 10.14+] Request notification permissions and customise the permissions being requested around displaying notifications
* [iOS 10 or newer and macOS 10.14 or newer] Display notifications with attachments

## ⚠ Caveats and limitations
The cross-platform facing API exposed by the `FlutterLocalNotificationsPlugin` class doesn't expose platform-specific methods as its goal is to provide an abstraction for all platforms. As such, platform-specific configuration is passed in as data. There are platform-specific implementations of the plugin that can be obtained by calling the [`resolvePlatformSpecificImplementation`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/resolvePlatformSpecificImplementation.html). An example of using this is provided in the section on requesting permissions on iOS. In spite of this, there may still be gaps that don't cover your use case and don't make sense to add as they don't fit with the plugin's architecture or goals. Developers can fork or maintain their own code for showing notifications in these situations.

##### Compatibility with firebase_messaging
Previously, there were issues that prevented this plugin working properly with the `firebase_messaging` plugin. This meant that callbacks from each plugin might not be invoked. Version 6.0.13 of `firebase_messaging` should resolve this issue so please bump your `firebase_messaging` dependency and follow the steps covered in `firebase_messaging`'s readme file.

##### Scheduled Android notifications
Some Android OEMs have their own customised Android OS that can prevent applications from running in the background. Consequently, scheduled notifications may not work when the application is in the background on certain devices (e.g. by Xiaomi, Huawei). If you experience problems like this then this would be the reason why. As it's a restriction imposed by the OS, this is not something that can be resolved by the plugin. Some devices may have setting that lets users control which applications run in the background. The steps for these can be vary and but is still up to the users of your application to do given it's a setting on the phone itself.

##### Recurring Android notifications
This feature uses the [Alarm Manager](https://developer.android.com/reference/android/app/AlarmManager) API. This is standard practice but does mean the delivery of the notifications/alarms are inexact and this is documented Android behaviour as per the previous link. It has been reported that Samsung's implementation of Android has imposed a maximum of 500 alarms that can be scheduled via this API and exceptions can occur when going over the limit.

##### iOS pending notifications limit
There is a limit imposed by iOS where it will only keep 64 notifications that will fire the soonest.

##### Scheduled notifications and daylight savings
The notification APIs used on iOS versions older than 10 (aka the `UILocalNotification` APIs) have limited supported for time zones.

##### Custom notification sounds
[iOS and macOS restrictions](https://developer.apple.com/documentation/usernotifications/unnotificationsound?language=objc) apply (e.g. supported file formats).

##### macOS differences

Due to limitations currently within the macOS Flutter engine, `getNotificationAppLaunchDetails` will return null on macOS versions older than 10.14. These limitations will mean that conflicts may occur when using this plugin with other notification plugins (e.g. for push notifications).

The `schedule`, `showDailyAtTime` and `showWeeklyAtDayAndTime` methods that were implemented before macOS support was added and have been marked as deprecated aren't implemented on macOS.

## 📷 Screenshots

| Android | iOS |
| ------------- | ------------- |
| <img height="480" src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/android_notification.png"> |  <img height="414" src="https://github.com/MaikuB/flutter_local_notifications/raw/master/images/ios_notification.png"> |

## 👏 Acknowledgements

* [Javier Lecuona](https://github.com/javiercbk) for submitting the PR that added the ability to have notifications shown daily
* [Jeff Scaturro](https://github.com/JeffScaturro) for submitting the PR to fix the iOS issue around showing daily and weekly notifications and migrating the plugin to AndroidX
* [Ian Cavanaugh](https://github.com/icavanaugh95) for helping create a sample to reproduce the problem reported in [issue #88](https://github.com/MaikuB/flutter_local_notifications/issues/88)
* [Zhang Jing](https://github.com/byrdkm17) for adding 'ticker' support for Android notifications
* ...and everyone else for their contributions. They are greatly appreciated

## ⚙️ Android Setup

#### Custom notification icons and sounds

Notification icons should be added as a drawable resource. The example project/code shows how to set default icon for all notifications and how to specify one for each notification. It is possible to use launcher icon/mipmap and this by default is `@mipmap/ic_launcher` in the Android manifest and can be passed `AndroidInitializationSettings` constructor. However, the offical Android guidance is that you should use drawable resources. Custom notification sounds should be added as a raw resource and the sample illustrates how to play a notification with a custom sound. Refer to the following links around Android resources and notification icons.

 * [Notifications](https://developer.android.com/studio/write/image-asset-studio#notification)
 * [Providing resources](https://developer.android.com/guide/topics/resources/providing-resources)
 * [Icon design status bar](https://developer.android.com/guide/practices/ui_guidelines/icon_design_status_bar)


When specifying the large icon bitmap or big picture bitmap (associated with the big picture style), bitmaps can be either a drawable resource or file on the device. This is specified via a single property (e.g. the `largeIcon` property associated with the `AndroidNotificationDetails` class) where a value that is an instance of the `DrawableResourceAndroidBitmap` means the bitmap should be loaded from an drawable resource. If this is an instance of the `FilePathAndroidBitmap`, this indicates it should be loaded from a file referred to by a given file path.

⚠️ For Android 8.0+, sounds and vibrations are associated with notification channels and can only be configured when they are first created. Showing/scheduling a notification will create a channel with the specified id if it doesn't exist already. If another notification specifies the same channel id but tries to specify another sound or vibration pattern then nothing occurs.

#### Scheduled notifications

If your application needs the ability to schedule notifications then you need to request permissions to be notified when the phone has been booted as scheduled notifications uses the `AlarmManager` API to determine when notifications should be displayed. However, they are cleared when a phone has been turned off. Requesting permission requires adding the following to the manifest (i.e. your application's `AndroidManifest.xml` file)

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

The following is also needed to ensure notifications remain scheduled upon a reboot and after an application is updated

```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
</receiver>
```

Developers will also need to add the following so that plugin can handle displaying scheduled notifications

```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
```

If the vibration pattern of an Android notification will be customised then add the following

```xml
<uses-permission android:name="android.permission.VIBRATE" />
```


#### Fullscreen intent notifications

If your application needs the ability to schedule full-screen intent notifications, add the following to the manifest (i.e. your application's `AndroidManifest.xml` file)

```xml
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

You'll also need to add the next attributes to the activity you're opening, usually the class that extends FlutterActivity.
These make sure the screen turns on and shows when the device is locked.
```xml
<activity
    android:showWhenLocked="true"
    android:turnScreenOn="true">
```

For reference, the example app's `AndroidManifest.xml` file can be found [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/src/main/AndroidManifest.xml)


#### Release build configuration

Before creating the release build of your app (which is the default setting when building an APK or app bundle) you will likely need to customise your ProGuard configuration file as per this [link](https://developer.android.com/studio/build/shrink-code#keep-code) and add the following line:

```
-keep class com.dexterous.** { *; }
```

After doing so, rules specific to the GSON dependency being used by the plugin will also needed to be added. These rules can be found [here](https://github.com/google/gson/blob/master/examples/android-proguard-example/proguard.cfg). The example app has a consolidated Proguard rules (`proguard-rules.pro`) file that combines these together for reference [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/proguard-rules.pro).

⚠️ Ensure that you have configured the resources that should be kept so that resources like your notification icons aren't discarded by the R8 compiler by following the instructions [here](https://developer.android.com/studio/build/shrink-code#keep-resources). Without doing this, you might not see the icon you've specified in your app's notifications. The configuration used by the example app can be found [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/src/main/res/raw/keep.xml) where it is specifying that all drawable resources should be kept, as well as the file used to play a custom notification sound (sound file is located [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/src/main/res/raw/slow_spring_board.mp3)).



## ⚙️ iOS setup

#### General setup

Add the following lines to the `didFinishLaunchingWithOptions` method in the AppDelegate.m/AppDelegate.swift file of your iOS project

Objective-C:
```objc
if (@available(iOS 10.0, *)) {
  [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
}
```

Swift:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

#### Handling notifications whilst the app is in the foreground
By design, iOS applications *do not* display notifications while the app is in the foreground. 

For iOS 10+, use the presentation options to control the behaviour for when a notification is triggered while the app is in the foreground. 

For older versions of iOS, you need to handle the callback as part of specifying the method that should be fired to the `onDidReceiveLocalNotification` argument when creating an instance `IOSInitializationSettings` object that is passed to the function for initializing the plugin. 

Here is an example:

```dart
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS);
flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: onSelectNotification);

...

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecondScreen(payload),
              ),
            );
          },
        )
      ],
    ),
  );
}
```



## ❓ Usage
Before going on to copy-paste the code snippets in this section, double-check you have configured your application correctly.
If you encounter any issues please refer to the API docs and the sample code in the `example` directory before opening a request on Github.

### Example app
The `example` directory has a sample application that demonstrates the features of this plugin.

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
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
final MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings();
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS);
await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: selectNotification);
```

Initialisation should only be done **once**, and this can be done is in the `main` function of your application. Alternatively, this can be done within the first page shown in your app. Developers can refer to the example app that has code for the initialising within the `main` function. The code above has been simplified for explaining the concepts. Here we have specified the default icon to use for notifications on Android (refer to the *Android setup* section) and designated the function (`selectNotification`) that should fire when a notification has been tapped on via the `onSelectNotification` callback. Specifying this callback is entirely optional but here it will trigger navigation to another page and display the payload associated with the notification.

```dart
Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    );
}
```

In the real world, this payload could represent the id of the item you want to display the details of. Once the initialisation is complete, then you can manage the displaying of notifications.

The `IOSInitializationSettings` and `MacOSInitializationSettings` provides default settings on how the notification be presented when it is triggered and the application is in the foreground. There are optional named parameters that can be modified to suit your application's purposes. Here, it is omitted and the default values for these named properties is set such that all presentation options (alert, sound, badge) are enabled.

On iOS and macOS, initialisation may show a prompt to requires users to give the application permission to display notifications (note: permissions don't need to be requested on Android). Depending on when this happens, this may not be the ideal user experience for your application. If so, please refer to the next section on how to work around this.



⚠ If the app has been launched by tapping on a notification created by this plugin, calling `initialize` is what will trigger the `onSelectNotification` to trigger to handle the notification that the user tapped on. An alternative to handling the "launch notification" is to call the `getNotificationAppLaunchDetails` method that is available in the plugin. This could be used, for example, to change the home route of the app for deep-linking. Calling `initialize` will still cause the `onSelectNotification` callback to fire for the launch notification. It will be up to developers to ensure that they don't process the same notification twice (e.g. by storing and comparing the notification id).

### [iOS (all supported versions) and macOS 10.14+] Requesting notification permissions

The constructor for the `IOSInitializationSettings` and `MacOSInitializationSettings` classes has three named parameters (`requestSoundPermission`, `requestBadgePermission` and `requestAlertPermission`) that controls which permissions are being requested. If you want to request permissions at a later point in your application on iOS, set all of the above to false when initialising the plugin.

```dart
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
```

Then call the `requestPermissions` method with desired permissions at the appropriate point in your application


For iOS:

```dart
final bool result = await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
    );
```

For macOS:

```dart
final bool result = await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
    );
```

Here the call to `flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()` returns the iOS implementation of the plugin that contains APIs specific to iOS if the application is running on iOS. Similarly, the macOS implementation is returned by calling `flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()`. The `?.` operator is used as the result will be null when run on other platforms. Developers may alternatively choose to guard this call by checking the platform their application is running on.

### Displaying a notification

```dart
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
await flutterLocalNotificationsPlugin.show(
    0, 'plain title', 'plain body', platformChannelSpecifics,
    payload: 'item x');
```

In this block of code, the details specific to the Android platform is specified. This includes the channel details that is required for Android 8.0+. Whilst not shown, it's possible to specify details for iOS and macOS as well using the optional `iOS` and `macOS` named parameters if needed. The payload has been specified ('item x'), that will passed back through your application when the user has tapped on a notification. Note that for Android devices that notifications will only in appear in the tray and won't appear as a toast aka heads-up notification unless things like the priority/importance has been set appropriately. Refer to the Android docs (https://developer.android.com/guide/topics/ui/notifiers/notifications.html#Heads-up) for additional information. Note that the "ticker" text is passed here though it is optional and specific to Android. This allows for text to be shown in the status bar on older versions of Android when the notification is shown.

### Scheduling a notification

Starting in version 1.5 of the plugin, scheduling notifications now requires developers to specify a date and time relative to a specific time zone. This is to solve issues with daylight savings that existed in the `schedule` method that is now deprecated. A new `zonedSchedule` method is provided that expects an instance `TZDateTime` class provided by the [`timezone`](https://pub.dev/packages/timezone) package. As the `flutter_local_notifications` plugin already depends on the `timezone` package, it's not necessary for developers to add the `timezone` package as a direct dependency. In other words, the `timezone` package will be a transitive dependency after you add the `flutter_local_notifications` plugin as a dependency in your application.

Usage of the `timezone` package requires initialisation that is covered in the package's readme. For convenience the following are code snippets used by the example app.

Import the `timezone` package

```dart
import 'package:timezone/data/latest.dart' as tz;
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

The `timezone` package doesn't provide a way to obtain the current time zone on the device so developers will need to use platform channels (which is what the example app does) or use other packages that may be able to provide the information (e.g. [`flutter_native_timezone`](https://pub.dev/packages/flutter_native_timezone)).

Assuming the local location has been set, the `zonedScheduled` method can then be called in a manner similar to the following code

```dart
await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'scheduled title',
    'scheduled body',
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
        android: AndroidNotificationDetails('your channel id',
            'your channel name', 'your channel description')),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
```

On Android, the `androidAllowWhileIdle` is used to determine if the notification should be delivered at the specified time even when the device in a low-power idle mode.

The `uiLocalNotificationDateInterpretation` is required as on iOS versions older than 10 as time zone support is limited. This means it's not possible schedule a notification for another time zone and have iOS adjust the time the notification will appear when daylight savings happens. With this parameter, it is used to determine if the scheduled date should be interpreted as absolute time or wall clock time.

There is an optional `scheduledNotificationRepeatFrequency` parameter that can be used to schedule a notification to appear on a daily or weekly basis.

### Periodically show a notification with a specified interval

```dart
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('repeating channel id',
        'repeating channel name', 'repeating description');
const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
    'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics,
    androidAllowWhileIdle: true);
```

### Retrieveing pending notification requests

```dart
final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
```

### [Android only] Retrieving active notifications

```dart
final List<ActiveNotification> activeNotifications =
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();
```

### [Android only] Grouping notifications

This is a "translation" of the sample available at https://developer.android.com/training/notify-user/group.html
For iOS, you could just display the summary notification (not shown in the example) as otherwise the following code would show three notifications 

```dart
const String groupKey = 'com.android.example.WORK_EMAIL';
const String groupChannelId = 'grouped channel id';
const String groupChannelName = 'grouped channel name';
const String groupChannelDescription = 'grouped channel description';
// example based on https://developer.android.com/training/notify-user/group.html
const AndroidNotificationDetails firstNotificationAndroidSpecifics =
    AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey);
const NotificationDetails firstNotificationPlatformSpecifics =
    NotificationDetails(android: firstNotificationAndroidSpecifics);
await flutterLocalNotificationsPlugin.show(1, 'Alex Faarborg',
    'You will not believe...', firstNotificationPlatformSpecifics);
const AndroidNotificationDetails secondNotificationAndroidSpecifics =
    AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey);
const NotificationDetails secondNotificationPlatformSpecifics =
    NotificationDetails(android: secondNotificationAndroidSpecifics);
await flutterLocalNotificationsPlugin.show(
    2,
    'Jeff Chang',
    'Please join us to celebrate the...',
    secondNotificationPlatformSpecifics);

// Create the summary notification to support older devices that pre-date
/// Android 7.0 (API level 24).
///
/// Recommended to create this regardless as the behaviour may vary as
/// mentioned in https://developer.android.com/training/notify-user/group
const List<String> lines = <String>[
    'Alex Faarborg  Check this out',
    'Jeff Chang    Launch Party'
];
const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
    lines,
    contentTitle: '2 messages',
    summaryText: 'janedoe@example.com');
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        styleInformation: inboxStyleInformation,
        groupKey: groupKey,
        setAsGroupSummary: true);
const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
await flutterLocalNotificationsPlugin.show(
    3, 'Attention', 'Two messages', platformChannelSpecifics);
```

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
final NotificationAppLaunchDetails notificationAppLaunchDetails =
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

Part of this is because the plugin detects if you're running on a supported plugin to determine which platform implementation of the plugin should be used. If it's neither Android or iOS, then it defaults to the aforementioned behaviour to reduce friction when writing tests. If this not desired then consider using mocks. 

If a platform-specific implementation of the plugin is required for your tests, a [named constructor](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/FlutterLocalNotificationsPlugin.private.html) is available that allows you to specify the platform required e.g. a [`FakePlatform`](https://api.flutter.dev/flutter/package-platform_platform/FakePlatform-class.html).
