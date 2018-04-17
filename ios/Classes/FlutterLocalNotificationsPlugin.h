#import <Flutter/Flutter.h>
#import <UserNotifications/UserNotifications.h>

@interface FlutterLocalNotificationsPlugin : NSObject <FlutterPlugin, UNUserNotificationCenterDelegate>
+ (bool) resumingFromBackground;
+ (void)handleSelectNotification:(NSString *)payload;
@end
