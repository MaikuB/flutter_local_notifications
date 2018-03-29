# flutter_local_notifications

[![pub package](https://img.shields.io/pub/v/flutter_local_notifications.svg)](https://pub.dartlang.org/packages/flutter_local_notifications)

A cross platform plugin for displaying local notifications.
Note that this plugin aims to provide abstractions for all platforms as opposed to having methods that only work on specific platforms. However, each method allows passing in "platform-specifics" that contains data that is specific for customising notifications on each platform.

Uses the NotificationCompat APIs on Android for backwards compatibility support for devices with older versions of Android. For iOS, there is support for the User Notifications Framework introduced in iOS 10 but will use UILocalNotification for older versions of iOS.

## Getting Started

Check out the `example` directory for a sample app.

### Android Integration

If your application needs the ability to schedule notifications then you need to add the following the manifest

```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
```

Notification icons should be added as a drawable resource. The sample code shows how to set default icon for all notifications and how to specify one for each notification.

### iOS Integration

By design, iOS applications do not display notifications when they're in the foreground. For iOS 10+, use the presentation options to control the behaviour for when a notification is triggered while the app is in the foreground. For older versions of iOS, you will need update the AppDelegate class to handle when a local notification is received to display an alert. This is shown in the sample app within the `didReceiveLocalNotification` method of the `AppDelegate` class. The notification title can be found by looking up the `title` within the `userInfo` dictionary of the `UILocalNotification` object.
