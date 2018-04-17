# flutter_local_notifications

[![pub package](https://img.shields.io/pub/v/flutter_local_notifications.svg)](https://pub.dartlang.org/packages/flutter_local_notifications)

A cross platform plugin for displaying local notifications. 

Features supported (example app has code to cover each functionality)

* Support for Android and iOS. Uses the NotificationCompat APIs so it can be run older Android devices. Supports the old and new iOS notification APIs (the User Notifications Framework introduced in iOS 10 but will use the UILocalNotification APIs for devices predating iOS 10)
* Display basic notifications
* Scheduling when notifications should appear
* Cancelling/removing notifications
* Customising the notification sound
* Ability to handle when a user has tapped on a notification, when the app is the foreground, background or terminated
* [Android] Configuring the importance level
* [Android] Configuring the priority
* [Android] Customising the vibration pattern for notifications
* [Android] Configure the default icon for all notifications
* [Android] Configure the icon for each notification (overrides the default when specified)
* [Android] Formatting notification content via HTML markup (see https://developer.android.com/guide/topics/resources/string-resource.html#StylingWithHTML)
* [Android] Support for basic notification styling and the big text style for (will look into adding more styles)
* [iOS] Customise the permissions to be requested around displaying notifications

Note that this plugin aims to provide abstractions for all platforms as opposed to having methods that only work on specific platforms. However, each method allows passing in "platform-specifics" that contains data that is specific for customising notifications on each platform. It is still under development so expect the API surface to change over time.

Contributions are welcome by submitting a PR for me to review. If it's to add new features, appreciate it if you could try to maintain the architecture or try to improve on it :)

## Getting Started

The first step is to initialise the plugin with the settings to use for each platform

```
InitializationSettingsAndroid initializationSettingsAndroid =
        new InitializationSettingsAndroid('app_icon');
    InitializationSettingsIOS initializationSettingsIOS =
        new InitializationSettingsIOS();
    InitializationSettings initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    FlutterLocalNotifications.initialize(initializationSettings,
        selectNotification: onSelectNotification);
```

Here we specify we have specified the default icon to use for notifications on Android and designated the function (onSelectNotification) that should fire when a notification has been tapped on. Specifying this callback is entirely optional. In the example, it is defined as follows to navigate to another page and display the payload associated with the notification. In the real world, this payload could represent the id of the item you want to display the details of.

```
Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    );
}
```

Once the initialisation has been done. We can display a notification with the following code

```
NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid(
            'your channel id', 'your channel name', 'your channel description');
    NotificationDetailsIOS iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item id 2');
```

In this block of code, the details for each platform have been specified. This includes the channel details that is required for Android 8.0+. The payload has been specified ('item id 2'), that will passed back through your application when the user has tapped on a notification.

Scheduling a notification can be achieved by following the example

```
var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: 5));
    NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid('your other channel id',
            'your other channel name', 'your other channel description');
    NotificationDetailsIOS iOSPlatformChannelSpecifics =
        new NotificationDetailsIOS();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
```

Cancelling/deleting a notification is also possible

```
// cancel the notification with id value of zero
await FlutterLocalNotifications.cancel(0);
```

This should cover the basic functionality. Please check out the `example` directory for a sample app that illustrates the rest of the functionality available and refer to the API docs for more information. Also read the below on what you need to configure on each platform

### Android Integration

If your application needs the ability to schedule notifications then you need to request permissions to be notified when the phone has been booted as scheduled notifications uses AlarmManager to determine when notifications should be displayed. However, they are cleared when a phone has been turned off. Requesting permission requires adding the following to the manifest

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Developers will also need to add the following so that plugin can handle displaying scheduled notifications and reschedule notifications upon a reboot

```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"></action>
    </intent-filter>
</receiver>
```
If the vibration pattern of an Android notification will be customised then add the following

```xml
<uses-permission android:name="android.permission.VIBRATE" />
```

Notification icons should be added as a drawable resource. The sample code shows how to set default icon for all notifications and how to specify one for each notification.

Custom notification sounds should be added as a raw resource and the sample illustrates how to play a notification with a custom sound.

Note that with Android 8.0+, sounds and vibrations are associated with notification channels and can only be configured when they are first created. Showing/scheduling a notification will create a channel with the specified id if it doesn't exist already. If another notification specifies the same channel id but tries to specify another sound or vibration pattern then nothing occurs.

### iOS Integration

By design, iOS applications do not display notifications when they're in the foreground. For iOS 10+, use the presentation options to control the behaviour for when a notification is triggered while the app is in the foreground. For older versions of iOS, you will need update the AppDelegate class to handle when a local notification is received to display an alert. This is shown in the sample app within the `didReceiveLocalNotification` method of the `AppDelegate` class. The notification title can be found by looking up the `title` within the `userInfo` dictionary of the `UILocalNotification` object.
