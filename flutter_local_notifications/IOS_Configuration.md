# iOS/macOS Configuration

Adjust `AppDelegate.m` and set the plugin registrant callback:

If you're using Objective-C, add this function anywhere in AppDelegate.m:
``` objc
// This is required for calling FlutterLocalNotificationsPlugin.setPluginRegistrantCallback method.
#import <FlutterLocalNotificationsPlugin.h>
...
...
void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
    [GeneratedPluginRegistrant registerWithRegistry:registry];
}
```

then extend `didFinishLaunchingWithOptions` and register the callback:

``` objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];

    // Add this method    
    [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:registerPlugins];
}
```

For Swift, open the `AppDelegate.swift` and update the `didFinishLaunchingWithOptions` as follows
where the commented code indicates the code to add in and why

```swift
import UIKit
import Flutter
// This is required for calling FlutterLocalNotificationsPlugin.setPluginRegistrantCallback method.
import flutter_local_notifications

@UIApplicationMain
override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  // This is required to make any communication available in the action isolate.
  FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
    GeneratedPluginRegistrant.register(with: registry)
  }

  ...
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

On iOS/macOS, notification actions need to be configured before the app is started using the `initialize` method

``` dart
final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    // ...
    notificationCategories: [
      DarwinNotificationCategory(
        'demoCategory',
        actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
            'id_2',
            'Action 2',
            options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
            },
            ),
            DarwinNotificationAction.plain(
            'id_3',
            'Action 3',
            options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
            },
            ),
        ],
        options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
    )
],
```

On iOS/macOS, the notification category will define which actions are available.

**Usage**:

You need to configure a **top level** or **static** method which will handle the action:

``` dart
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}
```

Specify this function as a parameter in the `initialize` method of this plugin:

``` dart
await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // ...
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
);
```

Remember this function runs (except Linux) in a separate isolate! This function also requires the `@pragma('vm:entry-point')` annotation to ensure that tree-shaking doesn't remove the code since it would be invoked on the native side. See [here](https://github.com/dart-lang/sdk/blob/master/runtime/docs/compiler/aot/entry_point_pragma.md) for official documentation on the annotation.
