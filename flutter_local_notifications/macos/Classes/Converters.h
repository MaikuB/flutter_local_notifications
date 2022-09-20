//
//  Converters.h
//  flutter_local_notifications
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface Converters : NSObject

+ (UNNotificationCategoryOptions)parseNotificationCategoryOptions:
    (NSArray *)options API_AVAILABLE(ios(10.0), macos(10.14));
+ (UNNotificationActionOptions)parseNotificationActionOptions:(NSArray *)options
    API_AVAILABLE(ios(10.0), macos(10.14));

@end

NS_ASSUME_NONNULL_END
