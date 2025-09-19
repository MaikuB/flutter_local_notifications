# General usage

While each platform inherently supports different types of notifications and features, there is quite a lot of functionality that can be accessed on all platforms. This page describes how to work with the common features, and access platform-specific ones.

While some of these methods will have their arguments, return types, and usage spelled out in detail, this document is meant to complement the [API reference](https://pub.dev/documentation/flutter_local_notifications/latest/index.html) on Pub. If you're looking for more details, nuances, or information about a function's signature, refer to the reference. Remember you can also check the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) for a pretty thorough reference of what this plugin can do.

## Concepts

### The different plugin classes

At its core, this plugin is described by the [`FlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin-class.html) class. This abstract class declares all the methods that are more-or-less shared between the platforms, albeit with small differences that will be noted where applicable.

Sometimes, though, you need to access features that are unique to a specific platform. For example, each platform has its own way of requesting permissions, and it may be important to do so on a per-platform basis.

In such cases, the plugin offers a method, [`resolvePlatformSpecificImplementation<T>()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/resolvePlatformSpecificImplementation.html), where `T` is the type of plugin for a given platform, eg, [`AndroidFlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin-class.html). This method will return an instance of the Android plugin only on Android devices, and null otherwise. When combined with Dart's `?.` null-aware operator, you can safely and concisely program platform-specific functions.

For example, to request [alarm permissions](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestExactAlarmsPermission.html) on Android:

```dart
final androidPlugin = plugin
  .resolvePlatformSpecificImplementation
  <AndroidFlutterLocalNotificationsPlugin>();

// On non-Android platforms, this will be null.
await androidPlugin?.requestExactAlarmsPermission();
```

For a description of the features associated with each platform, see their respective usage guides. The rest of this document will focus primarily on features that are common to all platforms and accessible on the "main" plugin.

### The different details classes

The different platforms share a lot of functionality, but also differ wildly in how they implement it. To that end, this plugin offers a [`NotificationDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/NotificationDetails-class.html) class that allows you to pass platform-specific notification details for every method. For example:

```dart
final details = NotificationDetails(
	android: AndroidNotificationDetails(silent: true),
  iOS: DarwinNotificationDetails(presentSound: false),
  macOS: DarwinNotificationDetails(presentSound: false),
  linux: LinuxNotificationDetails(suppressSound: true),
  windows: WindowsNotificationDetails(audio: WindowsNotificationAudio.silent()),
);

await plugin.show(0, "This is a quiet notification", "Very quiet indeed", details);
```

In this example, all the platforms are doing the same thing in different ways. Of course, being silent is something all the platforms can do, but there are specific features that are available on some platforms and not others. This paradigm allows you to pick and choose what features you want. Note that "Darwin" refers to iOS and MacOS together, but the `NotificationDetails` class has separate parameters so you can still choose different behaviors for them.

The platform-specific features will be described in more detail in their respective usage guides.

## Initialization

### Determining your timezone

To schedule notifications, this plugin uses [`package:timezone`](https://pub.dev/packages/timezone) to ensure the notification comes at the right time for your users. The [`TZDateTime`](https://pub.dev/documentation/timezone/latest/timezone.standalone/TZDateTime-class.html) class has a few constructors to make this convenient, but many of them require a [`Location`](https://pub.dev/documentation/timezone/latest/timezone.standalone/Location-class.html) be passed.

You'll need to add this before calling any scheduling-related methods.

```dart
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void initTimezones() {
  if (kIsWeb || Platform.isLinux) return;
  tz.initializeTimeZones();
  if (Platform.isWindows) return;
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}
```

### The initialize function

The [`initialize()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/initialize.html) method is used to set up the plugin:

```dart
// 1. The initialization settings
final initSettings = InitializationSettings(
	android: AndroidInitializationSettings("app_icon"),
  iOS: DarwinInitializationSettings(requestSoundPermission: true),
  macOS: DarwinInitializationSettings(requestSoundPermission: true),
  linux: LinuxInitializationSettings(defaultActionName: "Open"),
  windows: WindowsInitializationSettings(
    appName: "My Application",
    appUserModelId: "com.developerName.applicationName",
    // Search online for GUID generators to make your own
    guid: "d49b0314-ee7a-4626-bf79-97cdb8a991bb",
  ),
);

// 2. The foreground handler
void onNotificationTap(NotificationResponse response) {
  // The app/UI app is in the foreground, and all state can be used
  print("Got a notification with payload: ${response.payload}");
}

// 3. The background handler
@pragma("vm:entry_point")
void onNotificationTapBackground(NotificationResponse response) {
  // The app/UI is suspended or terminated, and all state is gone
  print("Got a notification with payload: ${response.payload}");
}

final plugin = FlutterLocalNotificationsPlugin();
await plugin = await plugin.initialize(
	initSettings,
  onDidReceiveNotificationResponse: onNotificationTap,
  onDidReceiveBackgroundNotificationResponse: onNotificationTapBackground,
);
```

#### 1. Initialization settings

The [`InitializationSettings`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/InitializationSettings-class.html) is a wrapper around initialization settings for each platform, just like `NotificationDetails`. See each platform's respective usage guides for more details. You'll need to provide the initialization settings for all platforms your app is expected to run on, or the plugin will throw an error at runtime.

#### 2. The foreground handler

A notification that is tapped when the app is in the foreground and are supposed, or a notification with an action that specifically launches the app, will trigger the `onDidReceiveNotificationResponse` callback passed to `initialize()`. This callback is guaranteed to be called when your Dart code is running and your app is in the foreground, so it may do anything a normal function will do. A classic case is navigating to some page, like a message or chat thread.

The callback provides a [`NotificationResponse`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/NotificationResponse-class.html), which provides all sorts of information about the notification that was tapped. This class has a few fields to determine what notification was pressed:

- the `id` of the notification
- the `payload` attached to the original notification, if any
- the `actionId` representing what action, if any, was pressed
- the `input`, representing what the user entered into the text box, if any
  - Windows will use the `data` field instead, since there may be multiple text fields

These fields are all set when showing the notification. See below for more details.

#### 3. The background handler

When the application is suspended or terminated and a notification is tapped that does not launch the app, the `onDidReceiveBackgroundNotification` callback is triggered. This callback also provides a `NotificationResponse`, like the foreground handler, but the callback provided must be able to run in the background, in another isolate.

Specifically, the function must be a top-level or static function annotated with

```dart
@pragma('vm:entry-point')
```

which is needed to prevent Flutter from thinking the function is unused and stripping it from your release builds.

This function can be run when your app is in the foreground or not, so it must be capable of running without using any plugins that may depend on Flutter initialization. Because the callback is run in another isolate, you cannot rely on any state or initialization performed in the main isolate, even from `main()`. Think of the background handler as an entirely new entrypoint for your app that must initialize minimal resources, perform just one task, then gracefully return.

Be careful how much work you do in this state. Most devices will kill your background handler if it takes too long to complete or uses too many resources. As a rule of thumb, if you need to do a lot of work, prefer to save some data representing that work in a file or database, so you can do that work later when the user opens the app again, or send it to your server for more processing.

### Checking if a notification launched the app

When your app is terminated and a user taps a notification, they usually want to be taken to a specific part of your app. This is useful, for example, when viewing a new message, news article, or friend request. Use the [`getNotificationAppLaunchDetails()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getNotificationAppLaunchDetails.html) function to get details on how the app was launched.

The function returns an instance of [`NotificationAppLaunchDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/NotificationAppLaunchDetails-class.html), which has two main components:

- `didNotificationLaunchApp`, which is true if and only if the app was launched directly by a notification
- `notificationResponse`, containing the details of the notification that was tapped, if any (see above)

For example, say you show a notification meant to lead the user to a specific page of your app. You may set the route of the desired page as the notification's `payload` property (see below). Then, to get the appropriate page:

```dart
Future<String?> getInitialRoute() async {
  final details = await plugin.getNotificationAppLaunchDetails();
  return details?.notificationResponse?.payload;
}
```

## Showing notifications

### Requesting permission

Android, iOS, MacOS, and the Web platforms will require the user to grant you permission before your app is allowed to show notifications. It's important to not just request notifications immediately, but to wait until the user presses a button to confirm they are ready to do so, and you should try to provide as much functionality as possible without requiring notification permissions. If you simply ask for permission on app startup, not only may your app [get rejected from the stores](https://developer.apple.com/app-store/review/guidelines/#4.5.4) or [upset your users](https://www.reddit.com/r/AskReddit/comments/1l8cxfz/what_are_the_most_annoying_notifications_your/), but if they deny your request, the device may not show your prompt again. Web browsers will also automatically block your request unless it's associated with a user action, like a button press.

For more information, see the platform-specific usage guides. [This page](https://web.dev/articles/permissions-best-practices) also serves some good advice on permissions best practices.

### Show a notification

The [`show()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/show.html) function shows a notification immediately, and accepts five arguments:

- the `id` of the notification, as an integer. This ID is used to uniquely identify the notification to the device. If you send a new notification with the same ID, it will be updated in-place, which is useful in cases like chat threads and loading notifications.
- an optional `title` of the notification, as a string. If null, platforms will usually show the name of the app instead.
- an optional `body` of the notification, as a string
- an optional `NotificationDetails`, as discussed above
- an optional notification `payload`, as a string. This will be available to your app, via `NotificationResponse.payload`, if the notification is pressed. Use this to provide enough context for your app to meaningfully respond, like taking your user to a specific page or sending a message.

These same parameters will be present on most methods that show notifications. Other platform-specific functionality can be specified in the `NotificationDetails`. For an example, see [above](#the-different-details-classes)

### Schedule a notification

> [!NOTE]
>
> Not supported on Linux or the Web

The [`zonedSchedule()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/zonedSchedule.html) method accepts the same five arguments as `show()`, but also accepts:

- the `scheduledDate` to show the notification
- the `uiLocalNotificationDateInterpretation`, which describes how devices prior to iOS 10 should interpret the `scheduledDate`
- the `androidScheduleMode`, which determines how precisely the device should schedule the notification
  - More precision requires special permissions -- see the Android setup and usage guides

- an optional `matchDateTimeComponents`, which tells the OS whether and how to periodically schedule this notification

Note that the `scheduledDate` is not a regular `DateTime`, but rather a [`TZDateTime`](https://pub.dev/documentation/timezone/latest/timezone.standalone/TZDateTime-class.html) from `package:timezone` to ensure location data is incorporated into the notification delivery time. See above for how to set that up and get the user's current location. For example:

```dart
await plugin.zonedSchedule(
	0, "Your event is now!", "This is a body",
  tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
  NotificationDetails(...),
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  payload: "goto-event_EVENT_ID",
);
```

By default, notifications shown with this function will not repeat unless `matchDateTimeComponents` is provided, in which case the [`DateTimeComponents`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/DateTimeComponents.html) will specify how to repeat. For example, passing `DateTimeComponents.dayOfWeekAndTime` will make the notification repeat once a week, during the given date time. Where possible, though, try to use [`periodicallyShowWithDuration()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShowWithDuration.html) (see below).

### Periodically show a notification

> [!Note]
>
> Not supported on Linux, Windows, or the Web

To periodically show a notification, use [`periodicallyShowWithDuration()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShow.html). It takes the same arguments as `show()`, but also accepts a `repeatIntervalDuration` specifying how far apart these notifications should be and an `androidScheduleMode` as explained above. For example:

```dart
await plugin.periodicallyShowWithDuration(
	0, "Have you moved today?", "Exercise is important!",
  Duration(hours: 1),
  NotificationDetails(...),
  androidScheduleMode: AndroidScheduleMode.inexact,
  payload: "yes-they-moved",
)
```

### Notification actions

While many details differ between platforms, all platforms support the concept of notification actions. See your platform's usage guide for exact details, but the general idea is allowing a user to select an action within your notification itself, triggering a response from your application without requiring the user to open your app and select it themselves. In some platforms and circumstances, this action may be triggered entirely in the background, allowing your user to stay in their current app.

For example, imagine a messaging app that just got a message from another user. Your notification may include a text action, allowing the user to send a response directly within the notification. Again, the exact details here differ by platform.

Actions affect how your app handles responses. The foreground handler, background handler, and `getNotificationAppLaunchDetails()` method all provide you with a `NotificationResponse` object, which will contain a non-null `actionId` if an action was used, with a non-null `input` (or `data`) if a text field was used. For example, a notification can have a payload `new-message_CHAT_ID` and an `actionId` of `mark-read`.

### Custom icons or sounds

All platforms support showing unique icons or sounds as part of your notification. These can sometimes be files downloaded at runtime, or a file somewhere on the user's device, but otherwise may need to be bundled with your app directly in a platform-specific way. Refer to the platform-specific setup guides for more details.

### Importance

All platforms support some idea of an importance/priority/urgency. Use this wisely, and try to be as granular as possible so as not to annoy your users. Some platforms may require special permissions for higher priorities that can bypass Do Not Disturb modes, so check the platform usage guides for more details.

## Managing notifications

### Cancelling notifications

To cancel a notification, call [`cancel()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancel.html) with the ID used to create the notification. To cancel all notifications, use [`cancelAll()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancelAll.html) instead, or [`cancelAllPendingNotifications()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancelAllPendingNotifications.html) (not supported on Linux and Web).

> [!Note]
> Windows will only allow you to use `cancel()` if you have **package identity**. Without it, this function will always do nothing, but `cancelAll()` will still work. See the Windows setup guide for more details.

### Checking current notifications

To see notifications that are still being shown but have not been dismissed or cancelled, use [`getActiveNotifications()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getActiveNotifications.html). This returns a list of [`ActiveNotification`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/ActiveNotification-class.html) that contains information about the notification, such as its ID, title, body, payload, and more.

> [!Note]
> Windows will only allow you to check notifications by ID if you have **package identity**. Without it, this function will always return an empty list. See the Windows setup guide for more details.

### Check scheduled notifications

To check for notifications that were scheduled for the future and have yet to be shown, use [`pendingNotificationRequests()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/pendingNotificationRequests.html). This function returns a list of [`PendingNotificationRequest`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/PendingNotificationRequest/PendingNotificationRequest.html`) objects, which provide information about the notification's ID, title, body, and payload. This is not supported on Linux and the Web, and will instead return an empty list.

## Testing

This class is based on the [`FlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin-class.html). If you need to write unit tests involving this plugin, just mock out that class (and any of the platform-specific plugin classes you may have used) for your tests. If a platform-specific implementation of the plugin is required for your tests, use the [debugDefaultTargetPlatformOverride](https://api.flutter.dev/flutter/foundation/debugDefaultTargetPlatformOverride.html) property provided by the Flutter framework.
