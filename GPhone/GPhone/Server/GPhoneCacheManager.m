//
//  GPhoneCacheManager.m
//  GPhone
//
//  Created by 郁兵生 on 2017/12/21.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPhoneCacheManager.h"

@implementation GPhoneCacheManager
+(id)sharedManager{
    static GPhoneCacheManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        //[self restore];
    }
    return self;
}

- (id)restoreWithkey:(NSString *)key
{
    return [GPLDATA unarchiveObjectforKey:key];
}

- (void)store:(id)object withKey:(NSString *)key
{
    [GPLDATA archiveObject:object forKey:key];
}

- (void)cleanWithKey:(NSString *)key
{
    [GPLDATA clearArchiveForKey:key];
}

- (void)cleanAllKey
{
    [GPLDATA clearArchive];
}

@end
