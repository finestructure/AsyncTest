//
//  SenTestCase+Async.h
//
//  Created by Sven A. Schmidt on 2012-08-06.
//

#import <SenTestingKit/SenTestingKit.h>

@interface SenTestCase (Async)

@property (nonatomic, readonly) dispatch_queue_t serialQueue;

- (void)waitWithTimeout:(NSTimeInterval)timeout forSuccessInBlock:(BOOL(^)())block;

@end
