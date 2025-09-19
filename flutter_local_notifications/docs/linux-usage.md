# Linux Usage Guide

> [!Important]
>
> Make sure to read the [General Usage Guide](./usage.md) first.
>

This guide will explore all the features this plugin has available for apps running on Linux. Some features can only be called on the Linux plugin, not the general plugin. The rest of this guide will assume the following:

```dart
final plugin = FlutterLocalNotificationsPlugin();
final linuxPlugin = plugin
  .resolvePlatformSpecificImplementation
  <LinuxFlutterLocalNotificationsPlugin>();
```

While some of these methods will have their arguments, return types, and usage spelled out in detail, this document is meant to complement the [API reference](https://pub.dev/documentation/flutter_local_notifications/latest/index.html) on Pub. If you're looking for more details, nuances, or information about a function's signature, refer to the reference. Remember you can also check the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) for a pretty thorough reference of what this plugin can do.

## Initialization

The `LinuxInitializationSettings` object takes a few parameters

- `defaultActionName` (required): The default text to show for the available action
- `defaultIcon`: The default icon for all notifications (see below for icon types)
- `defaultSound`: The default sound for all notifications (see below for sound types)
- `defaultSuppressSound`: Asks the notification server to not play any sounds

### Server capabilities

On Linux, notifications are shown by sending D-Bus messages to a notifications server that implements the [Desktop Notifications Specification](https://specifications.freedesktop.org/notification-spec/). In order to stay server-agnostic, you can query the server ahead of time with [`linuxPlugin?.getCapabilities()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/LinuxFlutterLocalNotificationsPlugin/getCapabilities.html) to find out what features it supports. That function returns a list of [`LinuxServerCapabilities`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/LinuxServerCapabilities-class.html) that describe what kinds of features it supports. You can then decide to not use certain features if you know the server does not support them. Notable capabilities to watch out for include:

- `actions`: Notification Actions (see below)
- `body`: Whether the `body` parameter to `show()` will be respected
- `persistence`: Whether to show the notification until the user dismisses it
- `sound`: Whether the server can play sounds

## Showing notifications

### Presentation options

The [`LinuxNotificationDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/LinuxNotificationDetails-class.html) class provides a lot of options, including:

- `icon` and `sound`: see below
- `category` and `urgency`: pre-defined options that describe the type of message
- `resident` and `transient`: whether the notification should remain or not
- `location`: where to display the notification

### Markup

If the server supports the `bodyMarkup` capability, you may use the following HTML tags in your body:

- `<b>Bold text</b>`
- `<i>Italic text</i>`
- `<u>Underlined text</u>`
- `<a href="google.com">Links</a>`

If the server supports the `bodyImages` capability, you may include images in your body as well:

- `<img src=images.com/my-image.png" alt="image description" />`

### Notification Actions

Notifications can sometimes be used to accept user input and act on their behalf without necessarily opening the app. See [this section](./usage.md#notification-actions) of the General Usage Guide, and [this section](./usage.md#the-initialize-function) on how to respond to action interactions. Here is an example of button actions:
```dart
void onNotifcationTapped(NotificationResponse response) {
  switch (response.actionId) {
    "delete-message": deleteMessage(id: response.payload);
    "mark-as-read": markMessageAsRead(id: response.payload);
  }
}

final details = LinuxNotificationDetails(
  actions: [
    LinuxNotificationAction(key: "delete-message", label: "Delete message"),
    LinuxNotificationAction(label: "mark-as-read", label: "Mark as Read"),
  ],
);
await plugin.show(
  2, "New message from Alice", "Hey, are you free?",
  NotificationDetails(linux: details),
  payload: "message_ID_123",
);
```

### Custom icons

To use a custom icon, specify `LinuxInitializationSettings.defaultIcon` for every notification, or override on a per-notification basis with `LinuxNotificationDetails.icon`. Icons can be one of:

- `AssetsLinuxIcon`, which take a Flutter asset
- `ByteDataLinuxIcon`, which takes a [`LinuxRawIconData`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/LinuxRawIconData-class.html)
- `ThemeLinuxIcon`, which takes one of [these](https://www.freedesktop.org/wiki/Specifications/icon-naming-spec/) pre-defined icon names
- `FilePathLinuxIcon`, which takes am image from a `file://` URI or absolute path

### Custom sounds

To use a custom sound, specify `LinuxInitializationSettings.defaultSound` for every notification, or override on a per-notification basis with `LinuxNotificationDetails.sound`. Sounds can be:

- `AssetsLinuxSound`, which takes a Flutter asset
- `ThemeLinuxSound`, which takes one of [these](https://www.freedesktop.org/wiki/Specifications/sound-theme-spec/) pre-defined sound names

## Limitations

- Scheduling and repeating notifications are not supported on Linux.

- All notifications are sent to the main `onDidReceiveNotificationResponse` handler, which runs on the main isolate of the running application and cannot be launched in the background if the application is not running. To respond to notification clicks after the application is terminated, [register your application as D-Bus activatable](https://wiki.gnome.org/HowDoI/DBusApplicationLaunching). This is not feasible to do in this plugin since plugins are loaded after the application, so `getNotificationAppLaunchDetails()` wouldn't be possible to implement correctly.