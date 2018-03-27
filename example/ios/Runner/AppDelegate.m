#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(@available(iOS 10.0, *)) {
        return;
    }
    
    NSString* title = notification.userInfo[@"title"];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:notification.alertBody delegate:nil     cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
