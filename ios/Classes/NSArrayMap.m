#import "NSArrayMap.h"

@implementation NSArray (Map)

- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj)];
    }];
    return result;
}

@end
