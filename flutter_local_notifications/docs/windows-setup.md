# Windows Setup

> [!Important]
> Before proceeding, please make sure you are using the latest version of the plugin, since some versions require changes to the setup process.

While this plugin handles some of the setup, other settings are required on a project basis and therefore must be applied within your project before notifications will work.

If you have already made modifications to these files, please be extra careful and pay attention to context to avoid losing your changes. As always, it is recommended to version control your application to avoid losing changes.

If something isn't clear, keep in mind the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) has all of this setup done already, so you can use it as a reference.

This guide will only handle the setup that comes before compiling your application. For details on what this plugin can do and how to use it, see the [Windows Usage Guide](windows-usage.md).

## MSIX packaging

The [MSIX packaging format](https://learn.microsoft.com/en-us/windows/msix/overview) is a relatively new technique to package and distribute modern Windows apps. An MSIX installs an app onto the system as if it were downloaded from the Windows store (indeed, Windows store apps are packaged with MSIX). MSIX installers can also be used to update an existing application while preserving user data, making them really convenient.

However, their relevance here goes beyond convenience: Windows [restricts](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/modernize-packaged-apps) some APIs to apps that have "package identity", ie, have been installed using an MSIX installer. That restriction includes notifications. Specifically, the following methods behave differently without package identity:

- non-packaged apps cannot see details about previously shown notifications
- [`getActiveNotifications()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getActiveNotifications.html) will return an empty list
- [`cancel()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancel.html) does nothing as it cannot find the notification with the specified ID.

Other APIs will most likely work during debug mode and in exe releases, but it is still highly recommended to use MSIX packaging instead.

### Setting up MSIX

The [msix package](https://pub.dev/packages/msix) can help generate an MSIX installer for your application. See the instructions there for full details, but you'll need to be consistent with the Dart code for this plugin to work:

| Setting Name | `pubspec.yaml` (`msix_config`) | `WindowsInitializationSettings` |
| ------------ | ------------------------------ | ------------------------------- |
| Display Name | `display_name`                 | `appName`                       |
| Package name | `identity_name`                | `appUserModelId`                |
| Unique ID    | `toast_activator.clsid`        | `guid`                          |

The display name is set in the MSIX and cannot be changed in Dart. The GUID/CLSID, as the name implies, needs to be _globally unique_. Avoid using IDs from tutorials as other apps on the user's device may be using them as well. Instead, use [online GUID generators](https://guidgenerator.com) to generate a new, unique GUID, and use that for your MSIX and Dart options. 

For a full example, see the `msix_config` section of [the example app's `pubspec.yaml`](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/pubspec.yaml).
