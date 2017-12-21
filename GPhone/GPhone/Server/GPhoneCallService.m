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
    char pushToken[65];  //puthToken(64) + 0
    char authCode_nonce[17];  //authCode(8) + nonce(8) + 0
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
- (void) relayLogin {
    relaySN = 0x11223344;
    static int seqId;
    strcpy(authCode_nonce, "3F2504E0");
    galaxy_relayLoginReq(relaySN, seqId++, 1, "02a2fca6e3ec1ea62aa4b6a344fb9ad7f31f491b7099c0ddf7761cea6c563980", authCode_nonce);
}
- (void)dialWith:(NSString *)phone {
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    char *asciiCode = [phone UTF8String]; //65
    galaxy_sessionInvite(asciiCode, 0, 0, 0, 0, 0, relaySN);
//    [self performSelectorOnMainThread:@selector(startSessionInviteTimer) withObject:nil waitUntilDone:NO];
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
    NSLog(@"%@",result);
}

static void SessionConfirm_Callback(void *inUserData, unsigned int relaySN, int menuSupport, int chatSupport, int callSupport, const char *nonce, int errorCode) {
    [STRONGSELF handleSessionConfirmCallBackWithRelaySN:relaySN MenuSupport:menuSupport ChatSupport:chatSupport CallSupport:callSupport Nonce:nonce ErrorCode:errorCode];
}

- (void) handleSessionConfirmCallBackWithRelaySN: (unsigned int)relaySN MenuSupport: (int)menuSupport ChatSupport: (int)chatSupport CallSupport: (int)callSupport Nonce: (const char*)nonce ErrorCode: (int)errorCode {
    [timerSessionInvite invalidate];
    if(errorCode) {
        NSString *result = [NSString stringWithFormat: @"Session Confirm got with error code %d", errorCode];

        return;
    }
    if(!callSupport) {
        return;
    }
    
    if(nonce) {
        if(strlen(nonce) != 8) {
            return;
        }
        NSLog(@"authCode_nonce before=%s", authCode_nonce);
        strcpy(authCode_nonce + 8, nonce);
        NSLog(@"authCode_nonce=%s", authCode_nonce);
        CC_MD5(authCode_nonce, 16, callMD5);
        galaxy_callSetup(0, callMD5, 0);
    }
    else galaxy_callSetup(0, 0, 0);
    
    [self performSelectorOnMainThread:@selector(startCallSetupTimer) withObject:nil waitUntilDone:NO];
    
}
- (void) startCallSetupTimer
{
    timerCallSetup = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(repeatCallSetup) userInfo:nil repeats:YES];
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
    [timerCallSetup invalidate];
    NSString *result;
    if(errorCode == 0) result = @"Call released normally";
    else if(errorCode == 8) result = @"呼叫鉴权失败，请删除gmobile重新添加";
    else if(errorCode == 10) result = @"呼叫失败，请确认运营商服务是否正常，比如SIM卡是否欠费停机";
    else result = [NSString stringWithFormat: @"Call released with error code %d", errorCode];
    NSLog(@"%@",result);
}

@end
