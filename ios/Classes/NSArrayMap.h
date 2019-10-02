@interface NSArray (Map)

- (NSArray *)map:(id (^)(id obj))block;

@end
