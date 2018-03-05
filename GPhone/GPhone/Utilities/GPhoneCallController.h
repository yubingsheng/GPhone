//
//  GPhoneCallController.h
//  GPhone
//
//  Created by 郁兵生 on 2018/3/5.
//  Copyright © 2018年 郁兵生. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

@interface GPhoneCallController : NSObject

- (void)startCallWithHandle:(NSString*)handle;
- (void)endCall;

@property (nonatomic, strong) NSUUID* outCallUUID;
//@property (nonatomic, strong) NSString* currentHandle;
@end

