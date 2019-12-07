#import "FlutterLocalNotificationsPlugin.h"
#import "NotificationTime.h"
#import "NotificationDetails.h"
#import "NotificationActionDetails.h"



@implementation FlutterLocalNotificationsPlugin{
    FlutterMethodChannel* _channel;
    bool displayAlert;
    bool playSound;
    bool updateBadge;
    bool initialized;
    bool launchingAppFromNotification;
    NSUserDefaults *persistentState;
    NSObject<FlutterPluginRegistrar> *_registrar;
    NSString *launchPayload;
    UILocalNotification *launchNotification;
}

NSString *const INITIALIZE_METHOD = @"initialize";
NSString *const INITIALIZED_HEADLESS_SERVICE_METHOD = @"initializedHeadlessService";
NSString *const SHOW_METHOD = @"show";
NSString *const SCHEDULE_METHOD = @"schedule";
NSString *const PERIODICALLY_SHOW_METHOD = @"periodicallyShow";
NSString *const SHOW_DAILY_AT_TIME_METHOD = @"showDailyAtTime";
NSString *const SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD = @"showWeeklyAtDayAndTime";
NSString *const CANCEL_METHOD = @"cancel";
NSString *const CANCEL_ALL_METHOD = @"cancelAll";
NSString *const PENDING_NOTIFICATIONS_REQUESTS_METHOD = @"pendingNotificationRequests";
NSString *const GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD = @"getNotificationAppLaunchDetails";
NSString *const CHANNEL = @"dexterous.com/flutter/local_notifications";
NSString *const CALLBACK_CHANNEL = @"dexterous.com/flutter/local_notifications_background";
NSString *const ON_NOTIFICATION_METHOD = @"onNotification";
NSString *const DID_RECEIVE_LOCAL_NOTIFICATION = @"didReceiveLocalNotification";

NSString *const DAY = @"day";

NSString *const REQUEST_SOUND_PERMISSION = @"requestSoundPermission";
NSString *const REQUEST_ALERT_PERMISSION = @"requestAlertPermission";
NSString *const REQUEST_BADGE_PERMISSION = @"requestBadgePermission";
NSString *const DEFAULT_PRESENT_ALERT = @"defaultPresentAlert";
NSString *const DEFAULT_PRESENT_SOUND = @"defaultPresentSound";
NSString *const DEFAULT_PRESENT_BADGE = @"defaultPresentBadge";
NSString *const CALLBACK_DISPATCHER = @"callbackDispatcher";
NSString *const ON_NOTIFICATION_CALLBACK_DISPATCHER = @"onNotificationCallbackDispatcher";
NSString *const PLATFORM_SPECIFICS = @"platformSpecifics";
NSString *const ID = @"id";
NSString *const TITLE = @"title";
NSString *const BODY = @"body";
NSString *const SOUND = @"sound";
NSString *const PRESENT_ALERT = @"presentAlert";
NSString *const PRESENT_SOUND = @"presentSound";
NSString *const PRESENT_BADGE = @"presentBadge";
NSString *const MILLISECONDS_SINCE_EPOCH = @"millisecondsSinceEpoch";
NSString *const REPEAT_INTERVAL = @"repeatInterval";
NSString *const REPEAT_TIME = @"repeatTime";
NSString *const HOUR = @"hour";
NSString *const MINUTE = @"minute";
NSString *const SECOND = @"second";

NSString *const NOTIFICATION_ID = @"NotificationId";
NSString *const PAYLOAD = @"payload";
NSString *const NOTIFICATION_LAUNCHED_APP = @"notificationLaunchedApp";

NSString *const ACTIONS = @"actions";

NSString *const ACTION_ICON = @"icon";
NSString *const ACTION_TITLE = @"title";
NSString *const ACTION_KEY = @"actionKey";
NSString *const ACTION_EXTRAS = @"extras";

typedef NS_ENUM(NSInteger, RepeatInterval) {
    EveryMinute,
    Hourly,
    Daily,
    Weekly
};

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL
                                     binaryMessenger:[registrar messenger]];
    
    FlutterLocalNotificationsPlugin* instance = [[FlutterLocalNotificationsPlugin alloc] initWithChannel:channel registrar:registrar];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = instance;
    }
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    
    if (self) {
        _channel = channel;
        _registrar = registrar;
        persistentState = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)pendingNotificationRequests:(FlutterResult _Nonnull)result {
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center =  [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            NSMutableArray<NSMutableDictionary<NSString *, NSObject *> *> *pendingNotificationRequests = [[NSMutableArray alloc] initWithCapacity:[requests count]];
            for (UNNotificationRequest *request in requests) {
                NSMutableDictionary *pendingNotificationRequest = [[NSMutableDictionary alloc] init];
                pendingNotificationRequest[ID] = request.content.userInfo[NOTIFICATION_ID];
                if (request.content.title != nil) {
                    pendingNotificationRequest[TITLE] = request.content.title;
                }
                if (request.content.body != nil) {
                    pendingNotificationRequest[BODY] = request.content.body;
                }
                if (request.content.userInfo[PAYLOAD] != [NSNull null]) {
                    pendingNotificationRequest[PAYLOAD] = request.content.userInfo[PAYLOAD];
                }
                [pendingNotificationRequests addObject:pendingNotificationRequest];
            }
            result(pendingNotificationRequests);
        }];
    } else {
        NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
        NSMutableArray<NSDictionary<NSString *, NSObject *> *> *pendingNotificationRequests = [[NSMutableArray alloc] initWithCapacity:[notifications count]];
        for( int i = 0; i < [notifications count]; i++) {
            UILocalNotification* localNotification = [notifications objectAtIndex:i];
            NSMutableDictionary *pendingNotificationRequest = [[NSMutableDictionary alloc] init];
            pendingNotificationRequest[ID] = localNotification.userInfo[NOTIFICATION_ID];
            if (localNotification.userInfo[TITLE] != [NSNull null]) {
                pendingNotificationRequest[TITLE] = localNotification.userInfo[TITLE];
            }
            if (localNotification.alertBody) {
                pendingNotificationRequest[BODY] = localNotification.alertBody;
            }
            if (localNotification.userInfo[PAYLOAD] != [NSNull null]) {
                pendingNotificationRequest[PAYLOAD] = localNotification.userInfo[PAYLOAD];
            }
            [pendingNotificationRequests addObject:pendingNotificationRequest];
        }
        result(pendingNotificationRequests);
    }
}

- (void)initialize:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    NSDictionary *arguments = [call arguments];
    if(arguments[DEFAULT_PRESENT_ALERT] != [NSNull null]) {
        displayAlert = [[arguments objectForKey:DEFAULT_PRESENT_ALERT] boolValue];
    }
    if(arguments[DEFAULT_PRESENT_SOUND] != [NSNull null]) {
        playSound = [[arguments objectForKey:DEFAULT_PRESENT_SOUND] boolValue];
    }
    if(arguments[DEFAULT_PRESENT_BADGE] != [NSNull null]) {
        updateBadge = [[arguments objectForKey:DEFAULT_PRESENT_BADGE] boolValue];
    }
    bool requestedSoundPermission = false;
    bool requestedAlertPermission = false;
    bool requestedBadgePermission = false;
    if (arguments[REQUEST_SOUND_PERMISSION] != [NSNull null]) {
        requestedSoundPermission = [arguments[REQUEST_SOUND_PERMISSION] boolValue];
    }
    if (arguments[REQUEST_ALERT_PERMISSION] != [NSNull null]) {
        requestedAlertPermission = [arguments[REQUEST_ALERT_PERMISSION] boolValue];
    }
    if (arguments[REQUEST_BADGE_PERMISSION] != [NSNull null]) {
        requestedBadgePermission = [arguments[REQUEST_BADGE_PERMISSION] boolValue];
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
            if(self->launchPayload != nil) {
                [self handleSelectNotification:self->launchPayload];
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
            [self handleSelectNotification:payload];
        }
        result(@YES);
    }
    initialized = true;
}

- (void)showNotification:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    NotificationDetails *notificationDetails = [[NotificationDetails alloc]init];
    notificationDetails.id = call.arguments[ID];
    if(call.arguments[TITLE] != [NSNull null]) {
        notificationDetails.title = call.arguments[TITLE];
    }
    if(call.arguments[BODY] != [NSNull null]) {
        notificationDetails.body = call.arguments[BODY];
    }
    notificationDetails.payload = call.arguments[PAYLOAD];
    notificationDetails.presentAlert = displayAlert;
    notificationDetails.presentSound = playSound;
    notificationDetails.presentBadge = updateBadge;
    
    [self readNotificationActionList:notificationDetails call:call];
    
    if(call.arguments[PLATFORM_SPECIFICS] != [NSNull null]) {
        NSDictionary *platformSpecifics = call.arguments[PLATFORM_SPECIFICS];
        
        if(platformSpecifics[PRESENT_ALERT] != [NSNull null]) {
            notificationDetails.presentAlert = [[platformSpecifics objectForKey:PRESENT_ALERT] boolValue];
        }
        if(platformSpecifics[PRESENT_SOUND] != [NSNull null]) {
            notificationDetails.presentSound = [[platformSpecifics objectForKey:PRESENT_SOUND] boolValue];
        }
        if(platformSpecifics[PRESENT_BADGE] != [NSNull null]) {
            notificationDetails.presentBadge = [[platformSpecifics objectForKey:PRESENT_BADGE] boolValue];
        }
        notificationDetails.sound = platformSpecifics[SOUND];
    }
    if([SCHEDULE_METHOD isEqualToString:call.method]) {
        notificationDetails.secondsSinceEpoch = @([call.arguments[MILLISECONDS_SINCE_EPOCH] longLongValue] / 1000);
    } else if([PERIODICALLY_SHOW_METHOD isEqualToString:call.method] || [SHOW_DAILY_AT_TIME_METHOD isEqualToString:call.method] || [SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD isEqualToString:call.method]) {
        if (call.arguments[REPEAT_TIME]) {
            NSDictionary *timeArguments = (NSDictionary *) call.arguments[REPEAT_TIME];
            notificationDetails.repeatTime = [[NotificationTime alloc] init];
            if (timeArguments[HOUR] != [NSNull null]) {
                notificationDetails.repeatTime.hour = @([timeArguments[HOUR] integerValue]);
            }
            if (timeArguments[MINUTE] != [NSNull null]) {
                notificationDetails.repeatTime.minute = @([timeArguments[MINUTE] integerValue]);
            }
            if (timeArguments[SECOND] != [NSNull null]) {
                notificationDetails.repeatTime.second = @([timeArguments[SECOND] integerValue]);
            }
        }
        if (call.arguments[DAY]) {
            notificationDetails.day = @([call.arguments[DAY] integerValue]);
        }
        notificationDetails.repeatInterval = @([call.arguments[REPEAT_INTERVAL] integerValue]);
    }
    if(@available(iOS 10.0, *)) {
        [self showUserNotification:notificationDetails];
    } else {
        [self showLocalNotification:notificationDetails];
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
                break;
            }
        }
    }
    result(nil);
}

- (void)cancelAllNotifications:(FlutterResult _Nonnull) result {
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center =  [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    result(nil);
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([INITIALIZE_METHOD isEqualToString:call.method]) {
        [self initialize:call result:result];
    } else if ([SHOW_METHOD isEqualToString:call.method] || [SCHEDULE_METHOD isEqualToString:call.method] || [PERIODICALLY_SHOW_METHOD isEqualToString:call.method] || [SHOW_DAILY_AT_TIME_METHOD isEqualToString:call.method]
               || [SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD isEqualToString:call.method]) {
        [self showNotification:call result:result];
    } else if([CANCEL_METHOD isEqualToString:call.method]) {
        [self cancelNotification:call result:result];
    } else if([CANCEL_ALL_METHOD isEqualToString:call.method]) {
        [self cancelAllNotifications:result];
    } else if([GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD isEqualToString:call.method]) {
        NSString *payload;
        if(launchNotification != nil) {
            payload = launchNotification.userInfo[PAYLOAD];
        } else {
            payload = launchPayload;
        }
        NSDictionary *notificationAppLaunchDetails = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:launchingAppFromNotification], NOTIFICATION_LAUNCHED_APP, payload, PAYLOAD, nil];
        result(notificationAppLaunchDetails);
    } else if([INITIALIZED_HEADLESS_SERVICE_METHOD isEqualToString:call.method]) {
        result(nil);
    } else if([PENDING_NOTIFICATIONS_REQUESTS_METHOD isEqualToString:call.method]) {
        [self pendingNotificationRequests:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSDictionary*)buildUserDict:(NSNumber *)id title:(NSString *)title presentAlert:(bool)presentAlert presentSound:(bool)presentSound presentBadge:(bool)presentBadge payload:(NSString *)payload {
    NSDictionary *userDict =[NSDictionary dictionaryWithObjectsAndKeys:id, NOTIFICATION_ID, title, TITLE, [NSNumber numberWithBool:presentAlert], PRESENT_ALERT, [NSNumber numberWithBool:presentSound], PRESENT_SOUND, [NSNumber numberWithBool:presentBadge], PRESENT_BADGE, payload, PAYLOAD, nil];
    return userDict;
}

- (void) readNotificationActionList:(NotificationDetails *) notificationDetails call:(FlutterMethodCall * _Nonnull)call {
    if(call.arguments[ACTIONS] == [NSNull null]) {
        return;
    }
    
    NSArray<NSDictionary<NSString *, NSObject *> *> *rawActionList = (NSArray<NSDictionary<NSString *, NSObject *> *> *) call.arguments[ACTIONS];
    
    notificationDetails.actions = [NSMutableArray new];
    
    for (NSDictionary<NSString *, NSObject *> * rawAction in rawActionList) {
        NotificationActionDetails* action = [self readNotificationActionDetails:rawAction];
        if (action != nil) {
            [notificationDetails.actions addObject:action];
        }
    }
    
}

- (NotificationActionDetails*)readNotificationActionDetails:(NSDictionary<NSString *, NSObject *> *) action {
    if (action == nil) {
        return nil;
    }

    NotificationActionDetails *actionDetail = [NotificationActionDetails new];
    actionDetail.title = (NSString*) action[ACTION_TITLE];
    actionDetail.actionKey = (NSString*) action[ACTION_KEY];
    actionDetail.extras = (NSDictionary<NSString *, NSString *>*) action[ACTION_EXTRAS];
    
    return actionDetail;
}

- (void) buildNotificationActions:(NotificationDetails *) notificationDetails center:(UNUserNotificationCenter * _Nonnull)center content:(UNMutableNotificationContent * _Nonnull)content API_AVAILABLE(ios(10.0)) {
    if (notificationDetails.actions == nil) {
        return;
    }

    NSMutableString *categoryName = [NSMutableString new];
    [categoryName appendString:@"category_"];
    
    NSMutableDictionary *userInfo = [content.userInfo mutableCopy];
    userInfo[ACTION_EXTRAS] = [NSMutableDictionary new];
    
    // I need to build the notification actions list
    NSMutableArray<NotificationActionDetails*> *actions = notificationDetails.actions;
    NSMutableArray<UNNotificationAction *> *unActions = [[NSMutableArray alloc] initWithCapacity:[actions count]];
    for ( int i = 0; i < [actions count]; i++) {
        NotificationActionDetails *actionDetail = [actions objectAtIndex:i];
        UNNotificationAction *unAction = [UNNotificationAction
                                          actionWithIdentifier:actionDetail.actionKey
                                          title:actionDetail.title
                                          options:UNNotificationActionOptionForeground];
        unActions[i] = unAction;
        userInfo[ACTION_EXTRAS][actionDetail.actionKey] = actionDetail.extras;
        
        [categoryName appendString:actionDetail.actionKey];
    }
    
    // I create a category with the actions that I'm using and I set it on the NotificationCenter
    UNNotificationCategory *category = [UNNotificationCategory
                                        categoryWithIdentifier:categoryName
                                        actions:unActions intentIdentifiers:@[]
                                        options:UNNotificationCategoryOptionNone];
    
    NSSet *categories = [NSSet setWithObject:category];
    [center setNotificationCategories:categories];
    content.categoryIdentifier = categoryName;
    content.userInfo = userInfo;
}

- (void) showUserNotification:(NotificationDetails *) notificationDetails NS_AVAILABLE_IOS(10.0) {
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    UNNotificationTrigger *trigger;
    content.title = notificationDetails.title;
    content.body = notificationDetails.body;
    if(notificationDetails.presentSound) {
        if(!notificationDetails.sound || [notificationDetails.sound isKindOfClass:[NSNull class]]) {
            content.sound = UNNotificationSound.defaultSound;
        } else {
            content.sound = [UNNotificationSound soundNamed:notificationDetails.sound];
        }
    }
    content.userInfo = [self buildUserDict:notificationDetails.id title:notificationDetails.title presentAlert:notificationDetails.presentAlert presentSound:notificationDetails.presentSound presentBadge:notificationDetails.presentBadge payload:notificationDetails.payload];
    if(notificationDetails.secondsSinceEpoch == nil) {
        NSTimeInterval timeInterval = 0.1;
        Boolean repeats = NO;
        if(notificationDetails.repeatInterval != nil) {
            switch([notificationDetails.repeatInterval integerValue]) {
                case EveryMinute:
                    timeInterval = 60;
                    break;
                case Hourly:
                    timeInterval = 60 * 60;
                    break;
                case Daily:
                    timeInterval = 60 * 60 * 24;
                    break;
                case Weekly:
                    timeInterval = 60 * 60 * 24 * 7;
                    break;
            }
            repeats = YES;
        }
        if (notificationDetails.repeatTime != nil) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setCalendar:calendar];
            if (notificationDetails.day != nil) {
                [dateComponents setWeekday:[notificationDetails.day integerValue]];
            }
            [dateComponents setHour:[notificationDetails.repeatTime.hour integerValue]];
            [dateComponents setMinute:[notificationDetails.repeatTime.minute integerValue]];
            [dateComponents setSecond:[notificationDetails.repeatTime.second integerValue]];
            trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats: repeats];
        } else {
            trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval
                                                                         repeats:repeats];
        }
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[notificationDetails.secondsSinceEpoch longLongValue]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents    = [calendar components:(NSCalendarUnitYear  |
                                                                    NSCalendarUnitMonth |
                                                                    NSCalendarUnitDay   |
                                                                    NSCalendarUnitHour  |
                                                                    NSCalendarUnitMinute|
                                                                    NSCalendarUnitSecond) fromDate:date];
        trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:false];
    }
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [self buildNotificationActions:notificationDetails center:center content:content];
    
    UNNotificationRequest* notificationRequest = [UNNotificationRequest
                                                  requestWithIdentifier:[notificationDetails.id stringValue] content:content trigger:trigger];
    
    [center addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to Add Notification Request");
        }
    }];
    
}

- (void) showLocalNotification:(NotificationDetails *) notificationDetails {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = notificationDetails.body;
    if(@available(iOS 8.2, *)) {
        notification.alertTitle = notificationDetails.title;
    }
    
    if(notificationDetails.presentSound) {
        if(!notificationDetails.sound || [notificationDetails.sound isKindOfClass:[NSNull class]]){
            notification.soundName = UILocalNotificationDefaultSoundName;
        } else {
            notification.soundName = notificationDetails.sound;
        }
    }
    
    notification.userInfo = [self buildUserDict:notificationDetails.id title:notificationDetails.title presentAlert:notificationDetails.presentAlert presentSound:notificationDetails.presentSound presentBadge:notificationDetails.presentBadge payload:notificationDetails.payload];
    if(notificationDetails.secondsSinceEpoch == nil) {
        if(notificationDetails.repeatInterval != nil) {
            NSTimeInterval timeInterval = 0;
            
            switch([notificationDetails.repeatInterval integerValue]) {
                case EveryMinute:
                    timeInterval = 60;
                    notification.repeatInterval = NSCalendarUnitMinute;
                    break;
                case Hourly:
                    timeInterval = 60 * 60;
                    notification.repeatInterval = NSCalendarUnitHour;
                    break;
                case Daily:
                    timeInterval = 60 * 60 * 24;
                    notification.repeatInterval = NSCalendarUnitDay;
                    break;
                case Weekly:
                    timeInterval = 60 * 60 * 24 * 7;
                    notification.repeatInterval = NSCalendarUnitWeekOfYear;
                    break;
            }
            if (notificationDetails.repeatTime != nil) {
                NSDate *now = [NSDate date];
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
                NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
                [dateComponents setHour:[notificationDetails.repeatTime.hour integerValue]];
                [dateComponents setMinute:[notificationDetails.repeatTime.minute integerValue]];
                [dateComponents setSecond:[notificationDetails.repeatTime.second integerValue]];
                if(notificationDetails.day != nil) {
                    [dateComponents setWeekday:[notificationDetails.day integerValue]];
                }
                notification.fireDate = [calendar dateFromComponents:dateComponents];
            } else {
                notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
            }
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            return;
        }
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    } else {
        notification.fireDate = [NSDate dateWithTimeIntervalSince1970:[notificationDetails.secondsSinceEpoch longLongValue]];
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

- (void)handleSelectNotification:(NSString *)payload {
    [_channel invokeMethod:@"selectNotification" arguments:payload];
}

- (void)notifyActionTapped:(NSString *)actionKey extras:(NSDictionary *)extras {
    NSMutableDictionary<NSString*, NSObject*> *arguments = [[NSMutableDictionary<NSString*, NSObject*> alloc] init];
    arguments[ACTION_KEY] = actionKey;
    arguments[ACTION_EXTRAS] = extras;
    [_channel invokeMethod:@"onNotificationActionTapped" arguments:arguments];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        NSString *payload = (NSString *) response.notification.request.content.userInfo[PAYLOAD];
        if(initialized) {
            [self handleSelectNotification:payload];
        } else {
            launchPayload = payload;
            launchingAppFromNotification = true;
        }
    }
    else {
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        NSDictionary *extras = (NSDictionary*) userInfo[ACTION_EXTRAS][response.actionIdentifier];
        
        [self notifyActionTapped:response.actionIdentifier extras:extras];
    }
    
    completionHandler();
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil) {
        launchNotification = (UILocalNotification *)[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        launchingAppFromNotification = launchNotification != nil;
    }
    
    return YES;
}

- (void)application:(UIApplication*)application
didReceiveLocalNotification:(UILocalNotification*)notification {
    if(@available(iOS 10.0, *)) {
        return;
    }
    
    NSMutableDictionary *arguments = [[NSMutableDictionary alloc] init];
    arguments[ID]= notification.userInfo[NOTIFICATION_ID];
    if (notification.userInfo[TITLE] != [NSNull null]) {
        arguments[TITLE] =notification.userInfo[TITLE];
    }
    if (notification.alertBody != nil) {
        arguments[BODY] = notification.alertBody;
    }
    if (notification.userInfo[PAYLOAD] != [NSNull null]) {
        arguments[PAYLOAD] =notification.userInfo[PAYLOAD];
    }
    [_channel invokeMethod:DID_RECEIVE_LOCAL_NOTIFICATION arguments:arguments];
}

@end
