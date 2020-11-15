# Contributing to flutter_local_notifications

Contributions are welcome by submitting a PR for to be reviewed. If it's to add new features, appreciate it if you could try to maintain the architecture or try to improve on it. If you are looking to add platform-specific functionality do not add this to the cross-platform facing API (i.e. the [`FlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin-class.html) class. The recommended approaches in this scenario are:

1. see if it can be passed as platform-specific configuration or
2. add methods to the platform-specific implementations. For example, on iOS there is an [`IOSFlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin-class.html) class. You may notice there's a [`requestPermissions()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin/requestPermissions.html) method that only exists there

Please ensure that no analysis issues are found and all tests continue to pass and add/update the tests as appropriate.
Most of the tests are around verifying the details sent via the platform channel.

For API docs, please try to adhere to the effective Dart documentation guidelines that can be found [here](https://dart.dev/guides/language/effective-dart/documentation).