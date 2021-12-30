#import "Converters.h"

@implementation Converters

+ (UNNotificationCategoryOptions)parseNotificationCategoryOptions:
    (NSArray *)options API_AVAILABLE(ios(10.0)) {
  int result = UNNotificationCategoryOptionNone;

  for (NSNumber *option in options) {
    result |= [option intValue];
  }

  return result;
}

+ (UNNotificationActionOptions)parseNotificationActionOptions:(NSArray *)options
    API_AVAILABLE(ios(10.0)) {
  int result = UNNotificationActionOptionNone;

  for (NSNumber *option in options) {
    result |= [option intValue];
  }

  return result;
}

@end
