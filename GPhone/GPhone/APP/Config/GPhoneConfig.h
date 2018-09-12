//
//  GPhoneConfig.h
//  GPhone
//
//  Created by 杨正锋 on 2017/12/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//
#import <Foundation/Foundation.h>

#pragma mark - Interface
@interface GPhoneConfig : NSObject
+(GPhoneConfig *)sharedManager;

#pragma mark - KEYS

#define RELAYSN @"relaysn"
#define RELAYNAME @"relayname"
#define RELAYSNARRAY @"relayarray"
#define MESSAGES @"message"
#define CALLHISTORY @"callhistory"
#define PUSHKITTOKEN @"pushKitToken"
#define PUSHTOKEN @"pushToken"
#define AUTHCODE @"authCode"
#define MESSAGECOUNT @"messsagecount"
#define CONTACTS @"contact"

#pragma mark - APPCnfig
@property (strong, nonatomic) NSString *relaySN;
@property (strong, nonatomic) NSString *relayName;
@property (strong, nonatomic) NSMutableArray *relaysNArray;
@property (strong, nonatomic) NSMutableArray *callHistoryArray;
@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong, nonatomic) NSString* pushKitToken;
@property (strong, nonatomic) NSString* pushToken;
@property (strong, nonatomic) NSString* authCode;
@property (strong, nonatomic) NSString *messageNumber;
@end
