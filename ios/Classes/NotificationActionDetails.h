//
//  NotificationActionDetails.h
//  Pods
//
//  Created by Gianluca Paradiso on 05/12/2019.
//

#import <Foundation/Foundation.h>

@interface NotificationActionDetails : NSObject
    @property(nonatomic, strong) NSString *title;
    @property(nonatomic, strong) NSString *actionKey;
    @property(nonatomic, strong) NSDictionary<NSString*, NSString*> *extras;
@end
