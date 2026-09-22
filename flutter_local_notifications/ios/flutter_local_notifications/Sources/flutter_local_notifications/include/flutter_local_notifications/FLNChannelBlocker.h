#import <Foundation/Foundation.h>

/// Utility class for preventing duplicate notification handling between
/// flutter_local_notifications and firebase_messaging.
@interface FLNChannelBlocker : NSObject

/// Install the interception/suppression on FlutterMethodChannel.
/// This method should be called once during plugin registration.
+ (void)installBlocker;

@end
