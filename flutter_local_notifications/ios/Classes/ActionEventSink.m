//
//  ActionEventSink.m
//  flutter_local_notifications
//
//  Created by Sebastian Roth on 11/1/20.
//

#import "ActionEventSink.h"

@interface ActionEventSink () {
  NSMutableArray<NSDictionary *> *cache;
  FlutterEventSink eventSink;
}

@end

@implementation ActionEventSink

- (instancetype)init {
  self = [super init];
  if (self) {
    cache = [NSMutableArray array];
  }
  return self;
}

- (void)addItem:(NSDictionary *)item {
  if (eventSink) {
    eventSink(item);
  } else {
    [cache addObject:item];
  }
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:
                                           (nonnull FlutterEventSink)events {
  for (NSDictionary *item in cache) {
    events(item);
  }
  [cache removeAllObjects];

  eventSink = events;

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  eventSink = nil;

  return nil;
}

@end
