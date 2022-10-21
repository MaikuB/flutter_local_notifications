//
//  FlutterEngineManager.h
//  flutter_local_notifications
//
//  Created by Sebastian Roth on 12/30/21.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>

#import "ActionEventSink.h"
#import "FlutterEngineManager.h"

NS_ASSUME_NONNULL_BEGIN

static FlutterEngine *backgroundEngine;

@implementation FlutterEngineManager {
  NSUserDefaults *_persistentState;
}

+ (BOOL)shouldAddAppDelegateToRegistrar:
    (NSObject<FlutterPluginRegistrar> *)registrar {
  return backgroundEngine == nil ||
         registrar.messenger != backgroundEngine.binaryMessenger;
}

- (instancetype)init {
  self = [super init];

  if (self) {
    _persistentState = [NSUserDefaults standardUserDefaults];
  }

  return self;
}

- (void)startEngineIfNeeded:(ActionEventSink *)actionEventSink
            registerPlugins:(FlutterPluginRegistrantCallback)registerPlugins {
  if (backgroundEngine) {
    return;
  }

  NSNumber *dispatcherHandle =
      [_persistentState objectForKey:@"dispatcher_handle"];

  FlutterCallbackInformation *info = [FlutterCallbackCache
      lookupCallbackInformation:[dispatcherHandle longValue]];

  if (!info) {
    NSLog(@"Callback information could not be retrieved");
    return;
  }

  NSString *entryPoint = info.callbackName;
  NSString *uri = info.callbackLibraryPath;

  backgroundEngine =
      [[FlutterEngine alloc] initWithName:@"FlutterLocalNotificationsIsolate"
                                  project:nil
                   allowHeadlessExecution:true];

  dispatch_async(dispatch_get_main_queue(), ^{
    FlutterEventChannel *channel = [FlutterEventChannel
        eventChannelWithName:
            @"dexterous.com/flutter/local_notifications/actions"
             binaryMessenger:backgroundEngine.binaryMessenger];

    [backgroundEngine runWithEntrypoint:entryPoint libraryURI:uri];
    [channel setStreamHandler:actionEventSink];

    NSAssert(registerPlugins != nil, @"failed to set registerPlugins");
    registerPlugins(backgroundEngine);
  });
}

- (void)registerDispatcherHandle:(NSNumber *)dispatcherHandle
                  callbackHandle:(NSNumber *)callbackHandle {
  [_persistentState setObject:callbackHandle forKey:@"callback_handle"];
  [_persistentState setObject:dispatcherHandle forKey:@"dispatcher_handle"];
}

/// Called from the dart side to know which Dart method to call up next to
/// actually handle the notification.
- (NSNumber *)getCallbackHandle {
  return [_persistentState valueForKey:@"callback_handle"];
}

@end

NS_ASSUME_NONNULL_END
