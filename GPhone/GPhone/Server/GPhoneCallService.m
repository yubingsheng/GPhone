//
//  GPhoneCallService.m
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPhoneCallService.h"
#import "galaxy_controller.h"

@implementation GPhoneCallService

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
                    0,0, CallAlerting_Callback, CallAnswer_Callback, CallReleased_Callback,(__bridge void *)(self),
                    0,0,0,0,0,
                    0,0,0,0,
                    0,0,0,0)) {
        
    }
}
#pragma mark - API
- (void)dial {
     galaxy_sessionInvite("10101234111", "13621918174", 0, 0, 0, 0, 0);
}

#pragma mark - Delegate

static void SessionConfirm_Callback(void *inUserData, unsigned int relaySN, int menuSupport, int chatSupport, int callSupport, const char *nonce, int errorCode) {
    GPhoneCallService *GPService = (__bridge GPhoneCallService *)inUserData;
    [GPService handleSessionConfirmCallBackWithRelaySN:relaySN MenuSupport:menuSupport ChatSupport:chatSupport CallSupport:callSupport Nonce:nonce ErrorCode:errorCode];
}

- (void) handleSessionConfirmCallBackWithRelaySN: (unsigned int)relaySN MenuSupport: (int)menuSupport ChatSupport: (int)chatSupport CallSupport: (int)callSupport Nonce: (const char*)nonce ErrorCode: (int)errorCode {
    if(errorCode) {
        NSLog(@"SessionConfirm got with error code %d", errorCode);
        return;
    }
    if(!callSupport) {
        NSLog(@"SessionConfirm got without call support");
        return;
    }
    //TODO 如果返回nonce，则需要计算auth并填入galaxy_callSetup的参数中。
    galaxy_callSetup(0, 0);
    
}

static void CallAlerting_Callback(void *inUserData) {
    GPhoneCallService *GPService = (__bridge GPhoneCallService *)inUserData;
    [GPService handleCallAlertingCallBack];
}

- (void) handleCallAlertingCallBack {
    [self performSelectorOnMainThread:@selector(displayCallAlerting) withObject:nil waitUntilDone:NO];
}

- (void) displayCallAlerting {
    
}

static void CallAnswer_Callback(void *inUserData) {
    GPhoneCallService *GPService = (__bridge GPhoneCallService *)inUserData;
    [GPService handleCallAnswerCallBack];
}

- (void) handleCallAnswerCallBack {
    [self performSelectorOnMainThread:@selector(displayCallAnswer) withObject:nil waitUntilDone:NO];
}

- (void) displayCallAnswer {
    
}

static void CallReleased_Callback(void *inUserData, int errorCode) {
    GPhoneCallService *GPService = (__bridge GPhoneCallService *)inUserData;
    [GPService handleCallReleasedCallBackWithErrorCode:errorCode];
}

- (void) handleCallReleasedCallBackWithErrorCode: (int)errorCode {
    [self performSelectorOnMainThread:@selector(displayCallReleased) withObject:nil waitUntilDone:NO];
}

- (void) displayCallReleased {
    
}

@end
