//
//  GPHoneHandel.h
//  GPhone
//
//  Created by 郁兵生 on 2018/1/26.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import "ContactModel.h"

@interface GPhoneHandel : NSObject

/*
 通话记录缓存
 */
+ (NSMutableArray *)callHistoryContainWith:(ContactModel *)contactModel;
/*
 短信记录缓存
 */
+ (NSMutableArray *)messageHistoryContainWith:(ContactModel *)contactModel;
/*
 短信未读数
 */
+ (void) messageTabbarItemBadgeValue:(NSInteger)num;
/*
 时间格式
 */
+(NSString *)friendlyTime:(NSString *)datetime;

/*
 date to string
 */
+ (NSString *)dateToStringWith:(NSDate *)date;

/*
 authCode
 */
+ (const char)authCode;
@end
