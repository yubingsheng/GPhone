#include  "gdata.h"
int loginSeqId;
unsigned int relaySN;
const char *relayName = "联通卡";
//APPLE says: APNs device tokens are of variable length. Do not hard-code their size.
char pushToken[128];  
char pushTokenVoIP[128];  
char authCode_nonce[25];  //authCode(16) + nonce(8) + 0
unsigned char callMD5[16];
    
int messageId;
char authCode_nonce_message[25];  //authCode(16) + nonce(8) + 0

volatile int notification_viberate;
volatile int interface_viberate;
//int g_callin;
//int g_callinId;
//int g_callin_alerting_sent;

//void *gvc;
