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
    NSTimer *timerSMSInHello;
    NSTimer *timerMessageNonce;
    NSTimer *timerCallInAlerting;
    NSTimer *timerCallAnswer;
    
    int loginSeqId;
    
    NSString *relayName;
    
    char authCode_nonce[25];  //authCode(8) + nonce(8) + 0
    
    unsigned char callMD5[16];
    int msgRepetition;
    int messageId;
    int messageInHelloRepetition;
    MessageModel *messageModel;
}

+(GPhoneCallService *)sharedManager{
    static dispatch_once_t predicate;
    static GPhoneCallService * gPhoneCallService;
    dispatch_once(&predicate, ^{
        gPhoneCallService = [[GPhoneCallService alloc] init];
        [gPhoneCallService initGalaxy];
        [gPhoneCallService initProperty];
    });
    return gPhoneCallService;
}
- (void)initProperty {
    _relaySN = [[NSNumber numberWithInteger:[GPhoneConfig.sharedManager relaySN].integerValue] unsignedIntValue];
    relayName = GPhoneConfig.sharedManager.relayName;
    memcpy(authCode_nonce, [GPhoneConfig.sharedManager.authCode cStringUsingEncoding:NSASCIIStringEncoding], GPhoneConfig.sharedManager.authCode.length * 2);
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
    galaxy_setCallInCallbacks(CallInAlertingAck_Callback,CallInAnswerAck_Callback,CallInReleased_Callback, (__bridge void *)(self));
    
    galaxy_setMessageCallbacks(MessageNonceRsp_Callback, MessageSubmitRsp_Callback, MessageInHelloAck_Callback, MessageDeliverReq_Callback, (__bridge void *)(self));
}

#pragma mark - CallingView

- (void)callingViewWithCallType:(BOOL)isIn {
    _callingView = nil;
    _callingView = [[RTCView alloc] initWithNumber:_currentContactModel.phoneNumber nickName:_currentContactModel.fullName byRelay:GPhoneConfig.sharedManager.relayName in_outCall:isIn];
    _callingView.delegate = self;
    [_callingView show];
    [GPhoneHandel callHistoryContainWith:_currentContactModel];
    if (!isIn) {
        [self sessionInviteWith:_currentContactModel.phoneNumber];
    }
}

#pragma mark - API
- (void) relayLoginWith:(unsigned int)relay relayName:(NSString*)name {
    [self showWith:@""];
    _relaySN = relay;
    relayName = name;
    int seqId = rand();
    int a = rand();
    int b = rand();
    const char authcode[25];
    sprintf(authcode, "%08x%08x", a, b);
    //"3F2504E08D64C20A"
    strcpy(authCode_nonce, authcode);
    memcpy(pushTokenVoIP, [GPhoneConfig.sharedManager.pushKitToken cStringUsingEncoding:NSASCIIStringEncoding], 2*[GPhoneConfig.sharedManager.pushKitToken length]);
    memcpy(pushToken, [GPhoneConfig.sharedManager.pushToken cStringUsingEncoding:NSASCIIStringEncoding], 2*[GPhoneConfig.sharedManager.pushToken length]);
    //    strcpy(pushTokenVoIP, pushToken); //实际应用中，由Apple分配，并保存在flash中。
    galaxy_relayLoginReq(seqId, _relaySN, [relayName UTF8String], 1, pushToken, pushTokenVoIP, authCode_nonce);
}

- (void)sessionInviteWith:(NSString*)phoneNumber {
    if(!galaxy_sessionInvite(phoneNumber.UTF8String, 0, 0, 0, _relaySN)) {
        char gerror[32];
        NSLog(@"galaxy_sessionInvite failed, gerror=%s", galaxy_error(gerror));
        [self showToastWith:[NSString stringWithFormat:@"galaxy_sessionInvite failed, gerror=%s", galaxy_error(gerror)]];
    }else {
        if (!timerSessionInvite) {
            timerSessionInvite = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sessionInvite:) userInfo:phoneNumber repeats:YES];
            
        }
    }
}
- (void)sessionInvite:(NSTimer*)timer {
    [self sessionInviteWith:timer.userInfo];
}

- (void)dialWith:(ContactModel *)contactModel {
  
    _currentContactModel = contactModel;
    _currentContactModel.phoneNumber = [contactModel.phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [self callingViewWithCallType:NO];
    [APPDELEGATE setProximityMonitoringWiht:YES];
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
    if(!galaxy_callRelease()) {
        char gerror[32];
        NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
        [self showToastWith:[NSString stringWithFormat:@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror)]];
    }else {
        [timerCallSetup invalidate];
        [timerSessionInvite invalidate];
        [APPDELEGATE setProximityMonitoringWiht:NO];
        interface_viberate = 0;
        //        [APPDELEGATE.callController endCall];
        //        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    }
}

- (void)sendMsgWith:(MessageModel*)text {
    if (messageId <= 0 || !messageId) {
        messageId = text.msgId;
        [self showWith:@"发送中"];
        messageModel = text;
    }
    msgRepetition ++;
    if(!galaxy_messageNonceReq(messageId,  _relaySN)) {
        char gerror[32];
        NSLog(@"galaxy_messageNonceReq failed, gerror=%s", galaxy_error(gerror));
    }
    else {
        [timerMessageNonce invalidate];
        int timeInterval = 0;
        if (msgRepetition < 1 || !msgRepetition) {
            timeInterval = 5;
            msgRepetition = 1;
        }else if(msgRepetition <= 2 ){
            timeInterval = 15;
        }else if (msgRepetition >2) {
            [self hiddenWith:@"消息发送失败！"];
            return;
        }
        if (!timerMessageNonce) {
            timerMessageNonce = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(sendMsgWith:) userInfo:text repeats:YES];
        }
    }
}

-(void)sendMsg:(NSTimer*)timer {
    [self sendMsgWith:timer.userInfo];
}

- (void)messageInHello:(NSNumber*)seqId {
    if (messageInHelloRepetition < 1 || !messageInHelloRepetition){
        messageInHelloRepetition = 1;
    }else {
        messageInHelloRepetition ++;
    }
    if(!galaxy_messageInHello(seqId.intValue, _relaySN)) {
        //display.text = @"messageInHello failed";
        char gerror[32];
        NSLog(@"galaxy_messageInHello failed, gerror=%s", galaxy_error(gerror));
    }else {
        if (messageInHelloRepetition >2) {
            [self hiddenWith:@"消息发送失败！"];
            [timerSMSInHello invalidate];
            return;
        }
        if (!timerSMSInHello) {
            timerSMSInHello = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(messageInHello:) userInfo:seqId repeats:YES];
        }
    }
}

- (void)messageInHelloWiht:(NSTimer*)timer {
    [self messageInHello:timer.userInfo];
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
    relayName = name;
    if(!galaxy_relayStatusReq(relaySN)) {
        [self showToastWith:@"获取gMobil状态失败！"];
    } else {
        NSLog( @"get gMobile status");
    }
}

- (void)callInAlertingWith:(NSString*)callId relaySN:(NSString*)relaySN {
    if(!galaxy_callInAlerting()) {
        char gerror[32];
        NSLog(@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror));
        [self showToastWith:[NSString stringWithFormat:@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror)]];
    }else {
        if (!timerCallInAlerting) {
            timerCallInAlerting = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(callInAnswer) userInfo:@{@"callid":callId, @"relaysn":relaySN} repeats:YES];
        }
    }
}

- (void)callInAlerting:(NSTimer*)timer {
    NSDictionary *dic = timer.userInfo;
    [self callInAlertingWith:[dic valueForKey:@"callid"] relaySN:[dic valueForKey:@"relaysn"]];
}

// 应答
- (void)callInAnswer {
    if(!galaxy_callInAnswer()) {
        char gerror[32];
        NSLog(@"galaxy_callInAnswer failed, gerror=%s", galaxy_error(gerror));
        [self showToastWith:[NSString stringWithFormat:@"galaxy_callInAnswer failed, gerror=%s", galaxy_error(gerror)]];
    }
    else {
        if(!timerCallAnswer){
            timerCallAnswer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(callInAnswer) userInfo:nil repeats:YES];
        }
    }
}

- (void)callRelease {
    if(!galaxy_callRelease()) {
        char gerror[32];
        NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
        [self showToastWith:[NSString stringWithFormat:@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror)]];
    }
    else {
        NSLog(@"SHAY galaxy_callInRelease sent");
    }
}
#pragma mark - Delegate
static void CallInReleased_Callback(void *inUserData, int errorCode) {
    [STRONGSELF handleCallInReleaseCallBackWithErrorCode:errorCode];
}
- (void) handleCallInReleaseCallBackWithErrorCode: (int)errorCode {
    NSLog(@"SHAY callInReleaseCallback called");
    interface_viberate = 0;
    [timerCallAnswer invalidate];
    [APPDELEGATE setProximityMonitoringWiht:NO];
    if (_callingView) {
        dispatch_sync(dispatch_get_main_queue(), ^(){
            if(_callingView.frame.size.width <= 100) [_callingView microClick];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_callingView dismiss];
                _callingView = nil;
            });
            if (_relayStatusBlock) {
                _relayStatusBlock(NO);
                
            }});
    }
    //实际应用中，要停止callInAlerting和callInAnswer重发定时器
    //[appDelegate.providerDelegate.provider reportCallWithUUID:appDelegate.providerDelegate.inCallUUID endedAtDate:nil reason:CXCallEndedReasonRemoteEnded];
    NSString *result;
    if(errorCode == 0) return;
    else if(errorCode == 8) result = @"呼叫鉴权失败，请删除gmobile重新添加";
    else if(errorCode == 10) result = @"呼叫失败，请确认运营商服务是否正常，比如SIM卡是否欠费停机";
    else result = [NSString stringWithFormat: @"Call released with error code %d", errorCode];
    [self hiddenWith: result];
}
static void CallInAnswerAck_Callback(void *inUserData) {
    [STRONGSELF handleCallInAnswerAck];
}

- (void) handleCallInAnswerAck{
    //galaxy_relayStatusReq(relaySN);
    //实际应用中，要停止callInAnswer重发定时器
    NSLog(@"SHAY callInAnswerAck got");
    NSString *result = @"Call Answered";
    [APPDELEGATE setProximityMonitoringWiht:YES];
    [timerCallAnswer invalidate];
}
static void CallInAlertingAck_Callback(void *inUserData) {
    [STRONGSELF handleCallInAlertingAck];
}

- (void) handleCallInAlertingAck {
    // stop callInAlerting timer
    [timerCallInAlerting invalidate];
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

- (void) handleRelayLoginRspWithRelaySN: (unsigned int)relaySN SeqId: (int)seqId ErrorCode: (int)errorCode {
    NSString *result;
    if (_loginBlock) {
        _loginBlock(errorCode==0);
    }
    if (errorCode != 0) {
        _relaySN = 0;
    }
    if(errorCode == 0) {
        //实际应用中，登录成功后，需要将relay、pushToken和authCode写入flash保存，APP启动时，首先读取已经保存的这些数据
        [GPhoneCacheManager.sharedManager store:[NSString stringWithFormat:@"%u",relaySN] withKey:RELAYSN];
        [GPhoneCacheManager.sharedManager store:relayName withKey:RELAYNAME];
        GPhoneConfig.sharedManager.authCode =  [NSString stringWithFormat:@"%s",authCode_nonce];
        [self initProperty];
        RelayModel *model = [RelayModel alloc];
        model.relayName = relayName;
        model.relaySN = relaySN;
        model.authCode = [NSString stringWithFormat:@"%s",authCode_nonce];
        [GPhoneHandel relaysContainWith:model];
        if (_addRelayBlock) {
            _addRelayBlock(YES);
        }
        result = [NSString stringWithFormat:@"%@添加成功!",relayName];
    }
    else if(errorCode == 3) result = @"gMobile登录失败，请先弹出SIM卡再重新尝试登陆";
    else if(errorCode == 4) {
        if (_addRelayFailedBlock) {
            _addRelayFailedBlock(errorCode);
        } 
    }
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
        galaxy_callSetup(0, pushTokenVoIP,callMD5, 0);
    }
    else galaxy_callSetup(0, pushTokenVoIP, 0, 0);
    
    [self performSelectorOnMainThread:@selector(startCallSetupTimer) withObject:nil waitUntilDone:NO];
    
}
- (void) startCallSetupTimer{
    timerCallSetup = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(repeatCallSetup) userInfo:nil repeats:YES];
}
- (void) repeatCallSetup{
    if(strlen(authCode_nonce) == 24) galaxy_callSetup(1, pushTokenVoIP, callMD5, 0);//set parm repeated to 1 !!!
    else galaxy_callSetup(1, pushTokenVoIP, 0, 0);//set parm repeated to 1 !!!
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
    dispatch_sync(dispatch_get_main_queue(), ^(){
        [STRONGSELF handleCallAnswerCallBack];
    });
}

- (void) handleCallAnswerCallBack {
    [timerCallInAlerting invalidate];
    [APPDELEGATE shake];
    [_callingView connected];

}

static void CallReleased_Callback(void *inUserData, int errorCode) {
    [STRONGSELF handleCallReleasedCallBackWithErrorCode:errorCode];
}
- (void) handleCallReleasedCallBackWithErrorCode: (int)errorCode {
    [timerCallSetup invalidate];
    interface_viberate = 0;
    NSString *result;
    if (_callingView) {
        dispatch_sync(dispatch_get_main_queue(), ^(){
            if(_callingView.frame.size.width <= 100) [_callingView microClick];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_callingView dismiss];
                _callingView = nil;
            });
        });
    }
    
    if(errorCode == 0) return;
    else if(errorCode == 8) {
        result = @"呼叫鉴权失败，请删除gMobile重新添加";
        if (_relayStatusBlock) {
            _relayStatusBlock(NO);
            
        }
    }
    else if(errorCode == 10) result = @"呼叫失败，请确认运营商服务是否正常，比如SIM卡是否欠费停机";
    else result = [NSString stringWithFormat: @"Call released with error code %d", errorCode];
    [self hiddenWith: result];
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

- (void) handleMessageNonceRspCallBackWithMessageId: (int) msgId relaySN: (unsigned int)relaySN nonce: (const char*)nonce errorCode: (int)errorCode
{
    [timerMessageNonce invalidate];
    messageId = 0;
    msgRepetition = 0;
    if(errorCode) {
        NSString *result = [NSString stringWithFormat: @"messageNonceRsp got with error code %d", errorCode];
        [self showToastWith:result];
        if (_messageBlock) {
            _messageBlock(NO);
        }
        return;
    }
    if(nonce) {
        if(strlen(nonce) != 8) {
            [self hiddenWith:@"size of nonce in sessionConfirm not 8"];
            if (_messageBlock) {
                _messageBlock(NO);
            }
            return;
        }
        
        strcpy(authCode_nonce + 16, nonce);
        CC_MD5(authCode_nonce, (CC_LONG)strlen(authCode_nonce), callMD5);
        //在实际应用中，必须启动定时器，具体参考galaxy_messageSubmitReq函数的注释。
        //NSString *sm = @"月落乌啼霜满天，江枫渔火对愁眠；姑苏城外寒山寺，夜半钟声到客船。月落乌啼霜满天，江枫渔火对愁眠；姑苏城外寒山寺，夜半钟声到客船。月落乌啼霜满天，江枫渔火对愁眠；姑苏城外寒山寺，夜半钟声到客船。";
        if(!galaxy_messageSubmitReq(msgId, relaySN, callMD5, messageModel.phone.UTF8String, messageModel.text.UTF8String)){
            char gerror[32];
            NSLog(@"galaxy_messageSubmitReq failed, gerror=%s", galaxy_error(gerror));
        }
    }
    else {
        NSString *result = [NSString stringWithFormat: @"messageNonceRsp got without nonce"];
        [self showWith:result];
        if (_messageBlock) {
            _messageBlock(NO);
        }
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
        [self hiddenWith:result];
        if (_messageBlock) {
            _messageBlock(NO);
        }
        return;
    }
    else {
        [self hiddenWith:@""];
        if (_messageBlock) {
            _messageBlock(YES);
        }
        return;
    }
}

static void MessageInHelloAck_Callback(void *inUserData, int seqId, unsigned int relaySN){
    [STRONGSELF handleMessageInHelloAckCallBackWithSeqId:seqId relaySN:relaySN];
}

- (void) handleMessageInHelloAckCallBackWithSeqId: (int) seqId relaySN: (unsigned int)relaySN{
    NSString *result = [NSString stringWithFormat: @"messageInHelloAck got with seqId %d", seqId];
    //    [self hiddenWith:result];
    //实际应用中，需要停止messageInHello重发定时器。
    return;
}
static void MessageDeliverReq_Callback(void *inUserData, int messageId, unsigned int relaySN, const char *callingNumber, const char *content, const char *timestamp){
    [STRONGSELF handleMessageDeliverReqCallBackWithMessageId:messageId relaySN:relaySN callingNumber:callingNumber content:content timestamp:timestamp];
}

- (void) handleMessageDeliverReqCallBackWithMessageId: (int) messageId relaySN: (unsigned int)relaySN callingNumber: (const char*)callingNumber content: (const char*) content timestamp: (const char*)timestamp{
    //实际应用中，要根据messageId检查是否是重复发送的短消息。
    //timestamp转换为本地时区的时间
    NSDate *dateTime = [self formatTimestamp:[NSString stringWithFormat: @"%s", timestamp]];
    NSString *sms = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
    NSString *result = [NSString stringWithFormat: @"短信内容:[%@],来自号码:[%s],发送时间:[%@]",
                        sms, callingNumber, dateTime];
    NSString *phoneNumber = [[NSString stringWithFormat:@"%s",callingNumber] stringByReplacingOccurrencesOfString:@"86" withString:@""];
    NSLog(@"%@", result);
    NSMutableArray *messageList = [NSMutableArray arrayWithArray:GPhoneConfig.sharedManager.messageArray];
    BOOL containContact = NO;
    for (int i = 0; i < messageList.count; i++) {
        ContactModel *model = messageList[i];
        if ([model.phoneNumber isEqualToString:phoneNumber]) {
            BOOL contain = NO;
            containContact = YES;
            for (MessageModel *message in model.messageList) {
                if (message.msgId == messageId) {
                    contain = YES;
                }
            }
            if (!contain) {
                NSMutableArray *messageList = [NSMutableArray arrayWithArray:model.messageList];
                [messageList addObject:[[MessageModel alloc] initWithMsgId:messageId text:sms date:dateTime msgType:JSBubbleMessageTypeIncoming phone:[NSString stringWithFormat:@"%s",callingNumber]]];
                model.messageList = messageList;
                model.unread += 1;
                [GPhoneHandel messageHistoryContainWith:model];
                dispatch_sync(dispatch_get_main_queue(), ^(){
                    [GPhoneHandel messageTabbarItemBadgeValue: -1];
                });
            }
        }
    }
    if (!containContact){
        ContactModel *contactModel = [[ContactModel alloc]initWithId:0 time:1 identifier:@"" phoneNumber:phoneNumber fullName:@"" creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
        contactModel.relaySN = [NSString stringWithFormat:@"%u",relaySN];
        NSMutableArray *messageList = [[NSMutableArray alloc]init];
        [messageList addObject:[[MessageModel alloc] initWithMsgId:messageId text:sms date:dateTime msgType:JSBubbleMessageTypeIncoming phone:[NSString stringWithFormat:@"%s",callingNumber]]];
        contactModel.messageList = messageList;
        contactModel.unread += 1;
        dispatch_sync(dispatch_get_main_queue(), ^(){
            [GPhoneHandel messageTabbarItemBadgeValue: -1];
        });
        [GPhoneHandel messageHistoryContainWith:contactModel];
    }
    //实际应用中，需要停止messageInHello重发定时器。
    return;
}

-(NSDate *)formatTimestamp:(NSString *)timestamp{
    NSDate *Date;
    //新建一个Date格式类，
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    //设置为timeStr的日期格式
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssZ"];
    //以timeStr的格式来得到Date
    //设置日期格式为要转化的类型
    //将要转化的日期变为字符串
    Date = [dateFormatter dateFromString:timestamp];
    return Date;
}

#pragma mark - RTCDelegate
-(void)hangUp {
    [self hangup];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
}
#pragma mark - HUD

- (void)showToastWith:(NSString *)message {
    [[[[iToast makeText:message] setGravity:iToastGravityCenter] setDuration:iToastDurationLong] show];
}

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
- (void)hidden {
    dispatch_sync(dispatch_get_main_queue(), ^(){
        _hud.mode = MBProgressHUDModeText;
        [_hud hideAnimated:YES afterDelay:0.0];
    });
    
}
- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud  = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
    return _hud;
}
@end
