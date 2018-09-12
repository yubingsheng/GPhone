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

typedef void (^RequestStatusBlock)(BOOL succeed); //普通block
typedef void(^RequestErrorStatusBlook)(NSInteger errorCode);

@protocol GPhoneCallServiceDelegate<NSObject>
@optional
- (void)relayStatusWith:(RelayStatusModel*) statusModel;
- (void)versionStatusWith:(int) status;
@end

@interface GPhoneCallService : NSObject <RTCDelegate>
@property (strong, nonatomic) RTCView *callingView;
@property (assign, nonatomic) id<GPhoneCallServiceDelegate> delegate;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSUUID *uuid;
@property (strong, nonatomic) ContactModel *currentContactModel;

@property (copy, nonatomic) RequestStatusBlock messageBlock;
@property (copy, nonatomic) RequestStatusBlock loginBlock;
@property (copy, nonatomic) RequestStatusBlock relayStatusBlock;
@property (copy, nonatomic) RequestStatusBlock addRelayBlock;
@property (copy, nonatomic) RequestErrorStatusBlook addRelayFailedBlock;
+(GPhoneCallService *)sharedManager;

/*
 获取RelayStatus
 */
- (void)relayStatus:(unsigned int)relaySN relayName:(NSString*)name;
/*
 注册Relay
 */
- (void) relayLoginWith:(unsigned int)relay relayName:(NSString*)name;
/*
 sessionInvite
 */
- (void)sessionInviteWith:(NSString*)phoneNumber;
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
 响铃
 */
- (void)callInAlertingWith:(NSString*)callId relaySN:(NSString*)relaySN;
/*
 callRelease
 */
- (void)callRelease;
/*
 应答
 */
- (void)callInAnswer;
/*
 版本检查
 */
- (void)versionCheck;
/*
 sms
 */
- (void)sendMsgWith:(MessageModel*)text;
/*
 App内的通话界面
 */
- (void)callingViewWithCallType:(BOOL)isIn;
#pragma mark - HUD
/*
 hud
 */
- (void)hiddenWith:(NSString*)title;

//#error 网络运营商改变调用Galaxy api (down)
//#error message优化
//#error 电话模式：通话时手机放耳边，屏幕暗掉，离开常亮 (down)
//#error Relay下线提示（errorcode == 8）
@end
