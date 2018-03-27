#import "FlutterLocalNotificationsPlugin.h"

@implementation FlutterLocalNotificationsPlugin

NSString *const INITIALIZE_METHOD = @"initialize";
NSString *const SHOW_METHOD = @"show";
NSString *const SCHEDULE_METHOD = @"schedule";
NSString *const CANCEL_METHOD = @"cancel";

NSString *const REQUEST_SOUND_PERMISSION = @"requestSoundPermission";
NSString *const REQUEST_ALERT_PERMISSION = @"requestAlertPermission";
NSString *const REQUEST_BADGE_PERMISSION = @"requestBadgePermission";
NSString *const PRESENT_ALERT = @"presentAlert";
NSString *const PRESENT_SOUND = @"presentSound";
NSString *const PRESENT_BADGE = @"presentBadge";
NSString *const PLATFORM_SPECIFICS = @"platformSpecifics";
NSString *const CHANNEL = @"dexterous.com/flutter/local_notifications";
NSString *const ID = @"id";
NSString *const TITLE = @"title";
NSString *const BODY = @"body";
NSString *const MILLISECONDS_SINCE_EPOCH = @"millisecondsSinceEpoch";

NSString *const USER_INFO_NOTIFICATION_ID = @"NotificationId";
NSString *const USER_INFO_TITLE = @"title";

bool displayAlert;
bool playSound;
bool updateBadge;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL
                                     binaryMessenger:[registrar messenger]];
    FlutterLocalNotificationsPlugin* instance = [[FlutterLocalNotificationsPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}


- (void)initialize:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    NSDictionary *arguments = [call arguments];
    NSDictionary *platformSpecifics = arguments[PLATFORM_SPECIFICS];
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions authorizationOptions = 0;
        if (platformSpecifics[REQUEST_SOUND_PERMISSION]) {
            authorizationOptions += UNAuthorizationOptionSound;
        }
        if (platformSpecifics[REQUEST_ALERT_PERMISSION]) {
            authorizationOptions += UNAuthorizationOptionAlert;
        }
        if (platformSpecifics[REQUEST_BADGE_PERMISSION]) {
            authorizationOptions += UNAuthorizationOptionBadge;
        }
        displayAlert = platformSpecifics[PRESENT_ALERT];
        playSound = platformSpecifics[PRESENT_SOUND];
        updateBadge = platformSpecifics[PRESENT_BADGE];
        [center requestAuthorizationWithOptions:(authorizationOptions) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            result(@(granted));
        }];
    } else {
        UIUserNotificationType notificationTypes = 0;
        if (platformSpecifics[REQUEST_SOUND_PERMISSION]) {
            notificationTypes |= UIUserNotificationTypeSound;
        }
        if (platformSpecifics[REQUEST_ALERT_PERMISSION]) {
            notificationTypes |= UIUserNotificationTypeAlert;
        }
        if (platformSpecifics[REQUEST_BADGE_PERMISSION]) {
            notificationTypes |= UIUserNotificationTypeBadge;
        }
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        result(@true);
    }
}

- (void)showNotification:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    NSNumber *id = call.arguments[ID];
    NSString *title = call.arguments[TITLE];
    NSString *body = call.arguments[BODY];
    NSNumber *secondsSinceEpoch;
    if([SCHEDULE_METHOD isEqualToString:call.method]) {
        secondsSinceEpoch = @([call.arguments[MILLISECONDS_SINCE_EPOCH] integerValue] / 1000);
    }
    if(@available(iOS 10.0, *)) {
        [self showUserNotification:id title:title body:body secondsSinceEpoch:secondsSinceEpoch];
    } else {
        [self showLocalNotification:id title:title body:body secondsSinceEpoch:secondsSinceEpoch];
    }
    result(nil);
}

- (void)cancelNotification:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    NSNumber* id = (NSNumber*)call.arguments;
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center =  [UNUserNotificationCenter currentNotificationCenter];
        NSArray *idsToRemove = [[NSArray alloc] initWithObjects:[id stringValue], nil];
        [center removePendingNotificationRequestsWithIdentifiers:idsToRemove];
        [center removeDeliveredNotificationsWithIdentifiers:idsToRemove];
        
    } else {
        NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
        for( int i = 0; i < [notifications count]; i++) {
            UILocalNotification* localNotification = [notifications objectAtIndex:i];
            NSNumber *userInfoNotificationId = localNotification.userInfo[USER_INFO_NOTIFICATION_ID];
            if([userInfoNotificationId longValue] == [id longValue]) {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }
    }
    result(nil);
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([INITIALIZE_METHOD isEqualToString:call.method]) {
        [self initialize:call result:result];
        
    } else if ([SHOW_METHOD isEqualToString:call.method] || [SCHEDULE_METHOD isEqualToString:call.method]) {
        [self showNotification:call result:result];
    } else if([CANCEL_METHOD isEqualToString:call.method]) {
        [self cancelNotification:call result:result];
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
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:id, USER_INFO_NOTIFICATION_ID, title, USER_INFO_TITLE, nil];
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
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:id, USER_INFO_NOTIFICATION_ID, title, USER_INFO_TITLE, nil];
    notification.userInfo = infoDict;
    if(secondsSinceEpoch == nil) {
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    } else {
        notification.fireDate = [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch integerValue]];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}



- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification :(UNNotification *)notification withCompletionHandler :(void (^)(UNNotificationPresentationOptions))completionHandler NS_AVAILABLE_IOS(10.0) {
    UNNotificationPresentationOptions presentationOptions = 0;
    if(displayAlert) {
        presentationOptions |= UNNotificationPresentationOptionAlert;
    }
    
    if(playSound){
        presentationOptions |= UNNotificationPresentationOptionSound;
    }
    
    if(updateBadge) {
        presentationOptions |= UNNotificationPresentationOptionBadge;
    }
    completionHandler(presentationOptions);
}

@end
