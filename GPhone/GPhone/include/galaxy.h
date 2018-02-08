#ifndef _Galaxy_sjfowe934jejfmlwfw
#define _Galaxy_sjfowe934jejfmlwfw
#ifdef __cplusplus
extern "C" {
#endif

/*this is the API for galaxy mcc01 client developing*/
/*
release notes:
20180128:
1, 入呼叫此版本已经可以正常使用。参考下面的入呼叫信令流程说明以及demo程序。由于demo程序对callkit的使用还有些问题，此版本demo程序只能正常接收一次入呼叫，需要杀掉demo程序后，才能再次正常接收入呼叫。使用demo程序测试入呼叫的步骤：
   1)，手工修改demo程序的ViewController.m里的device token和voip device token的值，设置为从APNS获取的正确的值。编译安装demo app。
   2)，使用任意电话拨打测试号码13255030725。
   3)，pushkit和callkit将被激活，可以在界面上应答呼叫。
2, 增加了versionCheck机制，包括galaxy_versionCheckReq()函数和相应的回调函数。APP在执行了galaxy_init()函数和设置了相应的回调函数后，应当调用galaxy_versionCheckReq()检查APP包含的galaxy库的版本兼容性。具体参考galaxy_versionCheckReq()函数说明和demo程序。
3，增加galaxy_error()函数，APP在某个galaxy函数调用失败时，需要使用galaxy_error()获取错误码并使用半透明灰色提示条将错误码呈现。更多内容参考galaxy_error()函数说明和demo程序。
4, 修改了galaxy_init()函数，去除了回调函数参数。回调函数单独在galaxy_setXxxxxCallbacks()中进行设置;
5, 头文件brook.h不再需要。

20171227:
1，galaxy_relayLoginReq方法增加relayName参数和pushTokenVoIP参数。relayName设置为用户输入的gmobile的名称，使用UTF-8编码；而pushTokenVoIP参数设置为APP从APPLE获取的pushkit device token。demo程序的类AppDelegate增加了相应的获取pushkit device token的代码。
2，galaxy_relayLoginReq方法的seqId和relaySN参数的位置做了对调。
3，galaxy_sessionInvite方法删除了callingNameSize和userInfoSize参数。
4，修改了入呼叫流程，详见下面的信令流程部分。
5，galaxy_init()方法对入呼叫的回调函数参数做了相应的调整。
6，demo程序提供了在收到pushkit推送消息时，启动callkit的简单示例代码。 其实现参考了 http://www.jianshu.com/p/3bf73a293535 。这个网页提供了一份demo代码，可用于理解和使用callkit。

20171214:
1，authCode字符串长度增加到16字节，原来为8个字节。在galaxy_relayLoginReq()的注释中，对authCode的产生和保存机制做了详细的说明。请注意authCode是全局性的，并不是每个gmobile都有自己的authCode。需要特别注意galaxy_relayLoginReq()注释中的这句话：
用户添加gmobile时，APP应当首先检查对应relaySN的gmobile是否已经添加过，如果已经添加过，则要提示用户"您要添加的gmobile已经存在，是否需要重新添加？"，并提供是和否的选项。

相应的，demo程序的以下变量定义和函数做了修改：
char authCode_nonce[41];  //authCode(16) + nonce(8) + 0

- (void) handleSessionConfirmCallBackWithRelaySN: (unsigned int)relaySN MenuSupport: (int)menuSupport ChatSupport: (int)chatSupport CallSupport: (int)callSupport Nonce: (const char*)nonce ErrorCode: (int)errorCode
- (void) repeatCallSetup
- (IBAction)login:(id)sender 

2，lib库增加一个libgalaxy7.a。
3，修改了底层传输规则，所以此版本库不兼容以前的版本。
4，用户每次启动APP，都应当重新获取deviceToken，如果和APP当前保存的deviceToken不一致(即deviceToken发生变化)，要提醒用户重新添加所有的gmobile，否则将无法接收到呼叫和短信。


20171206:
1，改进了demo程序的MD5的使用效率。
2, demo程序增加了galaxy_relayStatusReq的用法示例。

20171204:
1，galaxy_relayLoginReq()增加了seqId参数，用于匹配Req和Rsp。具体参见galaxy_relayLoginReq()函数的说明。
2，galaxy_sessonInvite()函数增加了超时重发要求。要求在调用galaxy_sessionInvite()时，启动定时器以重发galaxy_sessionInvite()。具体参见galaxy_sessionInvite()函数的说明。并在demo程序里写了相应的示例。
3，relay firmware update机制被取消。相应的，取消galaxy_relayFirmwareUpdateReq()，相应的回调函数也被取消。
4，galaxy_controller.h头文件重新命名为galaxy.h
5，demo程序增加了galaxy_relayLoginReq()的用法。


20171128:
1，galaxy_callSetup()函数增加了repeated参数。并增加了galaxy_callSetup()的注释说明，要求在调用galaxy_callSetup()时，启动定时器以重发galaxy_callSetup()。并在demo程序里写了相应的示例。特别的，APP需要为此增加call_trying回调函数。
2，galaxy库增加了bitcode支持。
*/


/*
信令流程说明：
一，从APP角度看出呼叫（外呼）流程：

动作                                                                                                      对应的MCC01消息
1，APP调用galaxy_sessionInvite()。                                                                        发送sessionInvite消息
2，session_confirm()回调函数被调用。                                                                      收到sessionConfirm消息
3，APP调用galaxy_callSetup()。                                                                            发送callSetup消息
4，call_alerting()回调函数被调用，指示对端开始振铃。此调用可能不发生。                                    收到callAlerting消息
5，call_answer()回调函数被调用，指示对端应答。                                                            收到callAnswer消息

在调用galaxy_callSetup()以后，call_released()回调函数可能会被随时调用，指示对端挂机。（接收到对端发送的MCC01 callRelease消息）
在调用galaxy_callSetup()以后，APP也可以随时调用galaxy_callRelease()函数以结束呼叫（挂机）。（向对端发送MCC01 callRelease消息）


二，从APP角度看入呼叫流程(呼叫正常接通)：

动作                                                                                                      对应的MCC01消息
1，APP收到PUSHKIT推送消息，指示有新的入呼叫。
2，APP启动callkit。向用户振铃。
3，APP在callkit启动成功后，调用galaxy_callInAlerting()。                                                  发送callInAlerting消息
4，galaxy收到对端发送的MCC01 callInAlertingAck消息， call_in_alerting_ack()回调函数被调用。
5，用户应答后，APP调用galaxy_callInAnswer()。向对端指示本端应答。                                         发送callInAnswer消息

在调用galaxy_callInAlerting方法后，call_in_released()回调函数可能会被随时调用，指示对端挂机。（接收到对端发送的MCC01 callInRelease消息）
在调用galaxy_callInAlerting方法后，APP也可以随时调用galaxy_callRelease()函数以结束呼叫（挂机）。（向对端发送MCC01 callInRelease消息）

三，从APP角度看入呼叫流程(呼叫被拒绝)：

动作                                                                                                      对应的MCC01消息
1，APP收到PUSHKIT推送消息，指示有新的入呼叫。
2，APP发现需要拒绝此呼叫（可能的原因包括当前已经有呼叫存在等）。
3，APP调用galaxy_callInReject()拒绝呼叫。                                                                 发送callInReject消息
4，galaxy收到对端发送的MCC01 callInRejectAck消息， call_in_reject_ack()回调函数被调用。

四，从APP角度看短信发送流程：

动作                                                                                                      对应的MCC01消息
1，APP调用galaxy_messageNonceReq()。 以获取鉴权用的nonce。                                                发送messageNonceReq消息
2，message_nonce_rsp()回调函数被调用。                                                                    收到messageNonceRsp消息
3，APP调用galaxy_messageSubmit()。                                                                        发送messageSubmit消息
4，message_submit_ack()回调函数被调用，指示对端成功发送了短信。                                           收到messageSubmitAck消息

五，从APP角度看短信接收流程：

动作                                                                                                      对应的MCC01消息
1，APP收到PUSH普通推送消息，指示有新的短信。
2，APP调用galaxy_messageInHello()。                                                                       发送messageInHello消息
3，galaxy收到对端发送的messageInHelloAck消息时，调用message_in_hello_ack()回调函数。
3，message_deliver()回调函数被调用，指示有新的短信。                                                      收到messageDeliver消息
*/


//此函数目前不用
void galaxy_setHDVoice(int enable_hd_voice);

//typedef void (*DtmfGot)(void *inUserData, int dtmf);

//此结构目前不使用
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
   result：参看MCC01协议的Mcc01VersionCheckResult
*/
typedef void (*VersionCheckRsp)(void *inUserData, int result);

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
typedef void (*CallInRejectAck)(void *inUserData, int callId, unsigned int relaySN);
//typedef void (*CallInRejectAck)(void *inUserData, unsigned int relaySN, const char *uuid);
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

/*
   函数功能：
   galaxy_init()函数是整个galaxy库的初始化库，APP在使用其他galaxy API之前，应当首先调用这个函数对galaxy库进行初始化。

   返回值：
   函数执行成功返回1，失败返回0。

*/
int galaxy_init();

/*
   函数功能：
   galaxy_setXXXCallbacks()函数用于设置相关的回调函数。

   返回值：无

   参数解释：
   以下参数应用于出呼叫：
   session_confirm：这是galaxy库收到MCC01的sessionConfirm消息时的回调函数，sessionConfirm是对端对sessionInvite消息的回应。对SessionConfirm类型的解释，请参考brook.h。 APP在此回调函数里，应当停止针对galaxy_sessionInvite()的重发定时器，参考函数galaxy_sessionInvite()的注释里重发定时器的说明。
   inUserData_session：用户数据，APP在调用galaxy_init()函数时，可将用户数据指针放入，sessionConfirm回调函数的第一个参数将返回这个指针。本函数的其他inUserData_xxx参数的作用类似。
   menu_rsp：目前不使用，直接设置为NULL。
   inUserData_menu：目前不使用，直接设置为NULL。
   call_trying：这是出呼叫对端指示接收到呼叫时的回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释。
   call_busy：直接设置为NULL。
   call_alerting：这是出呼叫对端振铃时的回调函数。galaxy库收到对端发送的MCC01 callAlerting消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释里重发定时器的说明。
   call_answer：这是出呼叫对端应答时的回调函数。galaxy库收到对端发送的MCC01 callAnswer消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释里重发定时器的说明。
   call_released：这是出呼叫对端挂机时的回调函数。galaxy库收到对端发送的MCC01 callRelease消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释里重发定时器的说明。
   inUserData_call：参考inUserData_session的解释。

   以下参数应用于入呼叫：
   call_in_alerting_ack：对于入呼叫，APP收到PUSHKIT消息后，确认当前空闲时需要调用galaxy_callInAlerting()向对端发送MCC01 callInAlerting消息向对端提示，本端正在振铃。在收到对端回应的MCC01 callInAlertingAck消息时，galaxy回调此函数，APP在此回调函数里，应当停止针对galaxy_callInAlerting()的重发定时器，参考函数galaxy_callInAlerting()的注释里重发定时器的说明。
   call_in_reject_ack：对于入呼叫，APP收到PUSHKIT消息后，如果确认拒接此呼叫，需要调用galaxy_callInReject()向对端发送MCC01 callInReject消息。在收到对端回应的MCC01 callInRejectAck消息时，galaxy回调此函数，APP在此回调函数里，应当停止针对galaxy_callInReject()的重发定时器，参考函数galaxy_callInReject()的注释里重发定时器的说明。
   call_in_answer_ack：对于入呼叫，APP在用户按键应答电话时需要调用galaxy_callInAnswer()向对端发送MCC01 callInAnswer消息向对端提示本端已经应答。在收到对端回应的MCC01 callInAnswerAck消息时，galaxy回调此函数，APP在此回调函数里，应当停止针对galaxy_callInAnswer()的重发定时器，参考函数galaxy_callInAnswer()的注释里重发定时器的说明。
   call_in_released：这是入呼叫对端挂机时的回调函数。galaxy库收到对端发送的MCC01 callInRelease消息后，调用此回调函数。
   inUserData_call_in：参考inUserData_session的解释。
   
   以下参数应用于短信的发送和接收：
   message_nonce_rsp：galaxy收到对端的MCC01 messageNonceRsp消息时的回调函数，MCC01 messageNonceRsp是对端对MCC01 messageNonceReq消息的回应。
   message_submit_ack：galaxy收到对端的MCC01 messageSubmitAck消息时的回调函数。
   message_deliver：galaxy收到对端的MCC01 messageDeliver消息时的回调函数。
   inUserData_message：参考inUserData_session的解释。
   
   以下参数应用于gmobile：
   relay_login_rsp：参考galaxy_relayLoginReq()函数的解释。
   relay_status_rsp：参考galaxy_relayStatusReq()函数的解释。
   //relay_firmware_upate_rsp：参考galaxy_relayFirmwareUpdateReq()函数的解释。
   inUserData_relay：
*/
void galaxy_setVersionCheckCallbacks(const VersionCheckRsp version_check_rsp, void *inUserData_version);
void galaxy_setRelayCallbacks(const RelayLoginRsp relay_login_rsp, const RelayStatusRsp relay_status_rsp, void *inUserData_relay);
void galaxy_setSessionCallbacks(const SessionConfirm session_confirm, void *inUserData_session);
void galaxy_setMenuCallbacks(const MenuRsp menu_rsp, void *inUserData_menu);
void galaxy_setCallOutCallbacks(const CallNotify call_trying, const CallNotify call_busy, const CallNotify call_alerting, const CallNotify call_answer, const CallReleased call_released, void *inUserData_call);
void galaxy_setCallInCallbacks(const CallInAlertingAck call_in_alerting_ack, const CallInRejectAck call_in_reject_ack, const CallInAnswerAck call_in_answer_ack, const CallInReleased call_in_released, void *inUserData_call_in);
void galaxy_setMessageCallbacks(const MessageNonceRsp message_nonce_rsp, const MessageSubmitAck message_submit_ack, const MessageDeliver message_deliver, void *inUserData_message);

/*
   函数功能：
   galaxy_versionCheckReq()用于检查当前galaxy库的版本号是否匹配。
   APP调用galaxy_versionCheckReq()向对端发送MCC01 versionCheckReq消息后，galaxy收到对端的回应消息MCC01 versionCheckRsp后，调用回调函数version_check_rsp。
   APP应当在galaxy_init()之后，立即调用此函数以检查当前APP使用的galaxy库是否兼容当前的服务器版本，如果服务器返回的版本检查结果是versionMustUpdate，则应当强制用户进行APP升级，拒绝用户继续使用APP。
   APP应当每隔3秒钟调用galaxy_versionCheckReq()重发MCC01 versionCheckReq消息，直到收到对端的回应消息。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。

   返回值：
   函数执行成功返回1，失败返回0。
   
*/
int galaxy_versionCheckReq();
/*
   函数功能：
   galaxy_relayLoginReq()用于添加gmobile。 relay是指VoIP呼叫的中继设备，gmobile是其中一种relay。
   APP调用galaxy_relayLoginReq()向对端发送MCC01 relayLoginReq消息后，galaxy收到对端的回应消息MCC01 relayLoginRsp后，调用回调函数relay_login_rsp。
   APP安装后首次启动时，应当提示用户添加gmobile。用户可以选择“以后再添加”，APP正常进入首页。
   用户添加gmobile时，APP应当首先检查对应relaySN的gmobile是否已经添加过，如果已经添加过，则要提示用户"您要添加的gmobile已经存在，是否需要重新添加？"，并提供是和否的选项。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   seqId: APP自定义的序列号，用于匹配Req和Rsp。seqId必须是大于0的整数。seqId应该在APP运行期间不重复。
   relaySN：gmobile的序列号。
   relayName: 用户设置的relay名称，使用UTF-8编码传入。 
   phoneType：参看MCC01协议里的Mcc01PhoneType。
   pushToken：in IOS, pushToken is the device token return by Apple APNs to APP。必须转换为ASCII字符串的形式，长度为64字节。比如 02a2fca6e3ec1ea62aa4b6a344fb9ad7f31f491b7099c0ddf7761cea6c563980
   pushTokenVoIP：in IOS, pushToken is the VoIP device token return by Apple pushkit to APP。必须转换为ASCII字符串的形式，长度为64字节。in android, set same value as pushToken。
   authCode：这是用于后续出呼叫和发送短信时鉴权的鉴权码。如果用户在添加gmobile时，APP当中没有已经注册成功的gmobile，则无论APP是否已经保存了authCode，APP都应当新产生一个随机数作为authCode并保存(如果原来已经保存了authCode，则替换它)，特别的，如果用户在添加gmobile时，虽然APP当中已经有一个注册过的gmobile，但此gmobile的relaySN和要添加的gmobile相同，则当做APP当中没有已经注册成功的gmobile；如果用户在添加gmobile时，APP当中已经有注册成功的gmobile，则使用当前保存的authCode。authCode是64bit随机数的十六进制ASCII字符串的形式，长度为16字节，比如"3F2504E08D64C20A"。
   
*/
//#define galaxy_relayLoginReq(seqId, relaySN, relayName, phoneType, pushToken, pushTokenVoIP, authCode) send_mcc01_relayLoginReq(seqId, relaySN, relayName, phoneType, pushToken, pushTokenVoIP, authCode)
int galaxy_relayLoginReq(int seqId, unsigned int relaySN, const char *relayName, int phoneType, const char *pushToken, const char *pushTokenVoIP, const char *authCode);
/*
   函数功能：
   APP调用galaxy_relayStatusReq向对端发送MCC01 relayStatusReq消息后，galaxy收到对端的回应消息MCC01 relayStatusRsp后，调用回调函数relay_status_rsp。
   APP在启动时，需要针对每个gmobile发送一遍此消息，以获取gmobile的当前状态。此后，用户可以随时按刷新按钮，通过调用此函数更新gmobile的状态。

   返回值：
   函数执行成功返回1，失败返回0。
*/
//#define galaxy_relayStatusReq(relaySN) send_mcc01_relayStatusReq(relaySN)
int galaxy_relayStatusReq(unsigned int relaySN);
/*
   函数功能：
   APP在回调函数relay_status_rsp中的参数status指示gmobile的状态为okWithFirmwareCanUpdate时，向用户呈现gmobile可以升级的对话框，在用户点击确认时，调用本函数要求gmobile进行升级。
   APP在回调函数relay_status_rsp中的参数status指示gmobile的状态为okWithFirmwareMustUpdate时，向用户呈现gmobile必须升级的对话框，在用户点击确认时，调用本函数要求gmobile进行升级。   

   返回值：
   函数执行成功返回1，失败返回0。
*/
//#define galaxy_relayFirmwareUpdateReq(relaySN) send_mcc01_relayFirmwareUpdateReq(relaySN)


/*
   函数功能：
   本函数是出呼叫时首先调用的函数。调用此函数后，galaxy向对端发送MCC01 sessionInvite消息。并且在收到对端的回应消息MCC01 sessionConfirm时，调用session_confirm回调函数。
   如果APP中当前已经有出呼叫或入呼叫存在（一个已经存在的出呼叫或者入呼叫，如果发送或者收到MCC01 callRelease消息，则表明呼叫结束，此呼叫已经不存在。），则不允许调用此函数。应当禁止用户尝试发起新的出呼叫。
   APP应当每隔3秒钟调用galaxy_sessionInvite()重发MCC01 sessionInvite消息，直到收到对端的sessionConfirm消息或呼叫结束。所以应当在接收到相应MCC01 sessionConfirm的回调函数里，停止计时器。参见galaxy_init()函数的说明。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   calledNumber：被叫号码，ASCII字符串形式。
   callingNumber: 主叫号码，ASCII字符串形式。目前填写NULL。
   callingName：UTF-8编码格式。目前不使用，直接填写NULL。
   userInfo：UTF-8编码格式。目前不使用，直接填写NULL。
   myRelaySN：如果此前没有通过galaxy_relayLoginReq()添加过任何gmobile，则此参数填写0；如果此前添加过单个gmobile，或者虽然有多个gmobile但用户设置了默认的gmobile，则填写此gmobile的序列号；如果此前添加过多个gmobile，且没有设置默认的gmobile，则在调用此函数前，要求用户选择使用的gmobile，然后把用户选中的gmobile的序列号填入此参数。
*/
//#define galaxy_sessionInvite(calledNumber, callingNumber, callingName, userInfo, myRelaySN) send_mcc01_sessionInvite(calledNumber, callingNumber, callingName, userInfo, myRelaySN)
int galaxy_sessionInvite(const char *calledNumber, const char *callingNumber, const char *callingName, const char *userInfo, unsigned int myRelaySN);

/*
   此函数目前不使用。
*/
//#define galaxy_menuReq(menuLevel, userInputContent1, userInputContent1Size, userInputContent2,userInputContent2Size, userInputContent3, userInputContent3Size) send_mcc01_menuReq(menuLevel, userInputContent1, userInputContent1Size, userInputContent2,userInputContent2Size, userInputContent3, userInputContent3Size)
int galaxy_menuReq(const char *menuLevel, const char *userInputContent1, int userInputContent1Size, const char *userInputContent2, int userInputContent2Size, const char *userInputContent3, int userInputContent3Size);

/*
   函数功能：
   本函数用于出呼叫。当session_confirm回调函数指示errorCode==0并且callSupport==1时，立即调用此函数尝试建立呼叫。
   APP应当每隔3秒钟调用galaxy_callSetup()重发MCC01 callSetup消息，直到收到对端的回应消息或呼叫结束。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_init()函数的说明。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   repeated：由于定时器到需要重新调用galaxy_callSetup()时，repeated参数置为1，否则置为0。 
   auth：鉴权信息。auth = MD5(authCode + nonce)。其中的authCode对应于在调用galaxy_relayLoginReq()使用的authCode(session_confirm回调函数返回的relaySN对应的gmobile的authCode)；nonce为session_confirm返回的nonce值。当session_confirm返回的nonce为NULL时，auth设置为NULL。举个例子：authCode="3F2504E0"，nonce="8E98347D"，则auth=MD5("3F2504E08E98347D")
   menuLevel：填入NULL。
*/
int galaxy_callSetup(int repeated, const unsigned char *auth, const char *menuLevel);



/*
   函数功能：
   本函数用于入呼叫。当APP收到PUSHKIT推送消息，指示有新的入呼叫时，APP调用此函数发送MCC01 callInAlerting消息给对端。galaxy库收到对端的callInAlertingAck消息，将调用相应的回调函数报告给APP。
   APP应当每隔3秒钟调用galaxy_callInAlerting()重发MCC01 callAlerting消息，直到收到对端的回应消息或呼叫结束。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_init()函数的说明。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   callid: 填写APP收到的PUSHKIT推送消息里传送过来的callid。
   relaySN：填写APP收到的PUSHKIT推送消息里传送过来的relaySN。
*/
//#define galaxy_callInAlerting(callid, relaySN)   send_mcc01_callInAlerting(callid, relaySN)
int galaxy_callInAlerting(int callid,  unsigned int relaySN);
/*
   函数功能：
   本函数用于入呼叫。当APP收到PUSHKIT推送消息，指示有新的入呼叫时，如果由于某种原因APP需要拒绝此呼叫（比如已经有呼叫存在），调用本函数拒绝。要特别注意，如果APP振铃后（发送了callInAlerting）需要结束呼叫（比如用户按拒接键），则必须调用galaxy_callRelease()，而不是galaxy_callInReject()。
   APP应当每隔3秒钟调用galaxy_callInReject()重发MCC01 callInReject消息，直到收到对端的回应消息。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_init()函数的说明。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   callid: 填写APP收到的PUSHKIT推送消息里传送过来的callid。
   relaySN：填写APP收到的PUSHKIT推送消息里传送过来的relaySN。
*/
int galaxy_callInReject(int callid,  unsigned int relaySN);
/*
   函数功能：
   本函数用于入呼叫。用户点击接听按钮时，APP调用此函数向对端发送MCC01 callInAnswer消息，以提示对端本端应答。
   APP应当每隔3秒钟调用galaxy_callInAnswer()重发MCC01 callAlerting消息，直到收到对端的回应消息或呼叫结束。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_init()函数的说明。

   返回值：
   函数执行成功返回1，失败返回0。
*/
//#define galaxy_callInAnswer()   send_mcc01_callInAnswer() 
int galaxy_callInAnswer();

/*
   函数功能：
   本函数可用于入呼叫和出呼叫。用户点击挂机按钮时，APP调用此函数向对端发送挂机消息（MCC01 callRelease或callInRelease消息）。

   返回值：
   函数执行成功返回1，失败返回0。
*/
//#define galaxy_callRelease() send_mcc01_callRelease()
int galaxy_callRelease();
/*
   函数功能：
   本函数可用于入呼叫和出呼叫。当APP检测到手机的网络环境发生改变，比如由运营商数据网络切换到WIFI，或者网络中断后又恢复，必须立即调用此函数更新语音媒体流。

   返回值：
   函数执行成功返回1，失败返回0。
*/
int galaxy_callResetAudioStream();
//此函数目前不使用
//#define galaxy_callSetHDVoice(enable_hd_voice) send_mcc01_callSetAudioCodecReq(enable_hd_voice)
int galaxy_callSetHDVoice(int enable_hd_voice);

/*
   函数功能：
   本函数可用于入呼叫和出呼叫。呼叫应答以后，用户在手机上按键时，调用本函数向对端发送相应的按键。
   用户每按一个键，都需要调用本函数一次。
   比如，用户按了5，则调用galaxy_dial_dtmf("5");

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   dtmf_char：按键字符串，允许的字符为0-9*#。
*/
int galaxy_dial_dtmf(const char *dtmf_char);

/*
   函数功能：
   本函数用于短信的发送。每次当APP需要发送短信，必须首先调用本函数向指定的gmobile（relaySN）发送MCC01 messageNonceReq消息以获取本次短信发送使用的nonce，对端将回送MCC01 messageNonceRsp消息，其中包含nonce。galaxy库将通过回调函数message_nonce_rsp告知APP对端的nonce。
   特别强调的是，每次发送短信，都需要重新获取nonce。
   APP第一次调用galaxy_messageNonceReq()后，应当启动定时器。并在APP界面上提示消息正在被发送。如果5秒钟后没有收到MCC01 messageNonceRsp消息（即message_nonce_rsp回调函数没有被调用），APP应当重新调用本函数以尝试重新发送MCC01 messageNonceReq消息。
   APP第二次调用galaxy_messageNonceReq()后，应当启动定时器。如果15秒钟后没有收到MCC01 messageNonceRsp消息，APP应当重新调用本函数以尝试重新发送MCC01 messageNonceReq消息。
   APP第三次调用galaxy_messageNonceReq()后，应当启动定时器。如果15秒钟后没有收到MCC01 messageNonceRsp消息，APP提示用户消息没有被成功发送。
   
   APP应当有能力鉴别针对同一个messageId的多次MCC01 messageNonceRsp消息（即message_nonce_rsp回调函数被多次调用），应当忽略后续重复的回应消息。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   relaySN：通过此relaySN对应的gmobile发送短信。
   messageId：APP为本次短信发送产生的一个随机数。
*/
//#define galaxy_messageNonceReq(messageId, relaySN) send_mcc01_messageNonceReq(messageId, relaySN) 
int galaxy_messageNonceReq(int messageId, unsigned int relaySN);
/*
   函数功能：
   本函数用于短信的发送。APP通过galaxy_messageNonceReq获取到nonce后，就立即调用galaxy_messageSubmit()发送实际的短信。
   APP第一次调用galaxy_messageSubmit()后，应当启动定时器。如果5秒钟后没有收到MCC01 messageSubmitAck消息（即message_submit_ack回调函数没有被调用），APP应当重新调用本函数以尝试重新发送MCC01 messageNonceReq消息。
   APP第二次调用galaxy_messageSubmit()后，应当启动定时器。如果15秒钟后没有收到MCC01 messageSubmitAck消息，APP应当重新调用本函数以尝试重新发送MCC01 messageSubmit消息。
   APP第三次调用galaxy_messageSubmit()后，应当启动定时器。如果15秒钟后没有收到MCC01 messageSubmitAck消息，APP提示用户消息没有被成功发送。
   如果接收到对端发送的MCC01 messageSubmitAck消息（message_submit_ack回调函数被调用），APP应当在界面上提示消息被成功发送。
      
   APP应当有能力鉴别针对同一个messageId的多次MCC01 messageSubmitAck消息（即message_submit_ack回调函数被多次调用），应当忽略后续重复的回应消息。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   relaySN：必须和之前的galaxy_messageNonceReq调用的relaySN相同。
   messageId：必须和之前的galaxy_messageNonceReq调用的messageId相同。
   auth：鉴权信息。auth = MD5(authCode + nonce)。 其中的authCode对应于在调用galaxy_relayLoginReq()使用的authCode(relaySN对应的gmobile的authCode)；nonce为message_nonce_rsp返回的nonce值。当message_nonce_rsp返回的nonce为NULL时，auth设置为NULL。举个例子：authCode="3F2504E0"，nonce="8E98347D"，则auth=MD5("3F2504E08E98347D")
   calledNumber：接收短信的被叫号码。
   callingNumber：填写为NULL。
   content：短信内容，UTF8编码格式。
   contentSize：短信字节数。
*/
//#define galaxy_messageSubmit(messageId, relaySN, auth, calledNumber, callingNumber, content, contentSize)    send_mcc01_messageSubmit(messageId, relaySN, auth, calledNumber, callingNumber, content, contentSize)
int galaxy_messageSubmit(int messageId, unsigned int relaySN, const unsigned char *auth, const char *calledNumber, const char *callingNumber, const char *content, int contentSize);

/*
   函数功能：
   在普通galaxy函数调用返回失败时，可以使本函数取回错误码。使用例子：
   char gerror[32];
   NSLog(@"galaxy_xxx failed, gerror=%s", galaxy_error(gerror));


   返回值：
   函数返回传入参数gerror的地址。
   
   参数解释：
   gerror：存放错误码的字符数组，至少32个字节。galaxy库将把错误码复制到gerror中。
*/
const char* galaxy_error(char *gerror);

#ifdef __cplusplus
}
#endif
#endif
