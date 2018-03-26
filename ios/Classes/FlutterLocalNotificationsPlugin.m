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
        
        if(@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            UNAuthorizationOptions authorizationOptions = 0;
            if (platformSpecifics[@"sound"]) {
                authorizationOptions += UNAuthorizationOptionSound;
            }
            if (platformSpecifics[@"alert"]) {
                authorizationOptions += UNAuthorizationOptionAlert;
            }
            if (platformSpecifics[@"badge"]) {
                authorizationOptions += UNAuthorizationOptionBadge;
            }
            
            [center requestAuthorizationWithOptions:(authorizationOptions) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                result(@(granted));
            }];
        } else {
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
        }
        
    } else if ([@"show" isEqualToString:call.method] || [@"schedule" isEqualToString:call.method]) {
        NSNumber *id = call.arguments[@"id"];
        
        NSString *title = call.arguments[@"title"];
        NSString *body = call.arguments[@"body"];
        NSNumber *secondsSinceEpoch;
        if([@"schedule" isEqualToString:call.method]) {
            secondsSinceEpoch = @([call.arguments[@"millisecondsSinceEpoch"] integerValue] / 1000);
        }
        if(@available(iOS 10.0, *)) {
            [self showUserNotification:id title:title body:body secondsSinceEpoch:secondsSinceEpoch];
        } else {
            [self showLocalNotification:id title:title body:body secondsSinceEpoch:secondsSinceEpoch];
        }
        result(nil);
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
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) showUserNotification:(NSNumber *)id title:(NSString *)title body:(NSString *)body secondsSinceEpoch:(NSNumber *)secondsSinceEpoch {
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        UNNotificationTrigger *trigger;
        content.title = title;
        content.body = body;
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:id, @"NotificationId", title, @"title", nil];
        content.userInfo = infoDict;
        if(secondsSinceEpoch == nil) {
            trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1
                                                                         repeats:NO];
        } else {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch integerValue]];
            NSCalendar *currentCalendar = [NSCalendar currentCalendar];
            NSDateComponents *dateComponents    = [currentCalendar components:(NSCalendarUnitYear  |
                                                                               NSCalendarUnitMonth |
                                                                               NSCalendarUnitDay   |
                                                                               NSCalendarUnitHour  |
                                                                               NSCalendarUnitMinute|
                                                                               NSCalendarUnitSecond) fromDate:date];
            trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:false];
        }
        UNNotificationRequest* notificationRequest = [UNNotificationRequest
                                                      requestWithIdentifier:[id stringValue] content:content trigger:trigger];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Unable to Add Notification Request");
            }
        }];
    }
}

- (void) showLocalNotification:(NSNumber *)id title:(NSString *)title body:(NSString *)body secondsSinceEpoch:(NSNumber *)secondsSinceEpoch {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = body;
    if(@available(iOS 8.2, *)) {
        notification.alertTitle = title;
    }
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:id, @"NotificationId", title, @"title", nil];
    notification.userInfo = infoDict;
    if(secondsSinceEpoch == nil) {
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    } else {
        notification.fireDate = [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch integerValue]];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
