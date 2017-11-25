//
//  GContact.h
//  GPhone
//
//  Created by Dylan on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GContact : NSObject

/**
 联系人名称
 */
@property(nonatomic,strong)NSString* contactName;

/**
 联系人名称拼音
 */
@property(nonatomic,strong)NSString* contactNamePY;

/**
 联系人电话
 */
@property(nonatomic,strong)NSString* contactMobile;

@end
