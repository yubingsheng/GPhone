//
//  GPhoneContactManage.h
//  GPhone
//
//  Created by 郁兵生 on 2018/9/12.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPhoneContactModel.h"

@interface GPhoneContactManager : NSObject
+ (GPhoneContactManager *)sharedManager;
/*
 更新全部的通讯录
 */

- (void)updateAllContact;

/*
  根据手机号匹配姓名
 */
- (NSString *) getContactInfoWith:(NSString*)phoneNumber;
/*
 判断是不是手机号
 */
+ (BOOL)checkPhone:(NSString *)phoneNumber;
@end
