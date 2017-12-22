//
//  GPhoneBaseModel.h
//  GPhone
//
//  Created by 郁兵生 on 2017/12/21.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPhoneBaseModel : NSObject
+ (id)instancefromJsonDic:(NSDictionary*)dic;
+ (NSArray *)instancesFromJsonArray:(NSArray *)array;
@end
