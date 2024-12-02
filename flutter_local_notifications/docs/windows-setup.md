# Windows Setup

> [!Important]
> Before proceeding, please make sure you are using the latest version of the plugin, since some versions require changes to the setup process.

While this plugin handles some of the setup, other settings are required on a project basis and therefore must be applied within your project before notifications will work.

If you have already made modifications to these files, please be extra careful and pay attention to context to avoid losing your changes. As always, it is recommended to version control your application to avoid losing changes.

## Limitations

Windows does not support repeating notifications, so [`periodicallyShow`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShow.html) and [`periodicallyShowWithDuration`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShowWithDuration.html) will throw `UnsupportedError`s.

## MSIX packaging

The [MSIX packaging format](https://learn.microsoft.com/en-us/windows/msix/overview) is a relatively new technique to package and distribute modern Windows apps. An MSIX installs an app onto the system as if it were downloaded from the Windows store (indeed, Windows store apps are packaged with MSIX). MSIX installers can also be used to update an existing application while preserving user data, making them really convenient.

However, their relevance here goes beyond convenience: Windows [restricts](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/modernize-packaged-apps) some APIs to apps that have "package identity", ie, have been installed using an MSIX installer. That restriction includes notifications. Specifically, the following methods behave differently without package identity:

- non-packaged apps cannot see details about previously shown notifications
- [`getActiveNotifications()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getActiveNotifications.html) will return an empty list
- [`cancel()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancel.html) does nothing as it cannot find the notification with the specified ID.

Other APIs will most likely work during debug mode and in exe releases, but it is still highly recommended to use MSIX packaging instead.

### Setting up MSIX

The [msix package](https://pub.dev/packages/msix) can help generate an MSIX installer for your application. See the instructions there for full details, but you'll need to be consistent with the Dart code for this plugin to work:

- The `display_name` MSIX option should match your `WindowsInitializationSettings.appName` option
- The `identity_name` MSIX option must be identical to your `WindowsInitializationSettings.appUserModelId` option
- Your `msix_config` must also specify a `toast_activator` section with the following:
  - a `clsid` option that exactly matches `WindowsInitializationSettings.guid`
  - a `display_name` option that will be on each notification and cannot be changed in Dart.

The GUID/CLSID, as the name implies, needs to be _globally unique_. Avoid using IDs from tutorials as other apps on the user's device may be using them as well. Instead, use [online GUID generators](https://guidgenerator.com) to generate a new, unique GUID, and use that for your MSIX and Dart options. 

For a full example, see [the example app's `pubspec.yaml`](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/pubspec.yaml).
