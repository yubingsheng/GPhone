//
//  GPhoneCacheManager.h
//  GPhone
//
//  Created by 郁兵生 on 2017/12/21.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPhoneCacheManager : NSObject
+(GPhoneCacheManager *)sharedManager;
- (id)restoreWithkey:(NSString *)key;
- (void)store:(id)object withKey:(NSString *)key;
- (void)cleanWithKey:(NSString *)key;
#pragma mark - 归档解挡
- (id)unarchiveObjectforKey:(NSString *)key;
- (void)archiveObject:(id)anObject forKey:(NSString *)key;

@end
