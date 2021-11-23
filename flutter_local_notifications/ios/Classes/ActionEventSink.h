//
//  ActionEventSink.h
//  flutter_local_notifications
//
//  Created by Sebastian Roth on 11/1/20.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActionEventSink : NSObject <FlutterStreamHandler>

- (void)addItem:(NSDictionary *)item;

@end

NS_ASSUME_NONNULL_END
