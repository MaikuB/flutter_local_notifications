# iOS Setup

> [!Important]
> Before proceeding, please make sure you are using the latest version of the plugin, since some versions require changes to the setup process.

While this plugin handles some of the setup, other settings are required on a project basis and therefore must be applied within your project before notifications will work.

If you have already made modifications to these files, please be extra careful and pay attention to context to avoid losing your changes. As always, it is recommended to version control your application to avoid losing changes.

If something isn't clear, keep in mind the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) has all of this setup done already, so you can use it as a reference.

This guide will only handle the setup that comes before compiling your application. For details on what this plugin can do and how to use it, see the [Darwin Usage Guide](darwin-usage.md).

## General setup

To start, add the following lines to the `application` method. The exact code differs between languages.

<details>
<summary>Objective-C - <code>ios/Runner/AppDelegate.m</code></summary>

```objc
if (@available(iOS 10.0, *)) {
  [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
}
```

</details>

<details>
<summary>Swift - <code>ios/Runner/AppDelegate.swift</code></summary>

```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

</details>

## Handling actions

Apps can define [actions](https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types) in their notifications which allow users to interact with the notifications on a deeper level without needing to navigate through the app.

A standard notification can be clicked, which opens the app in the standard way. A notification action, however, can get input from the user and pass it to a custom function, which can then open a specific page in the app or run a background task without opening the app at all.

To enable actions in your app, you must hook Flutter into the launch process. Normally, Flutter will do this for you in regular apps, but since actions can open your app in a non-standard way, you must perform the following setup.

<details>
<summary>Objective-C - <code>ios/Runner/AppDelegate.m</code></summary>

```objc
// Required to handle notification actions
#import <FlutterLocalNotificationsPlugin.h>

void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
  [GeneratedPluginRegistrant registerWithRegistry:registry];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:registerPlugins];
}
```

</details>

<details>
<summary>Swift - <code>ios/Runner/AppDelegate.swift</code></summary>


Swift (`ios/Runner/AppDelegate.swift`):

```swift
// Required to handle notification actions
import flutter_local_notifications

@UIApplicationMain
override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {

  // This is required to make any communication available in the action isolate.
  FlutterLocalNotificationsPlugin.setPluginRegistrantCallback {
    (registry) in GeneratedPluginRegistrant.register(with: registry)
  }

  if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
  }

  GeneratedPluginRegistrant.register(with: self)
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

</details>

## Clearing notifications on reinstall

On some devices (older than iOS 10), if the user uninstalls the app without cancelling their repeating notifications, the app may reschedule those notifications if it's reinstalled. To prevent this, add the following code to the `didFinishLaunchingWithOptions()` method of the `AppDelegate` class.

<details>
<summary>Objective-C - <code>ios/Runner/AppDelegate.m</code></summary>

```objc
if(![[NSUserDefaults standardUserDefaults]objectForKey:@"Notification"]){
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Notification"];
}
```

</details>

<details>
<summary>Swift - <code>ios/Runner/AppDelegate.swift</code></summary>

```swift
if(!UserDefaults.standard.bool(forKey: "Notification")) {
  UIApplication.shared.cancelAllLocalNotifications()
  UserDefaults.standard.set(true, forKey: "Notification")
}
```

</details>
