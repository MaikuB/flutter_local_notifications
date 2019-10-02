#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <shared_preferences/SharedPreferencesPlugin.h>
#import <flutter_local_notifications/FlutterLocalNotificationsPlugin.h>

@implementation AppDelegate

void registrationCallback(NSObject<FlutterPluginRegistry>* registry) {
    [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:registrationCallback];
    // cancel old notifications that were scheduled to be periodically shown upon a reinstallation of the app
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"Notification"]){
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Notification"];
    }
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
