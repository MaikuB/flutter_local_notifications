#import <Foundation/Foundation.h>
#import "NotificationTime.h"
#import "NotificationActionDetails.h"

@interface NotificationDetails : NSObject
    @property(nonatomic, strong) NSNumber *id;
    @property(nonatomic, strong) NSString *title;
    @property(nonatomic, strong) NSString *body;
    @property(nonatomic, strong) NSString *payload;
    @property(nonatomic) bool presentAlert;
    @property(nonatomic) bool presentSound;
    @property(nonatomic) bool presentBadge;
    @property(nonatomic, strong) NSString *sound;
    @property(nonatomic, strong) NSNumber *secondsSinceEpoch;
    @property(nonatomic, strong) NSNumber *repeatInterval;
    @property(nonatomic, strong) NotificationTime *repeatTime;
    @property(nonatomic, strong) NSNumber *day;
    @property(nonatomic, strong) NSMutableArray<NotificationActionDetails *> *actions;
@end
