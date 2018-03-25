# flutter_local_notifications

A cross platform plugin for displaying local notifications.
Note that this plugin aims to provide abstractions for all platforms as opposed to having methods that only work on specific platforms. However, each method allows passing in "platform-specifics" that contains data that is specific for customising notifications on each platform.

## Getting Started

Check out the `example` directory for a sample app.

### Android Integration

If your application needs the ability to schedule notifications then you need to add the following the manifest

```xml
        <receiver android:name="com.dexterous.localnotifications.ScheduledNotificationReceiver" />
```

### iOS Integration

By design, iOS applications do not display notifications when they're in the foreground. Therefore, you need to update the AppDelegate class to handle when a local notification is received to display an alert. This is shown in the sample app where the `didReceiveLocalNotification` method. The notification title can be found by looking up the `title` within the `userInfo` dictionary of the `UILocalNotification` object.
