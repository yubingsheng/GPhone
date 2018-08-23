#ifndef _Galaxy_sjfowe934jejfmlwfw
#define _Galaxy_sjfowe934jejfmlwfw
#ifdef __cplusplus
extern "C" {
#endif

/*this is the API for galaxy mcc01 client developing*/
/*
release notes:
20180608:
1, 增加了galaxy_io_pause()和galaxy_io_resume()两个API。用法和用途参加API说明和demo程序。
2, 此版本去除了callkit的支持，audiosession改由galaxy库激活和去活。demo程序也移除了callkit相关的代码。
4, 增加galaxy_callInSetup和galaxy_callInDrop两个API，删除galaxy_callInReject API。
   galaxy_callInSetup和galaxy_callInDrop两个API的用法和用途参加API说明和demo程序。
5, 如果APP没有发送任何消息回应入呼叫，对端结束呼叫时，pushkit将收到呼叫结束的pushkit。详见demo程序的PushkitManager.m的
   pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion函数。

6, galaxy_callSetup()API增加了pushTokenVoIP参数。
7, 由于去除了callkit的支持，入呼叫提醒改由local notification实现，详见demo程序的PushkitManager.m和NotificationManager.m。
8, 增加了以下4个API：
   CallState galaxy_get_call_state();
   unsigned int galaxy_get_relay_sn();
   int galaxy_get_call_id();
   CallDirection galaxy_get_call_direction();
   用法和用途参加API说明和demo程序。

9, demo程序中使用notification_viberate和interface_viberate两个全局变量，分别控制入呼叫时，APP在后台和前台的振铃，这两个全局变量的设置时机，请参考demo程序。

20180509:
1，需要定时器重发的函数调用，最多重发次数规定为3次。
2，CallReleased修改为CallRelease。
3，CallInReleased修改为CallInRelease。
4, IPV6兼容。
5, 发送mcc01消息失败时，尝试重新建立底层UDP socket。

20180223:
1，针对callkit做了优化，包括demo程序。本文档下面有针对callkit和galaxy库配合的使用规则的详细说明。

20180208:
1，可以进行短消息的发送和接收。具体步骤请参考信令流程和相应的API注释。demo程序也有相应的代码可供参考。
2, galaxy_setMessageCallbacks函数参数做了调整。增加了message_in_hello_ack回调函数。

20180128:
1，入呼叫此版本已经可以正常使用。参考下面的入呼叫信令流程说明以及demo程序。由于demo程序对callkit的使用还有些问题，此版本demo程序只能正常接收一次入呼叫，需要杀掉demo程序后，才能再次正常接收入呼叫。使用demo程序测试入呼叫的步骤：
   1)，手工修改demo程序的ViewController.m里的device token和voip device token的值，设置为从APNS获取的正确的值。编译安装demo app。
   2)，使用任意电话拨打测试号码13255030725。
   3)，pushkit和callkit将被激活，可以在界面上应答呼叫。
2，增加了versionCheck机制，包括galaxy_versionCheckReq()函数和相应的回调函数。APP在执行了galaxy_init()函数和设置了相应的回调函数后，应当调用galaxy_versionCheckReq()检查APP包含的galaxy库的版本兼容性。具体参考galaxy_versionCheckReq()函数说明和demo程序。
3，增加galaxy_error()函数，APP在某个galaxy函数调用失败时，需要使用galaxy_error()获取错误码并使用半透明灰色提示条将错误码呈现。更多内容参考galaxy_error()函数说明和demo程序。
4，修改了galaxy_init()函数，去除了回调函数参数。回调函数单独在galaxy_setXxxxxCallbacks()中进行设置;
5，头文件brook.h不再需要。

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
char authCode_nonce[25];  //authCode(16) + nonce(8) + 0

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
 callkit和galaxy库配合使用规则说明：
    This is the key difference between the CXProvider and the CXCallController: while the provider’s job is to report to the system, the call controller makes requests from the system on behalf of the user.
    以上来自 http://blog.csdn.net/kmyhy/article/details/74388913 ，英文版 https://www.raywenderlich.com/150015/callkit-tutorial-ios 。
    因为callkit能管理audiosession的激活和去激活，所以APP不必也不能显式得对audiosession进行激活和去激活。
	下面分入呼叫、出呼叫、呼叫结束三种情况进行描述。

一，入呼叫建立：
1）	从pushkit得到入呼叫后，使用CXProvider的reportNewIncomingCall 弹出iphone原生的电话振铃界面。
2）	用户划屏应答后，CXProviderDelegate的provider: performAnswerCallAction：回调函数被调用。APP必须实现这个回调函数，在这个回调函数中，需要做以下事情：
configureAudioSession()  //只配置，不激活！！！
其他必须的事情。
如果一切OK，最后[action fulfill]，否则[action fail]
3）	这之后，callkit会激活这个audiosession，无需APP手工调用setActive进行激活！！！ callkit激活auodiosession之后，会回调CXProviderDelegate的provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession方法。在这个方法中，APP调用galaxy_callInAnswer创建audio stream。

二，出呼叫建立
1）	用户在APP UI上点击拨打按钮。
2）	APP创建CXStartCallAction，然后调用CXCallController的requestTransaction将外呼请求报告为callkit。
3）	callkit回调CXProviderDelegate的provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action。在此回调函数中，APP需要实现以下事情：
configureAudioSession()  //只配置，不激活！！！
调出APP的出呼叫界面。
如果一切OK，最后[action fulfill]，否则[action fail]

4）	这之后，callkit会激活这个audiosession，无需APP手工调用setActive进行激活！！！ callkit激活auodiosession之后，会回调CXProviderDelegate的provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession方法。在这个方法中，APP调用galaxy_sessionInvite创建media stream。要注意出呼叫建立和入呼叫建立，都要回调到这个方法，但APP采取的做法是不一样的，所以APP要记录这个是出呼叫还是入呼叫，然后在此回调函数里采取适当的做法。
    在CXProviderDelegate的provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession方法中，还可调用CXProvider的reportOutgoingCallWithUUID:startedConnectingAtDate:方法向callkit报告呼叫状态，这个动作可做可不做。
    APP收到对端的callAnswer后，要调用CXProvider的reportOutgoingCallWithUUID:connectedAtDate:方法向callkit报告呼叫状态。


这里要说明一点：如果用户是通过iphone系统通讯录里沉淀的记录进行外呼，则流程是这样的：
1）	用户点击iphone系统通讯录里沉淀的记录进行外呼。
callkit回调UIApplicationDelegate的- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity  restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler
2）	 只需在此回调函数里解析出对应的电话号码，发起主叫流程即可：
  INInteraction *interaction = [userActivity interaction];  
  INIntent *intent = interaction.intent;  
  if ([intent isKindOfClass:[INStartAudioCallIntent class]])  {  
    INStartAudioCallIntent *audioIntent = (INStartAudioCallIntent *)intent;  
    INPerson *person = audioIntent.contacts.firstObject;  
    NSString *phoneNum = person.personHandle.value;      
    //继续出呼叫建立里的第2步。
  }
  注意应当：#import <Intents/Intents.h>

三，结束呼叫
参考资料：
http://blog.csdn.net/zhaochen_009/article/details/53410288?locationNum=12&fps=1
https://www.jianshu.com/p/305bd923c1ae
上述两份资料里的结束呼叫探讨值得一看。

1，对于入呼叫来讲，如果是本地结束呼叫，则是用户在系统拨号界面上点击挂机，则：callkit会回调CXProviderDelegate的provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action。APP在此回调函数中：
调用galaxy_callRelease
如果一切OK，最后[action fulfill]，否则[action fail]

然后callkit会自动deactivate此audiosession，并调用provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession回调函数，在此回调函数中，APP并无需做什么事情，写个LOG即可。

2，对于出呼叫来讲，如果是本地结束呼叫，则是在APP UI中点击挂机按钮。则APP：
创建CXEndCallAction对象
通过CXCallController，调用requestTransaction将这个挂断事件通知给Callkit
Callkit通过当前通话状态，通过CXProvider将挂断动作通知回给APP，这是通过回调CXProviderDelegate的provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action实现的。
然后继续上面的结束呼叫情况1。
3，对于入呼叫或出呼叫来讲，如果是远端结束呼叫，则APP调用CXProvider的reportCallWithUUID:endedAtDate:reason:方法。

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
1，APP调用galaxy_messageNonceReq()。 以获取鉴权用的nonce。注意要使用定时器重发。                          发送messageNonceReq消息
2，message_nonce_rsp()回调函数被调用。                                                                    收到messageNonceRsp消息
3，APP调用galaxy_messageSubmitReq()。注意要使用定时器重发。                                               发送messageSubmitReq消息
4，message_submit_rsp()回调函数被调用，指示对端成功发送了短信。                                           收到messageSubmitRsp消息

五，从APP角度看短信接收流程：

动作                                                                                                      对应的MCC01消息
1，APP收到PUSH普通推送消息，指示有新的短信。
2，APP调用galaxy_messageInHello()。注意要使用定时器重发。                                                 发送messageInHello消息
3，galaxy收到对端发送的messageInHelloAck消息时，调用message_in_hello_ack()回调函数。
3，message_deliver_req()回调函数被调用，指示有新的短信。                                                  收到messageDeliverReq消息
!!!通过message_deliver_req()收到的短消息要注意丢弃重复接收到的短消息。具体请参考galaxy_setMessageCallbacks函数的说明。
*/


//此函数目前不用
void galaxy_setHDVoice(int enable_hd_voice);

//typedef void (*DtmfGot)(void *inUserData, int dtmf);

//此结构目前不使用
typedef struct GMenu {
	const char *menuLevel;
	const char *contentType;
	const unsigned char *content;
	int contentSize;
	int needUserInput1;
	int needUserInput2;
	int needUserInput3;
	int nextAction; //0, none, 1, menu, 2, chat, 3, call, 4, cnc, 5, newSession
	const char *newCalledNumber;
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
   nonce：如果此指针值不为NULL，APP在后续调用的galaxy_callSetup()函数中，必须设置auth值。errorCode不为0时，此参数值无意义。nonce长度为8字节。
   errorCode：errorCode不等于0时，表示sessionInvite失败，APP应当提示用户“暂时无法发起呼叫”并结束后续流程。errorCode的取值参看MCC01协议的Mcc01SessionErrorCode。
*/
typedef void (*SessionConfirm)(void *inUserData, unsigned int relaySN, int menuSupport, int chatSupport, int callSupport, const char *nonce, int errorCode);
typedef void (*MenuRsp)(void *inUserData, const GMenu *gmenu, int gmenuCount, int errorCode);
typedef void (*CallNotify)(void *inUserData);

/*
   参数解释：
   errorCode：参看MCC01协议的Mcc01CallErrorCode。当返回的errorCode为authFailed时，APP要提示用户删除对应的gmobile重新添加（即重新执行galaxy_relayLoginReq()）
*/
typedef void (*CallRelease)(void *inUserData, int errorCode);

/*
   参数解释：
*/
typedef void (*CallInAlertingAck)(void *inUserData);
//typedef void (*CallInRejectAck)(void *inUserData, int callId, unsigned int relaySN);
//typedef void (*CallInRejectAck)(void *inUserData, unsigned int relaySN, const char *uuid);
//typedef void (*CallInSetup)(void *inUserData, unsigned int relaySN, const char *calledNumber, const char *callingNumber);
//typedef void (*CallInAlertingAck)(void *inUserData);
typedef void (*CallInAnswerAck)(void *inUserData);

/*
   参数解释：
   errorCode：参看MCC01协议的Mcc01CallInErrorCode
*/
typedef void (*CallInRelease)(void *inUserData, int errorCode);

//relaySN and messageId must deliver to APP since multi message may exist at the same time. 
//however, only one call exist at the same time.
/*
   参数解释：
   messageId：等于galaxy_messageNonceReq()调用时填入的messageId。
   relaySN：等于galaxy_messageNonceReq()调用时填入的relaySN。
   nonce：返回的nonce。nonce为NULL时，表示无需鉴权，后续的galaxy_messageSubmit()调用的auth填写为NULL。nonce长度为8字节。
   errorCode：参看MCC01协议的Mcc01MessageNonceErrorCode。
*/
typedef void (*MessageNonceRsp)(void *inUserData, int messageId, unsigned int relaySN, const char *nonce, int errorCode);
/*
   参数解释：
   messageId：等于galaxy_messageSubmitReq()调用时填入的messageId。
   relaySN：等于galaxy_messageSubmitReq()调用时填入的relaySN。
   errorCode：参看MCC01协议的Mcc01MessageSubmitErrorCode。当返回的errorCode为authFailed时，APP要提示用户删除对应的gmobile重新添加（即重新执行galaxy_relayLoginReq()
*/
typedef void (*MessageSubmitRsp)(void *inUserData, int messageId, unsigned int relaySN, int errorCode);
/*
   参数解释：
   参数含义和galaxy_messageInHello()函数各项参数的含义相同。
*/
typedef void (*MessageInHelloAck)(void *inUserData, int seqId, unsigned int relaySN);
/*
   参数解释：
   参数含义和galaxy_messageSubmitReq()函数各项参数的含义相同。
   timestamp: 主叫用户发送短消息的时间,带有时区信息。格式为yyyyMMddHHmmssZ，比如20180205091435+0800
              在IOS中，可以用如下的方法对timestamp进行操作,转换为本地时区时间：
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
*/
typedef void (*MessageDeliverReq)(void *inUserData, int messageId, unsigned int relaySN, const char *callingNumber, const char *content, const char *timestamp);

/*
   函数功能：
   galaxy_init()函数是整个galaxy库的初始化库，APP在使用其他galaxy API之前，应当首先调用这个函数对galaxy库进行初始化。

   返回值：
   函数执行成功返回1，失败返回0。

*/
int galaxy_init(void);

/*
   函数功能：
   用于设置版本兼容性检查消息的回调函数。

   参数解释：
   version_check_rsp：参考galaxy_versionCheckReq()函数的解释。
   inUserData_version：参考galaxy_setSessionCallbacks函数的inUserData_session参数的解释。
*/
void galaxy_setVersionCheckCallbacks(const VersionCheckRsp version_check_rsp, void *inUserData_version);
/*
   函数功能：
   用于设置relay相关的回调函数。

   参数解释：
   relay_login_rsp：参考galaxy_relayLoginReq()函数的解释。
   relay_status_rsp：参考galaxy_relayStatusReq()函数的解释。
   //relay_firmware_upate_rsp：参考galaxy_relayFirmwareUpdateReq()函数的解释。
   inUserData_relay：参考galaxy_setSessionCallbacks函数的inUserData_session参数的解释
*/
void galaxy_setRelayCallbacks(const RelayLoginRsp relay_login_rsp, const RelayStatusRsp relay_status_rsp, void *inUserData_relay);
/*
   函数功能：
   用于设置session相关的回调函数。

   参数解释：
   session_confirm：这是galaxy库收到MCC01的sessionConfirm消息时的回调函数，sessionConfirm是对端对sessionInvite消息的回应。对SessionConfirm类型的解释，请参考brook.h。 APP在此回调函数里，应当停止针对galaxy_sessionInvite()的重发定时器，参考函数galaxy_sessionInvite()的注释里重发定时器的说明。
   inUserData_session：用户数据，APP在调用galaxy_init()函数时，可将用户数据指针放入，sessionConfirm回调函数的第一个参数将返回这个指针。本函数的其他inUserData_xxx参数的作用类似。
*/
void galaxy_setSessionCallbacks(const SessionConfirm session_confirm, void *inUserData_session);
/*
   函数功能：
   用于设置menu相关的回调函数。

   参数解释：
   menu_rsp：目前不使用，直接设置为NULL。
   inUserData_menu：目前不使用，直接设置为NULL。
*/
void galaxy_setMenuCallbacks(const MenuRsp menu_rsp, void *inUserData_menu);
/*
   函数功能：
   用于设置出呼叫相关的回调函数。

   参数解释：
   call_trying：这是出呼叫对端指示接收到呼叫时的回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释。
   call_busy：直接设置为NULL。
   call_alerting：这是出呼叫对端振铃时的回调函数。galaxy库收到对端发送的MCC01 callAlerting消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释里重发定时器的说明。
   call_answer：这是出呼叫对端应答时的回调函数。galaxy库收到对端发送的MCC01 callAnswer消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释里重发定时器的说明。
   call_release：这是出呼叫对端挂机时的回调函数。galaxy库收到对端发送的MCC01 callRelease消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释里重发定时器的说明。
   inUserData_call：参考galaxy_setSessionCallbacks函数的inUserData_session参数的解释
*/
void galaxy_setCallOutCallbacks(const CallNotify call_trying, const CallNotify call_busy, const CallNotify call_alerting, const CallNotify call_answer, const CallRelease call_release, void *inUserData_call);
/*
   函数功能：
   用于设置入呼叫相关的回调函数。

   参数解释：
   call_in_alerting_ack：对于入呼叫，APP收到PUSHKIT消息后，确认当前空闲时需要调用galaxy_callInAlerting()向对端发送MCC01 callInAlerting消息向对端提示，本端正在振铃。在收到对端回应的MCC01 callInAlertingAck消息时，galaxy回调此函数，APP在此回调函数里，应当停止针对galaxy_callInAlerting()的重发定时器，参考函数galaxy_callInAlerting()的注释里重发定时器的说明。
   //call_in_reject_ack：对于入呼叫，APP收到PUSHKIT消息后，如果确认拒接此呼叫，需要调用galaxy_callInReject()向对端发送MCC01 callInReject消息。在收到对端回应的MCC01 callInRejectAck消息时，galaxy回调此函数，APP在此回调函数里，应当停止针对galaxy_callInReject()的重发定时器，参考函数galaxy_callInReject()的注释里重发定时器的说明。
   call_in_answer_ack：对于入呼叫，APP在用户按键应答电话时需要调用galaxy_callInAnswer()向对端发送MCC01 callInAnswer消息向对端提示本端已经应答。在收到对端回应的MCC01 callInAnswerAck消息时，galaxy回调此函数，APP在此回调函数里，应当停止针对galaxy_callInAlerting()和galaxy_callInAnswer()的重发定时器，参考函数galaxy_callInAlerting()和galaxy_callInAnswer()的注释里重发定时器的说明。
   call_in_release：这是入呼叫对端挂机时的回调函数。galaxy库收到对端发送的MCC01 callInRelease消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callInAlerting()和galaxy_callInAnswer()的重发定时器，参考函数galaxy_callInAlerting()和galaxy_callInAnswer()的注释里重发定时器的说明。
   inUserData_call_in：参考galaxy_setSessionCallbacks函数的inUserData_session参数的解释
*/
//void galaxy_setCallInCallbacks(const CallInAlertingAck call_in_alerting_ack, const CallInRejectAck call_in_reject_ack, const CallInAnswerAck call_in_answer_ack, const CallInRelease call_in_release, void *inUserData_call_in);
void galaxy_setCallInCallbacks(const CallInAlertingAck call_in_alerting_ack, const CallInAnswerAck call_in_answer_ack, const CallInRelease call_in_release, void *inUserData_call_in);
/*
   函数功能：
   用于设置短消息相关的回调函数。

   参数解释：
   message_nonce_rsp：galaxy收到对端的MCC01 messageNonceRsp消息时的回调函数，MCC01 messageNonceRsp是对端对MCC01 messageNonceReq消息的回应。
   message_submit_ack：galaxy收到对端的MCC01 messageSubmitAck消息时的回调函数。
   message_in_hello_ack: galaxy收到对端的MCC01 messageInHelloAck消息时的回调函数。
   message_deliver_req：galaxy收到对端的MCC01 messageDeliverReq消息时的回调函数。要特别注意的是，APP应当缓存最近五分钟内通过本回调函数收到的短消息的所有messageId，如果后续通过本回调函数收到的短消息的messageId和缓存中的某个messageId相同，就说明是重复发送，APP应当丢弃收到的短消息。
   inUserData_message：参考galaxy_setSessionCallbacks函数的inUserData_session参数的解释
   
*/
void galaxy_setMessageCallbacks(const MessageNonceRsp message_nonce_rsp, const MessageSubmitRsp message_submit_rsp, const MessageInHelloAck message_in_hello_ack, const MessageDeliverReq message_deliver_req, void *inUserData_message);

/*
   函数功能：
   galaxy_versionCheckReq()用于检查当前galaxy库的版本号是否匹配。
   APP调用galaxy_versionCheckReq()向对端发送MCC01 versionCheckReq消息后，galaxy收到对端的回应消息MCC01 versionCheckRsp后，调用回调函数version_check_rsp。
   APP应当在galaxy_init()之后，立即调用此函数以检查当前APP使用的galaxy库是否兼容当前的服务器版本，如果服务器返回的版本检查结果是versionMustUpdate，则应当强制用户进行APP升级，拒绝用户继续使用APP。
   APP应当每隔3秒钟调用galaxy_versionCheckReq()重发MCC01 versionCheckReq消息，直到收到对端的回应消息。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。

   返回值：
   函数执行成功返回1，失败返回0。
   
*/
int galaxy_versionCheckReq(void);
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
   authCode：这是用于后续出呼叫和发送短信时鉴权的鉴权码。每个用户添加的gmobile都对应一个authCode。用户在添加gmobile时，APP都应当新产生一个随机数作为此gmobile对应的authCode并保存(如果APP之前已经保存了此gmobile对应的authCode，则替换它)。authCode是64bit随机数的十六进制ASCII字符串的形式，长度为16字节，比如"3F2504E08D64C20A"。
   
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
   APP应当每隔3秒钟调用galaxy_sessionInvite()重发MCC01 sessionInvite消息，直到收到对端的sessionConfirm消息或呼叫结束，并且最多重发三次。所以应当在接收到相应MCC01 sessionConfirm的回调函数里，停止计时器。参见galaxy_setXXXCallbacks()函数关于停止定时器的说明。

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
   APP应当每隔3秒钟调用galaxy_callSetup()重发MCC01 callSetup消息，直到收到对端的回应消息或呼叫结束，并且最多重发三次。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_setXXXCallbacks()函数关于停止定时器的说明。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   repeated：由于定时器到需要重新调用galaxy_callSetup()时，repeated参数置为1，否则置为0。 
   pushTokenVoIP: VoIP push token
   auth：鉴权信息。auth = MD5(authCode + nonce)。其中的authCode对应于session_confirm回调函数返回的relaySN对应的gmobile的authCode(此authcode是galaxy_relayLoginReq时产生并保存的)；nonce为session_confirm返回的nonce值。当session_confirm返回的nonce为NULL时，auth设置为NULL。举个例子：authCode="3F2504E083E7D89B"，nonce="8E98347D"，则auth=MD5("3F2504E083E7D89B8E98347D")
   menuLevel：填入NULL。
*/
int galaxy_callSetup(int repeated, const char *pushTokenVoIP, const unsigned char *auth, const char *menuLevel);


/*
   函数功能：
   本函数用于入呼叫。当APP收到入呼叫setup的pushkit，应当调用此函数告知galaxy库，以便galaxy设置相应的呼叫数据和状态。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   callid: 来自pushkit的callid。
   relaySN：来自pushkit的relaySN。
*/
int galaxy_callInSetup(int callid,  unsigned int relaySN);

/*
   函数功能：
   本函数用于入呼叫。当APP收到入呼叫release的pushkit，应当调用此函数告知galaxy库，以便galaxy清除相应的呼叫数据和状态。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   callid: 来自pushkit的callid。
   relaySN：来自pushkit的relaySN。
*/
void galaxy_callInDrop(int callid,  unsigned int relaySN);

/*
   函数功能：
   本函数用于入呼叫。当APP收到PUSHKIT推送消息，指示有新的入呼叫时，APP调用此函数发送MCC01 callInAlerting消息给对端。galaxy库收到对端的callInAlertingAck消息，将调用相应的回调函数报告给APP。
   APP应当每隔3秒钟调用galaxy_callInAlerting()重发MCC01 callAlerting消息，直到收到对端的回应消息或呼叫结束，并且最多重发三次。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_setXXXCallbacks()函数关于停止定时器的说明。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   callid: 填写APP收到的PUSHKIT推送消息里传送过来的callid。
   relaySN：填写APP收到的PUSHKIT推送消息里传送过来的relaySN。
*/
//#define galaxy_callInAlerting(callid, relaySN)   send_mcc01_callInAlerting(callid, relaySN)
int galaxy_callInAlerting(void);

/*
   函数功能：
   本函数用于入呼叫。当APP收到PUSHKIT推送消息，指示有新的入呼叫时，如果由于某种原因APP需要拒绝此呼叫（比如已经有呼叫存在），调用本函数拒绝。要特别注意，如果APP振铃后（发送了callInAlerting）需要结束呼叫（比如用户按拒接键），则必须调用galaxy_callRelease()，而不是galaxy_callInReject()。
   APP应当每隔3秒钟调用galaxy_callInReject()重发MCC01 callInReject消息，直到收到对端的回应消息，并且最多重发三次。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_setXXXCallbacks()函数关于停止定时器的说明。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   callid: 填写APP收到的PUSHKIT推送消息里传送过来的callid。
   relaySN：填写APP收到的PUSHKIT推送消息里传送过来的relaySN。
*/
//int galaxy_callInReject(int callid,  unsigned int relaySN);


/*
   函数功能：
   本函数用于入呼叫。用户点击接听按钮时，APP调用此函数向对端发送MCC01 callInAnswer消息，以提示对端本端应答。
   APP应当每隔3秒钟调用galaxy_callInAnswer()重发MCC01 callAnswer消息，直到收到对端的回应消息或呼叫结束，并且最多重发三次。所以应当在接收到相应MCC01消息的回调函数里，停止计时器。参见galaxy_setXXXCallbacks()函数关于停止定时器的说明。

   返回值：
   函数执行成功返回1，失败返回0。
*/
//#define galaxy_callInAnswer()   send_mcc01_callInAnswer() 
int galaxy_callInAnswer(void);

/*
   函数功能：
   本函数可用于入呼叫和出呼叫。用户点击挂机按钮时，APP调用此函数向对端发送挂机消息（MCC01 callRelease或callInRelease消息）。

   返回值：
   函数执行成功返回1，失败返回0。
*/
//#define galaxy_callRelease() send_mcc01_callRelease()
int galaxy_callRelease(void);
/*
   函数功能：
   本函数可用于入呼叫和出呼叫。当APP检测到手机的网络环境发生改变，比如由运营商数据网络切换到WIFI，或者网络中断后又恢复，必须立即调用此函数更新语音媒体流。

   返回值：
   函数执行成功返回1，失败返回0。
*/
int galaxy_callResetAudioStream(void);
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
   重复发送的消息，其messageId必须相同。
   
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
   重复发送的消息，其messageId必须相同。
   如果接收到对端发送的MCC01 messageSubmitAck消息（message_submit_ack回调函数被调用），APP应当在界面上提示消息被成功发送。
      
   APP应当有能力鉴别针对同一个messageId的多次MCC01 messageSubmitAck消息（即message_submit_ack回调函数被多次调用），应当忽略后续重复的回应消息。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   relaySN：必须和之前的galaxy_messageNonceReq调用的relaySN相同。
   messageId：必须和之前的galaxy_messageNonceReq调用的messageId相同。
   auth：鉴权信息。auth = MD5(authCode + nonce)。 其中的authCode是relaySN对应的gmobile的authCode(此authcode是galaxy_relayLoginReq时产生并保存的)；nonce为message_nonce_rsp返回的nonce值。当message_nonce_rsp返回的nonce为NULL时，auth设置为NULL。举个例子：authCode="3F2504E083E7D89B"，nonce="8E98347D"，则auth=MD5("3F2504E083E7D89B8E98347D")
   calledNumber：接收短信的被叫号码。
   content：短信内容，UTF8编码格式。
*/
//#define galaxy_messageSubmit(messageId, relaySN, auth, calledNumber, callingNumber, content, contentSize)    send_mcc01_messageSubmit(messageId, relaySN, auth, calledNumber, callingNumber, content, contentSize)
int galaxy_messageSubmitReq(int messageId, unsigned int relaySN, const unsigned char *auth, const char *calledNumber, const char *content);

/*
   函数功能：
   每次APP启动，或者由后台转到前台，或者收到消息推送后用户点击消息启动程序，APP都需要调用本函数以通知服务器发送缓存的短消息。服务器收到messageInHello消息后，将会以messageDeliverReq消息发送所有缓存的短消息。
   如果APP在5秒内没有收到messageInHelloAck消息（也即message_in_hello_ack回调函数被调用），或者没有收到messageDeliverReq消息（也即message_deliver_req回调函数被调用），应当重复调用本函数，最多重复调用本函数3次。

   重复发送的消息，其seqId必须相同。
   

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   seqId：APP产生的一个随机数。在回调函数message_in_hello_ack中，将返回相同的seqId。
   relaySN：通过此relaySN对应的gmobile发送短信。
*/
int galaxy_messageInHello(int seqId, unsigned int relaySN);

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

/*
   函数功能：
   在APP无需galaxy库的IO功能（IP收发）时，应当及时使用galaxy_io_pause将其关闭。比如APP进入后台时。
   如果APP在进入后台之前不关闭galaxy库的IO功能，某些情况下会导致galaxy库的io功能异常
   关闭了galaxy库的IO功能后，MCC01消息将无法收发。

   返回值：
   无
   
   参数解释：
   无
*/

void galaxy_io_pause(void);

/*
   函数功能：
   和galaxy_io_pause配套使用，在APP需要galaxy库的IO功能时，应当及时使用galaxy_io_resume将其打开。

   返回值：
   无
   
   参数解释：
   无
*/
void galaxy_io_resume(void);

typedef enum CallState {
	IDLE, DIALED, TRYING, BUSY, ALERTING, ANSWERED     
} CallState;
typedef enum CallDirection {
	NONE, OUTBOUND, INBOUND
} CallDirection;


/*
   函数功能：
   获取galaxy库中当前呼叫的状态

   返回值：
   galaxy库中当前呼叫的状态。
   
   参数解释：
   无
*/
CallState galaxy_get_call_state(void);

/*
   函数功能：
   获取galaxy库中当前呼叫使用的relay的SN

   返回值：
   galaxy库中当前呼叫使用的relay的SN
   
   参数解释：
   无
*/
unsigned int galaxy_get_relay_sn(void);

/*
   函数功能：
   获取galaxy库中当前呼叫的callid

   返回值：
   galaxy库中当前呼叫的callid
   
   参数解释：
   无
*/
int galaxy_get_call_id(void);

/*
   函数功能：
   获取galaxy库中当前呼叫的方向

   返回值：
   galaxy库中当前呼叫的方向。
   INBOUND -- 入呼叫
   OUTBOUND  -- 出呼叫
   
   参数解释：
   无
*/
CallDirection galaxy_get_call_direction(void);

#ifdef __cplusplus
}
#endif
#endif
