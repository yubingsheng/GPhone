//
//  GPhoneCallService.m
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#define STRONGSELF (__bridge GPhoneCallService *)inUserData

#import "CommonCrypto/CommonDigest.h"
#import "GPhoneCallService.h"
#import "galaxy.h"

@implementation GPhoneCallService {
    NSTimer *timerSessionInvite;
    NSTimer *timerCallSetup;
    
    int loginSeqId;
    unsigned int relaySN;
    NSString *pushToken;
    NSString *authCode;
    NSString *gnonce;
    unsigned char callMD5[16];
}

+(GPhoneCallService *)sharedManager{
    static dispatch_once_t predicate;
    static GPhoneCallService * gPhoneCallService;
    dispatch_once(&predicate, ^{
        gPhoneCallService = [[GPhoneCallService alloc] init];
        [gPhoneCallService initGalaxy];
    });
    return gPhoneCallService;
}
- (void) initGalaxy {
    if(!galaxy_init(SessionConfirm_Callback, (__bridge void *)(self),
                    0, 0,
                    CallTrying_Callback,0, CallAlerting_Callback, CallAnswer_Callback, CallReleased_Callback,(__bridge void *)(self),
                    0,0,0,0,0,
                    0,0,0,0,
                    RelayLoginRsp_Callback,0,(__bridge void *)(self))) {
    }
}
#pragma mark - API
- (void)dial {
     galaxy_sessionInvite("10101234111", "13621918174", 0, 0, 0, 0, 0);
}

#pragma mark - Delegate

static void RelayLoginRsp_Callback(void *inUserData, unsigned int relaySN, int seqId, int errorCode)
{
    [STRONGSELF handleRelayLoginRspWithRelaySN:relaySN SeqId:seqId ErrorCode:errorCode];
}

- (void) handleRelayLoginRspWithRelaySN: (unsigned int)relaySN SeqId: (int)seqId ErrorCode: (int)errorCode
{
    NSString *result;
    if(errorCode == 0) {
        //实际应用中，登录成功后，需要将relay、pushToken和authCode写入flash保存，APP启动时，首先读取已经保存的这些数据
        result = @"relay login success";
    }
    else if(errorCode == 3) result = @"gmobile登录失败，请先弹出SIM卡再重新尝试登陆";
    else if(errorCode == 4) result = @"gmobile登录失败，gmobile不在线";
    else result = [NSString stringWithFormat: @"relay login failed with error code %d", errorCode];
    
    
    [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
}

static void SessionConfirm_Callback(void *inUserData, unsigned int relaySN, int menuSupport, int chatSupport, int callSupport, const char *nonce, int errorCode) {
    [STRONGSELF handleSessionConfirmCallBackWithRelaySN:relaySN MenuSupport:menuSupport ChatSupport:chatSupport CallSupport:callSupport Nonce:nonce ErrorCode:errorCode];
}

- (void) handleSessionConfirmCallBackWithRelaySN: (unsigned int)relaySN MenuSupport: (int)menuSupport ChatSupport: (int)chatSupport CallSupport: (int)callSupport Nonce: (const char*)nonce ErrorCode: (int)errorCode {
    [timerSessionInvite invalidate];
    if(errorCode) {
        NSLog(@"SessionConfirm got with error code %d", errorCode);
        return;
    }
    if(!callSupport) {
        NSLog(@"SessionConfirm got without call support");
        return;
    }
    
    if(nonce) {
        gnonce = [[NSString alloc] initWithCString:nonce encoding: NSASCIIStringEncoding];
    }
    
    if(authCode && gnonce) {
        NSString *datas = [authCode stringByAppendingString:gnonce];
        const char *data = [datas UTF8String];
        CC_MD5(data, strlen(data), callMD5);
        galaxy_callSetup(0, callMD5, 0);
    }
    else galaxy_callSetup(0, 0, 0);
    
    [self performSelectorOnMainThread:@selector(startCallSetupTimer) withObject:nil waitUntilDone:NO];
    
}

static void CallTrying_Callback(void *inUserData)
{
    [STRONGSELF handleCallTryingCallBack];
}

- (void) handleCallTryingCallBack
{
    [timerCallSetup invalidate];
}

static void CallAlerting_Callback(void *inUserData) {
    [STRONGSELF handleCallAlertingCallBack];
}

- (void) handleCallAlertingCallBack {
    [self performSelectorOnMainThread:@selector(displayCallAlerting) withObject:nil waitUntilDone:NO];
}

- (void) displayCallAlerting {
    
}

static void CallAnswer_Callback(void *inUserData) {
    [STRONGSELF handleCallAnswerCallBack];
}

- (void) handleCallAnswerCallBack {
    [self performSelectorOnMainThread:@selector(displayCallAnswer) withObject:nil waitUntilDone:NO];
}

- (void) displayCallAnswer {
    
}

static void CallReleased_Callback(void *inUserData, int errorCode) {
    [STRONGSELF handleCallReleasedCallBackWithErrorCode:errorCode];
}

- (void) handleCallReleasedCallBackWithErrorCode: (int)errorCode {
    [self performSelectorOnMainThread:@selector(displayCallReleased) withObject:nil waitUntilDone:NO];
}

- (void) displayCallReleased {
    
}

@end
