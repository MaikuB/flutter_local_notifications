# flutter_local_notifications_web

The web implementation of the `flutter_local_notifications` package.

## Notes

- If you are debugging with `flutter run -d chrome`, you will see notifications but they will not respond to being clicked! This is due to the private debugging window that Flutter opens, and they will respond properly in release builds. To test notification handlers, make sure to use `flutter run -d web-server`. If you find that hot reload is broken with `-d web-server`, try to test as much as possible with `-d chrome`.
- **You must request notification permissions before showing notifications -- but only in response to a user interaction.** If you try to request permissions automatically, like on loading a page, not only may your request be automatically denied, but the browser may deem your site as abusive and no longer show any more prompts to the user, and just block everything going forward.
- Notification actions are supported by Chrome and Edge, but not Firefox or Safari. They may catch up soon, but text input fields use a standards _proposal_, not an accepted standard, and so may only work on Chrome for a while.
- Browsers don't support scheduled or repeating notifications, and browsers on Android do not support custom vibration.

## Using the plugin

### Initialize the plugin

```dart
final plugin = FlutterLocalNotificationsPlugin();
await plugin.initialize();

if (!plugin.hasPermission) {
  // IMPORTANT: Only call this after a button press!
  await plugin.requestNotificationsPermission();
}
```

### Show a notification

```dart
var id = 0;  // increment this every time you show a notification
await plugin.show(id, "Title", "Body text", null);
```

### Use web-specific details
```dart
final webDetails = WebNotificationDetails(requireInteraction: true);
final details = NotificationDetails(web: webDetails);
await plugin.show(id, "Title", "Body text", details);
```

### Respond to notifications
```dart
// Handle incoming notifications when your site is open
void handleNotification(NotificationResponse notification) {
  print("User clicked on notification: ${notification.id}");
}

final plugin = FlutterLocalNotificationsPlugin();
await plugin.initialize(onNotificationReceived: handleNotification);

// When your site is closed, clicking the notification will launch your site
//  with special query parameters that include the notification details.
// When your site is opened, check if it was because of a notification:
final launchDetails = await plugin.getNotificationAppLaunchDetails();
if (launchDetails != null) {
  // The site was launched because a notification was clicked
  final notification = launchDetails.notificationResponse;
  print("User clicked on notification: ${notification.id}")
}
```
