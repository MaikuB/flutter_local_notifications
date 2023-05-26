# Contributing to flutter_local_notifications

Contributions are welcome by submitting a PR for to be reviewed. If it's to add new features, appreciate it if you could try to maintain the architecture or try to improve on it. If you are looking to add platform-specific functionality do not add this to the cross-platform facing API (i.e. the [`FlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin-class.html) class. The recommended approaches in this scenario are:

1. see if it can be passed as platform-specific configuration or
2. add methods to the platform-specific implementations. For example, on iOS there is an [`IOSFlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin-class.html) class. You may notice there's a [`requestPermissions()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin/requestPermissions.html) method that only exists there

Please ensure that no analysis issues are found and all tests continue to pass and add/update the tests as appropriate.
Most of the tests are around verifying the details sent via the platform channel.

For API docs, please try to adhere to the effective Dart documentation guidelines that can be found [here](https://dart.dev/guides/language/effective-dart/documentation).

Managing the monorepo is through the use of [`melos`](https://melos.invertase.dev). Currently the minimum Flutter SDK version supported is 3.0 with a corresponding minimum Dart SDK version of 2.17. This isn't compatible with melos versions 3.0 or newer due to incompatible Dart SDK version constraints. To avoid bumping the plugin's minimum Flutter and Dart SDK version constraints just for the sake of being able to use newer versions of `melos`, version 2.9.0 used. For local development purposes you can activate 2.9.0 by running `dart pub global activate melos 2.9.0`. The cirrus build scripts run the same command to specify `melos` version 2.9.0