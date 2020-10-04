#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationAttachment : NSObject
    @property(nonatomic, strong) NSString *identifier;
    @property(nonatomic, strong) NSString *filePath;
@end

NS_ASSUME_NONNULL_END
