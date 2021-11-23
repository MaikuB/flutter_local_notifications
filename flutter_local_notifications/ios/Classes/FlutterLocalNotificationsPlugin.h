#import <Flutter/Flutter.h>
#import <UserNotifications/UserNotifications.h>

@interface FlutterLocalNotificationsPlugin : NSObject <FlutterPlugin>
+ (void)setRegisterPlugins:(FlutterPluginRegistrantCallback *)callback;
@end
