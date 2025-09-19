# Android Usage Guide

> [!IMPORTANT]
>
> Make sure to read the [Android Setup Guide](./android-setup.md) and [General Usage Guide](./usage.md) first.

This guide will explore all the features this plugin has available for apps running on Android. Some features can only be called on the Android plugin, not the general plugin. The rest of this guide will assume the following:

```dart
final plugin = FlutterLocalNotificationsPlugin();
final androidPlugin = plugin
  .resolvePlatformSpecificImplementation
  <AndroidFlutterLocalNotificationsPlugin>();
```

While some of these methods will have their arguments, return types, and usage spelled out in detail, this document is meant to complement the [API reference](https://pub.dev/documentation/flutter_local_notifications/latest/index.html) on Pub. If you're looking for more details, nuances, or information about a function's signature, refer to the reference. Remember you can also check the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) for a pretty thorough reference of what this plugin can do.

> [!NOTE]
>
> Even though the plugin supports Android API Level 21 and above, this guide will assume you are working with at least API Level 26. See [this table](https://apilevels.com/) for more details.

## Initialization

Android only has one option to configure – the default app icon. The icon should be added as a [drawable resource](https://developer.android.com/guide/topics/resources/drawable-resource), saved in `android/app/src/main/res/drawable`, preferable as a PNG or WEBP file. Specify the name of the icon without the file extension. For example, for a resource saved as `res/drawable/app_icon.png`, your `initialize()` call should look like this: 

```dart
final settings = InitializationSettings(
  android: AndroidInitializationSettings("app_icon"),
);
await plugin.initialize(settings);
```

## Notification channels

Android groups notifications of a similar purpose into [notification channels](https://developer.android.com/develop/ui/views/notifications#ManageChannels). Separate from notification grouping, this is meant to allow users to customize how their notifications are shown, like "new message" or "upcoming deals". Using channels consistently will give users confidence and more options when changing settings, and will allow them to silence some notifications without missing on others. 

> [!IMPORTANT]
>
> Starting with Android 8.0 (API Level 26), notifications that don't have an associated notification channel will not show. You must create a notification channel and provide an appropriate `channelId` every time you show or schedule a notification, which means you must provide an `AndroidNotificationDetails`.

### Creating a notification channel

To create a notification channel, use [`createNotificationChannel`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/createNotificationChannel.html):

```dart
final chatChannel = AndroidNotificationChannel(
	"chat-messages", "Chat Messages",
  description: "New messages in private chats",
  importance: Importance.high,
  // ...
);
await androidPlugin?.createNotificationChannel(channel);
```

> [!Note]
> Notification sounds, vibration patterns, and importance levels are configured on the notification channel as a whole, not on each notification. These settings are finalized when the first notification of that channel is shown and cannot be changed. Instead, direct users to their system settings to make changes.

### Notification channel options

Notification channels support the following options. These options may only be set when the channel is being created, and may not be changed later. If you need to, you can delete the channel and recreate it, or guide the user to change it themselves. You can call `getNotificationChannels()` to get a list of channels, but note that users may change these options at any time in the settings, so the options may not be the same as when you created them.  

- `description`: will be shown to the user in the settings app, but not in the notifications themselves
- `groupId`: which notification channel group this channel belongs to (see below)
- `importance`: how important notifications in this channel should be
- `bypassDnd`: whether notifications in this group should bypass Do Not Disturb mode (see below)
- `playSound` , `sound`, and `audioAttributesUsage`: what sound notifications in this group will play. To use custom sounds, see [this section](./android-setup.md#custom-icons-and-sounds)
- `enableVibration` and `vibrationPattern`: how and whether the device should vibrate
- `enableLights` and `ledColor`: whether the device's LED should glow and with what color
- `showBadge`: whether the app should show a badge with these notifications

### Notification channel groups

If you have a lot of channels, you can also choose to use notification channel groups to group similar channels. First, create the group with [`createNotificationChannelGroup()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/createNotificationChannelGroup.html), then include the `groupId` in all your channels:

```dart
final chatsGroup = AndroidNotificationChannelGroup(
	"all-chats", "All Chats", description: "All your chat messages",
);
final privateChats = AndroidNotificationChannel(
	"private-chats", "Private Chats", groupId: "all-chats",
);
final publicChats = AndroidNotificationChannel(
  "group-chats", "Group Chats", groupId: "all-chats",
);
await androidPlugin?.createNotificationChannelGroup(chatsGroup);
await androidPlugin?.createNotificationChannel(privateChats);
await androidPlugin?.createNotificationChannelGroup(publicChats);
```

> [!NOTE]
>
> Once you've added a channel to a group, you cannot change it. If necessary, first delete the channels and groups using `deleteNotificationChannel()` and `deleteNotificationChannelGroup()`, then re-create them the way you want them. 

## Permissions

This next section will deal with requesting permissions. As noted in the general usage guide, requesting permissions is a very sensitive process in terms of user experience, and must be done only when necessary and only after informing the user of why you need the permissions. If the user rejects your request – which they might if they feel annoyed or don't understand why you need it – Android will stop showing your requests to the user and start blocking them automatically. If this happens, you will need to prompt the user to go to the settings themselves and grant your app permissions manually. 

### Requesting notification permissions

You will need permissions to show notifications at all. Be sure to call `androidPlugin?.requestNotificationsPermission` sometime after calling `initialize()`, but before calling any method that shows or schedules a notification. You can use `androidPlugin?.areNotificationsEnabled()` to check your permissions at runtime.

### Bypassing Do Not Disturb

To have a notification bypass Do Not Disturb: 

- Follow [this section](./android-setup.md#bypassing-do-not-disturb) of the Android Setup Guide
- After calling `plugin.initialize()`, call [`androidPlugin?.requestNotificationPolicyAccess()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestNotificationPolicyAccess.html)
- Create a notification channel with `bypassDnd: true`
- Show a notification with a `channelId` that corresponds to that channel
- You can use `androidPlugin?.hasNotificationPolicyAccess()` to check your permission at runtime

> [!Important]
>
> Bypassing Do Not Disturb does not mean the device's volume will be increased or vibration will be enabled, just that the notification will appear on-screen. In an emergency, the user may have sound and vibration disabled and won't notice your notification. Use a different package to enable sound and vibration if you need it. 

### Showing full screen notifications

Some notifications need the user's full and complete attention, like a finished timer, an ongoing alarm, or incoming call. These notifications can take over the screen entirely and show a custom UI. Since they can be very invasive, they also require special permissions. 

- Follow [this section](./android-setup.md#full-screen-notifications) of the Android Setup Guide
- After calling `plugin.initialize()`, call [`androidPlugin?.requestFullScreenIntentPermission()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestFullScreenIntentPermission.html)
- Create a notification channel with `importance: Importance.high` or higher

- Create a notification with `AndroidNotificationDetails(fullScreenIntent: true)`
- There is not yet a function to determine your full-screen permission at runtime ([GitHub issue](https://github.com/MaikuB/flutter_local_notifications/issues/2478))

> [!NOTE]
>
> Starting with API Level 34 (Android 14), only applications that provide call or alarm functionality will receive this permission. If the user is actively using the device, they will receive a heads-up notification instead. 

If the system chooses to show a full-screen notification, your app will be launched and `onDidReceiveNotificationResponse` will fire, allowing your app to show a special UI based on the notification. 

### Scheduling with precision

Using `zonedSchedule()` or `periodicallyShowWithDuration()` will cause your notification to appear at an inexact time by default. You can request more exact timing, but this comes with noticeably more battery strain and more permissions.

- Follow [this section](./android-setup.md#scheduling-with-precision) of the Android Setup Guide
- If you chose `SCHEDULE_EXACT_ALARM`, call [`androidPlugin?.requestExactAlarmsPermission()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestExactAlarmsPermission.html)
- Choose an appropriate [`AndroidScheduleMode`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidScheduleMode.html)
- called `zonedSchedule()` or `periodicallyShow()` with the `scheduleMode` parameter
- You can use `androidPlugin?.canScheduleExactNotifications()` to check your permission at runtime

## Showing Notifications

> [!IMPORTANT]
>
> You **must** provide an `AndroidNotificationDetails` for all notifications and provide a `channelId` that you created previously. If you do not pass these details, or pass a channel that does not exist, your notifications will not be shown.

### Presentation options

Most notification presentation options are set on the notification channel instead of the notification itself (see above). See [`AndroidNotificationDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationDetails-class.html) for all available fields. Notable options include: 

- `icon`: use a custom icon for this notification. To use custom icons, see [this section](./android-setup.md#custom-icons-and-sounds) of the Android Setup Guide.
- `showProgress`: show a loading bar
- `groupKey`: use the same value across multiple notifications to group them together
- `usesChronometer`: show a clock that ticks up or down. Useful for timers or media playback
- `color`: sets an accent color. If `colorized` is true, this will be the background color instead
- `styleInfomation`: allows you to choose a [custom style](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/DefaultStyleInformation-class.html) for the notification
- and many more

### Notification actions

Notifications can sometimes be used to accept user input and act on their behalf without necessarily opening the app. See [this section](./android-setup#using-notification-actions) of the Android Setup Guide, [this section](./usage.md#notification-actions) of the General Usage Guide for details, and [this section](./usage.md#the-initialize-function) on how to respond to action interactions. See [`AndroidNotificationAction`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationAction-class.html) for the full API, or the following examples: 

```dart
final actionsDetails = AndroidNotificationDetails("my-channel",
  actions: [
    // A basic button
    AndroidNotificationAction("button-id", "Button 1"),
    // A text field 
    AndroidNotificationAction(
    	"text-field-id", "Press to open text box",
      inputs: [
        AndroidNotificationActionInput(label: "Enter a message"),
      ],
    ),
		// Multiple choice
    AndroidNotificationAction(
      "choice-id", "Choose your favorite fruit",
      inputs: [
        AndroidNotificationActionInput(
          choices: ["Apple", "Banana"],
          allowFreeFormInput: false,
        ),
      ],
    ),
  ],
);
```

### Foreground Services

A [foreground service](https://developer.android.com/develop/background-work/services/foreground-services) indicates ongoing work in the form of a notification. You can use [`AndroidNotificationDetails.ongoing`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationDetails/ongoing.html) to specify if the notification should be non-dismissible, but a foreground service does more than that, including requesting to the device that your application be given a higher priority, even in the background. Note that this plugin does not implement logic in Dart to actually perform the operations, but rather just shows the service notification itself.

Android defines many different types of foreground services. These are just predefined categories and not limitations, but it can still be useful to let the system know what type of service you're running. Refer to [this page](https://developer.android.com/develop/background-work/services/fg-service-types) to find all the different types of services.

To create a foreground service, follow [this section](./android-setup.md#using-foreground-services) in the Android Setup Guide, then call [`startForegroundService()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/startForegroundService.html) and pass the appropriate service types, if any. The system will check if you have the necessary permissions for each service type and reject your request if not. The prerequisite permissions can be found at the link above. When you're done, use `stopForegroundService()`.

> [!WARNING]
>
> The `startType` parameter must be set to `startNotSticky`. This means that your service will not be restarted if your app is killed. This is okay because the foreground service itself – on the Java side – does not contain any important logic, as that is carried out on the Dart side only. If you want to be able to perform important background work that is restarted when necessary, consider using a plugin like [`package:flutter_foreground_service`](https://pub.dev/packages/flutter_foreground_service)
