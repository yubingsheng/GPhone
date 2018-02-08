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
- (void)versionStatusWith:(int) status;
@end

@interface GPhoneCallService : NSObject <RTCDelegate>
@property (strong, nonatomic) RTCView *callingView;
@property (assign, nonatomic) id<GPhoneCallServiceDelegate> delegate;
@property (strong, nonatomic) MBProgressHUD *hud;
+(GPhoneCallService *)sharedManager;

/*
 获取RelayStatus
 */
- (void)relayStatus:(unsigned int)relaySN;
/*
 注册Relay
 */
- (void) relayLoginWith:(unsigned int)relay relayName:(NSString*)name;
/*
 呼出
 */
- (void)dialWith:(ContactModel *)contactModel;
/*
 分机号
 */
- (void)dialWith_dtmf:(NSString *)number;
/*
 主动挂断
 */
- (void)hangup;
/*
 版本检查
 */
- (void)versionCheck;
@end
