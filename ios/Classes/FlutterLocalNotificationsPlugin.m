#import "FlutterLocalNotificationsPlugin.h"

static bool appResumingFromBackground;

@implementation FlutterLocalNotificationsPlugin

FlutterMethodChannel* channel;
NSString *const INITIALIZE_METHOD = @"initialize";
NSString *const SHOW_METHOD = @"show";
NSString *const SCHEDULE_METHOD = @"schedule";
NSString *const CANCEL_METHOD = @"cancel";
NSString *const CHANNEL = @"dexterous.com/flutter/local_notifications";

NSString *const REQUEST_SOUND_PERMISSION = @"requestSoundPermission";
NSString *const REQUEST_ALERT_PERMISSION = @"requestAlertPermission";
NSString *const REQUEST_BADGE_PERMISSION = @"requestBadgePermission";
NSString *const DEFAULT_PRESENT_ALERT = @"defaultPresentAlert";
NSString *const DEFAULT_PRESENT_SOUND = @"defaultPresentSound";
NSString *const DEFAULT_PRESENT_BADGE = @"defaultPresentBadge";
NSString *const PLATFORM_SPECIFICS = @"platformSpecifics";
NSString *const ID = @"id";
NSString *const TITLE = @"title";
NSString *const BODY = @"body";
NSString *const SOUND = @"sound";
NSString *const PRESENT_ALERT = @"presentAlert";
NSString *const PRESENT_SOUND = @"presentSound";
NSString *const PRESENT_BADGE = @"presentBadge";
NSString *const MILLISECONDS_SINCE_EPOCH = @"millisecondsSinceEpoch";

NSString *const NOTIFICATION_ID = @"NotificationId";
NSString *const PAYLOAD = @"payload";
NSString *launchPayload;
bool displayAlert;
bool playSound;
bool updateBadge;
bool initialized;
+ (bool) resumingFromBackground { return appResumingFromBackground; }
UILocalNotification *launchNotification;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    channel = [FlutterMethodChannel
               methodChannelWithName:CHANNEL
               binaryMessenger:[registrar messenger]];
    FlutterLocalNotificationsPlugin* instance = [[FlutterLocalNotificationsPlugin alloc] init];
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = instance;
    }
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}


- (void)initialize:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    appResumingFromBackground = false;
    NSDictionary *arguments = [call arguments];
    NSDictionary *platformSpecifics = arguments[PLATFORM_SPECIFICS];
    if(arguments[DEFAULT_PRESENT_ALERT] != [NSNull null]) {
        displayAlert = [[platformSpecifics objectForKey:DEFAULT_PRESENT_ALERT] boolValue];
    }
    if(arguments[DEFAULT_PRESENT_SOUND] != [NSNull null]) {
        playSound = [[platformSpecifics objectForKey:DEFAULT_PRESENT_SOUND] boolValue];
    }
    if(arguments[DEFAULT_PRESENT_BADGE] != [NSNull null]) {
        updateBadge = [[platformSpecifics objectForKey:DEFAULT_PRESENT_BADGE] boolValue];
    }
    bool requestedSoundPermission = false;
    bool requestedAlertPermission = false;
    bool requestedBadgePermission = false;
    if (platformSpecifics[REQUEST_SOUND_PERMISSION] != [NSNull null]) {
        requestedSoundPermission = [platformSpecifics[REQUEST_SOUND_PERMISSION] boolValue];
    }
    if (platformSpecifics[REQUEST_ALERT_PERMISSION] != [NSNull null]) {
        requestedAlertPermission = [platformSpecifics[REQUEST_ALERT_PERMISSION] boolValue];
    }
    if (platformSpecifics[REQUEST_BADGE_PERMISSION] != [NSNull null]) {
        requestedBadgePermission = [platformSpecifics[REQUEST_BADGE_PERMISSION] boolValue];
    }
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions authorizationOptions = 0;
        if (requestedSoundPermission) {
            authorizationOptions += UNAuthorizationOptionSound;
        }
        if (requestedAlertPermission) {
            authorizationOptions += UNAuthorizationOptionAlert;
        }
        if (requestedBadgePermission) {
            authorizationOptions += UNAuthorizationOptionBadge;
        }
        [center requestAuthorizationWithOptions:(authorizationOptions) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(launchPayload != nil) {
                [FlutterLocalNotificationsPlugin handleSelectNotification:launchPayload];
            }
            result(@(granted));
        }];
    } else {
        UIUserNotificationType notificationTypes = 0;
        if (requestedSoundPermission) {
            notificationTypes |= UIUserNotificationTypeSound;
        }
        if (requestedAlertPermission) {
            notificationTypes |= UIUserNotificationTypeAlert;
        }
        if (requestedBadgePermission) {
            notificationTypes |= UIUserNotificationTypeBadge;
        }
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        if(launchNotification != nil) {
            NSString *payload = launchNotification.userInfo[PAYLOAD];
            [channel invokeMethod:@"selectNotification" arguments:payload];
        }
        result(@true);
    }
    initialized = true;
}

- (void)showNotification:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    NSNumber *id = call.arguments[ID];
    NSString *title = call.arguments[TITLE];
    NSString *body = call.arguments[BODY];
    NSString *payload = call.arguments[PAYLOAD];
    NSDictionary *platformSpecifics = call.arguments[PLATFORM_SPECIFICS];
    bool presentAlert = displayAlert;
    bool presentSound = playSound;
    bool presentBadge = updateBadge;
    
    if(platformSpecifics[PRESENT_ALERT] != [NSNull null]) {
        presentAlert = [[platformSpecifics objectForKey:PRESENT_ALERT] boolValue];
    }
    if(platformSpecifics[PRESENT_SOUND] != [NSNull null]) {
        presentSound = [[platformSpecifics objectForKey:PRESENT_SOUND] boolValue];
    }
    if(platformSpecifics[PRESENT_BADGE] != [NSNull null]) {
        presentBadge = [[platformSpecifics objectForKey:PRESENT_BADGE] boolValue];
    }
    NSString *sound = platformSpecifics[SOUND];
    NSNumber *secondsSinceEpoch;
    if([SCHEDULE_METHOD isEqualToString:call.method]) {
        secondsSinceEpoch = @([call.arguments[MILLISECONDS_SINCE_EPOCH] integerValue] / 1000);
    }
    if(@available(iOS 10.0, *)) {
        [self showUserNotification:id title:title body:body secondsSinceEpoch:secondsSinceEpoch presentAlert:presentAlert  presentSound:presentSound presentBadge:presentBadge sound:sound payload:payload];
    } else {
        [self showLocalNotification:id title:title body:body secondsSinceEpoch:secondsSinceEpoch presentAlert:presentAlert  presentSound:presentSound presentBadge:presentBadge sound:sound payload:payload];
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
            NSNumber *userInfoNotificationId = localNotification.userInfo[NOTIFICATION_ID];
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

- (NSDictionary*)buildUserDict:(NSNumber *)id title:(NSString *)title presentAlert:(bool)presentAlert presentSound:(bool)presentSound presentBadge:(bool)presentBadge payload:(NSString *)payload {
    NSDictionary *userDict =[NSDictionary dictionaryWithObjectsAndKeys:id, NOTIFICATION_ID, title, TITLE, [NSNumber numberWithBool:presentAlert], PRESENT_ALERT, [NSNumber numberWithBool:presentSound], PRESENT_SOUND, [NSNumber numberWithBool:presentBadge], PRESENT_BADGE, payload, PAYLOAD, nil];
    return userDict;
}

- (void) showUserNotification:(NSNumber *)id title:(NSString *)title body:(NSString *)body secondsSinceEpoch:(NSNumber *)secondsSinceEpoch presentAlert:(bool)presentAlert presentSound:(bool)presentSound presentBadge:(bool)presentBadge sound:(NSString*)sound payload:(NSString *)payload {
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        UNNotificationTrigger *trigger;
        content.title = title;
        content.body = body;
        if(presentSound) {
            if(!sound || [sound isKindOfClass:[NSNull class]]) {
                content.sound = UNNotificationSound.defaultSound;
            } else {
                content.sound = [UNNotificationSound soundNamed:sound];
            }
        }
        content.userInfo = [self buildUserDict:id title:title presentAlert:presentAlert presentSound:presentSound presentBadge:presentBadge payload:payload];
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

- (void) showLocalNotification:(NSNumber *)id title:(NSString *)title body:(NSString *)body secondsSinceEpoch:(NSNumber *)secondsSinceEpoch presentAlert:(bool)presentAlert presentSound:(bool)presentSound presentBadge:(bool)presentBadge sound:(NSString*)sound payload:(NSString *)payload {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = body;
    if(@available(iOS 8.2, *)) {
        notification.alertTitle = title;
    }
    if(presentSound) {
        if(!sound || [sound isKindOfClass:[NSNull class]]){
            notification.soundName = UILocalNotificationDefaultSoundName;
        } else {
            notification.soundName = sound;
        }
    }
    notification.userInfo = [self buildUserDict:id title:title presentAlert:presentAlert presentSound:presentSound presentBadge:presentBadge payload:payload];
    if(secondsSinceEpoch == nil) {
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    } else {
        notification.fireDate = [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch integerValue]];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification :(UNNotification *)notification withCompletionHandler :(void (^)(UNNotificationPresentationOptions))completionHandler NS_AVAILABLE_IOS(10.0) {
    UNNotificationPresentationOptions presentationOptions = 0;
    NSNumber *presentAlertValue = (NSNumber*)notification.request.content.userInfo[PRESENT_ALERT];
    NSNumber *presentSoundValue = (NSNumber*)notification.request.content.userInfo[PRESENT_SOUND];
    NSNumber *presentBadgeValue = (NSNumber*)notification.request.content.userInfo[PRESENT_BADGE];
    bool presentAlert = [presentAlertValue boolValue];
    bool presentSound = [presentSoundValue boolValue];
    bool presentBadge = [presentBadgeValue boolValue];
    if(presentAlert) {
        presentationOptions |= UNNotificationPresentationOptionAlert;
    }
    if(presentSound){
        presentationOptions |= UNNotificationPresentationOptionSound;
    }
    if(presentBadge) {
        presentationOptions |= UNNotificationPresentationOptionBadge;
    }
    completionHandler(presentationOptions);
}

+ (void)handleSelectNotification:(NSString *)payload {
    [channel invokeMethod:@"selectNotification" arguments:payload];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        
        NSString *payload = (NSString *) response.notification.request.content.userInfo[PAYLOAD];
        if(initialized) {
            [FlutterLocalNotificationsPlugin handleSelectNotification:payload];
        } else {
            launchPayload = payload;
        }
        
    }
}
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil) {
        launchNotification = (UILocalNotification *)[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    }
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    appResumingFromBackground = true;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    appResumingFromBackground = false;
}

@end
