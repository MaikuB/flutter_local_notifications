# Cross-platform usage

While each platform inherently supports different types of notifications and features, there is quite a lot of functionality that can be accessed on all platforms. This page describes how to work with the common features, and access platform-specific ones.

While some of these methods will have their arguments, return types, and usage spelled out in detail, this document is meant to complement the [API reference](https://pub.dev/documentation/flutter_local_notifications/latest/index.html) on Pub.dev. If you're looking for more details, nuances, or information about a function's signature, refer to the reference.

## The different plugin classes

At its core, this plugin is described by the [`FlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin-class.html) class. This abstract class declares all the methods that are more-or-less shared between the platforms, albeit with small differences that will be noted where applicable.

Sometimes, though, you need to access features that are unique to a specific platform. For example, each platform has its own way of requesting permissions, and it may be important to do so on a per-platform basis.

In such cases, the plugin offers a method, [`resolvePlatformSpecificImplementation<T>()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/resolvePlatformSpecificImplementation.html), where `T` is the type of plugin for a given platform, eg, [`AndroidFlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin-class.html). This method will return an instance of the Android plugin only on Android devices, and null otherwise. When combined with Dart's `?.` null-aware operator, you can safely and concisely program platform-specific functions.

For example, to request [alarm permissions](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestExactAlarmsPermission.html) on Android:

```dart
plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.requestExactAlarmsPermission();
```

For a description of the features associated with each platform, see their respective usage guides. The rest of this document will focus primarily on features that are common to all platforms and accessible on the "main" plugin.

## Initialization

### Determining your timezone

To schedule notifications, this plugin uses [`package:timezone`](https://pub.dev/packages/timezone) to ensure the notification comes at the right time for your users. The [`TZDateTime`](https://pub.dev/documentation/timezone/latest/timezone.standalone/TZDateTime-class.html) class has a few constructors to make this convenient, but many of them require a [`Location`](https://pub.dev/documentation/timezone/latest/timezone.standalone/Location-class.html) be passed.

You'll need to add this before calling any scheduling-related methods.

```dart
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void initTimezones() {
  if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) return;
  tz.initializeTimeZones();
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}
```

### The initialize function

The [`initialize()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/initialize.html) method takes three arguments:

#### Initialization settings

The [`InitializationSettings`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/InitializationSettings-class.html) is a wrapper around initialization settings for each platform. See each platform's respective usage guides for more details.

#### The foreground handler

A notification that is tapped when the app is in the foreground and are supposed, or a notification with an action that specifically launches the app, will trigger the `onDidReceiveNotificationResponse` callback passed to `initialize()`. This callback is guaranteed to be called when your Dart code is running and your app is in the foreground, so it may do anything a normal function will do.

The callback provides a [`NotificationResponse`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/NotificationResponse-class.html), which provides all sorts of information about the notification that was tapped. Continue reading to learn more about what each field corresponds to for a given notification.

#### The background handler

When the application is terminated and a notification is tapped that does not launch the app, the `onDidReceiveBackgroundNotification` callback is triggered. This callback also provides a `NotificationResponse`, like the foreground handler, but the callback provided must be able to run in the background, in another isolate.

Specifically, the function must be a top-level or static function annotated with

```dart
@pragma('vm:entry-point')
```

which is needed to prevent Flutter from thinking the function is unused and stripping it from your release builds.

This function can be run when your app is in the foreground or not, so it must be capable of running without using any plugins that may depend on Flutter initialization. Because the callback is run in another isolate, you cannot rely on any state or initialization performed in the main isolate, even from `main()`. Think of the background handler as an entirely new entrypoint for your app that must initialize minimal resources, perform just one task, then gracefully return.

### Checking if a notification launched the app

When a user taps a notification to launch the app, they usually wish to be taken to a specific part of your app, usually to perform a certain purpose. Use the [`getNotificationAppLaunchDetails()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getNotificationAppLaunchDetails.html) function to get details on how the app was launched.

The function returns an instance of [`NotificationAppLaunchDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/NotificationAppLaunchDetails-class.html), which has two main components:

- `didNotificationLaunchApp`, which is true if and only if the app was launched directly by a notification, and
- `notificationResponse`, containing the details of the notification that was tapped, if any.

For example, say you show a notification meant to lead the user to a specific page of your app. You may set the route of the desired page as the notification's `payload` property (see below). Then, to get the appropriate page:

```dart
Future<String?> getInitialRoute() async {
  // On some devices, this will always return null
  final details = await plugin.getNotificationAppLaunchDetails();
  return details?.notificationResponse?.payload;
}
```

## Showing notifications

### Specifying platform-specific details

Since each platform handles notifications differently, only a few parameters are declared on each method below. The rest are declared in platform-specific notification detail classes, like [`AndroidNotificationDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationDetails-class.html). These classes can get quite large, so refer to each platform's usage guide and the API reference for more details.

The [`NotificationDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/NotificationDetails-class.html) class is a container class that allows details to be specified or omitted for any platform. You should pass this wrapper object to the functions below instead of platform details directly.

### Notification actions

While many details differ between platforms, many platforms support the concept of notification actions. See your platform's usage guide for exact details, but the general idea is allowing a user to select an action within your notification itself, triggering a response from your application. In some platforms and circumstances, this action may be triggered entirely in the background, allowing your user to stay in their current app.

For example, imagine a messaging app that just got a message from another user. Your notification may include a text action, allowing the user to send a response directly within the notification. Again, the exact details here differ by platform.

Actions affect how your app handles responses. The foreground handler, background handler, and `getNotificationAppLaunchDetails()` method all provide you with a `NotificationResponse` object. The response has a few fields that can be affected when a user interacts with a notification's action:

- the `notificationResponseType` field will be `NotificationResponseType.selectedNotificationAction`
- the `actionId` field will be set to the ID of the action the user tapped
- the `input` field may be set to whatever the user inputted to the field. Check your platform's usage guide for details, but this usually refers to a text input, if any
- the `data` field may be set to the data returned by the platform. For example, Windows uses this instead of the `input` field

### Show a notification immediately

The [`show()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/show.html) function shows a notification immediately, and accepts five arguments:

- the `id` of the notification, as an integer. This ID is used to uniquely identify the notification to the device. On some platforms, re-using this ID will result in the notification being silently updated. Check your platform's usage guide for more details.
- an optional `title` of the notification, as a string. If null, platforms will usually show the name of the app instead.
- an optional `body` of the notification, as a string
- an optional `notificationDetails`, as discussed above
- an optional notification `payload`, as a string. This will be available to your app, via `NotificationResponse.payload`

These same parameters will be present on most methods that show notifications. Other platform-specific functionality can be specified in the `notificationDetails` class, as described above.

### Schedule a notification

**Not supported on Linux**

The [`zonedSchedule()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/zonedSchedule.html) method accepts the same five arguments as `show()`, but also accepts:

- the `scheduledDate` to show the notification
- the `uiLocalNotificationDateInterpretation`, which describes how devices prior to iOS 10 should interpret the `scheduledDate`
- the `androidScheduleMode`, which determines how precisely the device should schedule the notification
- an optional `matchDateTimeComponents`, which tells the OS whether and how to periodically schedule this notification

Note that the `scheduledDate` is not a regular `DateTime`, but rather a [`TZDateTime`](https://pub.dev/documentation/timezone/latest/timezone.standalone/TZDateTime-class.html) from `package:timezone` to ensure location data is incorporated into the notification delivery time. See above for how to set that up and get the user's current location.

By default, notifications shown with this function will not repeat unless `matchDateTimeComponents` is provided, in which case the [`DateTimeComponents`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/DateTimeComponents.html) will specify how to repeat. For example, passing `DateTimeComponents.dayOfWeekAndTime` will make the notification repeat once a week, during the given date time.

Where possible, try to use `periodicallyShowWithDuration()`. The previous example can be rewritten as

```dart
previouslyShowWithDuration(
  // ...,
  repeatIntervalDuration: const Duration(days: 7),
)
```

### Periodically show a notification

**Not supported on Windows or Linux**

To periodically show a notification, use [`periodicallyShowWithDuration()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShow.html). It takes the same arguments as `show()`, but also accepts a `repeatIntervalDuration` specifying how far apart these notifications should be.

## Existing notifications

### Cancelling notifications

To cancel a notification, call [`cancel()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancel.html) with the ID used to create the notification. To cancel all notifications, use [`cancelAll()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancelAll.html) instead.

> [!Note]
> Windows will only allow you to use `cancel()` if you have **package identity**. Without it, this function will always do nothing, but `cancelAll()` will still work. See the Windows setup guide for more details.

### Checking notifications

#### Check current notifications

To see notifications that are still being shown but have not been dismissed or cancelled, use [`getActiveNotifications()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getActiveNotifications.html). This returns a list of [`ActiveNotification`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/ActiveNotification-class.html) that contains information about the notification, such as its ID, title, body, payload, and more.

> [!Note]
> Windows will only allow you to check notifications by ID if you have **package identity**. Without it, this function will always return an empty list. See the Windows setup guide for more details.

#### Check future notifications

To check for notifications that were scheduled for the future and have yet to be shown, use [`pendingNotificationRequests()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/pendingNotificationRequests.html). This function returns a list of [`PendingNotificationRequest`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/PendingNotificationRequest/PendingNotificationRequest.html`) objects, which provide information about the notification's ID, title, body, and payload.
