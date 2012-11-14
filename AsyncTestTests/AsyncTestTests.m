//
//  AsyncTestTests.m
//  AsyncTestTests
//
//  Created by Sven A. Schmidt on 19.08.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "AsyncTestTests.h"
#import "SenTestCase+Async.h"


@interface Downloader : NSObject
- (void)startDownload;
@end

@implementation Downloader


- (void)startDownload
{
  [self performSelector:@selector(sendNotification) withObject:nil afterDelay:1];
}


- (void)startDownloadWithCompletion:(void (^)())completion
{
  NSTimeInterval delay = 1;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_current_queue(), completion);
}


- (void)sendNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadCompleted" object:self];
}

@end



@implementation AsyncTestTests


- (void)test_notification
{
  Downloader *dl = [[Downloader alloc] init];
  
  __block BOOL received = NO;
  [[NSNotificationCenter defaultCenter] addObserverForName:@"DownloadCompleted" object:dl queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    received = YES;
  }];
  
  [dl startDownload];
  
  [self waitWithTimeout:1.1 forSuccessInBlock:^BOOL{
    return received;
  }];
  STAssertTrue(received, nil);
}


- (void)test_completion
{
  Downloader *dl = [[Downloader alloc] init];
  
  __block BOOL received = NO;
  [dl startDownloadWithCompletion:^{
    received = YES;
  }];
  
  [self waitWithTimeout:1.1 forSuccessInBlock:^BOOL{
    return received;
  }];
  STAssertTrue(received, nil);
}


@end
