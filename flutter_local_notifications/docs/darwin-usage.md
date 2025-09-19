# Darwin Usage Guide

> [!Important]
>
> Make sure to read the [iOS Setup Guide](./ios-setup.md) and [General Usage Guide](./usage.md) first.

This guide will explore all the features this plugin has available for apps running on Darwin platforms – iOS and MacOS. Some features can only be called on the Darwin plugins, not the general plugin. See the general usage guide for how to get that at runtime. The rest of this guide will assume the following. 

```dart
final plugin = FlutterLocalNotificationsPlugin();
final iOSPlugin = plugin
  .resolvePlatformSpecificImplementation
  <IOSFlutterLocalNotificationsPlugin>();
final macOSPlugin = plugin
  .resolvePlatformSpecificImplementation
  <MacOSFlutterLocalNotificationsPlugin>();
final darwinPlugin = iOSPlugin;  // or macOSPlugin
```

Both plugins support the same features, but you will still need to call the same methods on both plugins if your application will run on both platforms. 

While some of these methods will have their arguments, return types, and usage spelled out in detail, this document is meant to complement the [API reference](https://pub.dev/documentation/flutter_local_notifications/latest/index.html) on Pub. If you're looking for more details, nuances, or information about a function's signature, refer to the reference. Remember you can also check the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) for a pretty thorough reference of what this plugin can do.

> [!Note]
>
> While this plugin supports MacOS 10.13 and iOS 12, this guide will assume you are targeting iOS 14 and MacOS 11 or higher, which both released in 2020.

## Initialization

### Foreground options

When the app is in the foreground, the device will, by default, not show the notification. To override this behavior, customize `DarwinInitializationSettings` (all of these default to `true`)

- `defaultPresentBadge`: gives the app icon a badge 
- `defaultPresentBanner`: shows a notification banner on-screen
- `defaultPresentList`: adds the notification to the Notification Center
- `defaultPresentSound`: plays a notification sound

### Notification actions

Notifications can sometimes be used to accept user input and act on their behalf without necessarily opening the app. See [this section](./ios-setup#handling-actions) of the iOS Setup Guide, [this section](./usage.md#notification-actions) of the General Usage Guide, and [this section](./usage.md#the-initialize-function) on how to respond to action interactions. 

On Darwin, you must declare your actions in `DarwinInitializationSettings` with the `notificationCategories` field, which takes a list of [`DarwinNotificationCategory`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/DarwinNotificationCategory-class.html) objects, each with their own list of [`DarwinNotificationAction`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/DarwinNotificationAction-class.html)s. Categories are defined for similar types of notifications, like new emails, interesting sales, and more. Each category will have the same set of actions. Here are some examples: 

```dart
// Set up the actions
final hotNewDeal = DarwinNotificationCategory(
	"new-promo",
  actions: [
    DarwinNotificationAction(
      "purchase", "Buy this!", 
      options: {DarwinNotificationActionOption.foreground},
    ),
  ],
),
final newMessage = DarwinNotificationCategory(
	"new-message", 
  actions: [
    DarwinNotificationAction.text(
      "reply", "Reply", buttonTitle: "Send a reply",
      placeholder: "Enter a message...",
      options: {DarwinNotificationActionOption.authenticationRequired},
    ),
  ],
);

// Set up a handler to handle tapped notifications
void onNotificationPressed(NotificationResponse response) {
  switch (response.actionId) {  // which action was pressed
    "new-promo": goToPage("/deals/${response.payload}");
    "new-message": respond(response.payload, response.input);
  }
}

// Initialize the categories
final darwinSettings = DarwinInitializationSettings(
  notificationCategories: [hotNewDeal, newMessage],
);

await plugin.initialize(
  InitializationSettings(iOS: darwinSettings, macOS: darwinSettings),
  onDidReceiveNotificationResponse: onNotificationPressed,
);

// Show the notification
final dealDetails = DarwinNotificationDetails(categoryIdentifier: "new-promo");
await plugin.show(
  1, "A Hot New Deal!", "Look what's on sale!",
	payload: "deal_id_123",
	NotificationDetails(iOS: dealDetails, macOS: dealDetails),
);
```

## Requesting permissions

This next section will deal with requesting permissions. As noted in the general usage guide, requesting permissions is a very sensitive process in terms of user experience, and must be done only when necessary and only after informing the user of why you need the permissions. If the user rejects your request – which they might if they feel annoyed or don't understand why you need it – Android will stop showing your requests to the user and start blocking them automatically. If this happens, you will need to prompt the user to go to the settings themselves and grant your app permissions manually. 

> [!Important]
>
> By default, `DarwinInitializationSettings` defaults to `true` for `requestAlertPermission`, `requestBadgePermission`, `requestListPermission`, and `requestSoundPermission`. You should set those all to false explicitly and follow the guidance below instead ([GitHub issue](https://github.com/MaikuB/flutter_local_notifications/issues/2693))

### Notification Permissions

You will need permissions to show notifications at all. Be sure to call [`requestPermissions()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/MacOSFlutterLocalNotificationsPlugin/requestPermissions.html) sometime after calling `initialize()`, but before calling any method that shows or schedules a notification. You can use [`checkPermissions()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/MacOSFlutterLocalNotificationsPlugin/checkPermissions.html) to check your permissions at runtime.

> [!NOTE]
>
> Use this method instead of setting fields like `DarwinInitializationSettings.requestSoundPermission`. You want to wait until the very last minute to request permissions, preferably until the user has initiated an action themselves. If users feel like the notification request is helping them complete an action, they are more likely to grant it as opposed to when it feels spammy. See Apple's guidance [here](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications#Explicitly-request-authorization-in-context).

### Provisional Notifications

Instead of asking for broad permissions right away, you can request [provisional permissions](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications#Use-provisional-authorization-to-send-trial-notifications) instead. This will allow your app to send notifications quietly in a way that doesn't disturb the user – instead of a banner or sound, your notification will be sent straight to the Notification Center. These notifications will also come with a prompt to the user if they want to keep allowing more notifications or turn them off, which can either grant or deny your broader permissions automatically.  

```dart
// Either right away
final darwinSettings = DarwinInitializationSettings(requestProvisionalPermission: true);
// Or when you need it
await darwinPlugin?.requestPermissions(provisional: true);
```

### Bypassing Do Not Disturb

If you have notifications that are important enough to need to bypass Do Not Disturb:

- Request the [Critical Alerts](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.usernotifications.critical-alerts) entitlement from Apple (requires a special form)
- Include `critical: true` in your `requestPermissions()` call
- Send a notification with `InterruptionLevel.critical`

 enum lets you control how much your notification should be allowed to interrupt the user. If you plan to use `InterruptionLevel.timeSensitive`, you'll need to [enable](https://help.apple.com/xcode/mac/current/#/dev88ff319e7) the time-sensitive capability. See the video [here](https://developer.apple.com/videos/play/wwdc2021/10091/) for more details. If you plan to use `InterruptionLevel.critical`, you'll need to [get approval](https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/) from Apple.

> [!Important]
>
> Bypassing Do Not Disturb does not mean the device's volume will be increased or vibration will be enabled, just that the notification will appear on-screen. In an emergency, the user may have sound and vibration disabled and won't notice your notification. Use a different package to enable sound and vibration if you need it. 

## Showing notifications

Make sure you've read the [General Usage Guide](./usage.md#showing-notifications) for a full understanding of the different functions.

### Presentation options

The [`DarwinNotificationDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/DarwinNotificationDetails-class.html) has a few options, including

- `presentBadge`, `presentSound`, `presentBanner`, and `presentList`: same as above
- `sound`: plays a custom sound (`presentSound` must be true). See [the Apple docs](https://developer.apple.com/documentation/usernotifications/unnotificationsound?language=objc)
- `badgeNumber`: changes the app badge count
- `attachments`: a list of [images](https://developer.apple.com/documentation/usernotifications/unnotificationattachment?language=objc) to show with the notification
- `subtitle`: a secondary description (separate from the notification's body)
- `threadIdentifier`: all notifications with the same value will be grouped together
- `categoryIdentifier`: the identifier of a category, as described above
- `interruptionLevel`: how much the device should get the user's attention

> [!Note]
>
> Using `InterruptionLevel.critical` requires bypassing Do Not Disturb – see above
> Using `InterruptionLevel.timeSensitive` requires enabling the capability in XCode

### Limitations

- `getNotificationAppLaunchDetails()` will always return null prior to MacOS 10.14
- iOS will only schedule up to 64 notifications at a time
