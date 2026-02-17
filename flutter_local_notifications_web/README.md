# flutter_local_notifications_web

The web implementation of the `flutter_local_notifications` package.

## Browser Compatibility

| Feature | Chrome/Edge | Firefox | Safari |
|---------|-------------|---------|--------|
| Basic notifications | ✅ | ✅ | ✅ |
| Notification actions | ✅ | ❌ | ❌ |
| Text input actions | ❌ | ❌ | ❌ |
| Custom vibration | ✅ (desktop only) | ✅ (desktop only) | ❌ |
| Service worker | ✅ | ✅ | ✅ |

Note: Firefox and Safari may add action support in future versions. Text input fields use a standards proposal and may only work on Chrome for the foreseeable future.

## Important Limitations

- **No scheduled notifications**: Browsers don't support scheduling notifications for future delivery. Methods like `zonedSchedule()` will throw `UnsupportedError`.
- **No repeating notifications**: `periodicallyShow()` and `periodicallyShowWithDuration()` are not supported and will throw `UnsupportedError`.
- **Permission must be user-initiated**: You can only request notification permissions in response to a user action (like a button click).
- **Custom vibration on mobile**: Browsers on Android do not support custom vibration patterns.

## Notes

- If you are debugging with `flutter run -d chrome`, you will see notifications but they will not respond to being clicked! This is due to the private debugging window that Flutter opens, and they will respond properly in release builds. To test notification handlers, make sure to use `flutter run -d web-server`. If you find that hot reload is broken with `-d web-server`, try to test as much as possible with `-d chrome`.
- **You must request notification permissions before showing notifications -- but only in response to a user interaction.** If you try to request permissions automatically, like on loading a page, not only may your request be automatically denied, but the browser may deem your site as abusive and no longer show any more prompts to the user, and just block everything going forward.
- Notification actions are supported by Chrome and Edge, but not Firefox or Safari. They may catch up soon, but text input fields use a standards _proposal_, not an accepted standard, and so may only work on Chrome for a while.
- Browsers don't support scheduled or repeating notifications, and browsers on Android do not support custom vibration.

## Using the plugin

### Check browser support

```dart
// Check if the browser supports notifications before initializing
if (WebFlutterLocalNotificationsPlugin.isSupported) {
  final plugin = FlutterLocalNotificationsPlugin();
  final initialized = await plugin.initialize();
  
  if (initialized == false) {
    // Initialization failed - browser may not support Service Workers
    print('Failed to initialize notifications');
  }
} else {
  print('Notifications are not supported in this browser');
}
```

### Initialize the plugin

```dart
final plugin = FlutterLocalNotificationsPlugin();
final initialized = await plugin.initialize();

if (initialized == false) {
  // Handle initialization failure
  print('Failed to initialize notifications');
  return;
}

if (!plugin.hasPermission) {
  // IMPORTANT: Only call this after a button press!
  await plugin.requestNotificationsPermission();
}
```

### Check permission status

```dart
final plugin = FlutterLocalNotificationsPlugin();

// Check if permission is granted
if (plugin.hasPermission) {
  // Can show notifications
}

// Check if permission was explicitly denied
if (plugin.isPermissionDenied) {
  // User blocked notifications - guide them to browser settings
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Notifications Blocked'),
      content: Text(
        'You have blocked notifications. To enable them, '
        'please update your browser settings.',
      ),
    ),
  );
}

// Get the raw permission status
final status = plugin.permissionStatus; // 'granted', 'denied', or 'default'
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
await plugin.initialize(onDidReceiveNotificationResponse: handleNotification);

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

## Troubleshooting

### Notifications don't respond to clicks in debug mode

If you're using `flutter run -d chrome`, notifications will appear but won't respond to clicks. This is due to the private debugging window Flutter opens. Use `flutter run -d web-server` to test notification handlers properly.


### Notifications don't appear

1. Check that initialization succeeded: `await plugin.initialize()` should return `true`
2. Check that you've requested and been granted permission
3. Verify the service worker is registered (check browser DevTools > Application > Service Workers)
4. Make sure you called `initialize()` before `show()`
5. Check browser console for errors
6. Verify browser supports notifications: `WebFlutterLocalNotificationsPlugin.isSupported`

### Service worker not updating

If you modify the service worker and changes don't appear:
1. Clear browser cache
2. Unregister the old service worker in DevTools
3. Hard refresh the page (Cmd+Shift+R or Ctrl+Shift+R)

### Browser blocks all notifications from my site

If you repeatedly request permissions without user interaction, browsers may permanently block your site. Users will need to manually reset permissions in their browser settings.

