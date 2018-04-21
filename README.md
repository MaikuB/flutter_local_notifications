# flutter_local_notifications

[![pub package](https://img.shields.io/pub/v/flutter_local_notifications.svg)](https://pub.dartlang.org/packages/flutter_local_notifications)

A cross platform plugin for displaying local notifications. 

## Supported Platforms
* Android API 16+ (4.1+, the minimum version supported by Flutter). Uses the NotificationCompat APIs so it can be run older Android devices.
* iOS 8.0+ (the minimum version supported by Flutter). Supports the old and new iOS notification APIs (the User Notifications Framework introduced in iOS 10 but will use the UILocalNotification APIs for devices predating iOS 10)

## Features

* Mockable (plugin and API methods aren't static)
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
* [Android] Group notifications
* [iOS] Customise the permissions to be requested around displaying notifications

Note that this plugin aims to provide abstractions for all platforms as opposed to having methods that only work on specific platforms. However, each method allows passing in "platform-specifics" that contains data that is specific for customising notifications on each platform. It is still under development so expect the API surface to change over time.

Contributions are welcome by submitting a PR for me to review. If it's to add new features, appreciate it if you could try to maintain the architecture or try to improve on it :)

## Getting Started

The first step is to create a new instance of the plugin class and then initialise it with the settings to use for each platform

```
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
InitializationSettingsAndroid initializationSettingsAndroid =
        new InitializationSettingsAndroid('app_icon');
InitializationSettingsIOS initializationSettingsIOS =
    new InitializationSettingsIOS();
InitializationSettings initializationSettings = new InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS);
flutterLocalNotificationsPlugin.initialize(initializationSettings,
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

Once the initialisation has been done, then you can manage the displaying of notifications

### Displaying a notification

```
NotificationDetailsAndroid androidPlatformChannelSpecifics =
        new NotificationDetailsAndroid(
            'your channel id', 'your channel name', 'your channel description');
NotificationDetailsIOS iOSPlatformChannelSpecifics =
    new NotificationDetailsIOS();
NotificationDetails platformChannelSpecifics = new NotificationDetails(
    androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
await flutterLocalNotificationsPlugin.show(
    0, 'plain title', 'plain body', platformChannelSpecifics,
    payload: 'item id 2');
```

In this block of code, the details for each platform have been specified. This includes the channel details that is required for Android 8.0+. The payload has been specified ('item id 2'), that will passed back through your application when the user has tapped on a notification. Note that for Android devices that notifications will only in appear in the tray and won't appear as a toast aka heads-up notification unless things like the priority/importance has been set appropriately. Refer to the Android docs (https://developer.android.com/guide/topics/ui/notifiers/notifications.html#Heads-up) for additional information.

### Scheduling a notification

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
await flutterLocalNotificationsPlugin.schedule(
    0,
    'scheduled title',
    'scheduled body',
    scheduledNotificationDateTime,
    platformChannelSpecifics);
```

### [Android only] Grouping notifications

This is a "translation" of the sample available at https://developer.android.com/training/notify-user/group.html

```
String groupKey = 'com.android.example.WORK_EMAIL';
String groupChannelId = 'grouped channel id';
String groupChannelName = 'grouped channel name';
String groupChannelDescription = 'grouped channel description';
// example based on https://developer.android.com/training/notify-user/group.html
NotificationDetailsAndroid firstNotificationAndroidSpecifics =
    new NotificationDetailsAndroid(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
NotificationDetails firstNotificationPlatformSpecifics =
    new NotificationDetails(firstNotificationAndroidSpecifics, null);
await flutterLocalNotificationsPlugin.show(0, 'Alex Faarborg',
    'You will not believe...', firstNotificationPlatformSpecifics);
NotificationDetailsAndroid secondNotificationAndroidSpecifics =
    new NotificationDetailsAndroid(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
NotificationDetails secondNotificationPlatformSpecifics =
    new NotificationDetails(secondNotificationAndroidSpecifics, null);
await flutterLocalNotificationsPlugin.show(
    0,
    'Jeff Chang',
    'Please join us to celebrate the...',
    secondNotificationPlatformSpecifics);

// create the summary notification
List<String> lines = new List<String>();
lines.add('Alex Faarborg  Check this out');
lines.add('Jeff Chang    Launch Party');
InboxStyleInformation inboxStyleInformation = new InboxStyleInformation(
    lines,
    contentTitle: '2 new messages',
    summaryText: 'janedoe@example.com');
NotificationDetailsAndroid androidPlatformChannelSpecifics =
    new NotificationDetailsAndroid(
        groupChannelId, groupChannelName, groupChannelDescription,
        style: NotificationStyleAndroid.Inbox,
        styleInformation: inboxStyleInformation,
        groupKey: groupKey,
        setAsGroupSummary: true);
NotificationDetails platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, null);
await flutterLocalNotificationsPlugin.show(
    0, 'Attention', 'Two new messages', platformChannelSpecifics);
```

### Cancelling/deleting a notification

```
// cancel the notification with id value of zero
await flutterLocalNotificationsPlugin.cancel(0);
```

This should cover the basic functionality. Please check out the `example` directory for a sample app that illustrates the rest of the functionality available and refer to the API docs for more information. Also read the below on what you need to configure on each platform

## Android Integration

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

## iOS Integration

By design, iOS applications do not display notifications when they're in the foreground. For iOS 10+, use the presentation options to control the behaviour for when a notification is triggered while the app is in the foreground. For older versions of iOS, you will need update the AppDelegate class to handle when a local notification is received to display an alert. This is shown in the sample app within the `didReceiveLocalNotification` method of the `AppDelegate` class. The notification title can be found by looking up the `title` within the `userInfo` dictionary of the `UILocalNotification` object

```
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(@available(iOS 10.0, *)) {
        return;
    }
    
    NSString *payload = notification.userInfo[@"payload"];
    if(FlutterLocalNotificationsPlugin.resumingFromBackground) {
        // resuming from the background so don't want to show an alert as we would've seen
        // the notification while the app was in the background
        [FlutterLocalNotificationsPlugin handleSelectNotification:payload];
        return;
    }
    
    // display the alert as the app was in the foreground so notification wouldn't be displayed.
    // when the user taps on OK, fire the code in our Flutter app that is responsible for handling
    // the action for when the user taps on a notification
    NSString *title = notification.userInfo[@"title"];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:notification.alertBody
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [FlutterLocalNotificationsPlugin handleSelectNotification:payload];
                                                          }];
    
    [alert addAction:defaultAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
}
```

In theory, it should be possible for the plugin to handle this but this the method doesn't seem to fire. Will lodge an issue on the Flutter repository to see if this could be looked into. If this is confirmed to be an issue then I will move this code to be part of the plugin once the fix is out.

## Testing

As the plugin class is not static, it is possible to mock and verify it's behaviour when writing tests as part of your application. Check the source code for a sample test suite can be found at _test/flutter_local_notifications_test.dart_ that demonstrates how this can be done.
