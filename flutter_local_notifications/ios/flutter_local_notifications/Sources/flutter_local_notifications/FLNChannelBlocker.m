#import "./include/flutter_local_notifications/FLNChannelBlocker.h"
#import <Flutter/Flutter.h>
#import <objc/runtime.h>

@implementation FLNChannelBlocker

/// Determines if a FlutterMethodChannel call should be suppressed.
/// Suppresses all firebase_messaging notification taps when FLN is also handling notifications.
+ (BOOL)shouldSuppressChannel:(FlutterMethodChannel *)channel
                       method:(NSString *)method
                        args:(id)args {
  // Suppress firebase_messaging background notification taps when FLN is also handling notifications
  // since this is handler by onDidReceiveNotificationResponse of flutter_local_notifications
  if ([method isEqualToString:@"Messaging#onMessageOpenedApp"]) return YES;

  // Do not suppress other methods
  return NO;
}

/// Installs method swizzling on FlutterMethodChannel to intercept and suppress
/// duplicate notification handling calls.
+ (void)swizzleChannelMethods {
  Class cls = [FlutterMethodChannel class];

  Method orig1 = class_getInstanceMethod(cls, @selector(invokeMethod:arguments:));
  Method orig2 = class_getInstanceMethod(cls, @selector(invokeMethod:arguments:result:));

  IMP orig1IMP = method_getImplementation(orig1);
  IMP orig2IMP = orig2 ? method_getImplementation(orig2) : NULL;

  // Replacement for -invokeMethod:arguments:
  void (^block1)(id, NSString *, id) = ^(id selfObj, NSString *method, id args) {
    if ([FLNChannelBlocker shouldSuppressChannel:selfObj method:method args:args]) return;
    ((void(*)(id, SEL, NSString *, id))orig1IMP)(selfObj, @selector(invokeMethod:arguments:), method, args);
  };
  IMP new1IMP = imp_implementationWithBlock(block1);
  method_setImplementation(orig1, new1IMP);

  // Replacement for -invokeMethod:arguments:result:
  if (orig2IMP) {
    void (^block2)(id, NSString *, id, FlutterResult) = ^(id selfObj, NSString *method, id args, FlutterResult result) {
      if ([FLNChannelBlocker shouldSuppressChannel:selfObj method:method args:args]) {
        if (result) result(nil);
        return;
      }
      ((void(*)(id, SEL, NSString *, id, FlutterResult))orig2IMP)
        (selfObj, @selector(invokeMethod:arguments:result:), method, args, result);
    };
    IMP new2IMP = imp_implementationWithBlock(block2);
    method_setImplementation(orig2, new2IMP);
  }
}

/// Install the interception/suppression on FlutterMethodChannel.
/// This method should be called once during plugin registration.
+ (void)installBlocker {
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    [FLNChannelBlocker swizzleChannelMethods];
  });
}

@end
