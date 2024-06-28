# Grouping Notifications on iOS

For iOS, you can specify `threadIdentifier` in `DarwinNotificationDetails`. Notifications with the same `threadIdentifier` will get grouped together automatically.

```dart
const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(threadIdentifier: 'thread_id');
```
