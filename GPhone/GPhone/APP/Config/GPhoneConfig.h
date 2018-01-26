//
//  GPhoneConfig.h
//  GPhone
//
//  Created by 杨正锋 on 2017/12/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//
#import <Foundation/Foundation.h>

#pragma mark - Interface
@interface GPhoneConfig : NSObject{
//    int loginSeqId;
//    unsigned int relaySN;
//    char pushToken[65];  //puthToken(64) + 0
//    char authCode_nonce[41];  //authCode(8) + nonce(8) + 0
//    unsigned char callMD5[16];
}
+(GPhoneConfig *)sharedManager;

#pragma mark - KEYS

#define RELAYSN @"relaysn"
#define RELAYSNARRAY @"relaysn"
#define MESSAGES @"message"
#define CALLHISTORY @"callhistory"
#define PUSHTOKEN @"pushtoken"

#pragma mark - APPCnfig
@property (strong, nonatomic) NSString *relaySN;
@property (strong, nonatomic) NSMutableArray *relaysNArray;
@property (strong, nonatomic) NSMutableArray *callHistoryArray;
@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong, nonatomic) NSString* pushKitToken;

@end
