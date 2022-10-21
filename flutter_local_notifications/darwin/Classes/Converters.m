#import "Converters.h"

@implementation Converters

+ (UNNotificationCategoryOptions)parseNotificationCategoryOptions:
    (NSArray *)options {
  int result = UNNotificationCategoryOptionNone;

  for (NSNumber *option in options) {
    result |= [option intValue];
  }

  return result;
}

+ (UNNotificationActionOptions)parseNotificationActionOptions:
    (NSArray *)options {
  int result = UNNotificationActionOptionNone;

  for (NSNumber *option in options) {
    result |= [option intValue];
  }

  return result;
}

@end
