# flutter_local_notifications

[![pub package](https://img.shields.io/pub/v/flutter_local_notifications.svg)](https://pub.dartlang.org/packages/flutter_local_notifications)
![Build Status](https://github.com/MaikuB/flutter_local_notifications/actions/workflows/validate.yml/badge.svg)

A cross platform plugin for displaying local notifications.

## 📱 Supported platforms

* **Android+**. Uses the [NotificationCompat APIs](https://developer.android.com/reference/androidx/core/app/NotificationCompat) so it can be run older Android devices
* **iOS** Uses the [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework)
* **macOS** Uses the [UserNotification APIs](https://developer.apple.com/documentation/usernotifications) (aka the User Notifications Framework)
* **Linux**. Uses the [Desktop Notifications Specification](https://specifications.freedesktop.org/notification-spec/)
* **Windows** Uses the [C++/WinRT](https://learn.microsoft.com/en-us/windows/uwp/cpp-and-winrt-apis/) implementation of [Toast Notifications](https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/toast-notifications-overview)

Note: the plugin requires Flutter SDK 3.22 at a minimum. The list of support platforms for Flutter 3.22 itself can be found [here](https://github.com/flutter/website/blob/4fa26a1e909a2243fa18e4d101192bb5d400fcf2/src/_data/platforms.yml)

### iOS pending notifications limit

There is a limit imposed by iOS where it will only keep the 64 notifications that were last set on any iOS versions newer than 9. On iOS versions 9 and older, the 64 notifications that fire soonest are kept. [See here for more details.](https://ileyf.cn.openradar.appspot.com/38065340)

### Custom notification sounds

[iOS and macOS restrictions](https://developer.apple.com/documentation/usernotifications/unnotificationsound?language=objc) apply (e.g. supported file formats).

### Linux limitations

Capabilities depend on the system notification server implementation, therefore, not all features listed in `LinuxNotificationDetails` may be supported. One of the ways to check some capabilities is to call the `LinuxFlutterLocalNotificationsPlugin.getCapabilities()` method.

The `onDidReceiveNotificationResponse` callback runs on the main isolate of the running application and cannot be launched in the background if the application is not running. To respond to notification after the application is terminated, your application should be registered as DBus activatable (please see [DBusApplicationLaunching](https://wiki.gnome.org/HowDoI/DBusApplicationLaunching) for more information), and register action before activating the application. This is difficult to do in a plugin because plugins instantiate during application activation, so `getNotificationAppLaunchDetails` can't be implemented without changing the main user application.


## 👏 Acknowledgements

* [Javier Lecuona](https://github.com/javiercbk) for submitting the PR that added the ability to have notifications shown daily
* [Jeff Scaturro](https://github.com/JeffScaturro) for submitting the PR to fix the iOS issue around showing daily and weekly notifications and migrating the plugin to AndroidX
* [Ian Cavanaugh](https://github.com/icavanaugh95) for helping create a sample to reproduce the problem reported in [issue #88](https://github.com/MaikuB/flutter_local_notifications/issues/88)
* [Zhang Jing](https://github.com/byrdkm17) for adding 'ticker' support for Android notifications
* [Kenneth](https://github.com/kennethnym), [lightrabbit](https://github.com/lightrabbit), and [Levi Lesches](https://github.com/Levi-Lesches) for adding Windows support
* ...and everyone else for their contributions. They are greatly appreciated

## 🔧 iOS setup

### Handling notifications whilst the app is in the foreground

By design, iOS applications *do not* display notifications while the app is in the foreground unless configured to do so.

For iOS 10+, use the presentation options to control the behaviour for when a notification is triggered while the app is in the foreground. The default settings of the plugin will configure these such that a notification will be displayed when the app is in the foreground.

## ❓ Usage

Before going on to copy-paste the code snippets in this section, double-check you have configured your application correctly.
If you encounter any issues please refer to the API docs and the sample code in the `example` directory before opening a request on Github.

On iOS/macOS, notification actions need to be configured before the app is started using the `initialize` method

``` dart
final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    // ...
    notificationCategories: [
      DarwinNotificationCategory(
        'demoCategory',
        actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
            'id_2',
            'Action 2',
            options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
            },
            ),
            DarwinNotificationAction.plain(
            'id_3',
            'Action 3',
            options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
            },
            ),
        ],
        options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
    )
],
```

On iOS/macOS, the notification category will define which actions are availble. On Android and Linux, you can put the actions directly in the `AndroidNotificationDetails` and `LinuxNotificationDetails` classes.

## Initialisation

The first step is to create a new instance of the plugin class and then initialise it with the settings to use for each platform

```dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
        defaultActionName: 'Open notification');
final WindowsInitializationSettings initializationSettingsWindows =
    WindowsInitializationSettings(
        appName: 'Flutter Local Notifications Example',
        appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
        // Search online for GUID generators to make your own
        guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb')
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
    windows: initializationSettingsWindows);
await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
```

Initialisation can be done in the `main` function of your application or can be done within the first page shown in your app. Developers can refer to the example app that has code for the initialising within the `main` function. The code above has been simplified for explaining the concepts. Here we have specified the default icon to use for notifications on Android (refer to the *Android setup* section) and designated the function (`onDidReceiveNotificationResponse`) that should fire when a notification has been tapped on via the `onDidReceiveNotificationResponse` callback. Specifying this callback is entirely optional but here it will trigger navigation to another page and display the payload associated with the notification. This callback **cannot** be used to handle when a notification launched an app. Use the `getNotificationAppLaunchDetails` method when the app starts if you need to handle when a notification triggering the launch for an app e.g. change the home route of the app for deep-linking.

The `DarwinInitializationSettings` class provides default settings on how the notification be presented when it is triggered and the application is in the foreground on iOS/macOS. There are optional named parameters that can be modified to suit your application's purposes. Here, it is omitted and the default values for these named properties is set such that all presentation options (alert, sound, badge) are enabled.

The `LinuxInitializationSettings` class requires a name for the default action that calls the `onDidReceiveNotificationResponse` callback when the notification is clicked.

On iOS and macOS, initialisation may show a prompt to requires users to give the application permission to display notifications (note: permissions don't need to be requested on Android). Depending on when this happens, this may not be the ideal user experience for your application. If so, please refer to the next section on how to work around this.

### [iOS (all supported versions) and macOS 10.14+] Requesting notification permissions

The constructor for the `DarwinInitializationSettings` class  has three named parameters (`requestSoundPermission`, `requestBadgePermission` and `requestAlertPermission`) that controls which permissions are being requested. If you want to request permissions at a later point in your application on iOS, set all of the above to false when initialising the plugin.

```dart
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
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

### Grouping notifications

#### iOS

For iOS, you can specify `threadIdentifier` in `DarwinNotificationDetails`. Notifications with the same `threadIdentifier` will get grouped together automatically.

```dart
const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(threadIdentifier: 'thread_id');
```

## 📈 Testing

As the plugin class is not static, it is possible to mock and verify its behaviour when writing tests as part of your application.
Check the source code for a sample test suite that has been kindly implemented (_test/flutter_local_notifications_test.dart_) that demonstrates how this can be done.

If you decide to use the plugin class directly as part of your tests, the methods will be mostly no-op and methods that return data will return default values.

Part of this is because the plugin detects if you're running on a supported plugin to determine which platform implementation of the plugin should be used. If the platform isn't supported, it will default to the aforementioned behaviour to reduce friction when writing tests. If this not desired then consider using mocks.

If a platform-specific implementation of the plugin is required for your tests, use the [debugDefaultTargetPlatformOverride](https://api.flutter.dev/flutter/foundation/debugDefaultTargetPlatformOverride.html) property provided by the Flutter framework.
