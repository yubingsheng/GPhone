//
//  GPhoneCallService.m
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#define STRONGSELF (__bridge GPhoneCallService *)inUserData

#import "GPhoneCallService.h"


@implementation GPhoneCallService {
    NSTimer *timerVersionCheck;
    NSTimer *timerSessionInvite;
    NSTimer *timerCallSetup;
    
    int loginSeqId;
    unsigned int relaySN;
    NSString *relayName;
    char pushToken[128];  //puthToken(64) + 0
    char authCode_nonce[25];  //authCode(8) + nonce(8) + 0
    char pushTokenVoIP[128];
    unsigned char callMD5[16];
    char authCode_nonce_message[25];
    
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
    if(!galaxy_init()) {
        char gerror[32];
        NSLog(@"galaxy_init failed, gerror=%s", galaxy_error(gerror));
    }
    else {
        
    }
    galaxy_setVersionCheckCallbacks(VersionCheckRsp_Callback,(__bridge void *)(self));
    galaxy_setRelayCallbacks(RelayLoginRsp_Callback,RelayStatusRsp_Callback,(__bridge void *)(self));
    galaxy_setSessionCallbacks(SessionConfirm_Callback, (__bridge void *)(self));
    galaxy_setCallOutCallbacks(CallTrying_Callback,0, CallAlerting_Callback, CallAnswer_Callback, CallReleased_Callback,(__bridge void *)(self));
    //实际应用中，callIn的每个callback必须有，且必须要做相应的处理，比如定时器的停止。尤其对于callInRelease_Callback，要在callkit做相应的结束呼叫的处理。
    galaxy_setCallInCallbacks(CallInAlertingAck_Callback,0,0,OutCallReleased_Callback, (__bridge void *)(self));
    galaxy_setMessageCallbacks(MessageNonceRsp_Callback, MessageSubmitRsp_Callback, MessageInHelloAck_Callback, MessageDeliverReq_Callback, (__bridge void *)(self));

}
#pragma mark - API
- (void) relayLoginWith:(unsigned int)relay relayName:(NSString*)name {
    [self showWith:@""];
    relaySN = relay;
    relayName = name;
    int seqId = rand();
    strcpy(authCode_nonce, [GPhoneHandel authCode]);
    memcpy(pushTokenVoIP, [GPhoneConfig.sharedManager.pushKitToken cStringUsingEncoding:NSASCIIStringEncoding], 2*[GPhoneConfig.sharedManager.pushKitToken length]);
    memcpy(pushToken, [GPhoneConfig.sharedManager.pushToken cStringUsingEncoding:NSASCIIStringEncoding], 2*[GPhoneConfig.sharedManager.pushToken length]);
//    strcpy(pushTokenVoIP, pushToken); //实际应用中，由Apple分配，并保存在flash中。
    galaxy_relayLoginReq(seqId, relaySN, [relayName UTF8String], 1, pushToken, pushTokenVoIP, authCode_nonce);
}

- (void)dialWith:(ContactModel *)contactModel {
    contactModel.phoneNumber = [contactModel.phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [GPhoneHandel callHistoryContainWith:contactModel];
    const char *asciiCode = [contactModel.phoneNumber UTF8String]; //65
    galaxy_sessionInvite(asciiCode, 0, 0, 0, relaySN);
    _callingView = [[RTCView alloc] initWithNumber:contactModel.phoneNumber nickName:contactModel.fullName byRelay:[GPhoneConfig.sharedManager relaySN]];
    _callingView.delegate = self;
    [_callingView show];
}

- (void)dialWith_dtmf:(NSString *)number {
  
    if(galaxy_dial_dtmf(number.UTF8String)){
        NSLog(@"success！");
    } else {
        char gerror[32];
        NSLog(@"galaxy_versionCheck failed, gerror=%s", galaxy_error(gerror));
    }
}

-(void)hangup {
    [timerSessionInvite invalidate];
    [timerCallSetup invalidate];
    if(!galaxy_callRelease()) {
        char gerror[32];
        NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
    }else {
        
    }
}

- (void)sendMsgWith:(NSString*)text {
    int messageId = rand();
    //在实际应用中，必须启动定时器，具体参考galaxy_messageNonceReq函数的注释。
    relaySN = [[NSNumber numberWithInteger:[GPhoneConfig.sharedManager relaySN].integerValue] unsignedIntValue];
    if(!galaxy_messageNonceReq(messageId,  relaySN)) {
        char gerror[32];
        NSLog(@"galaxy_messageNonceReq failed, gerror=%s", galaxy_error(gerror));
    }
    else {
        NSLog(@"send sms succ");
    }
}

- (void)versionCheck {
    if(!galaxy_versionCheckReq()) {
        char gerror[32];
        NSLog(@"galaxy_versionCheck failed, gerror=%s", galaxy_error(gerror));
    } else {
        if (!timerVersionCheck) {
            timerVersionCheck = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(versionCheck) userInfo:nil repeats:YES];
        }
    }
}

- (void)relayStatus:(unsigned int)relaySN relayName:(NSString*)name {
    [self showWith:@""];
    relayName = name;
    if(!galaxy_relayStatusReq(relaySN)) {
        [self hiddenWith:@"获取GMobil状态失败！"];
    } else {
        NSLog( @"get gmobile status");
    }
}

#pragma mark - Delegate

static void CallInAlertingAck_Callback(void *inUserData, int callId, unsigned int relaySN) {
    [STRONGSELF handleCallInAlertingAckWithCallId:callId relaySN:relaySN];
}

- (void) handleCallInAlertingAckWithCallId: (int)callId relaySN: (unsigned int)relaySN
{
    //TODO stop callInAlerting timer
    NSLog(@"SHAY callInAlertingAck got");
}


static void RelayStatusRsp_Callback(void *inUserData, unsigned int relaySN, int networkOK, int signalStrength) {
    [STRONGSELF handleRelayStatusRspWithRelaySN:relaySN networkOK:networkOK signalStrength:signalStrength];
}

- (void) handleRelayStatusRspWithRelaySN: (unsigned int)relaySN networkOK: (BOOL)networkOK signalStrength: (int)signalStrength{
    if ([_delegate respondsToSelector:@selector(relayStatusWith:)]) {
        RelayStatusModel *model = [RelayStatusModel alloc];
        model.relaySN = relaySN;
        model.netWorkStatus = networkOK;
        model.signalStrength = signalStrength;
        model.relayName = relayName;
        [_delegate relayStatusWith:model];
    }
}

static void RelayLoginRsp_Callback(void *inUserData, int seqId, unsigned int relaySN, int errorCode)
{
    [STRONGSELF handleRelayLoginRspWithRelaySN:relaySN SeqId:seqId ErrorCode:errorCode];
}

- (void) handleRelayLoginRspWithRelaySN: (unsigned int)relaySN SeqId: (int)seqId ErrorCode: (int)errorCode
{
    NSString *result;
    if(errorCode == 0) {
        //实际应用中，登录成功后，需要将relay、pushToken和authCode写入flash保存，APP启动时，首先读取已经保存的这些数据
        [GPhoneCacheManager.sharedManager store:[NSString stringWithFormat:@"%u",relaySN] withKey:RELAYSN];
        [GPhoneCacheManager.sharedManager store:relayName withKey:RELAYNAME];
        RelayModel *model = [RelayModel alloc];
        model.relayName = relayName;
        model.relaySN = relaySN;
        NSMutableArray *relayArray = [NSMutableArray arrayWithArray:GPhoneConfig.sharedManager.relaysNArray];
        [relayArray addObject:model];
        GPhoneConfig.sharedManager.relaysNArray = relayArray;
        result = [NSString stringWithFormat:@"%@添加成功!",relayName];
    }
    else if(errorCode == 3) result = @"gmobile登录失败，请先弹出SIM卡再重新尝试登陆";
    else if(errorCode == 4) result = @"gmobile登录失败，gmobile不在线";
    else result = [NSString stringWithFormat: @"relay login failed with error code %d", errorCode];
    [self hiddenWith: result];
}

static void SessionConfirm_Callback(void *inUserData, unsigned int relaySN, int menuSupport, int chatSupport, int callSupport, const char *nonce, int errorCode) {
    [STRONGSELF handleSessionConfirmCallBackWithRelaySN:relaySN MenuSupport:menuSupport ChatSupport:chatSupport CallSupport:callSupport Nonce:nonce ErrorCode:errorCode];
}

- (void) handleSessionConfirmCallBackWithRelaySN: (unsigned int)relaySN MenuSupport: (int)menuSupport ChatSupport: (int)chatSupport CallSupport: (int)callSupport Nonce: (const char*)nonce ErrorCode: (int)errorCode {
    [timerSessionInvite invalidate];
    if(errorCode) {
        NSString *result = [NSString stringWithFormat: @"Session Confirm got with error code %d", errorCode];
        [self hiddenWith: result];
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
        strcpy(authCode_nonce + 16, nonce);
        NSLog(@"authCode_nonce=%s", authCode_nonce);
        CC_MD5(authCode_nonce, strlen(authCode_nonce), callMD5);
        galaxy_callSetup(0, callMD5, 0);
    }
    else galaxy_callSetup(0, 0, 0);
    
    [self performSelectorOnMainThread:@selector(startCallSetupTimer) withObject:nil waitUntilDone:NO];
    
}
- (void) startCallSetupTimer{
    timerCallSetup = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(repeatCallSetup) userInfo:nil repeats:YES];
}
- (void) repeatCallSetup{
    if(strlen(authCode_nonce) == 24) galaxy_callSetup(1, callMD5, 0);//set parm repeated to 1 !!!
    else galaxy_callSetup(1, 0, 0);//set parm repeated to 1 !!!
}

static void CallTrying_Callback(void *inUserData){
    [STRONGSELF handleCallTryingCallBack];
}

- (void) handleCallTryingCallBack{
    [timerCallSetup invalidate];
}

static void CallAlerting_Callback(void *inUserData) {
    [STRONGSELF handleCallAlertingCallBack];
}

- (void) handleCallAlertingCallBack {
    NSLog(@"CallAlertingCallBack");
}

static void CallAnswer_Callback(void *inUserData) {
    [STRONGSELF handleCallAnswerCallBack];
}

- (void) handleCallAnswerCallBack {
    [_callingView connected];
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
    [self hiddenWith: result];
}

static void OutCallReleased_Callback(void *inUserData, int errorCode) {
    
    [STRONGSELF handleCallReleasedCallBackWithErrorCodee:errorCode];
}
- (void) handleCallReleasedCallBackWithErrorCodee: (int)errorCode {
    [timerCallSetup invalidate];
    NSString *result;
    if(errorCode == 0) result = @"Call released normally";
    else if(errorCode == 8) result = @"呼叫鉴权失败，请删除gmobile重新添加";
    else if(errorCode == 10) result = @"呼叫失败，请确认运营商服务是否正常，比如SIM卡是否欠费停机";
    else result = [NSString stringWithFormat: @"Call released with error code %d", errorCode];
    [self hiddenWith: result];
    NSLog(@"uuid == %@", _uuid);
    
}

static void VersionCheckRsp_Callback(void *inUserData, int result) {
    [STRONGSELF handleVersionCheckRspWithResult:result];
}

- (void) handleVersionCheckRspWithResult: (int)result {
    [timerVersionCheck invalidate];
    //实际应用中，如果result返回2，也就是versionMustUpdate，应当立即弹出对话框，提示用户“应用必须升级到最新版本才能继续使用”，用户点击确认后，退出APP
    if ([_delegate respondsToSelector:@selector(versionStatusWith:)]) {
        [_delegate versionStatusWith:result];
    }
}
#pragma mark - Message
static void MessageNonceRsp_Callback(void *inUserData, int messageId, unsigned int relaySN, const char *nonce, int errorCode){
    [STRONGSELF handleMessageNonceRspCallBackWithMessageId:messageId relaySN:relaySN nonce:nonce errorCode:errorCode];
}

- (void) handleMessageNonceRspCallBackWithMessageId: (int) messageId relaySN: (unsigned int)relaySN nonce: (const char*)nonce errorCode: (int)errorCode
{
    if(errorCode) {
        NSString *result = [NSString stringWithFormat: @"messageNonceRsp got with error code %d", errorCode];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
        return;
    }
    
    if(nonce) {
        if(strlen(nonce) != 8) {
            [self performSelectorOnMainThread:@selector(displayText:) withObject:@"size of nonce in sessionConfirm not 8" waitUntilDone:NO];
            return;
        }
        strcpy(authCode_nonce_message + 16, nonce);
        CC_MD5(authCode_nonce_message, (CC_LONG)strlen(authCode_nonce_message), callMD5);
        //在实际应用中，必须启动定时器，具体参考galaxy_messageSubmitReq函数的注释。
        //NSString *sm = @"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz";
        //NSString *sm = @"月落乌啼霜满天，江枫渔火对愁眠；姑苏城外寒山寺，夜半钟声到客船。月落乌啼霜满天，江枫渔火对愁眠；姑苏城外寒山寺，夜半钟声到客船。月落乌啼霜满天，江枫渔火对愁眠；姑苏城外寒山寺，夜半钟声到客船。";
        //if(!galaxy_messageSubmitReq(messageId, relaySN, callMD5, calledNumber.text.UTF8String, sm.UTF8String))
        if(!galaxy_messageSubmitReq(messageId, relaySN, callMD5, @"18016388248".UTF8String, @"hello".UTF8String))
        {
            char gerror[32];
            NSLog(@"galaxy_messageSubmitReq failed, gerror=%s", galaxy_error(gerror));
        }
    }
    else {
        NSString *result = [NSString stringWithFormat: @"messageNonceRsp got without nonce"];
        [self showWith:result];
        return;
    }
    
}

static void MessageSubmitRsp_Callback(void *inUserData, int messageId, unsigned int relaySN, int errorCode){
    [STRONGSELF handleMessageSubmitRspCallBackWithMessageId:messageId relaySN:relaySN errorCode:errorCode];
}

- (void) handleMessageSubmitRspCallBackWithMessageId: (int) messageId relaySN: (unsigned int)relaySN errorCode: (int)errorCode
{
    if(errorCode) {
        NSString *result = [NSString stringWithFormat: @"messageSubmitRsp got with error code %d", errorCode];
        [self showWith:result];
        return;
    }
    else {
        NSString *result = [NSString stringWithFormat: @"sms send succ"];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
        return;
    }
}

static void MessageInHelloAck_Callback(void *inUserData, int seqId, unsigned int relaySN){
    [STRONGSELF handleMessageInHelloAckCallBackWithSeqId:seqId relaySN:relaySN];
}

- (void) handleMessageInHelloAckCallBackWithSeqId: (int) seqId relaySN: (unsigned int)relaySN{
    NSString *result = [NSString stringWithFormat: @"messageInHelloAck got with seqId %d", seqId];
    [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
    //实际应用中，需要停止messageInHello重发定时器。
    return;
}
static void MessageDeliverReq_Callback(void *inUserData, int messageId, unsigned int relaySN, const char *callingNumber, const char *content, const char *timestamp){
    [STRONGSELF handleMessageDeliverReqCallBackWithMessageId:messageId relaySN:relaySN callingNumber:callingNumber content:content timestamp:timestamp];
}

- (void) handleMessageDeliverReqCallBackWithMessageId: (int) messageId relaySN: (unsigned int)relaySN callingNumber: (const char*)callingNumber content: (const char*) content timestamp: (const char*)timestamp
{
    //实际应用中，要根据messageId检查是否是重复发送的短消息。
    //timestamp转换为本地时区的时间
    NSString *dateTime = [self formatTimestamp:[NSString stringWithFormat: @"%s", timestamp]];
    NSString *sms = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
    NSString *result = [NSString stringWithFormat: @"短信内容:[%@],来自号码:[%s],发送时间:[%@]",
                        sms, callingNumber, dateTime];
    NSLog(@"%@", result);
    //实际应用中，需要停止messageInHello重发定时器。
    return;
}
-(NSString *)formatTimestamp:(NSString *)timestamp
{
    NSDate *Date;
    //新建一个Date格式类，
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置为timeStr的日期格式
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssZ"];
    //以timeStr的格式来得到Date
    Date = [dateFormatter dateFromString:timestamp];
    //设置日期格式为要转化的类型
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //将要转化的日期变为字符串
    NSString *formatStr = [dateFormatter stringFromDate:Date];
    return formatStr;
}

#pragma mark - RTCDelegate
-(void)hangUp {
    [self hangup];
}
#pragma mark - HUD
- (void)showWith:(NSString *)title {
        self.hud.label.text = title;
        _hud.mode = MBProgressHUDModeIndeterminate;

}
- (void)hiddenWith:(NSString*)title {
    dispatch_sync(dispatch_get_main_queue(), ^(){
        self.hud.label.text = title;
        _hud.mode = MBProgressHUDModeText;
        [_hud hideAnimated:YES afterDelay:0.5];
    });
    
}
- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud  = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
    return _hud;
}
@end
