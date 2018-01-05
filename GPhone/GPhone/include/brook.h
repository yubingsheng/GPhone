#ifndef __BROOK_H__wefoi389jfiojfEJI9jief
#define __BROOK_H__wefoi389jfiojfEJI9jief

#ifdef __cplusplus
extern "C" {
#endif

//本结构目前不用
typedef struct GMenu {
	char *menuLevel;
	char *contentType;
	unsigned char *content;
	int contentSize;
	int needUserInput1;
	int needUserInput2;
	int needUserInput3;
	int nextAction; //0, none, 1, menu, 2, chat, 3, call, 4, cnc, 5, newSession
	char *newCalledNumber;
}GMenu;

//inUserData normally used in IOS to transfer 'self' reference. in android just simply set to 0
/*
   参数解释：
   relaySN：等于galaxy_relayLoginReq()调用时填入的relaySN。
   errorCode：参看MCC01协议的Mcc01RelayLoginErrorCode。
*/
typedef void (*RelayLoginRsp)(void *inUserData, int seqId, unsigned int relaySN, int errorCode);

/*
   参数解释：
   relaySN：等于galaxy_relayStatusReq()调用时填入的relaySN。
   networkOK: 此relay的网络连接是否正常。
   signalStrength: 对于gmobile，指无线信号强度，0~5,0指无信号，5指最强信号。
   //relayFirmwareUpdateStatus：参看MCC01协议的Mcc01RelayFirmwareUpdateStatus
*/
//typedef void (*RelayStatusRsp)(void *inUserData, unsigned int relaySN, int networkOK, int signalStrength, int relayFirmwareUpdateStatus);
typedef void (*RelayStatusRsp)(void *inUserData, unsigned int relaySN, int networkOK, int signalStrength);


/*
   参数解释：
   relaySN：等于galaxy_relayFirmwareUpdateReq()调用时填入的relaySN。
   result：参看MCC01协议的Mcc01RelayFirmwareUpdateResult。
*/
//typedef void (*RelayFirmwareUpdateRsp)(void *inUserData, unsigned int relaySN, int result);

/*
   SessionConfirm参数解释：
   relaySN：被选中的relay的序列号。后续的galaxy_callSetup()函数调用时，auth参数应当根据此relaySN对应的值来产生，具体参考galaxy_callSetup()的说明。
   menuSupport：目前忽略此参数。
   chatSupport：目前忽略此参数。
   callSupport：如果此参数值为0，APP应当提示用户“被叫号码不支持语音呼叫”并结束本次呼叫。errorCode不为0时，此参数值无意义。
   nonce：如果此指针值不为NULL，APP在后续调用的galaxy_callSetup()函数中，必须设置auth值。errorCode不为0时，此参数值无意义。
   errorCode：errorCode不等于0时，表示sessionInvite失败，APP应当提示用户“暂时无法发起呼叫”并结束后续流程。errorCode的取值参看MCC01协议的Mcc01SessionErrorCode。
*/
typedef void (*SessionConfirm)(void *inUserData, unsigned int relaySN, int menuSupport, int chatSupport, int callSupport, const char *nonce, int errorCode);
typedef void (*MenuRsp)(void *inUserData, const GMenu *gmenu, int gmenuCount, int errorCode);
typedef void (*CallNotify)(void *inUserData);

/*
   参数解释：
   errorCode：参看MCC01协议的Mcc01CallErrorCode。当返回的errorCode为authFailed时，APP要提示用户删除对应的gmobile重新添加（即重新执行galaxy_relayLoginReq()）
*/
typedef void (*CallReleased)(void *inUserData, int errorCode);

/*
   参数解释：
   relaySN：入呼叫来自的gmobile的序列号。
   calledNumber：入呼叫的被叫号码，正常情况下为NULL。
   callingNumber：入呼叫的主叫号码。ASCII字符串。
*/
typedef void (*CallInAlertingAck)(void *inUserData, int callId, unsigned int relaySN);
typedef void (*CallInRejectAck)(void *inUserData, unsigned int relaySN, const char *uuid);
//typedef void (*CallInSetup)(void *inUserData, unsigned int relaySN, const char *calledNumber, const char *callingNumber);
//typedef void (*CallInAlertingAck)(void *inUserData);
typedef void (*CallInAnswerAck)(void *inUserData);

/*
   参数解释：
   errorCode：参看MCC01协议的Mcc01CallInErrorCode
*/
typedef void (*CallInReleased)(void *inUserData, int errorCode);

//relaySN and messageId must deliver to APP since multi message may exist at the same time. 
//however, only one call exist at the same time.
/*
   参数解释：
   messageId：等于galaxy_messageNonceReq()调用时填入的messageId。
   relaySN：等于galaxy_messageNonceReq()调用时填入的relaySN。
   nonce：返回的nonce。nonce为NULL时，表示无需鉴权，后续的galaxy_messageSubmit()调用的auth填写为NULL。
   errorCode：参看MCC01协议的Mcc01MessageNonceErrorCode。
*/
typedef void (*MessageNonceRsp)(void *inUserData, int messageId, unsigned int relaySN, const char *nonce, int errorCode);
/*
   参数解释：
   messageId：等于galaxy_messageSubmit()调用时填入的messageId。
   relaySN：等于galaxy_messageSubmit()调用时填入的relaySN。
   errorCode：参看MCC01协议的Mcc01MessageSubmitErrorCode。当返回的errorCode为authFailed时，APP要提示用户删除对应的gmobile重新添加（即重新执行galaxy_relayLoginReq()
*/
typedef void (*MessageSubmitAck)(void *inUserData, int messageId, unsigned int relaySN, int errorCode);
/*
   参数解释：
   参数含义和galaxy_messageSubmit()函数各项参数的含义相同。
*/
typedef void (*MessageDeliver)(void *inUserData, int messageId, unsigned int relaySN, const char *calledNumber, const char *callingNumber, const char *content, int contentSize);


//set myRelaySN to 0 when no my relay
int send_mcc01_sessionInvite(const char *calledNumber, const char *callingNumber, const char *callingName, const char *userInfo, unsigned int myRelaySN);
int send_mcc01_menuReq(const char *menuLevel, const char *userInputContent, int userInputContentSize, const char *userInputContentExt1, int userInputContentExt1Size, const char *userInputContentExt2, int userInputContentExt2Size);

int send_mcc01_callInAlerting(int repeated, unsigned int relaySN, const char *uuid, const char *callingNumber);
int send_mcc01_callInReject(unsigned int relaySN, const char *uuid, const char *callingNumber);
//int send_mcc01_callInAlerting();
int send_mcc01_callInAnswer();

int send_mcc01_callSetAudioCodecReq(int opus_16000_enabled);
int send_mcc01_callRelease();

int send_mcc01_messageNonceReq(int messageId, unsigned int relaySN);
//auth fixed to 16byte
int send_mcc01_messageSubmit(int messageId, unsigned int relaySN, const unsigned char *auth, const char *calledNumber, const char *callingNumber, const char *content, int contentSize);

int send_mcc01_relayLoginReq(int seqId, unsigned int relaySN, const char *relayName, int phoneType, const char *pushToken, const char *pushTokenVoIP, const char *authCode);
int send_mcc01_relayStatusReq(unsigned int relaySN);
//int send_mcc01_relayFirmwareUpdateReq(unsigned int relaySN);
#ifdef __cplusplus
}
#endif
#endif //__BROOK_H__
