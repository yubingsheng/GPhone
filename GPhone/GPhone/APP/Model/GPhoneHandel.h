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
+(NSString *)friendlyTime:(NSString *)datetime;
@end
