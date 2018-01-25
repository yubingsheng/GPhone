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

- (NSString*)relaySN{
    return [GPhoneCacheManager.sharedManager restoreWithkey:RELAYSN];
}

- (NSMutableArray*)relaysNArray {
    return [GPhoneCacheManager.sharedManager restoreWithkey:RELAYSNARRAY];
}

- (NSMutableArray*)messageArray {
    return [GPhoneCacheManager.sharedManager restoreWithkey:MESSAGES];
}

- (NSMutableArray*) callHistoryArray {
    return [GPhoneCacheManager.sharedManager restoreWithkey:CALLHISTORY];
}

- (NSString*)pushToken {
    return [GPhoneCacheManager.sharedManager restoreWithkey:PUSHTOKEN];
}

@end
