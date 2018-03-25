#import "FlutterLocalNotificationsPlugin.h"

@implementation FlutterLocalNotificationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"dexterous.com/flutter/local_notifications"
            binaryMessenger:[registrar messenger]];
  FlutterLocalNotificationsPlugin* instance = [[FlutterLocalNotificationsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([@"initialize" isEqualToString:call.method]) {
        NSDictionary *arguments = [call arguments];
        NSDictionary *platformSpecifics = arguments[@"platformSpecifics"];
        UIUserNotificationType notificationTypes = 0;
        if (platformSpecifics[@"sound"]) {
            notificationTypes |= UIUserNotificationTypeSound;
        }
        if (platformSpecifics[@"alert"]) {
            notificationTypes |= UIUserNotificationTypeAlert;
        }
        if (platformSpecifics[@"badge"]) {
            notificationTypes |= UIUserNotificationTypeBadge;
        }
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else if ([@"show" isEqualToString:call.method] || [@"schedule" isEqualToString:call.method]) {
      NSNumber *id = call.arguments[@"id"];
      NSString *title = call.arguments[@"title"];
      NSString *body = call.arguments[@"body"];
      UILocalNotification *notification = [[UILocalNotification alloc] init];
      notification.alertBody = body;
      NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:id, @"NotificationId", title, @"title", nil];
      notification.userInfo = infoDict;
      if([@"schedule" isEqualToString:call.method]) {
          NSNumber *secondsSinceEpoch = @([call.arguments[@"millisecondsSinceEpoch"] integerValue] / 1000);
          notification.fireDate = [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch integerValue]];
          [[UIApplication sharedApplication] scheduleLocalNotification:notification];
      } else {
          [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
      }
    } else if([@"cancel" isEqualToString:call.method]) {
      NSNumber* id = (NSNumber*)call.arguments;
      NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
      for( int i = 0; i < [notifications count]; i++) {
          UILocalNotification* localNotification = [notifications objectAtIndex:i];
          NSNumber *userInfoNotificationId = localNotification.userInfo[@"NotificationId"];
          if([userInfoNotificationId longValue] == [id longValue]) {
              [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
          }
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
