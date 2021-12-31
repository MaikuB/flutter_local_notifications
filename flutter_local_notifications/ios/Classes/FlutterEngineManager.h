//
//  FlutterEngineManager.h
//  flutter_local_notifications
//
//  Created by Sebastian Roth on 12/30/21.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>

#import "ActionEventSink.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlutterEngineManager : NSObject

/// The App Delegate used by this plugin should only be added to the main
/// isolate in a Flutter App.
///
/// This method checks whether the background engine is running or whether the
/// registrat belongs to it.
+ (BOOL)shouldAddAppDelegateToRegistrar:
    (NSObject<FlutterPluginRegistrar> *)registrar;

- (void)startEngineIfNeeded:(ActionEventSink *)actionEventSink
            registerPlugins:(FlutterPluginRegistrantCallback)registerPlugins;

- (void)registerDispatcherHandle:(NSNumber *)dispatcherHandle
                  callbackHandle:(NSNumber *)callbackHandle;

/// Called from the dart side to know which Dart method to call up next to
/// actually handle the notification.
- (NSNumber *)getCallbackHandle;

@end

NS_ASSUME_NONNULL_END
