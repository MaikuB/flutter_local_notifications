# Windows Usage Guide

> [!Important]
>
> Make sure to read the [Windows Setup Guide](./windows-setup.md) and [General Usage Guide](./usage.md) first.
>
> Specifically, [this section](./windows-setup.md#msix-packaging) of the Windows Setup Guide describes the concept of **package identity**, without which your app will have some limitations. Setting up package identity is preferred.

This guide will explore all the features this plugin has available for apps running on Windows. Some features can only be called on the Windows plugin, not the general plugin. The rest of this guide will assume the following:

```dart
final plugin = FlutterLocalNotificationsPlugin();
final windowsPlugin = plugin
  .resolvePlatformSpecificImplementation
  <FlutterLocalNotificationsWindows>();
```

While some of these methods will have their arguments, return types, and usage spelled out in detail, this document is meant to complement the [API reference](https://pub.dev/documentation/flutter_local_notifications/latest/index.html) on Pub. If you're looking for more details, nuances, or information about a function's signature, refer to the reference. Remember you can also check the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) for a pretty thorough reference of what this plugin can do.

## Initialization

The `WindowsInitializationSettings` object has a few parameters that need to match the ones provided in your MSIX configuration. Refer to [this table](./windows-setup.md#setting-up-msix) in the setup guide for details. If you're not using an MSIX package, then these values can be whatever you want them to be, but they must still be valid and properly formatted. The following is a full example:

```yaml
# pubspec.yaml
msix_config:
  display_name: Flutter Local Notifications Example
  identity_name: com.example.FlutterLocalNotificationsExample
  msix_version: 1.0.0.0
  store: false
  install_certificate: false
  output_name: example
  toast_activator:
    clsid: "d49b0314-ee7a-4626-bf79-97cdb8a991bb"
    arguments: "msix-args"
    display_name: "Flutter Local Notifications Example"
```

```dart
final windowsSettings = WindowsInitializationSettings(
  appName: "Flutter Local Notifications Example",
  appUserModelId: "com.example.FlutterLocalNotificationsExample",
  guid: "d49b0314-ee7a-4626-bf79-97cdb8a991bb",
);
await plugin.initialize(InitializationSettings(windows: windowsSettings);
```

> [!Note]
>
> Without package identity, your application will have the following limitations:
>
> - `getActiveNotifications()` will always return an empty list
> - `cancel()` will not work, only `cancelAll()`

## Showing notifications

### Presentation options

The [`WindowsNotificationDetails`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsNotificationDetails-class.html) class supports a number of options, including:

- `actions` and `inputs` – see below
- `images`: a list of [`WindowsImage`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsImage-class.html)s, either shown regularly or used to override the app icon
- `rows`: a list of [`WindowsRow`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsRow-class.html)s and columns that group images and text together
- `progressBars`: a list of [`WindowsProgressBar`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsProgressBar-class.html)s
- `header`: uses a custom ID that can be used to group multiple notifications together
- `audio`: a [`WindowsNotificationAudio`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsNotificationAudio-class.html) to play, or `WindowsNotificationAudio.silent()`
- `duration`: describes how long the notification should stick around for
- `scenario`: a preset [`WindowsNotificationScenario`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsNotificationScenario.html) that describes the notification and its style
- `timestamp`: can be used to back-date a notification
- `subtitle`: a third line of text, under the body

The example app has a [separate file](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/lib/windows.dart) just for all the Windows features, so be sure to check that out! You can also check out the [App Notifications](https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/) section of the Windows docs, and especially [this page](https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/adaptive-interactive-toasts?tabs=appsdk).

### Notification Actions

Notifications can sometimes be used to accept user input and act on their behalf without necessarily opening the app. See [this section](./usage.md#notification-actions) of the General Usage Guide, and [this section](./usage.md#the-initialize-function) on how to respond to action interactions. Here is an example of a few different types of actions in a notification

<details>
<summary>Expand to see a full example</summary>

```dart
final markReadButton = WindowsAction(content: "Mark as Read", arguments: "mark-read");

final deleteButton = WindowsAction(
	content: "Delete",
  arguments: "delete-message",
  buttonStyle: WindowsButtonStyle.critical,
  tooltip: "Delete this message",
);

final respondTextInput = WindowsTextInput(
	id: "reply-message",
  placeHoldContent: "Enter a message...",
  title: "Reply",
);

final presetSelection = WindowsSelection(
	id: "reply-message",
  title: "Respond with a preset message",
  items: [
    WindowsSelection(id: "reply1", content: "Hello!"),
    WindowsSelection(id: "reply2", content: "Please leave me alone..."),
  ],
);

final details = WindowsNotificationDetails(
	actions: [markReadButton, deleteButton],
  inputs: [respondTextInput, presetSelection],
);

await plugin.show(
  1, "Alice sent you a message", "Hey! Are you ready?",
	NotificationDetails(windows: details),
  payload: "message_ID_123",
);

void onNotificationTapped(NotificationResponse response) {
  final messageId = response.payload;
  switch (response.actionId) {
    case "delete-message": deleteMessage(messageId);
    case "mark-read": markRead(messageID, true);
    case "reply-message":
      // Inputs on Windows are in NotificationResponse.data
      final reply = response.data["reply-message"];
      replyToMessage(messageId, reply);
  }
}
```

</details>

### Custom images and sounds

images can come from different sources: the web, MSIX bundles, files on the user's device, or Flutter assets. See the documentation for [`WindowsImage`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsImage-class.html) for complete details on when each time of source is usable.

Sounds can either be one of the [`WindowsNotificationSound`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsNotificationSound.html) presets, or a Flutter asset using [`WindowsNotificationAudio.asset()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/WindowsNotificationAudio/WindowsNotificationAudio.asset.html). When used in an MSIX package, this constructor will automatically convert the resource to an `ms-appx://` URI, and use a fallback preset sound in debug or non-packaged releases.

### Custom XML

Windows notifications are sent in the form of an XML schema, which the Windows SDK has to parse and verify. Using the `WindowsNotificationDetails` class in this library lets you skip that and build your notification with pure Dart code, but if you wanted to use raw XML for some unsupported or custom behavior, you can:

- `windowsPlugin?.isValidXml()` will validate that the XML is indeed valid Windows XML
- `windowsPlugin?.showRawXml()` is equivalent to `plugin.show()`, but with raw XML instead of details
- `windowsPlugin?.zonedScheduleRawXml()` is equivalent to `zonedSchedule()` but with raw XML

For more information, see the [Windows docs](https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/schema-root). To test your XML during development, use the [Windows Notifications Visualizer](https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/notifications-visualizer), or input it into the text field in the Windows example app.

### Data bindings

Any time you need to supply a text value, like `title`, `body`, `subtitle`, or even in raw XML, you can use a "binding", which is essentially a variable you can replace on the fly. For example, instead of

```dart
await plugin.show(1, "Alice sent you a message", null, null);
```

You can use

```dart
final bindings = {"sender": "Alice"};
final details = WindowsNotificationDetails(bindings: bindings);
await plugin.show(
  1, "{sender} sent you a message!", null, NotificationDetails(windows: details),
);
```

You can then update the bindings at any time, and the notification will be updated in-place:

```dart
await windowsPlugin?.updateBindings({"sender": "Bob"});
```

You can also use this to update progress bars in real-time, though there is a special method for that:

```dart
final progressBar = WindowsProgressBar(
  id: "downloading-progress",
  status: "Downloading...",
  value: null,  // null=indeterminate, ie no progress yet
  label: "Downloading...",  // note: no progress yet
);
final details = WindowsNotificationDetails(progressBars: [progressBar]);
await plugin.show(2, "Downloading songs", null, NotificationDetails(windows: details));

void updateDownloadProgress(int percentage) {
  progressBar.value = percentage / 100;
  progressBar.label = "Downloading: $percentage%";
  // Must use the same notification ID and progress bar
  await windowsPlugin?.updateProgressBar(2, progressBar);
}
```

## Limitations

- Without package identity, `getActiveNotifications()` will always return an empty list
- Without package identity, `cancel()` will not work, use `cancelAll()` or `cancelPendingNotifications()`
- Windows does not support repeating notifications. Trying to use `periodicallyShow()` or `periodicallyShowWithDuration()` will result in an `UnsupportedError`.
