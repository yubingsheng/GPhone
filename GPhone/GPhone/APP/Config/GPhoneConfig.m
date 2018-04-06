//
//  GPhoneConfig.m
//  GPhone
//
//  Created by 杨正锋 on 2017/12/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPhoneConfig.h"

@implementation GPhoneConfig

+(id)sharedManager{
    static GPhoneConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - lazyLoading
// getter
- (NSString*)relaySN{
    return [GPhoneCacheManager.sharedManager restoreWithkey:RELAYSN];
}
- (NSString*)relayName{
    return [GPhoneCacheManager.sharedManager restoreWithkey:RELAYNAME];
}
- (NSMutableArray*)relaysNArray {
    NSMutableArray *array = [GPhoneCacheManager.sharedManager unarchiveObjectforKey:RELAYSNARRAY];
    if (!array) {
        array = [[NSMutableArray alloc]init];
    }
    return array;
}
- (NSString *)messageNumber {
     return [GPhoneCacheManager.sharedManager restoreWithkey:MESSAGECOUNT];
}
- (NSMutableArray*)messageArray {
    return [GPhoneCacheManager.sharedManager unarchiveObjectforKey:MESSAGES];
}

- (NSMutableArray*) callHistoryArray {
    return [GPhoneCacheManager.sharedManager unarchiveObjectforKey:CALLHISTORY];
}

- (NSString*)pushKitToken {
    return [GPhoneCacheManager.sharedManager restoreWithkey:PUSHKITTOKEN];
}

- (NSString *)pushToken {
     return [GPhoneCacheManager.sharedManager restoreWithkey:PUSHTOKEN];
}
- (NSString *)authCode {
    return [GPhoneCacheManager.sharedManager restoreWithkey:AUTHCODE];
}
// setter
- (void)setMessageNumber:(NSString *)messageNumber {
    [GPhoneCacheManager.sharedManager store:messageNumber withKey:MESSAGECOUNT];
}
- (void)setCallHistoryArray:(NSMutableArray *)callHistoryArray {
    [GPhoneCacheManager.sharedManager archiveObject:callHistoryArray forKey:CALLHISTORY];
}
- (void)setRelaysNArray:(NSMutableArray *)relaysNArray {
    [GPhoneCacheManager.sharedManager archiveObject:relaysNArray forKey:RELAYSNARRAY];
}
- (void)setMessageArray:(NSMutableArray *)messageArray {
    [GPhoneCacheManager.sharedManager archiveObject:messageArray forKey:MESSAGES];
}
- (void)setAuthCode:(NSString *)authCode {
    [GPhoneCacheManager.sharedManager store:authCode withKey:AUTHCODE];
}
@end
