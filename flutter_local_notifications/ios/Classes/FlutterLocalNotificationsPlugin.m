#import "FlutterLocalNotificationsPlugin.h"
#import "ActionEventSink.h"
#import "Converters.h"
#import "FlutterEngineManager.h"

@implementation FlutterLocalNotificationsPlugin {
  FlutterMethodChannel *_channel;
  bool _initialized;
  bool _launchingAppFromNotification;
  NSObject<FlutterPluginRegistrar> *_registrar;
  FlutterEngineManager *_flutterEngineManager;
  NSMutableDictionary *_launchNotificationResponseDict;
}

static FlutterPluginRegistrantCallback registerPlugins;
static ActionEventSink *actionEventSink;

NSString *const FOREGROUND_ACTION_IDENTIFIERS =
    @"dexterous.com/flutter/local_notifications/foreground_action_identifiers";
NSString *const INITIALIZE_METHOD = @"initialize";
NSString *const GET_CALLBACK_METHOD = @"getCallbackHandle";
NSString *const SHOW_METHOD = @"show";
NSString *const ZONED_SCHEDULE_METHOD = @"zonedSchedule";
NSString *const PERIODICALLY_SHOW_METHOD = @"periodicallyShow";
NSString *const PERIODICALLY_SHOW_WITH_DURATION_METHOD =
    @"periodicallyShowWithDuration";
NSString *const CANCEL_METHOD = @"cancel";
NSString *const CANCEL_ALL_METHOD = @"cancelAll";
NSString *const PENDING_NOTIFICATIONS_REQUESTS_METHOD =
    @"pendingNotificationRequests";
NSString *const GET_ACTIVE_NOTIFICATIONS_METHOD = @"getActiveNotifications";
NSString *const GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD =
    @"getNotificationAppLaunchDetails";
NSString *const CHANNEL = @"dexterous.com/flutter/local_notifications";
NSString *const CALLBACK_CHANNEL =
    @"dexterous.com/flutter/local_notifications_background";
NSString *const ON_NOTIFICATION_METHOD = @"onNotification";
NSString *const DID_RECEIVE_LOCAL_NOTIFICATION = @"didReceiveLocalNotification";
NSString *const REQUEST_PERMISSIONS_METHOD = @"requestPermissions";
NSString *const CHECK_PERMISSIONS_METHOD = @"checkPermissions";

NSString *const DAY = @"day";

NSString *const REQUEST_SOUND_PERMISSION = @"requestSoundPermission";
NSString *const REQUEST_ALERT_PERMISSION = @"requestAlertPermission";
NSString *const REQUEST_BADGE_PERMISSION = @"requestBadgePermission";
NSString *const REQUEST_PROVISIONAL_PERMISSION =
    @"requestProvisionalPermission";
NSString *const REQUEST_CRITICAL_PERMISSION = @"requestCriticalPermission";
NSString *const DEFAULT_PRESENT_ALERT = @"defaultPresentAlert";
NSString *const DEFAULT_PRESENT_SOUND = @"defaultPresentSound";
NSString *const DEFAULT_PRESENT_BADGE = @"defaultPresentBadge";
NSString *const DEFAULT_PRESENT_BANNER = @"defaultPresentBanner";
NSString *const DEFAULT_PRESENT_LIST = @"defaultPresentList";
NSString *const SOUND_PERMISSION = @"sound";
NSString *const ALERT_PERMISSION = @"alert";
NSString *const BADGE_PERMISSION = @"badge";
NSString *const PROVISIONAL_PERMISSION = @"provisional";
NSString *const CRITICAL_PERMISSION = @"critical";
NSString *const CALLBACK_DISPATCHER = @"callbackDispatcher";
NSString *const ON_NOTIFICATION_CALLBACK_DISPATCHER =
    @"onNotificationCallbackDispatcher";
NSString *const PLATFORM_SPECIFICS = @"platformSpecifics";
NSString *const ID = @"id";
NSString *const TITLE = @"title";
NSString *const SUBTITLE = @"subtitle";
NSString *const BODY = @"body";
NSString *const SOUND = @"sound";
NSString *const ATTACHMENTS = @"attachments";
NSString *const ATTACHMENT_IDENTIFIER = @"identifier";
NSString *const ATTACHMENT_FILE_PATH = @"filePath";
NSString *const ATTACHMENT_HIDE_THUMBNAIL = @"hideThumbnail";
NSString *const ATTACHMENT_THUMBNAIL_CLIPPING_RECT = @"thumbnailClippingRect";
NSString *const INTERRUPTION_LEVEL = @"interruptionLevel";
NSString *const THREAD_IDENTIFIER = @"threadIdentifier";
NSString *const PRESENT_ALERT = @"presentAlert";
NSString *const PRESENT_SOUND = @"presentSound";
NSString *const PRESENT_BADGE = @"presentBadge";
NSString *const PRESENT_BANNER = @"presentBanner";
NSString *const PRESENT_LIST = @"presentList";
NSString *const BADGE_NUMBER = @"badgeNumber";
NSString *const MILLISECONDS_SINCE_EPOCH = @"millisecondsSinceEpoch";
NSString *const REPEAT_INTERVAL = @"repeatInterval";
NSString *const REPEAT_INTERVAL_MILLISECODNS = @"repeatIntervalMilliseconds";
NSString *const SCHEDULED_DATE_TIME = @"scheduledDateTimeISO8601";
NSString *const TIME_ZONE_NAME = @"timeZoneName";
NSString *const MATCH_DATE_TIME_COMPONENTS = @"matchDateTimeComponents";
NSString *const UILOCALNOTIFICATION_DATE_INTERPRETATION =
    @"uiLocalNotificationDateInterpretation";

NSString *const NOTIFICATION_ID = @"NotificationId";
NSString *const PAYLOAD = @"payload";
NSString *const NOTIFICATION_LAUNCHED_APP = @"notificationLaunchedApp";
NSString *const ACTION_ID = @"actionId";
NSString *const NOTIFICATION_RESPONSE_TYPE = @"notificationResponseType";

NSString *const UNSUPPORTED_OS_VERSION_ERROR_CODE = @"unsupported_os_version";
NSString *const GET_ACTIVE_NOTIFICATIONS_ERROR_MESSAGE =
    @"iOS version must be 10.0 or newer to use getActiveNotifications";
NSString *const PRESENTATION_OPTIONS_USER_DEFAULTS =
    @"flutter_local_notifications_presentation_options";

NSString *const IS_NOTIFICATIONS_ENABLED = @"isEnabled";
NSString *const IS_SOUND_ENABLED = @"isSoundEnabled";
NSString *const IS_ALERT_ENABLED = @"isAlertEnabled";
NSString *const IS_BADGE_ENABLED = @"isBadgeEnabled";
NSString *const IS_PROVISIONAL_ENABLED = @"isProvisionalEnabled";
NSString *const IS_CRITICAL_ENABLED = @"isCriticalEnabled";

typedef NS_ENUM(NSInteger, RepeatInterval) {
  EveryMinute,
  Hourly,
  Daily,
  Weekly
};

typedef NS_ENUM(NSInteger, DateTimeComponents) {
  Time,
  DayOfWeekAndTime,
  DayOfMonthAndTime,
  DateAndTime
};

typedef NS_ENUM(NSInteger, UILocalNotificationDateInterpretation) {
  AbsoluteGMTTime,
  WallClockTime
};

static FlutterError *getFlutterError(NSError *error) {
  return [FlutterError
      errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
            message:error.localizedDescription
            details:error.domain];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:CHANNEL
                                  binaryMessenger:[registrar messenger]];

  FlutterLocalNotificationsPlugin *instance =
      [[FlutterLocalNotificationsPlugin alloc] initWithChannel:channel
                                                     registrar:registrar];

  if ([FlutterEngineManager shouldAddAppDelegateToRegistrar:registrar]) {
    [registrar addApplicationDelegate:instance];
  }

  [registrar addMethodCallDelegate:instance channel:channel];
}

+ (void)setPluginRegistrantCallback:(FlutterPluginRegistrantCallback)callback {
  registerPlugins = callback;
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];

  if (self) {
    _channel = channel;
    _registrar = registrar;
    _flutterEngineManager = [[FlutterEngineManager alloc] init];
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([INITIALIZE_METHOD isEqualToString:call.method]) {
    [self initialize:call.arguments result:result];
  } else if ([GET_CALLBACK_METHOD isEqualToString:call.method]) {
    result([_flutterEngineManager getCallbackHandle]);
  } else if ([SHOW_METHOD isEqualToString:call.method]) {

    [self show:call.arguments result:result];
  } else if ([ZONED_SCHEDULE_METHOD isEqualToString:call.method]) {
    [self zonedSchedule:call.arguments result:result];
  } else if ([PERIODICALLY_SHOW_METHOD isEqualToString:call.method]) {
    [self periodicallyShow:call.arguments result:result];
  } else if ([PERIODICALLY_SHOW_WITH_DURATION_METHOD
                 isEqualToString:call.method]) {
    [self periodicallyShow:call.arguments result:result];
  } else if ([REQUEST_PERMISSIONS_METHOD isEqualToString:call.method]) {
    [self requestPermissions:call.arguments result:result];
  } else if ([CHECK_PERMISSIONS_METHOD isEqualToString:call.method]) {
    [self checkPermissions:call.arguments result:result];
  } else if ([CANCEL_METHOD isEqualToString:call.method]) {
    [self cancel:((NSNumber *)call.arguments) result:result];
  } else if ([CANCEL_ALL_METHOD isEqualToString:call.method]) {
    [self cancelAll:result];
  } else if ([GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD
                 isEqualToString:call.method]) {

    NSMutableDictionary *notificationAppLaunchDetails =
        [[NSMutableDictionary alloc] init];
    notificationAppLaunchDetails[NOTIFICATION_LAUNCHED_APP] =
        [NSNumber numberWithBool:_launchingAppFromNotification];
    notificationAppLaunchDetails[@"notificationResponse"] =
        _launchNotificationResponseDict;
    result(notificationAppLaunchDetails);
  } else if ([PENDING_NOTIFICATIONS_REQUESTS_METHOD
                 isEqualToString:call.method]) {
    [self pendingNotificationRequests:result];
  } else if ([GET_ACTIVE_NOTIFICATIONS_METHOD isEqualToString:call.method]) {
    [self getActiveNotifications:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)pendingUserNotificationRequests:(FlutterResult _Nonnull)result
    NS_AVAILABLE_IOS(10.0) {
  UNUserNotificationCenter *center =
      [UNUserNotificationCenter currentNotificationCenter];
  [center getPendingNotificationRequestsWithCompletionHandler:^(
              NSArray<UNNotificationRequest *> *_Nonnull requests) {
    NSMutableArray<NSMutableDictionary<NSString *, NSObject *> *>
        *pendingNotificationRequests =
            [[NSMutableArray alloc] initWithCapacity:[requests count]];
    for (UNNotificationRequest *request in requests) {
      NSMutableDictionary *pendingNotificationRequest =
          [[NSMutableDictionary alloc] init];
      pendingNotificationRequest[ID] =
          request.content.userInfo[NOTIFICATION_ID];
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

- (void)activeUserNotificationRequests:(FlutterResult _Nonnull)result
    NS_AVAILABLE_IOS(10.0) {
  UNUserNotificationCenter *center =
      [UNUserNotificationCenter currentNotificationCenter];
  [center getDeliveredNotificationsWithCompletionHandler:^(
              NSArray<UNNotification *> *_Nonnull notifications) {
    NSMutableArray<NSMutableDictionary<NSString *, NSObject *> *>
        *activeNotifications =
            [[NSMutableArray alloc] initWithCapacity:[notifications count]];
    for (UNNotification *notification in notifications) {
      NSMutableDictionary *activeNotification =
          [[NSMutableDictionary alloc] init];
      activeNotification[ID] =
          notification.request.content.userInfo[NOTIFICATION_ID];
      if (notification.request.content.title != nil) {
        activeNotification[TITLE] = notification.request.content.title;
      }
      if (notification.request.content.body != nil) {
        activeNotification[BODY] = notification.request.content.body;
      }
      if (notification.request.content.userInfo[PAYLOAD] != [NSNull null]) {
        activeNotification[PAYLOAD] =
            notification.request.content.userInfo[PAYLOAD];
      }
      [activeNotifications addObject:activeNotification];
    }
    result(activeNotifications);
  }];
}

- (void)pendingLocalNotificationRequests:(FlutterResult _Nonnull)result {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  NSArray *notifications =
      [UIApplication sharedApplication].scheduledLocalNotifications;
  NSMutableArray<NSDictionary<NSString *, NSObject *> *>
      *pendingNotificationRequests =
          [[NSMutableArray alloc] initWithCapacity:[notifications count]];
  for (int i = 0; i < [notifications count]; i++) {
    UILocalNotification *localNotification = [notifications objectAtIndex:i];
#pragma clang diagnostic pop
    NSMutableDictionary *pendingNotificationRequest =
        [[NSMutableDictionary alloc] init];
    pendingNotificationRequest[ID] =
        localNotification.userInfo[NOTIFICATION_ID];
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
  if (@available(iOS 10.0, *)) {
    [self pendingUserNotificationRequests:result];
  } else {
    [self pendingLocalNotificationRequests:result];
  }
}

/// Extracts notification categories from [arguments] and configures them as
/// appropriate.
///
/// This code will simply return the `completionHandler` if not running on a
/// compatible iOS version or when no categories were specified in [arguments].
- (void)configureNotificationCategories:(NSDictionary *_Nonnull)arguments
                  withCompletionHandler:(void (^)(void))completionHandler {
  if (@available(iOS 10.0, *)) {
    if ([self containsKey:@"notificationCategories" forDictionary:arguments]) {
      NSMutableSet<UNNotificationCategory *> *notificationCategories =
          [NSMutableSet set];

      NSArray *categories = arguments[@"notificationCategories"];
      NSMutableArray<NSString *> *foregroundActionIdentifiers =
          [[NSMutableArray alloc] init];

      for (NSDictionary *category in categories) {
        NSMutableArray<UNNotificationAction *> *newActions =
            [NSMutableArray array];

        NSArray *actions = category[@"actions"];
        for (NSDictionary *action in actions) {
          NSString *type = action[@"type"];
          NSString *identifier = action[@"identifier"];
          NSString *title = action[@"title"];
          UNNotificationActionOptions options =
              [Converters parseNotificationActionOptions:action[@"options"]];

          if ((options & UNNotificationActionOptionForeground) != 0) {
            [foregroundActionIdentifiers addObject:identifier];
          }

          if ([type isEqualToString:@"plain"]) {
            [newActions
                addObject:[UNNotificationAction actionWithIdentifier:identifier
                                                               title:title
                                                             options:options]];
          } else if ([type isEqualToString:@"text"]) {
            NSString *buttonTitle = action[@"buttonTitle"];
            NSString *placeholder = action[@"placeholder"];
            [newActions addObject:[UNTextInputNotificationAction
                                      actionWithIdentifier:identifier
                                                     title:title
                                                   options:options
                                      textInputButtonTitle:buttonTitle
                                      textInputPlaceholder:placeholder]];
          }
        }

        UNNotificationCategory *notificationCategory = [UNNotificationCategory
            categoryWithIdentifier:category[@"identifier"]
                           actions:newActions
                 intentIdentifiers:@[]
                           options:[Converters parseNotificationCategoryOptions:
                                                   category[@"options"]]];

        [notificationCategories addObject:notificationCategory];
      }

      if (notificationCategories.count > 0) {
        UNUserNotificationCenter *center =
            [UNUserNotificationCenter currentNotificationCenter];
        [center setNotificationCategories:notificationCategories];
        [[NSUserDefaults standardUserDefaults]
            setObject:foregroundActionIdentifiers
               forKey:FOREGROUND_ACTION_IDENTIFIERS];
        completionHandler();
      } else {
        completionHandler();
      }
    }
  } else {
    completionHandler();
  }
}

- (void)getActiveNotifications:(FlutterResult _Nonnull)result {
  if (@available(iOS 10.0, *)) {
    [self activeUserNotificationRequests:result];
  } else {
    result([FlutterError errorWithCode:UNSUPPORTED_OS_VERSION_ERROR_CODE
                               message:GET_ACTIVE_NOTIFICATIONS_ERROR_MESSAGE
                               details:nil]);
  }
}

- (void)initialize:(NSDictionary *_Nonnull)arguments
            result:(FlutterResult _Nonnull)result {
  bool requestedSoundPermission = false;
  bool requestedAlertPermission = false;
  bool requestedBadgePermission = false;
  bool requestedProvisionalPermission = false;
  bool requestedCriticalPermission = false;
  NSMutableDictionary *presentationOptions = [[NSMutableDictionary alloc] init];
  if ([self containsKey:DEFAULT_PRESENT_ALERT forDictionary:arguments]) {
    presentationOptions[PRESENT_ALERT] =
        [NSNumber numberWithBool:[[arguments objectForKey:DEFAULT_PRESENT_ALERT]
                                     boolValue]];
  }
  if ([self containsKey:DEFAULT_PRESENT_SOUND forDictionary:arguments]) {
    presentationOptions[PRESENT_SOUND] =
        [NSNumber numberWithBool:[[arguments objectForKey:DEFAULT_PRESENT_SOUND]
                                     boolValue]];
  }
  if ([self containsKey:DEFAULT_PRESENT_BADGE forDictionary:arguments]) {
    presentationOptions[PRESENT_BADGE] =
        [NSNumber numberWithBool:[[arguments objectForKey:DEFAULT_PRESENT_BADGE]
                                     boolValue]];
  }
  if ([self containsKey:DEFAULT_PRESENT_BANNER forDictionary:arguments]) {
    presentationOptions[PRESENT_BANNER] = [NSNumber
        numberWithBool:[[arguments objectForKey:DEFAULT_PRESENT_BANNER]
                           boolValue]];
  }
  if ([self containsKey:DEFAULT_PRESENT_LIST forDictionary:arguments]) {
    presentationOptions[PRESENT_LIST] =
        [NSNumber numberWithBool:[[arguments objectForKey:DEFAULT_PRESENT_LIST]
                                     boolValue]];
  }
  [[NSUserDefaults standardUserDefaults]
      setObject:presentationOptions
         forKey:PRESENTATION_OPTIONS_USER_DEFAULTS];
  if ([self containsKey:REQUEST_SOUND_PERMISSION forDictionary:arguments]) {
    requestedSoundPermission = [arguments[REQUEST_SOUND_PERMISSION] boolValue];
  }
  if ([self containsKey:REQUEST_ALERT_PERMISSION forDictionary:arguments]) {
    requestedAlertPermission = [arguments[REQUEST_ALERT_PERMISSION] boolValue];
  }
  if ([self containsKey:REQUEST_BADGE_PERMISSION forDictionary:arguments]) {
    requestedBadgePermission = [arguments[REQUEST_BADGE_PERMISSION] boolValue];
  }
  if ([self containsKey:REQUEST_PROVISIONAL_PERMISSION
          forDictionary:arguments]) {
    requestedProvisionalPermission =
        [arguments[REQUEST_PROVISIONAL_PERMISSION] boolValue];
  }
  if ([self containsKey:REQUEST_CRITICAL_PERMISSION forDictionary:arguments]) {
    requestedCriticalPermission =
        [arguments[REQUEST_CRITICAL_PERMISSION] boolValue];
  }

  if ([self containsKey:@"dispatcher_handle" forDictionary:arguments] &&
      [self containsKey:@"callback_handle" forDictionary:arguments]) {
    [_flutterEngineManager
        registerDispatcherHandle:arguments[@"dispatcher_handle"]
                  callbackHandle:arguments[@"callback_handle"]];
  }

  // Configure the notification categories before requesting permissions
  [self configureNotificationCategories:arguments
                  withCompletionHandler:^{
                    // Once notification categories are set up, the permissions
                    // request will pick them up properly.
                    [self requestPermissionsImpl:requestedSoundPermission
                                 alertPermission:requestedAlertPermission
                                 badgePermission:requestedBadgePermission
                           provisionalPermission:requestedProvisionalPermission
                              criticalPermission:requestedCriticalPermission
                                          result:result];
                  }];

  _initialized = true;
}
- (void)requestPermissions:(NSDictionary *_Nonnull)arguments

                    result:(FlutterResult _Nonnull)result {
  bool soundPermission = false;
  bool alertPermission = false;
  bool badgePermission = false;
  bool provisionalPermission = false;
  bool criticalPermission = false;
  if ([self containsKey:SOUND_PERMISSION forDictionary:arguments]) {
    soundPermission = [arguments[SOUND_PERMISSION] boolValue];
  }
  if ([self containsKey:ALERT_PERMISSION forDictionary:arguments]) {
    alertPermission = [arguments[ALERT_PERMISSION] boolValue];
  }
  if ([self containsKey:BADGE_PERMISSION forDictionary:arguments]) {
    badgePermission = [arguments[BADGE_PERMISSION] boolValue];
  }
  if ([self containsKey:PROVISIONAL_PERMISSION forDictionary:arguments]) {
    provisionalPermission = [arguments[PROVISIONAL_PERMISSION] boolValue];
  }
  if ([self containsKey:CRITICAL_PERMISSION forDictionary:arguments]) {
    criticalPermission = [arguments[CRITICAL_PERMISSION] boolValue];
  }
  [self requestPermissionsImpl:soundPermission
               alertPermission:alertPermission
               badgePermission:badgePermission
         provisionalPermission:provisionalPermission
            criticalPermission:criticalPermission
                        result:result];
}

- (void)requestPermissionsImpl:(bool)soundPermission
               alertPermission:(bool)alertPermission
               badgePermission:(bool)badgePermission
         provisionalPermission:(bool)provisionalPermission
            criticalPermission:(bool)criticalPermission
                        result:(FlutterResult _Nonnull)result {
  if (!soundPermission && !alertPermission && !badgePermission &&
      !criticalPermission) {
    result(@NO);
    return;
  }
  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];

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
    if (@available(iOS 12.0, *)) {
      if (provisionalPermission) {
        authorizationOptions += UNAuthorizationOptionProvisional;
      }
      if (criticalPermission) {
        authorizationOptions += UNAuthorizationOptionCriticalAlert;
      }
    }
    [center requestAuthorizationWithOptions:(authorizationOptions)
                          completionHandler:^(BOOL granted,
                                              NSError *_Nullable error) {
                            result(@(granted));
                          }];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
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
    UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:notificationTypes
                                          categories:nil];
    [[UIApplication sharedApplication]
        registerUserNotificationSettings:settings];
#pragma clang diagnostic pop
    result(@YES);
  }
}

- (void)checkPermissions:(NSDictionary *_Nonnull)arguments

                  result:(FlutterResult _Nonnull)result {
  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];

    [center getNotificationSettingsWithCompletionHandler:^(
                UNNotificationSettings *_Nonnull settings) {
      BOOL isEnabled =
          settings.authorizationStatus == UNAuthorizationStatusAuthorized;
      BOOL isSoundEnabled =
          settings.soundSetting == UNNotificationSettingEnabled;
      BOOL isAlertEnabled =
          settings.alertSetting == UNNotificationSettingEnabled;
      BOOL isBadgeEnabled =
          settings.badgeSetting == UNNotificationSettingEnabled;
      BOOL isProvisionalEnabled = false;
      BOOL isCriticalEnabled = false;

      if (@available(iOS 12.0, *)) {
        isProvisionalEnabled =
            settings.authorizationStatus == UNAuthorizationStatusProvisional;
        isCriticalEnabled =
            settings.criticalAlertSetting == UNNotificationSettingEnabled;
      }

      NSDictionary *dict = @{
        IS_NOTIFICATIONS_ENABLED : @(isEnabled),
        IS_SOUND_ENABLED : @(isSoundEnabled),
        IS_ALERT_ENABLED : @(isAlertEnabled),
        IS_BADGE_ENABLED : @(isBadgeEnabled),
        IS_PROVISIONAL_ENABLED : @(isProvisionalEnabled),
        IS_CRITICAL_ENABLED : @(isCriticalEnabled),
      };

      result(dict);
    }];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIUserNotificationSettings *settings =
        UIApplication.sharedApplication.currentUserNotificationSettings;

    if (settings == nil) {
      result(@{
        IS_NOTIFICATIONS_ENABLED : @NO,
        IS_SOUND_ENABLED : @NO,
        IS_ALERT_ENABLED : @NO,
        IS_BADGE_ENABLED : @NO,
        IS_PROVISIONAL_ENABLED : @NO,
        IS_CRITICAL_ENABLED : @NO,
      });
      return;
    }

    UIUserNotificationType types = settings.types;

    BOOL isEnabled = types != UIUserNotificationTypeNone;
    BOOL isSoundEnabled = types & UIUserNotificationTypeSound;
    BOOL isAlertEnabled = types & UIUserNotificationTypeAlert;
    BOOL isBadgeEnabled = types & UIUserNotificationTypeBadge;

    NSDictionary *dict = @{
      IS_NOTIFICATIONS_ENABLED : @(isEnabled),
      IS_SOUND_ENABLED : @(isSoundEnabled),
      IS_ALERT_ENABLED : @(isAlertEnabled),
      IS_BADGE_ENABLED : @(isBadgeEnabled),
      IS_PROVISIONAL_ENABLED : @NO,
      IS_CRITICAL_ENABLED : @NO,
    };

    result(dict);
#pragma clang diagnostic pop
  }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UILocalNotification *)buildStandardUILocalNotification:
    (NSDictionary *)arguments {
  UILocalNotification *notification = [[UILocalNotification alloc] init];
#pragma clang diagnostic pop
  if ([self containsKey:BODY forDictionary:arguments]) {
    notification.alertBody = arguments[BODY];
  }

  NSString *title;
  if ([self containsKey:TITLE forDictionary:arguments]) {
    title = arguments[TITLE];
    if (@available(iOS 8.2, *)) {
      notification.alertTitle = title;
    }
  }

  NSDictionary *persistedPresentationOptions =
      [[NSUserDefaults standardUserDefaults]
          dictionaryForKey:PRESENTATION_OPTIONS_USER_DEFAULTS];
  bool presentAlert = false;
  bool presentSound = false;
  bool presentBadge = false;
  bool presentBanner = false;
  bool presentList = false;
  if (persistedPresentationOptions != nil) {
    presentAlert = [persistedPresentationOptions[PRESENT_ALERT] isEqual:@YES];
    presentSound = [persistedPresentationOptions[PRESENT_SOUND] isEqual:@YES];
    presentBadge = [persistedPresentationOptions[PRESENT_BADGE] isEqual:@YES];
    presentBanner = [persistedPresentationOptions[PRESENT_BANNER] isEqual:@YES];
    presentList = [persistedPresentationOptions[PRESENT_LIST] isEqual:@YES];
  }
  if (arguments[PLATFORM_SPECIFICS] != [NSNull null]) {
    NSDictionary *platformSpecifics = arguments[PLATFORM_SPECIFICS];

    if ([self containsKey:PRESENT_ALERT forDictionary:platformSpecifics]) {
      presentAlert = [[platformSpecifics objectForKey:PRESENT_ALERT] boolValue];
    }
    if ([self containsKey:PRESENT_SOUND forDictionary:platformSpecifics]) {
      presentSound = [[platformSpecifics objectForKey:PRESENT_SOUND] boolValue];
    }
    if ([self containsKey:PRESENT_BADGE forDictionary:platformSpecifics]) {
      presentBadge = [[platformSpecifics objectForKey:PRESENT_BADGE] boolValue];
    }
    if ([self containsKey:PRESENT_BANNER forDictionary:platformSpecifics]) {
      presentBanner =
          [[platformSpecifics objectForKey:PRESENT_BANNER] boolValue];
    }
    if ([self containsKey:PRESENT_LIST forDictionary:platformSpecifics]) {
      presentList = [[platformSpecifics objectForKey:PRESENT_LIST] boolValue];
    }

    if ([self containsKey:BADGE_NUMBER forDictionary:platformSpecifics]) {
      notification.applicationIconBadgeNumber =
          [platformSpecifics[BADGE_NUMBER] integerValue];
    }

    if ([self containsKey:SOUND forDictionary:platformSpecifics]) {
      notification.soundName = [platformSpecifics[SOUND] stringValue];
    }
  }

  if (presentSound && notification.soundName == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    notification.soundName = UILocalNotificationDefaultSoundName;
#pragma clang diagnostic pop
  }

  notification.userInfo = [self buildUserDict:arguments[ID]
                                        title:title
                                 presentAlert:presentAlert
                                 presentSound:presentSound
                                 presentBadge:presentBadge
                                presentBanner:presentBanner
                                  presentList:presentList
                                      payload:arguments[PAYLOAD]];
  return notification;
}

- (NSString *)getIdentifier:(id)arguments {
  return [arguments[ID] stringValue];
}

- (void)show:(NSDictionary *_Nonnull)arguments
      result:(FlutterResult _Nonnull)result {
  if (@available(iOS 10.0, *)) {
    UNMutableNotificationContent *content =
        [self buildStandardNotificationContent:arguments result:result];
    [self addNotificationRequest:[self getIdentifier:arguments]
                         content:content
                          result:result
                         trigger:nil];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UILocalNotification *notification =
        [self buildStandardUILocalNotification:arguments];
    [[UIApplication sharedApplication]
        presentLocalNotificationNow:notification];
#pragma clang diagnostic pop
    result(nil);
  }
}

- (void)zonedSchedule:(NSDictionary *_Nonnull)arguments
               result:(FlutterResult _Nonnull)result {
  if (@available(iOS 10.0, *)) {
    UNMutableNotificationContent *content =
        [self buildStandardNotificationContent:arguments result:result];
    UNCalendarNotificationTrigger *trigger =
        [self buildUserNotificationCalendarTrigger:arguments];
    [self addNotificationRequest:[self getIdentifier:arguments]
                         content:content
                          result:result
                         trigger:trigger];

  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UILocalNotification *notification =
        [self buildStandardUILocalNotification:arguments];
#pragma clang diagnostic pop
    NSString *scheduledDateTime = arguments[SCHEDULED_DATE_TIME];
    NSString *timeZoneName = arguments[TIME_ZONE_NAME];
    NSNumber *matchDateComponents = arguments[MATCH_DATE_TIME_COMPONENTS];
    NSNumber *uiLocalNotificationDateInterpretation =
        arguments[UILOCALNOTIFICATION_DATE_INTERPRETATION];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:timeZoneName];
    NSISO8601DateFormatter *dateFormatter =
        [[NSISO8601DateFormatter alloc] init];
    [dateFormatter setTimeZone:timezone];
    dateFormatter.formatOptions = NSISO8601DateFormatWithFractionalSeconds |
                                  NSISO8601DateFormatWithInternetDateTime;
    NSDate *date = [dateFormatter dateFromString:scheduledDateTime];
    notification.fireDate = date;
    if (uiLocalNotificationDateInterpretation != nil) {
      if ([uiLocalNotificationDateInterpretation integerValue] ==
          AbsoluteGMTTime) {
        notification.timeZone = nil;
      } else if ([uiLocalNotificationDateInterpretation integerValue] ==
                 WallClockTime) {
        notification.timeZone = timezone;
      }
    }
    if (matchDateComponents != nil) {
      if ([matchDateComponents integerValue] == Time) {
        notification.repeatInterval = NSCalendarUnitDay;
      } else if ([matchDateComponents integerValue] == DayOfWeekAndTime) {
        notification.repeatInterval = NSCalendarUnitWeekOfYear;
      } else if ([matchDateComponents integerValue] == DayOfMonthAndTime) {
        notification.repeatInterval = NSCalendarUnitMonth;
      } else if ([matchDateComponents integerValue] == DateAndTime) {
        notification.repeatInterval = NSCalendarUnitYear;
      }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
#pragma clang diagnostic pop
    result(nil);
  }
}

- (void)periodicallyShow:(NSDictionary *_Nonnull)arguments
                  result:(FlutterResult _Nonnull)result {
  if (@available(iOS 10.0, *)) {
    UNMutableNotificationContent *content =
        [self buildStandardNotificationContent:arguments result:result];
    UNTimeIntervalNotificationTrigger *trigger =
        [self buildUserNotificationTimeIntervalTrigger:arguments];
    [self addNotificationRequest:[self getIdentifier:arguments]
                         content:content
                          result:result
                         trigger:trigger];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UILocalNotification *notification =
        [self buildStandardUILocalNotification:arguments];
#pragma clang diagnostic pop
    NSTimeInterval timeInterval = 0;
    if ([self containsKey:REPEAT_INTERVAL_MILLISECODNS
            forDictionary:arguments]) {
      NSInteger repeatIntervalMilliseconds =
          [arguments[REPEAT_INTERVAL_MILLISECODNS] integerValue];
      timeInterval = repeatIntervalMilliseconds / 1000.0;
      notification.repeatInterval = NSCalendarUnitSecond;
    }
    switch ([arguments[REPEAT_INTERVAL] integerValue]) {
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
#pragma clang diagnostic pop
    result(nil);
  }
}

- (void)cancel:(NSNumber *)id result:(FlutterResult _Nonnull)result {
  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
    NSArray *idsToRemove =
        [[NSArray alloc] initWithObjects:[id stringValue], nil];
    [center removePendingNotificationRequestsWithIdentifiers:idsToRemove];
    [center removeDeliveredNotificationsWithIdentifiers:idsToRemove];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *notifications =
        [UIApplication sharedApplication].scheduledLocalNotifications;
#pragma clang diagnostic pop
    for (int i = 0; i < [notifications count]; i++) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      UILocalNotification *localNotification = [notifications objectAtIndex:i];
#pragma clang diagnostic pop
      NSNumber *userInfoNotificationId =
          localNotification.userInfo[NOTIFICATION_ID];
      if ([userInfoNotificationId longValue] == [id longValue]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication]
            cancelLocalNotification:localNotification];
#pragma clang diagnostic pop
        break;
      }
    }
  }
  result(nil);
}

- (void)cancelAll:(FlutterResult _Nonnull)result {
  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
    [center removeAllDeliveredNotifications];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
#pragma clang diagnostic pop
  }
  result(nil);
}

- (UNMutableNotificationContent *)
    buildStandardNotificationContent:(NSDictionary *)arguments
                              result:(FlutterResult _Nonnull)result
    API_AVAILABLE(ios(10.0)) {
  UNMutableNotificationContent *content =
      [[UNMutableNotificationContent alloc] init];
  if ([self containsKey:TITLE forDictionary:arguments]) {
    content.title = arguments[TITLE];
  }
  if ([self containsKey:BODY forDictionary:arguments]) {
    content.body = arguments[BODY];
  }
  NSDictionary *persistedPresentationOptions =
      [[NSUserDefaults standardUserDefaults]
          dictionaryForKey:PRESENTATION_OPTIONS_USER_DEFAULTS];
  bool presentAlert = false;
  bool presentSound = false;
  bool presentBadge = false;
  bool presentBanner = false;
  bool presentList = false;
  if (persistedPresentationOptions != nil) {
    presentAlert = [persistedPresentationOptions[PRESENT_ALERT] isEqual:@YES];
    presentSound = [persistedPresentationOptions[PRESENT_SOUND] isEqual:@YES];
    presentBadge = [persistedPresentationOptions[PRESENT_BADGE] isEqual:@YES];
    presentBanner = [persistedPresentationOptions[PRESENT_BANNER] isEqual:@YES];
    presentList = [persistedPresentationOptions[PRESENT_LIST] isEqual:@YES];
  }
  if (arguments[PLATFORM_SPECIFICS] != [NSNull null]) {
    NSDictionary *platformSpecifics = arguments[PLATFORM_SPECIFICS];
    if ([self containsKey:PRESENT_ALERT forDictionary:platformSpecifics]) {
      presentAlert = [[platformSpecifics objectForKey:PRESENT_ALERT] boolValue];
    }
    if ([self containsKey:PRESENT_SOUND forDictionary:platformSpecifics]) {
      presentSound = [[platformSpecifics objectForKey:PRESENT_SOUND] boolValue];
    }
    if ([self containsKey:PRESENT_BADGE forDictionary:platformSpecifics]) {
      presentBadge = [[platformSpecifics objectForKey:PRESENT_BADGE] boolValue];
    }
    if ([self containsKey:PRESENT_BANNER forDictionary:platformSpecifics]) {
      presentBanner =
          [[platformSpecifics objectForKey:PRESENT_BANNER] boolValue];
    }
    if ([self containsKey:PRESENT_LIST forDictionary:platformSpecifics]) {
      presentList = [[platformSpecifics objectForKey:PRESENT_LIST] boolValue];
    }
    if ([self containsKey:BADGE_NUMBER forDictionary:platformSpecifics]) {
      content.badge = [platformSpecifics objectForKey:BADGE_NUMBER];
    }
    if ([self containsKey:THREAD_IDENTIFIER forDictionary:platformSpecifics]) {
      content.threadIdentifier = platformSpecifics[THREAD_IDENTIFIER];
    }
    if ([self containsKey:ATTACHMENTS forDictionary:platformSpecifics]) {
      NSArray<NSDictionary *> *attachments = platformSpecifics[ATTACHMENTS];
      if (attachments.count > 0) {
        NSMutableArray<UNNotificationAttachment *> *notificationAttachments =
            [NSMutableArray arrayWithCapacity:attachments.count];
        for (NSDictionary *attachment in attachments) {
          NSError *error;

          NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
          if ([self containsKey:ATTACHMENT_HIDE_THUMBNAIL
                  forDictionary:attachment]) {
            NSNumber *hideThumbnail = attachment[ATTACHMENT_HIDE_THUMBNAIL];
            [options
                setObject:hideThumbnail
                   forKey:UNNotificationAttachmentOptionsThumbnailHiddenKey];
          }
          if ([self containsKey:ATTACHMENT_THUMBNAIL_CLIPPING_RECT
                  forDictionary:attachment]) {
            NSDictionary *thumbnailClippingRect =
                attachment[ATTACHMENT_THUMBNAIL_CLIPPING_RECT];
            CGRect rect =
                CGRectMake([thumbnailClippingRect[@"x"] doubleValue],
                           [thumbnailClippingRect[@"y"] doubleValue],
                           [thumbnailClippingRect[@"width"] doubleValue],
                           [thumbnailClippingRect[@"height"] doubleValue]);
            NSDictionary *rectDict =
                CFBridgingRelease(CGRectCreateDictionaryRepresentation(rect));
            [options
                setObject:rectDict
                   forKey:
                       UNNotificationAttachmentOptionsThumbnailClippingRectKey];
          }

          UNNotificationAttachment *notificationAttachment =
              [UNNotificationAttachment
                  attachmentWithIdentifier:attachment[ATTACHMENT_IDENTIFIER]
                                       URL:[NSURL
                                               fileURLWithPath:
                                                   attachment
                                                       [ATTACHMENT_FILE_PATH]]
                                   options:options
                                     error:&error];
          if (error) {
            result(getFlutterError(error));
            return nil;
          }
          [notificationAttachments addObject:notificationAttachment];
        }
        content.attachments = notificationAttachments;
      }
    }
    if ([self containsKey:SOUND forDictionary:platformSpecifics]) {
      content.sound = [UNNotificationSound soundNamed:platformSpecifics[SOUND]];
    }
    if ([self containsKey:SUBTITLE forDictionary:platformSpecifics]) {
      content.subtitle = platformSpecifics[SUBTITLE];
    }
    if (@available(iOS 15.0, *)) {
      if ([self containsKey:INTERRUPTION_LEVEL
              forDictionary:platformSpecifics]) {
        NSNumber *interruptionLevel = platformSpecifics[INTERRUPTION_LEVEL];

        if (interruptionLevel != nil) {
          content.interruptionLevel = [interruptionLevel integerValue];
        }
      }
    }
    if ([self containsKey:@"categoryIdentifier"
            forDictionary:platformSpecifics]) {
      content.categoryIdentifier = platformSpecifics[@"categoryIdentifier"];
    }
  }

  if (presentSound && content.sound == nil) {
    content.sound = UNNotificationSound.defaultSound;
  }
  content.userInfo = [self buildUserDict:arguments[ID]
                                   title:content.title
                            presentAlert:presentAlert
                            presentSound:presentSound
                            presentBadge:presentBadge
                           presentBanner:presentBanner
                             presentList:presentList
                                 payload:arguments[PAYLOAD]];
  return content;
}

- (UNCalendarNotificationTrigger *)buildUserNotificationCalendarTrigger:
    (id)arguments NS_AVAILABLE_IOS(10.0) {
  NSString *scheduledDateTime = arguments[SCHEDULED_DATE_TIME];
  NSString *timeZoneName = arguments[TIME_ZONE_NAME];

  NSNumber *matchDateComponents = arguments[MATCH_DATE_TIME_COMPONENTS];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSTimeZone *timezone = [NSTimeZone timeZoneWithName:timeZoneName];
  NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
  [dateFormatter setTimeZone:timezone];
  dateFormatter.formatOptions = NSISO8601DateFormatWithFractionalSeconds |
                                NSISO8601DateFormatWithInternetDateTime;
  NSDate *date = [dateFormatter dateFromString:scheduledDateTime];

  calendar.timeZone = timezone;
  if (matchDateComponents != nil) {
    if ([matchDateComponents integerValue] == Time) {
      NSDateComponents *dateComponents =
          [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute |
                                NSCalendarUnitSecond | NSCalendarUnitTimeZone)
                      fromDate:date];
      return [UNCalendarNotificationTrigger
          triggerWithDateMatchingComponents:dateComponents
                                    repeats:YES];

    } else if ([matchDateComponents integerValue] == DayOfWeekAndTime) {
      NSDateComponents *dateComponents =
          [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitHour |
                                NSCalendarUnitMinute | NSCalendarUnitSecond |
                                NSCalendarUnitTimeZone)
                      fromDate:date];
      return [UNCalendarNotificationTrigger
          triggerWithDateMatchingComponents:dateComponents
                                    repeats:YES];
    } else if ([matchDateComponents integerValue] == DayOfMonthAndTime) {
      NSDateComponents *dateComponents =
          [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour |
                                NSCalendarUnitMinute | NSCalendarUnitSecond |
                                NSCalendarUnitTimeZone)
                      fromDate:date];
      return [UNCalendarNotificationTrigger
          triggerWithDateMatchingComponents:dateComponents
                                    repeats:YES];
    } else if ([matchDateComponents integerValue] == DateAndTime) {
      NSDateComponents *dateComponents =
          [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay |
                                NSCalendarUnitHour | NSCalendarUnitMinute |
                                NSCalendarUnitSecond | NSCalendarUnitTimeZone)
                      fromDate:date];
      return [UNCalendarNotificationTrigger
          triggerWithDateMatchingComponents:dateComponents
                                    repeats:YES];
    }
    return nil;
  }
  NSDateComponents *dateComponents = [calendar
      components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                  NSCalendarUnitHour | NSCalendarUnitMinute |
                  NSCalendarUnitSecond | NSCalendarUnitTimeZone)
        fromDate:date];
  return [UNCalendarNotificationTrigger
      triggerWithDateMatchingComponents:dateComponents
                                repeats:NO];
}

- (UNTimeIntervalNotificationTrigger *)buildUserNotificationTimeIntervalTrigger:
    (id)arguments API_AVAILABLE(ios(10.0)) {

  if ([self containsKey:REPEAT_INTERVAL_MILLISECODNS forDictionary:arguments]) {
    NSInteger repeatIntervalMilliseconds =
        [arguments[REPEAT_INTERVAL_MILLISECODNS] integerValue];
    return [UNTimeIntervalNotificationTrigger
        triggerWithTimeInterval:repeatIntervalMilliseconds / 1000.0
                        repeats:YES];
  }
  switch ([arguments[REPEAT_INTERVAL] integerValue]) {
  case EveryMinute:
    return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60
                                                              repeats:YES];
  case Hourly:
    return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 * 60
                                                              repeats:YES];
  case Daily:
    return
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 * 60 * 24
                                                           repeats:YES];
    break;
  case Weekly:
    return [UNTimeIntervalNotificationTrigger
        triggerWithTimeInterval:60 * 60 * 24 * 7
                        repeats:YES];
  }
  return nil;
}

- (NSDictionary *)buildUserDict:(NSNumber *)id
                          title:(NSString *)title
                   presentAlert:(bool)presentAlert
                   presentSound:(bool)presentSound
                   presentBadge:(bool)presentBadge
                  presentBanner:(bool)presentBanner
                    presentList:(bool)presentList
                        payload:(NSString *)payload {
  NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
  userDict[NOTIFICATION_ID] = id;
  if (title) {
    userDict[TITLE] = title;
  }
  userDict[PRESENT_ALERT] = [NSNumber numberWithBool:presentAlert];
  userDict[PRESENT_SOUND] = [NSNumber numberWithBool:presentSound];
  userDict[PRESENT_BADGE] = [NSNumber numberWithBool:presentBadge];
  userDict[PRESENT_BANNER] = [NSNumber numberWithBool:presentBanner];
  userDict[PRESENT_LIST] = [NSNumber numberWithBool:presentList];
  userDict[PAYLOAD] = payload;
  return userDict;
}

- (void)addNotificationRequest:(NSString *)identifier
                       content:(UNMutableNotificationContent *)content
                        result:(FlutterResult _Nonnull)result
                       trigger:(UNNotificationTrigger *)trigger
    API_AVAILABLE(ios(10.0)) {
  UNNotificationRequest *notificationRequest =
      [UNNotificationRequest requestWithIdentifier:identifier
                                           content:content
                                           trigger:trigger];
  UNUserNotificationCenter *center =
      [UNUserNotificationCenter currentNotificationCenter];
  [center addNotificationRequest:notificationRequest
           withCompletionHandler:^(NSError *_Nullable error) {
             if (error == nil) {
               result(nil);
               return;
             }
             result(getFlutterError(error));
           }];
}

- (BOOL)isAFlutterLocalNotification:(NSDictionary *)userInfo {
  return userInfo != nil && userInfo[NOTIFICATION_ID] &&
         userInfo[PRESENT_ALERT] && userInfo[PRESENT_SOUND] &&
         userInfo[PRESENT_BADGE] && userInfo[PAYLOAD];
}

- (void)handleSelectNotification:(NSInteger)notificationId
                         payload:(NSString *)payload {
  NSMutableDictionary *arguments = [[NSMutableDictionary alloc] init];
  NSNumber *notificationIdNumber = [NSNumber numberWithInteger:notificationId];
  arguments[@"notificationId"] = notificationIdNumber;
  arguments[PAYLOAD] = payload;
  arguments[NOTIFICATION_RESPONSE_TYPE] = [NSNumber numberWithInteger:0];
  [_channel invokeMethod:@"didReceiveNotificationResponse" arguments:arguments];
}

- (BOOL)containsKey:(NSString *)key forDictionary:(NSDictionary *)dictionary {
  return dictionary[key] != [NSNull null] && dictionary[key] != nil;
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:
             (void (^)(UNNotificationPresentationOptions))completionHandler
    NS_AVAILABLE_IOS(10.0) {
  if (![self
          isAFlutterLocalNotification:notification.request.content.userInfo]) {
    return;
  }
  UNNotificationPresentationOptions presentationOptions = 0;
  NSNumber *presentAlertValue =
      (NSNumber *)notification.request.content.userInfo[PRESENT_ALERT];
  NSNumber *presentSoundValue =
      (NSNumber *)notification.request.content.userInfo[PRESENT_SOUND];
  NSNumber *presentBadgeValue =
      (NSNumber *)notification.request.content.userInfo[PRESENT_BADGE];
  NSNumber *presentBannerValue =
      (NSNumber *)notification.request.content.userInfo[PRESENT_BANNER];
  NSNumber *presentListValue =
      (NSNumber *)notification.request.content.userInfo[PRESENT_LIST];
  bool presentAlert = [presentAlertValue boolValue];
  bool presentSound = [presentSoundValue boolValue];
  bool presentBadge = [presentBadgeValue boolValue];
  bool presentBanner = [presentBannerValue boolValue];
  bool presentList = [presentListValue boolValue];
  if (@available(iOS 14.0, *)) {
    if (presentBanner) {
      presentationOptions |= UNNotificationPresentationOptionBanner;
    }
    if (presentList) {
      presentationOptions |= UNNotificationPresentationOptionList;
    }
  } else {
    if (presentAlert) {
      presentationOptions |= UNNotificationPresentationOptionAlert;
    }
  }
  if (presentSound) {
    presentationOptions |= UNNotificationPresentationOptionSound;
  }
  if (presentBadge) {
    presentationOptions |= UNNotificationPresentationOptionBadge;
  }
  completionHandler(presentationOptions);
}

- (NSMutableDictionary *)extractNotificationResponseDict:
    (UNNotificationResponse *_Nonnull)response NS_AVAILABLE_IOS(10.0) {
  NSMutableDictionary *notitificationResponseDict =
      [[NSMutableDictionary alloc] init];
  NSInteger notificationId =
      [response.notification.request.identifier integerValue];
  NSString *payload =
      (NSString *)response.notification.request.content.userInfo[PAYLOAD];
  NSNumber *notificationIdNumber = [NSNumber numberWithInteger:notificationId];
  notitificationResponseDict[@"notificationId"] = notificationIdNumber;
  notitificationResponseDict[PAYLOAD] = payload;
  if ([response.actionIdentifier
          isEqualToString:UNNotificationDefaultActionIdentifier]) {
    notitificationResponseDict[NOTIFICATION_RESPONSE_TYPE] =
        [NSNumber numberWithInteger:0];
  } else if (response.actionIdentifier != nil &&
             ![response.actionIdentifier
                 isEqualToString:UNNotificationDismissActionIdentifier]) {
    notitificationResponseDict[ACTION_ID] = response.actionIdentifier;
    notitificationResponseDict[NOTIFICATION_RESPONSE_TYPE] =
        [NSNumber numberWithInteger:1];
  }

  if ([response respondsToSelector:@selector(userText)]) {
    notitificationResponseDict[@"input"] =
        [(UNTextInputNotificationResponse *)response userText];
  }
  return notitificationResponseDict;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler
    NS_AVAILABLE_IOS(10.0) {
  if (![self isAFlutterLocalNotification:response.notification.request.content
                                             .userInfo]) {
    return;
  }

  NSInteger notificationId =
      [response.notification.request.identifier integerValue];
  NSString *payload =
      (NSString *)response.notification.request.content.userInfo[PAYLOAD];

  if ([response.actionIdentifier
          isEqualToString:UNNotificationDefaultActionIdentifier]) {
    if (_initialized) {
      [self handleSelectNotification:notificationId payload:payload];
    } else {
      _launchNotificationResponseDict =
          [self extractNotificationResponseDict:response];
      _launchingAppFromNotification = true;
    }
    completionHandler();
  } else if (response.actionIdentifier != nil) {
    NSMutableDictionary *notificationResponseDict =
        [self extractNotificationResponseDict:response];
    NSArray<NSString *> *foregroundActionIdentifiers =
        [[NSUserDefaults standardUserDefaults]
            stringArrayForKey:FOREGROUND_ACTION_IDENTIFIERS];
    if ([foregroundActionIdentifiers indexOfObject:response.actionIdentifier] !=
        NSNotFound) {
      if (_initialized) {
        [_channel invokeMethod:@"didReceiveNotificationResponse"
                     arguments:notificationResponseDict];
      } else {
        _launchNotificationResponseDict = notificationResponseDict;
        _launchingAppFromNotification = true;
      }
    } else {
      if (!actionEventSink) {
        actionEventSink = [[ActionEventSink alloc] init];
      }

      [actionEventSink addItem:notificationResponseDict];
      [_flutterEngineManager startEngineIfNeeded:actionEventSink
                                 registerPlugins:registerPlugins];
    }

    completionHandler();
  }
}

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if (launchOptions != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UILocalNotification *launchNotification =
        (UILocalNotification *)[launchOptions
            objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
#pragma clang diagnostic pop
    _launchingAppFromNotification =
        launchNotification != nil &&
        [self isAFlutterLocalNotification:launchNotification.userInfo];
    if (_launchingAppFromNotification) {
      _launchNotificationResponseDict = [[NSMutableDictionary alloc] init];
      _launchNotificationResponseDict[@"notificationId"] =
          launchNotification.userInfo[NOTIFICATION_ID];
      _launchNotificationResponseDict[PAYLOAD] =
          launchNotification.userInfo[PAYLOAD];
      _launchNotificationResponseDict[NOTIFICATION_RESPONSE_TYPE] =
          [NSNumber numberWithInteger:0];
    }
  }

  return YES;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
#pragma clang diagnostic pop
  if (@available(iOS 10.0, *)) {
    return;
  }
  if (![self isAFlutterLocalNotification:notification.userInfo]) {
    return;
  }

  NSMutableDictionary *arguments = [[NSMutableDictionary alloc] init];
  arguments[ID] = notification.userInfo[NOTIFICATION_ID];
  if (notification.userInfo[TITLE] != [NSNull null]) {
    arguments[TITLE] = notification.userInfo[TITLE];
  }
  if (notification.alertBody != nil) {
    arguments[BODY] = notification.alertBody;
  }
  if (notification.userInfo[PAYLOAD] != [NSNull null]) {
    arguments[PAYLOAD] = notification.userInfo[PAYLOAD];
  }
  [_channel invokeMethod:DID_RECEIVE_LOCAL_NOTIFICATION arguments:arguments];
}

@end
