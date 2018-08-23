//
//  CallController.m
//  MyCall
//
//  Created by Mason on 2016/10/12.
//  Copyright © 2016年 Mason. All rights reserved.
//

#import "CallController.h"

@interface CallController ()

@property (nonatomic, strong) CXCallController* callController;

@end

@implementation CallController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _callController = [[CXCallController alloc] init];
    }
    return self;
}

- (void)startCallWithHandle:(NSString*)handle{
	//实际应用中要防止前一个呼叫还在进行中，就发起第二个呼叫。虽然第二个呼叫requestTransaction会失败，但会引起UUID混乱。
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
