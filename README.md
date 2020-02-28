# Flutter Local Notifications plugin

This repository consists hosts the following packages

- `flutter_local_notifications`: code for the cross-platform facing plugin used to display local notifications within Flutter applications
- `flutter_local_notifications_platform_interface`: the code for the common platform interface

These can be found in the corresponding directories within the same name. Most developers are likely here as they are looking to use the `flutter_local_notifications` plugin. There is a readme file within each directory with more information.

## Issues

If you run into bugs, please raise them on the GitHub repository. Please do not email them to me as GitHub is the appropriate place for them and allows for members of the community to answer questions, particularly if I miss the email. It would also be much appreciated if they could be limited to actual bugs or feature requests. If you're looking at how you could use the plugin to do a particular kind of notification, check the example app provides detailed code samples for each supported feature. Also try to check the README first in case you have missed something e.g. platform-specific setup.

## Contributions

Contributions are welcome by submitting a PR for to be reviewed. If it's to add new features, appreciate it if you could try to maintain the architecture or try to improve on it. If you are looking to add platform-specific functionality do not add this to the cross-platform facing API (i.e. the [`FlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin-class.html) class. The recommended approaches in this scenario are:

1. see if it can be passed as platform-specific configuration or
2. add methods to the platform-specific implementations. For example, on iOS there is an [`IOSFlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin-class.html) class. You may notice there's a [`requestPermissions()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin/requestPermissions.html) method that only exists there

