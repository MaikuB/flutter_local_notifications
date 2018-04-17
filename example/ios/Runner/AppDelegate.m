#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <flutter_local_notifications/FlutterLocalNotificationsPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// NOTE: cannot seem to handle this protocol in the plugin class. Possible bug in how Flutter registers app delegates
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(@available(iOS 10.0, *)) {
        return;
    }
    
    NSString *payload = notification.userInfo[@"payload"];
    if(FlutterLocalNotificationsPlugin.resumingFromBackground) {
        // resuming from the background so don't want to show an alert as we would've seen
        // the notification while the app was in the background
        [FlutterLocalNotificationsPlugin handleSelectNotification:payload];
        return;
    }
    
    // display the alert as the app was in the foreground so notification wouldn't be displayed.
    // when the user taps on OK, fire the code in our Flutter app that is responsible for handling
    // the action for when the user taps on a notification
    NSString *title = notification.userInfo[@"title"];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:notification.alertBody
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [FlutterLocalNotificationsPlugin handleSelectNotification:payload];
                                                          }];
    
    [alert addAction:defaultAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
}

@end
