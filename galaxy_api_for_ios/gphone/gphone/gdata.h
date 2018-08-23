#ifndef _GDATA_H_iwej8747263hfuHEIkksfkpowefkowji
#define _GDATA_H_iwej8747263hfuHEIkksfkpowefkowji

extern int loginSeqId;
extern unsigned int relaySN;
extern const char *relayName;
//APPLE says: APNs device tokens are of variable length. Do not hard-code their size.
extern char pushToken[128];  
extern char pushTokenVoIP[128];  
extern char authCode_nonce[25];  //authCode(16) + nonce(8) + 0
extern unsigned char callMD5[16];
    
extern int messageId;
extern char authCode_nonce_message[25];  //authCode(16) + nonce(8) + 0

extern volatile int notification_viberate;
extern volatile int interface_viberate;
//extern int g_callin;
//extern int g_callinId;
//extern int g_callin_alerting_sent;

//extern void *gvc;

#endif //_GDATA_H
