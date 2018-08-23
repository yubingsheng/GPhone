//
//  ViewController.m
//  gphone
//
//  Created by lixs on 2017/8/21.
//  Copyright © 2017年 lixs. All rights reserved.
//
#import "CommonCrypto/CommonDigest.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "galaxy.h"
#import "gdata.h"

@interface ViewController ()

@end

@implementation ViewController {
	//AppDelegate *appDelegate;
	//NSUUID* outCallUUID;
	NSTimer *timerVersionCheck;
    NSTimer *timerSessionInvite;
    NSTimer *timerCallSetup;
}


@synthesize display;
@synthesize calledNumber;
@synthesize sms;

- (void) displayText: (NSString*)text
{
    NSLog(@"into dialText with text %@", text);
    display.text = text;
}

static void VersionCheckRsp_Callback(void *inUserData, int result)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleVersionCheckRspWithResult:result];
}

- (void) handleVersionCheckRspWithResult: (int)result
{
    [timerVersionCheck invalidate];
	//实际应用中，如果result返回2，也就是versionMustUpdate，应当立即弹出对话框，提示用户“应用必须升级到最新版本才能继续使用”，用户点击确认后，退出APP
	if(result == 2) [self performSelectorOnMainThread:@selector(displayText:) withObject:@"应用必须升级到最新版本才能继续使用" waitUntilDone:NO];
}

static void RelayLoginRsp_Callback(void *inUserData, int seqId, unsigned int relaySN, int errorCode)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleRelayLoginRspWithSeqId:seqId relaySN:relaySN errorCode:errorCode];
}

- (void) handleRelayLoginRspWithSeqId: (int)seqId relaySN: (unsigned int)relaySN errorCode: (int)errorCode
{
    NSString *result;
    if(seqId != loginSeqId) {
        NSLog(@"seqId in relayLoginRsp != our recorded seqI");
        return;
    }
    if(errorCode == 0) {
        //实际应用中，登录成功后，需要将relaySN写入flash保存，APP启动时，首先读取已经保存的这些数据
        result = @"relay login success";
    }
    else if(errorCode == 3) result = @"gmobile登录失败，请先弹出SIM卡再重新尝试登陆";
    else if(errorCode == 4) result = @"gmobile登录失败，gmobile不在线";
    else result = [NSString stringWithFormat: @"gmobile login failed with error code %d", errorCode];
    

    [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
}


static void CallInAlertingAck_Callback(void *inUserData)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleCallInAlertingAck];
}

- (void) handleCallInAlertingAck
{
    //galaxy_relayStatusReq(relaySN);
    //实际应用中，要停止callInAlerting重发定时器
    NSLog(@"SHAY callInAlertingAck got");
}

static void CallInAnswerAck_Callback(void *inUserData)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleCallInAnswerAck];
}

- (void) handleCallInAnswerAck
{
    //galaxy_relayStatusReq(relaySN);
    //实际应用中，要停止callInAnswer重发定时器
    NSLog(@"SHAY callInAnswerAck got");
    NSString *result = @"Call Answered";;
    [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
}

static void CallInRelease_Callback(void *inUserData, int errorCode)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleCallInReleaseCallBackWithErrorCode:errorCode];
}

- (void) handleCallInReleaseCallBackWithErrorCode: (int)errorCode
{
	NSLog(@"SHAY callInReleaseCallback called");
	interface_viberate = 0;
    //实际应用中，要停止callInAlerting和callInAnswer重发定时器
	//[appDelegate.providerDelegate.provider reportCallWithUUID:appDelegate.providerDelegate.inCallUUID endedAtDate:nil reason:CXCallEndedReasonRemoteEnded];
    NSString *result;
    if(errorCode == 0) result = @"Call released normally";
	else if(errorCode == 8) result = @"呼叫鉴权失败，请删除gmobile重新添加";
	else if(errorCode == 10) result = @"呼叫失败，请确认运营商服务是否正常，比如SIM卡是否欠费停机";
    else result = [NSString stringWithFormat: @"Call released with error code %d", errorCode];
    [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
}

static void RelayStatusRsp_Callback(void *inUserData, unsigned int relaySN, int networkOK, int signalStrength)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleRelayStatusRspWithRelaySN:relaySN networkOK:networkOK signalStrength:signalStrength];
}

- (void) handleRelayStatusRspWithRelaySN: (unsigned int)relaySN networkOK: (int)networkOK signalStrength: (int)signalStrength
{
    NSString *result;
    result = [NSString stringWithFormat: @"gmobile network[%s], signal[%d]", networkOK ? "OK" : "FAIL", signalStrength];
    
    
    [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
}

static void SessionConfirm_Callback(void *inUserData, unsigned int relaySN, int menuSupport, int chatSupport, int callSupport, const char *nonce, int errorCode)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleSessionConfirmCallBackWithRelaySN:relaySN menuSupport:menuSupport chatSupport:chatSupport callSupport:callSupport nonce:nonce errorCode:errorCode];
}

- (void) handleSessionConfirmCallBackWithRelaySN: (unsigned int)relaySN menuSupport: (int)menuSupport chatSupport: (int)chatSupport callSupport: (int)callSupport nonce: (const char*)nonce errorCode: (int)errorCode
{
    //[appDelegate.providerDelegate.timerSessionInvite invalidate];
    [timerSessionInvite invalidate];
    if(errorCode) {
        NSString *result = [NSString stringWithFormat: @"Session Confirm got with error code %d", errorCode];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
        return;
    }
    if(!callSupport) {
        [self performSelectorOnMainThread:@selector(displayText:) withObject:@"SessionConfirm got without call support" waitUntilDone:NO];
        return;
    }
    
    if(nonce) {
        if(strlen(nonce) != 8) {
            [self performSelectorOnMainThread:@selector(displayText:) withObject:@"size of nonce in sessionConfirm not 8" waitUntilDone:NO];
            return;
        }
        NSLog(@"authCode_nonce before=%s", authCode_nonce);
        strcpy(authCode_nonce + 16, nonce);
        NSLog(@"authCode_nonce=%s", authCode_nonce);
        CC_MD5(authCode_nonce, (CC_LONG)strlen(authCode_nonce), callMD5);
        if(!galaxy_callSetup(0, pushTokenVoIP, callMD5, 0))
		{
			char gerror[32];
			NSLog(@"galaxy_callSetup failed, gerror=%s", galaxy_error(gerror));
		}
    }
    else {
		if(!galaxy_callSetup(0, pushTokenVoIP, 0, 0)) {
			char gerror[32];
			NSLog(@"galaxy_callSetup failed, gerror=%s", galaxy_error(gerror));
		}
	}
    
    [self performSelectorOnMainThread:@selector(startCallSetupTimer) withObject:nil waitUntilDone:NO];
}

- (void) startCallSetupTimer
{
    timerCallSetup = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(repeatCallSetup) userInfo:nil repeats:YES];
}

- (void) repeatCallSetup
{
    NSLog(@"galaxy callSetup repeat");
    if(strlen(authCode_nonce) == 24) galaxy_callSetup(1, pushTokenVoIP, callMD5, 0);//set parm repeated to 1 !!!
    else {
		if(!galaxy_callSetup(1, pushTokenVoIP, 0, 0)) {//set parm repeated to 1 !!!
			char gerror[32];
			NSLog(@"galaxy_callSetup failed, gerror=%s", galaxy_error(gerror));
		}
	}
}

static void CallTrying_Callback(void *inUserData)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleCallTryingCallBack];
}

- (void) handleCallTryingCallBack
{
    [timerCallSetup invalidate];
}
static void CallAlerting_Callback(void *inUserData)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleCallAlertingCallBack];
}

- (void) handleCallAlertingCallBack
{
    [timerCallSetup invalidate];
    [self performSelectorOnMainThread:@selector(displayText:) withObject:@"Call Alerting" waitUntilDone:NO];
    
}


static void CallAnswer_Callback(void *inUserData)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleCallAnswerCallBack];
}

- (void) handleCallAnswerCallBack
{
    [timerCallSetup invalidate];
	//[appDelegate.providerDelegate.provider reportOutgoingCallWithUUID:appDelegate.callController.outCallUUID connectedAtDate: nil];
    [self performSelectorOnMainThread:@selector(displayText:) withObject:@"Call Answer" waitUntilDone:NO];
}


static void CallRelease_Callback(void *inUserData, int errorCode)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleCallReleaseCallBackWithErrorCode:errorCode];
}

- (void) handleCallReleaseCallBackWithErrorCode: (int)errorCode
{
    [timerCallSetup invalidate];
	//[appDelegate.providerDelegate.provider reportCallWithUUID:appDelegate.callController.outCallUUID endedAtDate:nil reason:CXCallEndedReasonRemoteEnded];
    NSString *result;
    if(errorCode == 0) result = @"Call released normally";
	else if(errorCode == 8) result = @"呼叫鉴权失败，请删除gmobile重新添加";
	else if(errorCode == 10) result = @"呼叫失败，请确认运营商服务是否正常，比如SIM卡是否欠费停机";
    else result = [NSString stringWithFormat: @"Call released with error code %d", errorCode];
    [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
}

static void MessageNonceRsp_Callback(void *inUserData, int messageId, unsigned int relaySN, const char *nonce, int errorCode)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleMessageNonceRspCallBackWithMessageId:messageId relaySN:relaySN nonce:nonce errorCode:errorCode];
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
        if(!galaxy_messageSubmitReq(messageId, relaySN, callMD5, calledNumber.text.UTF8String, sms.text.UTF8String))
		{
			char gerror[32];
			NSLog(@"galaxy_messageSubmitReq failed, gerror=%s", galaxy_error(gerror));
		}
    }
    else {
        NSString *result = [NSString stringWithFormat: @"messageNonceRsp got without nonce"];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
        return;
	}
    
}

static void MessageSubmitRsp_Callback(void *inUserData, int messageId, unsigned int relaySN, int errorCode)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleMessageSubmitRspCallBackWithMessageId:messageId relaySN:relaySN errorCode:errorCode];
}

- (void) handleMessageSubmitRspCallBackWithMessageId: (int) messageId relaySN: (unsigned int)relaySN errorCode: (int)errorCode
{
    if(errorCode) {
        NSString *result = [NSString stringWithFormat: @"messageSubmitRsp got with error code %d", errorCode];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
        return;
    }
    else {
        NSString *result = [NSString stringWithFormat: @"sms send succ"];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
        return;
	}
}

static void MessageInHelloAck_Callback(void *inUserData, int seqId, unsigned int relaySN)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleMessageInHelloAckCallBackWithSeqId:seqId relaySN:relaySN];
}

- (void) handleMessageInHelloAckCallBackWithSeqId: (int) seqId relaySN: (unsigned int)relaySN
{
	NSString *result = [NSString stringWithFormat: @"messageInHelloAck got with seqId %d", seqId];
	[self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
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

static void MessageDeliverReq_Callback(void *inUserData, int messageId, unsigned int relaySN, const char *callingNumber, const char *content, const char *timestamp)
{
    ViewController *vc = (__bridge ViewController *)inUserData;
    [vc handleMessageDeliverReqCallBackWithMessageId:messageId relaySN:relaySN callingNumber:callingNumber content:content timestamp:timestamp];
}

- (void) handleMessageDeliverReqCallBackWithMessageId: (int) messageId relaySN: (unsigned int)relaySN callingNumber: (const char*)callingNumber content: (const char*) content timestamp: (const char*)timestamp
{
	//实际应用中，要根据messageId检查是否是重复发送的短消息。
	//timestamp转换为本地时区的时间
	NSString *dateTime = [self formatTimestamp:[NSString stringWithFormat: @"%s", timestamp]];
    NSString *sms = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
	NSString *result = [NSString stringWithFormat: @"短信内容:[%@],来自号码:[%s],发送时间:[%@]",
                        sms, callingNumber, dateTime];
	[self performSelectorOnMainThread:@selector(displayText:) withObject:result waitUntilDone:NO];
    NSLog(@"%@", result);
	//实际应用中，需要停止messageInHello重发定时器。
	return;
}

- (void) startSessionInviteTimer
{
    timerSessionInvite = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sessionInvite) userInfo:nil repeats:YES];
}

- (void) sessionInvite
{
	if(!galaxy_sessionInvite(calledNumber.text.UTF8String, 0, 0, 0, relaySN)) {
		char gerror[32];
		NSLog(@"galaxy_sessionInvite failed, gerror=%s", galaxy_error(gerror));
	}
    
}

- (IBAction)dial:(id)sender {

	//[appDelegate.callController startCallWithHandle:calledNumber.text];
	[self sessionInvite];
    [self performSelectorOnMainThread:@selector(startSessionInviteTimer) withObject:nil waitUntilDone:NO];
	display.text = @"Call Dialing";
}

- (IBAction)hangup:(id)sender {
	/*
    [appDelegate.providerDelegate.timerSessionInvite invalidate];
    [timerCallSetup invalidate];
	[appDelegate.callController endCall];
	*/
	interface_viberate = 0;
	//在实际应用中，如果是callin，要停止针对callInAlerting和callInAnswer的重发定时器
	if(!galaxy_callRelease()) {
		char gerror[32];
		NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
	}
	else {
		NSLog(@"SHAY galaxy_callInRelease sent");
	}
    display.text = @"Call Released";
}

- (IBAction)answer:(id)sender
{
	interface_viberate = 0;
	//实际应用中，要启动定时器重发galaxy_callInAnswer
	if(!galaxy_callInAnswer()) {
		char gerror[32];
		NSLog(@"galaxy_callInAnswer failed, gerror=%s", galaxy_error(gerror));
	}
	NSLog(@"SHAY galaxy_callInAnswer sent");
    display.text = @"Call Answering";
}

- (IBAction)sms:(id)sender {
    messageId = rand();
	//在实际应用中，必须启动定时器，具体参考galaxy_messageNonceReq函数的注释。
    if(!galaxy_messageNonceReq(messageId, relaySN)) {
        char gerror[32];
        NSLog(@"galaxy_messageNonceReq failed, gerror=%s", galaxy_error(gerror));
    }
    else display.text = @"SMS sending";
}

- (IBAction)login:(id)sender {
    loginSeqId++;
    //strcpy(pushToken, "98b5d16862a9cdbf43a8d220ab0b269a6ede0c8e535c67988b4ca79970e99007"); //实际应用中，由Apple分配，并保存在flash中。
    //strcpy(pushTokenVoIP, "67b0dbf63d7823c900fdbfdda1179185aab1a32fce25daf06586b975711e7edc"); //实际应用中，由Apple分配，并保存在flash中。
    
    //authCode_nonce前半部分存放authCode
    //sprintf(authCode_nonce, "%08x%08x", rand(), rand());
    strcpy(authCode_nonce, "3F2504E08D64C20A");  
    strcpy(authCode_nonce_message, "3F2504E08D64C20A");  

    if(!galaxy_relayLoginReq(loginSeqId, relaySN, relayName, 1, pushToken, pushTokenVoIP, authCode_nonce)) {
		display.text = @"gmobile login failed";
		char gerror[32];
		NSLog(@"galaxy_relayLoginReq failed, gerror=%s", galaxy_error(gerror));
	}
    else display.text = @"gmobile login start";
}

- (IBAction)getRelayStatus:(id)sender {
    if(!galaxy_relayStatusReq(relaySN)) {
		display.text = @"get gmobile status failed";
		char gerror[32];
		NSLog(@"galaxy_relayStatusReq failed, gerror=%s", galaxy_error(gerror));
	}
    else display.text = @"get gmobile status start";
}

- (void) startVersionCheckTimer
{
    timerVersionCheck = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(versionCheck) userInfo:nil repeats:YES];
}

- (void) versionCheck
{
	if(!galaxy_versionCheckReq()) {
		char gerror[32];
		NSLog(@"galaxy_versionCheck failed, gerror=%s", galaxy_error(gerror));
	}
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    relaySN = 0x11223344; //在实际应用中，relaySN由用户输入
    
    

	//appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!galaxy_init()) {
        display.text = @"init failed";
        char gerror[32];
		NSLog(@"galaxy_init failed, gerror=%s", galaxy_error(gerror));
    }
    else display.text = @"init succ";

	galaxy_setVersionCheckCallbacks(VersionCheckRsp_Callback,(__bridge void *)(self));
	galaxy_setRelayCallbacks(RelayLoginRsp_Callback,RelayStatusRsp_Callback,(__bridge void *)(self));
	galaxy_setSessionCallbacks(SessionConfirm_Callback, (__bridge void *)(self));
	galaxy_setCallOutCallbacks(CallTrying_Callback,0, CallAlerting_Callback, CallAnswer_Callback, CallRelease_Callback,(__bridge void *)(self));
	//实际应用中，callIn的每个callback必须有，且必须要做相应的处理，比如定时器的停止。尤其对于callInRelease_Callback，要在callkit做相应的结束呼叫的处理。
	galaxy_setCallInCallbacks(CallInAlertingAck_Callback,CallInAnswerAck_Callback,CallInRelease_Callback, (__bridge void *)(self));
	galaxy_setMessageCallbacks(MessageNonceRsp_Callback, MessageSubmitRsp_Callback, MessageInHelloAck_Callback, MessageDeliverReq_Callback, (__bridge void *)(self));

	//检查版本兼容性
	[self versionCheck];
    [self performSelectorOnMainThread:@selector(startVersionCheckTimer) withObject:nil waitUntilDone:NO];

    NSLog(@"SHAY view started");

	//NSString *td = [self formatTimeStr:@"20180205120833+0900"];
	//NSLog(@"SHAY datetime=%@", td);
	
    //实际应用中，galaxy_messageInHello必须按照API文档的说明，使用定时器重发
    /*
    int seqId = rand();
    
    if(!galaxy_messageInHello(seqId, relaySN)) {
        display.text = @"messageInHello failed";
        char gerror[32];
        NSLog(@"galaxy_messageInHello failed, gerror=%s", galaxy_error(gerror));
    }
    */
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
