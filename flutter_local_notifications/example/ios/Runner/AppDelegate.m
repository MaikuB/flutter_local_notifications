#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <flutter_local_notifications/FlutterLocalNotificationsPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // cancel old notifications that were scheduled to be periodically shown upon a reinstallation of the app
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"Notification"]){
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Notification"];
    }
    if(@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    }
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
