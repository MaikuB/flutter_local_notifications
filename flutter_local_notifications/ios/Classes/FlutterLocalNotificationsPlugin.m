#import "FlutterLocalNotificationsPlugin.h"

@implementation FlutterLocalNotificationsPlugin{
    FlutterMethodChannel* _channel;
    bool _displayAlert;
    bool _playSound;
    bool _updateBadge;
    bool _initialized;
    bool _launchingAppFromNotification;
    NSUserDefaults *_persistentState;
    NSObject<FlutterPluginRegistrar> *_registrar;
    NSString *_launchPayload;
    UILocalNotification *_launchNotification;
}

NSString *const INITIALIZE_METHOD = @"initialize";
NSString *const SHOW_METHOD = @"show";
NSString *const SCHEDULE_METHOD = @"schedule";
NSString *const ZONED_SCHEDULE_METHOD = @"zonedSchedule";
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
NSString *const REQUEST_PERMISSIONS_METHOD = @"requestPermissions";

NSString *const DAY = @"day";

NSString *const REQUEST_SOUND_PERMISSION = @"requestSoundPermission";
NSString *const REQUEST_ALERT_PERMISSION = @"requestAlertPermission";
NSString *const REQUEST_BADGE_PERMISSION = @"requestBadgePermission";
NSString *const SOUND_PERMISSION = @"sound";
NSString *const ALERT_PERMISSION = @"alert";
NSString *const BADGE_PERMISSION = @"badge";
NSString *const DEFAULT_PRESENT_ALERT = @"defaultPresentAlert";
NSString *const DEFAULT_PRESENT_SOUND = @"defaultPresentSound";
NSString *const DEFAULT_PRESENT_BADGE = @"defaultPresentBadge";
NSString *const CALLBACK_DISPATCHER = @"callbackDispatcher";
NSString *const ON_NOTIFICATION_CALLBACK_DISPATCHER = @"onNotificationCallbackDispatcher";
NSString *const PLATFORM_SPECIFICS = @"platformSpecifics";
NSString *const ID = @"id";
NSString *const TITLE = @"title";
NSString *const SUBTITLE = @"subtitle";
NSString *const BODY = @"body";
NSString *const SOUND = @"sound";
NSString *const ATTACHMENTS = @"attachments";
NSString *const ATTACHMENT_IDENTIFIER = @"identifier";
NSString *const ATTACHMENT_FILE_PATH = @"filePath";
NSString *const THREAD_IDENTIFIER = @"threadIdentifier";
NSString *const PRESENT_ALERT = @"presentAlert";
NSString *const PRESENT_SOUND = @"presentSound";
NSString *const PRESENT_BADGE = @"presentBadge";
NSString *const BADGE_NUMBER = @"badgeNumber";
NSString *const MILLISECONDS_SINCE_EPOCH = @"millisecondsSinceEpoch";
NSString *const REPEAT_INTERVAL = @"repeatInterval";
NSString *const REPEAT_TIME = @"repeatTime";
NSString *const HOUR = @"hour";
NSString *const MINUTE = @"minute";
NSString *const SECOND = @"second";
NSString *const SCHEDULED_DATE_TIME = @"scheduledDateTime";
NSString *const TIME_ZONE_NAME = @"timeZoneName";
NSString *const MATCH_DATE_TIME_COMPONENTS = @"matchDateTimeComponents";
NSString *const UILOCALNOTIFICATION_DATE_INTERPRETATION = @"uiLocalNotificationDateInterpretation";

NSString *const NOTIFICATION_ID = @"NotificationId";
NSString *const PAYLOAD = @"payload";
NSString *const NOTIFICATION_LAUNCHED_APP = @"notificationLaunchedApp";


typedef NS_ENUM(NSInteger, RepeatInterval) {
    EveryMinute,
    Hourly,
    Daily,
    Weekly
};

typedef NS_ENUM(NSInteger, DateTimeComponents) {
    Time,
    DayOfWeekAndTime
};

typedef NS_ENUM(NSInteger, UILocalNotificationDateInterpretation) {
    AbsoluteGMTTime,
    WallClockTime
};

static FlutterError *getFlutterError(NSError *error) {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                               message:error.localizedDescription
                               details:error.domain];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL
                                     binaryMessenger:[registrar messenger]];
    
    FlutterLocalNotificationsPlugin* instance = [[FlutterLocalNotificationsPlugin alloc] initWithChannel:channel registrar:registrar];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    
    if (self) {
        _channel = channel;
        _registrar = registrar;
        _persistentState = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([INITIALIZE_METHOD isEqualToString:call.method]) {
        [self initialize:call.arguments result:result];
    } else if([SHOW_METHOD isEqualToString:call.method]) {
        [self show:call.arguments result:result];
    } else if([ZONED_SCHEDULE_METHOD isEqualToString:call.method]) {
        [self zonedSchedule:call.arguments result:result];
    } else if([SCHEDULE_METHOD isEqualToString:call.method]) {
        [self schedule:call.arguments result:result];
    } else if([PERIODICALLY_SHOW_METHOD isEqualToString:call.method]) {
        [self periodicallyShow:call.arguments result:result];
    } else if([SHOW_DAILY_AT_TIME_METHOD isEqualToString:call.method]) {
        [self showDailyAtTime:call.arguments result:result];
    } else if([SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD isEqualToString:call.method]) {
        [self showWeeklyAtDayAndTime:call.arguments result:result];
    } else if([REQUEST_PERMISSIONS_METHOD isEqualToString:call.method]) {
        [self requestPermissions:call.arguments result:result];
    } else if([CANCEL_METHOD isEqualToString:call.method]) {
        [self cancel:((NSNumber *)call.arguments) result:result];
    } else if([CANCEL_ALL_METHOD isEqualToString:call.method]) {
        [self cancelAll:result];
    } else if([GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD isEqualToString:call.method]) {
        NSString *payload;
        if(_launchNotification != nil) {
            payload = _launchNotification.userInfo[PAYLOAD];
        } else {
            payload = _launchPayload;
        }
        NSDictionary *notificationAppLaunchDetails = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:_launchingAppFromNotification], NOTIFICATION_LAUNCHED_APP, payload, PAYLOAD, nil];
        result(notificationAppLaunchDetails);
    } else if([PENDING_NOTIFICATIONS_REQUESTS_METHOD isEqualToString:call.method]) {
        [self pendingNotificationRequests:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)pendingUserNotificationRequests:(FlutterResult _Nonnull)result NS_AVAILABLE_IOS(10.0) {
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
}

- (void)pendingLocalNotificationRequests:(FlutterResult _Nonnull)result {
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

- (void)pendingNotificationRequests:(FlutterResult _Nonnull)result {
    if(@available(iOS 10.0, *)) {
        [self pendingUserNotificationRequests:result];
    } else {
        [self pendingLocalNotificationRequests:result];
    }}

- (void)initialize:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    if([self containsKey:DEFAULT_PRESENT_ALERT forDictionary:arguments]) {
        _displayAlert = [[arguments objectForKey:DEFAULT_PRESENT_ALERT] boolValue];
    }
    if([self containsKey:DEFAULT_PRESENT_SOUND forDictionary:arguments]) {
        _playSound = [[arguments objectForKey:DEFAULT_PRESENT_SOUND] boolValue];
    }
    if([self containsKey:DEFAULT_PRESENT_BADGE forDictionary:arguments]) {
        _updateBadge = [[arguments objectForKey:DEFAULT_PRESENT_BADGE] boolValue];
    }
    bool requestedSoundPermission = false;
    bool requestedAlertPermission = false;
    bool requestedBadgePermission = false;
    if([self containsKey:REQUEST_SOUND_PERMISSION forDictionary:arguments]) {
        requestedSoundPermission = [arguments[REQUEST_SOUND_PERMISSION] boolValue];
    }
    if([self containsKey:REQUEST_ALERT_PERMISSION forDictionary:arguments]) {
        requestedAlertPermission = [arguments[REQUEST_ALERT_PERMISSION] boolValue];
    }
    if([self containsKey:REQUEST_BADGE_PERMISSION forDictionary:arguments]) {
        requestedBadgePermission = [arguments[REQUEST_BADGE_PERMISSION] boolValue];
    }
    [self requestPermissionsImpl:requestedSoundPermission alertPermission:requestedAlertPermission badgePermission:requestedBadgePermission checkLaunchNotification:true result:result];
    
    _initialized = true;
}

- (void)requestPermissions:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    bool soundPermission = false;
    bool alertPermission = false;
    bool badgePermission = false;
    if([self containsKey:SOUND_PERMISSION forDictionary:arguments]) {
        soundPermission = [arguments[SOUND_PERMISSION] boolValue];
    }
    if([self containsKey:ALERT_PERMISSION forDictionary:arguments]) {
        alertPermission = [arguments[ALERT_PERMISSION] boolValue];
    }
    if([self containsKey:BADGE_PERMISSION forDictionary:arguments]) {
        badgePermission = [arguments[BADGE_PERMISSION] boolValue];
    }
    [self requestPermissionsImpl:soundPermission alertPermission:alertPermission badgePermission:badgePermission checkLaunchNotification:false result:result];
}

- (void)requestPermissionsImpl:(bool)soundPermission
               alertPermission:(bool)alertPermission
               badgePermission:(bool)badgePermission
       checkLaunchNotification:(bool)checkLaunchNotification result:(FlutterResult _Nonnull)result{
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        UNAuthorizationOptions authorizationOptions = 0;
        if (soundPermission) {
            authorizationOptions += UNAuthorizationOptionSound;
        }
        if (alertPermission) {
            authorizationOptions += UNAuthorizationOptionAlert;
        }
        if (badgePermission) {
            authorizationOptions += UNAuthorizationOptionBadge;
        }
        [center requestAuthorizationWithOptions:(authorizationOptions) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(checkLaunchNotification && self->_launchPayload != nil) {
                [self handleSelectNotification:self->_launchPayload];
            }
            result(@(granted));
        }];
    } else {
        UIUserNotificationType notificationTypes = 0;
        if (soundPermission) {
            notificationTypes |= UIUserNotificationTypeSound;
        }
        if (alertPermission) {
            notificationTypes |= UIUserNotificationTypeAlert;
        }
        if (badgePermission) {
            notificationTypes |= UIUserNotificationTypeBadge;
        }
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        if(checkLaunchNotification && _launchNotification != nil && [self isAFlutterLocalNotification:_launchNotification.userInfo]) {
            NSString *payload = _launchNotification.userInfo[PAYLOAD];
            [self handleSelectNotification:payload];
        }
        result(@YES);
    }
}

- (UILocalNotification *)buildStandardUILocalNotification:(NSDictionary *)arguments {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if([self containsKey:BODY forDictionary:arguments]) {
        notification.alertBody = arguments[BODY];
    }
    
    NSString *title;
    if([self containsKey:TITLE forDictionary:arguments]) {
        title = arguments[TITLE];
        if(@available(iOS 8.2, *)) {
            notification.alertTitle = title;
        }
    }
    
    bool presentAlert = _displayAlert;
    bool presentSound = _playSound;
    bool presentBadge = _updateBadge;
    if(arguments[PLATFORM_SPECIFICS] != [NSNull null]) {
        NSDictionary *platformSpecifics = arguments[PLATFORM_SPECIFICS];
        
        if([self containsKey:PRESENT_ALERT forDictionary:platformSpecifics]) {
            presentAlert = [[platformSpecifics objectForKey:PRESENT_ALERT] boolValue];
        }
        if([self containsKey:PRESENT_SOUND forDictionary:platformSpecifics]) {
            presentSound = [[platformSpecifics objectForKey:PRESENT_SOUND] boolValue];
        }
        if([self containsKey:PRESENT_BADGE forDictionary:platformSpecifics]) {
            presentBadge = [[platformSpecifics objectForKey:PRESENT_BADGE] boolValue];
        }
        
        if([self containsKey:BADGE_NUMBER forDictionary:platformSpecifics]) {
            notification.applicationIconBadgeNumber = [platformSpecifics[BADGE_NUMBER] integerValue];
        }
        
        if([self containsKey:SOUND forDictionary:platformSpecifics]) {
            notification.soundName = [platformSpecifics[SOUND] stringValue];
        }
    }
    
    if(presentSound && notification.soundName == nil) {
        notification.soundName = UILocalNotificationDefaultSoundName;
    }
    
    notification.userInfo = [self buildUserDict:arguments[ID] title:title presentAlert:presentAlert presentSound:presentSound presentBadge:presentBadge payload:arguments[PAYLOAD]];
    return notification;
}

- (NSString *)getIdentifier:(id)arguments {
    return [arguments[ID] stringValue];
}

- (void)show:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [self buildStandardNotificationContent:arguments result:result];
        [self addNotificationRequest:[self getIdentifier:arguments] content:content result:result trigger:nil];
    } else {
        UILocalNotification * notification = [self buildStandardUILocalNotification:arguments];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        result(nil);
    }
}

- (void)zonedSchedule:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [self buildStandardNotificationContent:arguments result:result];
        UNCalendarNotificationTrigger *trigger = [self buildUserNotificationCalendarTrigger:arguments];
        [self addNotificationRequest:[self getIdentifier:arguments] content:content result:result trigger:trigger];
        
    } else {
        UILocalNotification * notification = [self buildStandardUILocalNotification:arguments];
        NSString *scheduledDateTime  = arguments[SCHEDULED_DATE_TIME];
        NSString *timeZoneName = arguments[TIME_ZONE_NAME];
        NSNumber *matchDateComponents = arguments[MATCH_DATE_TIME_COMPONENTS];
        NSNumber *uiLocalNotificationDateInterpretation = arguments[UILOCALNOTIFICATION_DATE_INTERPRETATION];
        NSTimeZone *timezone = [NSTimeZone timeZoneWithName:timeZoneName];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [dateFormatter setTimeZone:timezone];
        NSDate *date = [dateFormatter dateFromString:scheduledDateTime];
        notification.fireDate = date;
        if (uiLocalNotificationDateInterpretation != nil) {
            if([uiLocalNotificationDateInterpretation integerValue] == AbsoluteGMTTime) {
                notification.timeZone = nil;
            } else if([uiLocalNotificationDateInterpretation integerValue] == WallClockTime) {
                notification.timeZone = timezone;
            }
        }
        if(matchDateComponents != nil) {
            if([matchDateComponents integerValue] == Time) {
                notification.repeatInterval = NSCalendarUnitDay;
            } else if([matchDateComponents integerValue] == DayOfWeekAndTime) {
                notification.repeatInterval = NSCalendarUnitWeekOfYear;
            }
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        result(nil);
    }
}

- (void)schedule:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    NSNumber *secondsSinceEpoch = @([arguments[MILLISECONDS_SINCE_EPOCH] longLongValue] / 1000);
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [self buildStandardNotificationContent:arguments result:result];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch longLongValue]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear  |
                                                                 NSCalendarUnitMonth |
                                                                 NSCalendarUnitDay   |
                                                                 NSCalendarUnitHour  |
                                                                 NSCalendarUnitMinute|
                                                                 NSCalendarUnitSecond) fromDate:date];
        UNCalendarNotificationTrigger *trigger =   [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:false];
        [self addNotificationRequest:[self getIdentifier:arguments] content:content result:result trigger:trigger];
    } else {
        UILocalNotification * notification = [self buildStandardUILocalNotification:arguments];
        notification.fireDate = [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch longLongValue]];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        result(nil);
    }
}

- (void)periodicallyShow:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [self buildStandardNotificationContent:arguments result:result];
        UNTimeIntervalNotificationTrigger *trigger = [self buildUserNotificationTimeIntervalTrigger:arguments];
        [self addNotificationRequest:[self getIdentifier:arguments] content:content result:result trigger:trigger];
    } else {
        UILocalNotification * notification = [self buildStandardUILocalNotification:arguments];
        NSTimeInterval timeInterval = 0;
        switch([arguments[REPEAT_INTERVAL] integerValue]) {
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
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        result(nil);
    }
}

- (void)showDailyAtTime:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    NSDictionary *timeArguments = (NSDictionary *) arguments[REPEAT_TIME];
    NSNumber *hourComponent = timeArguments[HOUR];
    NSNumber *minutesComponent = timeArguments[MINUTE];
    NSNumber *secondsComponent = timeArguments[SECOND];
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [self buildStandardNotificationContent:arguments result:result];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setHour:[hourComponent integerValue]];
        [dateComponents setMinute:[minutesComponent integerValue]];
        [dateComponents setSecond:[secondsComponent integerValue]];
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats: YES];
        [self addNotificationRequest:[self getIdentifier:arguments] content:content result:result trigger:trigger];
    } else {
        UILocalNotification * notification = [self buildStandardUILocalNotification:arguments];
        notification.repeatInterval = NSCalendarUnitDay;
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setHour:[hourComponent integerValue]];
        [dateComponents setMinute:[minutesComponent integerValue]];
        [dateComponents setSecond:[secondsComponent integerValue]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        notification.fireDate = [calendar dateFromComponents:dateComponents];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        result(nil);
    }
}

- (void)showWeeklyAtDayAndTime:(NSDictionary * _Nonnull)arguments result:(FlutterResult _Nonnull)result {
    NSDictionary *timeArguments = (NSDictionary *) arguments[REPEAT_TIME];
    NSNumber *dayOfWeekComponent = arguments[DAY];
    NSNumber *hourComponent = timeArguments[HOUR];
    NSNumber *minutesComponent = timeArguments[MINUTE];
    NSNumber *secondsComponent = timeArguments[SECOND];
    if(@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [self buildStandardNotificationContent:arguments result:result];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setHour:[hourComponent integerValue]];
        [dateComponents setMinute:[minutesComponent integerValue]];
        [dateComponents setSecond:[secondsComponent integerValue]];
        [dateComponents setWeekday:[dayOfWeekComponent integerValue]];
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats: YES];
        [self addNotificationRequest:[self getIdentifier:arguments] content:content result:result trigger:trigger];
    } else {
        UILocalNotification * notification = [self buildStandardUILocalNotification:arguments];
        notification.repeatInterval = NSCalendarUnitWeekOfYear;
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setHour:[hourComponent integerValue]];
        [dateComponents setMinute:[minutesComponent integerValue]];
        [dateComponents setSecond:[secondsComponent integerValue]];
        [dateComponents setWeekday:[dayOfWeekComponent integerValue]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        notification.fireDate = [calendar dateFromComponents:dateComponents];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        result(nil);
    }
}

- (void)cancel:(NSNumber *)id result:(FlutterResult _Nonnull)result {
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

- (void)cancelAll:(FlutterResult _Nonnull) result {
    if(@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center =  [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    result(nil);
}

- (UNMutableNotificationContent *) buildStandardNotificationContent:(NSDictionary *) arguments result:(FlutterResult _Nonnull)result API_AVAILABLE(ios(10.0)){
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    if([self containsKey:TITLE forDictionary:arguments]) {
        content.title = arguments[TITLE];
    }
    if([self containsKey:BODY forDictionary:arguments]) {
        content.body = arguments[BODY];
    }
    bool presentAlert = _displayAlert;
    bool presentSound = _playSound;
    bool presentBadge = _updateBadge;
    if(arguments[PLATFORM_SPECIFICS] != [NSNull null]) {
        NSDictionary *platformSpecifics = arguments[PLATFORM_SPECIFICS];
        if([self containsKey:PRESENT_ALERT forDictionary:platformSpecifics]) {
            presentAlert = [[platformSpecifics objectForKey:PRESENT_ALERT] boolValue];
        }
        if([self containsKey:PRESENT_SOUND forDictionary:platformSpecifics]) {
            presentSound = [[platformSpecifics objectForKey:PRESENT_SOUND] boolValue];
        }
        if([self containsKey:PRESENT_BADGE forDictionary:platformSpecifics]) {
            presentBadge = [[platformSpecifics objectForKey:PRESENT_BADGE] boolValue];
        }
        if([self containsKey:BADGE_NUMBER forDictionary:platformSpecifics]) {
            content.badge = [platformSpecifics objectForKey:BADGE_NUMBER];
        }
        if([self containsKey:THREAD_IDENTIFIER forDictionary:platformSpecifics]) {
            content.threadIdentifier = platformSpecifics[THREAD_IDENTIFIER];
        }
        if([self containsKey:ATTACHMENTS forDictionary:platformSpecifics]) {
            NSArray<NSDictionary *> *attachments = platformSpecifics[ATTACHMENTS];
            if(attachments.count > 0) {
                NSMutableArray<UNNotificationAttachment *> *notificationAttachments = [NSMutableArray arrayWithCapacity:attachments.count];
                for (NSDictionary *attachment in attachments) {
                    NSError *error;
                    UNNotificationAttachment *notificationAttachment = [UNNotificationAttachment attachmentWithIdentifier:attachment[ATTACHMENT_IDENTIFIER]
                                                                                                                      URL:[NSURL fileURLWithPath:attachment[ATTACHMENT_FILE_PATH]]
                                                                                                                  options:nil error:&error];
                    if(error) {
                        result(getFlutterError(error));
                        return nil;
                    }
                    [notificationAttachments addObject:notificationAttachment];
                }
                content.attachments = notificationAttachments;
            }
        }
        if([self containsKey:SOUND forDictionary:platformSpecifics]) {
            content.sound = [UNNotificationSound soundNamed:platformSpecifics[SOUND]];
        }
        if([self containsKey:SUBTITLE forDictionary:platformSpecifics]) {
            content.subtitle = platformSpecifics[SUBTITLE];
        }
    }
    if(presentSound && content.sound == nil) {
        content.sound = UNNotificationSound.defaultSound;
    }
    content.userInfo = [self buildUserDict:arguments[ID] title:content.title presentAlert:presentAlert presentSound:presentSound presentBadge:presentBadge payload:arguments[PAYLOAD]];
    return content;
}

- (UNCalendarNotificationTrigger *) buildUserNotificationCalendarTrigger:(id) arguments NS_AVAILABLE_IOS(10.0) {
    NSString *scheduledDateTime  = arguments[SCHEDULED_DATE_TIME];
    NSString *timeZoneName = arguments[TIME_ZONE_NAME];
    
    NSNumber *matchDateComponents = arguments[MATCH_DATE_TIME_COMPONENTS];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:timeZoneName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // Needed for some countries, when phone DateTime format is 12H
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setLocale:posix];

    NSDate *date = [dateFormatter dateFromString:scheduledDateTime];

    calendar.timeZone = timezone;
    if(matchDateComponents != nil) {
        if([matchDateComponents integerValue] == Time) {
            NSDateComponents *dateComponents    = [calendar components:(
                                                                        NSCalendarUnitHour  |
                                                                        NSCalendarUnitMinute|
                                                                        NSCalendarUnitSecond | NSCalendarUnitTimeZone) fromDate:date];
            return [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
            
        } else if([matchDateComponents integerValue] == DayOfWeekAndTime) {
            NSDateComponents *dateComponents    = [calendar components:( NSCalendarUnitWeekday |
                                                                        NSCalendarUnitHour  |
                                                                        NSCalendarUnitMinute|
                                                                        NSCalendarUnitSecond | NSCalendarUnitTimeZone) fromDate:date];
            return [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        }
        return nil;
    }
    NSDateComponents *dateComponents    = [calendar components:(NSCalendarUnitYear  |
                                                                NSCalendarUnitMonth |
                                                                NSCalendarUnitDay   |
                                                                NSCalendarUnitHour  |
                                                                NSCalendarUnitMinute|
                                                                NSCalendarUnitSecond | NSCalendarUnitTimeZone) fromDate:date];
    return [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
}


- (UNTimeIntervalNotificationTrigger *)buildUserNotificationTimeIntervalTrigger:(id)arguments  API_AVAILABLE(ios(10.0)){
    switch([arguments[REPEAT_INTERVAL] integerValue]) {
        case EveryMinute:
            return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60
                                                                      repeats:YES];
        case Hourly:
            return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 * 60
                                                                      repeats:YES];
        case Daily:
            return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 * 60 * 24
                                                                      repeats:YES];
            break;
        case Weekly:
            return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 * 60 * 24 * 7
                                                                      repeats:YES];
    }
    return nil;
}


- (NSDictionary*)buildUserDict:(NSNumber *)id title:(NSString *)title presentAlert:(bool)presentAlert presentSound:(bool)presentSound presentBadge:(bool)presentBadge payload:(NSString *)payload {
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
    userDict[NOTIFICATION_ID] = id;
    if(title) {
        userDict[TITLE] = title;
    }
    userDict[PRESENT_ALERT] = [NSNumber numberWithBool:presentAlert];
    userDict[PRESENT_SOUND] = [NSNumber numberWithBool:presentSound];
    userDict[PRESENT_BADGE] = [NSNumber numberWithBool:presentBadge];
    userDict[PAYLOAD] = payload;
    return userDict;
}

- (void)addNotificationRequest:(NSString*)identifier content:(UNMutableNotificationContent *)content result:(FlutterResult _Nonnull)result trigger:(UNNotificationTrigger *)trigger API_AVAILABLE(ios(10.0)){
    UNNotificationRequest *notificationRequest = [UNNotificationRequest
                                                  requestWithIdentifier:identifier content:content trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (error == nil) {
            result(nil);
            return;
        }
        result(getFlutterError(error));
    }];
}

- (BOOL)isAFlutterLocalNotification:(NSDictionary *)userInfo {
    return userInfo != nil && userInfo[NOTIFICATION_ID] && userInfo[PRESENT_ALERT] && userInfo[PRESENT_SOUND] && userInfo[PRESENT_BADGE] && userInfo[PAYLOAD];
}

- (void)handleSelectNotification:(NSString *)payload {
    [_channel invokeMethod:@"selectNotification" arguments:payload];
}

- (BOOL)containsKey:(NSString *)key forDictionary:(NSDictionary *)dictionary{
    return dictionary[key] != [NSNull null] && dictionary[key] != nil;
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification :(UNNotification *)notification withCompletionHandler :(void (^)(UNNotificationPresentationOptions))completionHandler NS_AVAILABLE_IOS(10.0) {
    if(![self isAFlutterLocalNotification:notification.request.content.userInfo]) {
        return;
    }
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

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier] && [self isAFlutterLocalNotification:response.notification.request.content.userInfo]) {
        NSString *payload = (NSString *) response.notification.request.content.userInfo[PAYLOAD];
        if(_initialized) {
            [self handleSelectNotification:payload];
        } else {
            _launchPayload = payload;
            _launchingAppFromNotification = true;
        }
        completionHandler();
    }
}

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil) {
        UILocalNotification *launchNotification = (UILocalNotification *)[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        _launchingAppFromNotification = launchNotification != nil && [self isAFlutterLocalNotification:launchNotification.userInfo];
        if(_launchingAppFromNotification) {
            _launchNotification = launchNotification;
        }
    }
    
    return YES;
}

- (void)application:(UIApplication*)application
didReceiveLocalNotification:(UILocalNotification*)notification {
    if(@available(iOS 10.0, *)) {
        return;
    }
    if(![self isAFlutterLocalNotification:notification.userInfo]) {
        return;
    }
    
    NSMutableDictionary *arguments = [[NSMutableDictionary alloc] init];
    arguments[ID]= notification.userInfo[NOTIFICATION_ID];
    if (notification.userInfo[TITLE] != [NSNull null]) {
        arguments[TITLE] = notification.userInfo[TITLE];
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
