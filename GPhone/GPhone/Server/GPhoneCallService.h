//
//  GPhoneCallService.h
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RTCView.h"
#import "RelayStatusModel.h"

@protocol GPhoneCallServiceDelegate<NSObject>
@optional
- (void)relayStatusWith:(RelayStatusModel*) statusModel;
@end

@interface GPhoneCallService : NSObject <RTCDelegate>
@property (strong, nonatomic) RTCView *callingView;
@property (assign, nonatomic) id<GPhoneCallServiceDelegate> delegate;
+(GPhoneCallService *)sharedManager;

/*
 获取RelayStatus
 */
- (void)relayStatus:(unsigned int)relaySN;
/*
 注册Relay
 */
- (void) relayLogin:(unsigned int)relaySN;
/*
 呼出
 */
- (void)dialWithNumber:(NSString *)number nickName:(NSString *)name byRelay:(NSString *)relay;
/*
 主动挂断
 */
- (void)hangup;

@end
