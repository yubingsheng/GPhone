//
//  GPhoneCallController.m
//  GPhone
//
//  Created by 郁兵生 on 2018/3/5.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GPhoneCallController.h"

@interface GPhoneCallController ()

@property (nonatomic, strong) CXCallController* callController;

@end

@implementation GPhoneCallController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _callController = [[CXCallController alloc] init];
    }
    return self;
}

- (void)startCallWithHandle:(NSString*)handle{
    self.outCallUUID = [NSUUID UUID];
    //self.startConnectingDate = [NSDate date];
    //self.currentHandle = handle;
    CXHandle* handleNumber = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    CXStartCallAction* action = [[CXStartCallAction alloc] initWithCallUUID:self.outCallUUID handle:handleNumber];
    action.video = NO;
    //action.contactIdentifier = @"李先生";
    CXTransaction* transaction = [[CXTransaction alloc] init];
    [transaction addAction:action];
    [self requestTransaction:transaction];
    NSLog(@"SHAY start call execed");
}

- (void)endCall{
    CXEndCallAction* endAction = [[CXEndCallAction alloc] initWithCallUUID:self.outCallUUID];
    CXTransaction* transaction = [[CXTransaction alloc] init];
    [transaction addAction:endAction];
    [self requestTransaction:transaction];
}

- (void)requestTransaction:(CXTransaction*)transaction{
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"requestTransaction error %@", error);
        }
    }];
}

@end

