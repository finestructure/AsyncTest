//
//  SenTestCase+Async.m
//
//  Created by Sven A. Schmidt on 2012-08-06.
//

#import "SenTestCase+Async.h"

@implementation SenTestCase (Async)

- (dispatch_queue_t)serialQueue
{
  static dispatch_queue_t serialQueue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    serialQueue = dispatch_queue_create("SenTestCase.serialQueue", DISPATCH_QUEUE_SERIAL);
  });
  return serialQueue;
}


// new version based on GHUnit
- (void)waitWithTimeout:(NSTimeInterval)timeout forSuccessInBlock:(BOOL(^)())block
{
  BOOL(^serialBlock)() = ^BOOL{
    __block BOOL result;
    // suppress spurious analyser warning
#ifndef __clang_analyzer__
    dispatch_sync(self.serialQueue, ^{
      if (block) {
        result = block();
      }
    });
#endif
    return result;
  };
  NSArray *_runLoopModes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSRunLoopCommonModes, nil];
  
  NSTimeInterval checkEveryInterval = 0.01;
  NSDate *runUntilDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
  NSInteger runIndex = 0;
  while(! serialBlock()) {
    NSString *mode = [_runLoopModes objectAtIndex:(runIndex++ % [_runLoopModes count])];
    
    @autoreleasepool {
      if (!mode || ![[NSRunLoop currentRunLoop] runMode:mode beforeDate:[NSDate dateWithTimeIntervalSinceNow:checkEveryInterval]]) {
        // If there were no run loop sources or timers then we should sleep for the interval
        [NSThread sleepForTimeInterval:checkEveryInterval];
      }
    }
    
    // If current date is after the run until date
    if ([runUntilDate compare:[NSDate date]] == NSOrderedAscending) {
      break;
    }
  }
}


@end
