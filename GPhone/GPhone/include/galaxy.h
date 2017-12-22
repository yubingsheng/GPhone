#ifndef _Galaxy_sjfowe934jejfmlwfw
#define _Galaxy_sjfowe934jejfmlwfw
#ifdef __cplusplus
extern "C" {
#endif

/*this is the API for galaxy mcc01 client developing*/
/*
release notes:
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

#include "brook.h"

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


二，从APP角度看入呼叫流程：

动作                                                                                                      对应的MCC01消息
1，APP收到PUSH推送消息，指示有新的入呼叫或短信。
2，APP调用galaxy_hello()。                                                                                发送hello消息
3，call_in_setup()回调函数被调用。                                                                        收到callInSetup消息
4，APP调用galaxy_callInAlerting()。向对端指示本端正在振铃。                                               发送callInAlerting消息
5，APP调用galaxy_callInAnswer()。向对端指示本端应答。                                                     发送callInAnswer消息

在call_in_setup()回调函数被调用以后，call_in_released()回调函数可能会被随时调用，指示对端挂机。（接收到对端发送的MCC01 callInRelease消息）
在call_in_setup()回调函数被调用以后，APP也可以随时调用galaxy_callRelease()函数以结束呼叫（挂机）。（向对端发送MCC01 callInRelease消息）

三，从APP角度看短信发送流程：

动作                                                                                                      对应的MCC01消息
1，APP调用galaxy_messageNonceReq()。 以获取鉴权用的nonce。                                                发送messageNonceReq消息
2，message_nonce_rsp()回调函数被调用。                                                                    收到messageNonceRsp消息
3，APP调用galaxy_messageSubmit()。                                                                        发送messageSubmit消息
4，message_submit_ack()回调函数被调用，指示对端成功发送了短信。                                           收到messageSubmitAck消息

四，从APP角度看短信接收流程：

动作                                                                                                      对应的MCC01消息
1，APP收到PUSH推送消息，指示有新的入呼叫或短信。
2，APP调用galaxy_hello()。                                                                                发送hello消息                                                         
3，message_deliver()回调函数被调用，指示有新的短信。                                                      收到messageDeliver消息
*/


//此函数目前不用
void galaxy_setHDVoice(int enable_hd_voice);

//typedef void (*DtmfGot)(void *inUserData, int dtmf);

/*
   函数功能：
   galaxy_init()函数是整个galaxy库的初始化库，APP在使用其他galaxy API之前，应当首先调用这个函数对galaxy库进行初始化。

   返回值：
   函数执行成功返回1，失败返回0。

   参数解释：
   以下参数应用于出呼叫：
   session_confirm：这是galaxy库收到MCC01的sessionConfirm消息时的回调函数，sessionConfirm是对端对sessionInvite消息的回应。对SessionConfirm类型的解释，请参考brook.h。 APP在此回调函数里，应当停止针对galaxy_sessionInvite()的重发定时器，参考函数galaxy_sessionInvite()的注释。
   inUserData_session：用户数据，APP在调用galaxy_init()函数时，可将用户数据指针放入，sessionConfirm回调函数的第一个参数将返回这个指针。本函数的其他inUserData_xxx参数的作用类似。
   menu_rsp：目前不使用，直接设置为NULL。
   inUserData_menu：目前不使用，直接设置为NULL。
   call_trying：这是出呼叫对端指示接收到呼叫时的回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释。
   call_busy：直接设置为NULL。
   call_alerting：这是出呼叫对端振铃时的回调函数。galaxy库收到对端发送的MCC01 callAlerting消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释。
   call_answer：这是出呼叫对端应答时的回调函数。galaxy库收到对端发送的MCC01 callAnswer消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释。
   call_released：这是出呼叫对端挂机时的回调函数。galaxy库收到对端发送的MCC01 callRelease消息后，调用此回调函数。APP在此回调函数里，应当停止针对galaxy_callSetup()的重发定时器，参考函数galaxy_callSetup()的注释。
   inUserData_call：参考inUserData_session的解释。

   以下参数应用于入呼叫：
   call_in_setup：这是galaxy发现有入呼叫时的回调函数。galaxy库收到对端发送的MCC01 callInSetup消息后，调用此回调函数。
   call_in_alerting_ack：对于入呼叫，APP确认当前空闲时需要调用galaxy_callInAlerting()向对端发送MCC01 callInAlerting消息向对端提示，本端正在振铃。在收到对端回应的MCC01 callInAlertingAck消息时，galaxy回调此函数。通常此参数可以设置为NULL。
   call_in_answer_ack：对于入呼叫，APP在用户按键应答电话时需要调用galaxy_callInAnswer()向对端发送MCC01 callInAnswer消息向对端提示本端已经应答。在收到对端回应的MCC01 callInAnswerAck消息时，galaxy回调此函数。APP应当每隔3秒钟调用galaxy_callInAnswer()重发MCC01 callAnswer消息，直到收到MCC01 callInAnswerAck消息或呼叫结束。
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
int galaxy_init(
		const SessionConfirm session_confirm, void *inUserData_session,
		const MenuRsp menu_rsp, void *inUserData_menu,
		const CallNotify call_trying, const CallNotify call_busy, const CallNotify call_alerting, const CallNotify call_answer, const CallReleased call_released, void *inUserData_call,
		const CallInSetup call_in_setup, const CallInAlertingAck call_in_alerting_ack, const CallInAnswerAck call_in_answer_ack, const CallInReleased call_in_released, void *inUserData_call_in,
		const MessageNonceRsp message_nonce_rsp, const MessageSubmitAck message_submit_ack, const MessageDeliver message_deliver, void *inUserData_message,
		//const RelayLoginRsp relay_login_rsp, const RelayStatusRsp relay_status_rsp, const RelayFirmwareUpdateRsp relay_firmware_update_rsp, void *inUserData_relay);
		const RelayLoginRsp relay_login_rsp, const RelayStatusRsp relay_status_rsp, void *inUserData_relay);
		//const DtmfGot dtmf_got, void *inUserData_dtmf);

/*
   函数功能：
   galaxy_relayLoginReq()用于添加gmobile。 relay是指VoIP呼叫的中继设备，gmobile是其中一种relay。
   APP调用galaxy_relayLoginReq()向对端发送MCC01 relayLoginReq消息后，galaxy收到对端的回应消息MCC01 relayLoginRsp后，调用回调函数relay_login_rsp。
   APP安装后首次启动时，应当提示用户添加gmobile。用户可以选择“以后再添加”，APP正常进入首页。
   用户添加gmobile时，APP应当首先检查对应relaySN的gmobile是否已经添加过，如果已经添加过，则要提示用户"您要添加的gmobile已经存在，是否需要重新添加？"，并提供是和否的选项。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   relaySN：gmobile的序列号。
   seqId: APP自定义的序列号，用于匹配Req和Rsp。seqId必须是大于0的整数。seqId应该在APP运行期间不重复。
   phoneType：参看MCC01协议里的Mcc01PhoneType。
   pushToken：in IOS, pushToken is the device token return by Apple Server to APP。必须转换为ASCII字符串的形式，长度为64字节。比如 02a2fca6e3ec1ea62aa4b6a344fb9ad7f31f491b7099c0ddf7761cea6c563980
   authCode：这是用于后续出呼叫和发送短信时鉴权的鉴权码。如果用户在添加gmobile时，APP当中没有已经注册成功的gmobile，则无论APP是否已经保存了authCode，APP都应当新产生一个随机数作为authCode并保存(如果原来已经保存了authCode，则替换它)，特别的，如果用户在添加gmobile时，虽然APP当中已经有一个注册过的gmobile，但此gmobile的relaySN和要添加的gmobile相同，则当做APP当中没有已经注册成功的gmobile；如果用户在添加gmobile时，APP当中已经有注册成功的gmobile，则使用当前保存的authCode。authCode是64bit随机数的十六进制ASCII字符串的形式，长度为16字节，比如"3F2504E08D64C20A"。
   
*/
#define galaxy_relayLoginReq(relaySN, seqId, phoneType, pushToken, authCode) send_mcc01_relayLoginReq(relaySN, seqId, phoneType, pushToken, authCode)
/*
   函数功能：
   APP调用galaxy_relayStatusReq向对端发送MCC01 relayStatusReq消息后，galaxy收到对端的回应消息MCC01 relayStatusRsp后，调用回调函数relay_status_rsp。
   APP在启动时，需要针对每个gmobile发送一遍此消息，以获取gmobile的当前状态。此后，用户可以随时按刷新按钮，通过调用此函数更新gmobile的状态。

   返回值：
   函数执行成功返回1，失败返回0。
*/
#define galaxy_relayStatusReq(relaySN) send_mcc01_relayStatusReq(relaySN)
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
   callingName：填写NULL。
   callingNameSize：填写0。
   userInfo：填写NULL。
   userInfoSize：填写0。
   myRelaySN：如果此前没有通过galaxy_relayLoginReq()添加过任何gmobile，则此参数填写0；如果此前添加过单个gmobile，或者虽然有多个gmobile但用户设置了默认的gmobile，则填写此gmobile的序列号；如果此前添加过多个gmobile，且没有设置默认的gmobile，则在调用此函数前，要求用户选择使用的gmobile，然后把用户选中的gmobile的序列号填入此参数。
*/
#define galaxy_sessionInvite(calledNumber, callingNumber, callingName, callingNameSize, userInfo, userInfoSize, myRelaySN) send_mcc01_sessionInvite(calledNumber, callingNumber, callingName, callingNameSize, userInfo, userInfoSize, myRelaySN)
/*
   此函数目前不使用。
*/
#define galaxy_menuReq(menuLevel, userInputContent1, userInputContent1Size, userInputContent2,userInputContent2Size, userInputContent3, userInputContent3Size) send_mcc01_menuReq(menuLevel, userInputContent1, userInputContent1Size, userInputContent2,userInputContent2Size, userInputContent3, userInputContent3Size)

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
   本函数用于入呼叫或短信接收。当APP收到PUSH推送消息，指示有新的入呼叫或短信时，APP调用此函数发送MCC01 hello消息给对端，对端将发送MCC01 callInSetup消息（新入呼叫）或者MCC01 message Deliver（新的短信）。galaxy库收到对端的消息，将调用相应的回调函数报告给APP。

   返回值：
   函数执行成功返回1，失败返回0。
   
   参数解释：
   relaySN：填写APP收到的PUSH推送消息里传送过来的relaySN。
*/
#define galaxy_hello(relaySN)   send_mcc01_hello(relaySN)
/*
   函数功能：
   本函数用于入呼叫。如果有入呼叫并且本端空闲，APP调用此函数向对端发送MCC01 callInAlerting消息，以提示对端本端空闲并开始振铃。

   返回值：
   函数执行成功返回1，失败返回0。
*/
#define galaxy_callInAlerting() send_mcc01_callInAlerting()
/*
   函数功能：
   本函数用于入呼叫。用户点击接听按钮时，APP调用此函数向对端发送MCC01 callInAnswer消息，以提示对端本端应答。

   返回值：
   函数执行成功返回1，失败返回0。
*/
#define galaxy_callInAnswer()   send_mcc01_callInAnswer() 

/*
   函数功能：
   本函数可用于入呼叫和出呼叫。用户点击挂机按钮时，APP调用此函数向对端发送挂机消息（MCC01 callRelease或callInRelease消息）。

   返回值：
   函数执行成功返回1，失败返回0。
*/
#define galaxy_callRelease() send_mcc01_callRelease()
/*
   函数功能：
   本函数可用于入呼叫和出呼叫。当APP检测到手机的网络环境发生改变，比如由运营商数据网络切换到WIFI，或者网络中断后又恢复，必须立即调用此函数更新语音媒体流。

   返回值：
   函数执行成功返回1，失败返回0。
*/
int galaxy_callResetAudioStream();
//此函数目前不使用
#define galaxy_callSetHDVoice(enable_hd_voice) send_mcc01_callSetAudioCodecReq(enable_hd_voice)

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
#define galaxy_messageNonceReq(relaySN, messgeId) send_mcc01_messageNonceReq(relaySN, messageId) 
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
#define galaxy_messageSubmit(relaySN, messageId, auth, calledNumber, callingNumber, content, contentSize)    send_mcc01_messageSubmit(relaySN, messageId, auth, calledNumber, callingNumber, content, contentSize)



#ifdef __cplusplus
}
#endif
#endif
