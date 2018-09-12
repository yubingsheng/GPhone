//
//  GPhoneContactModel.m
//  GPhone
//
//  Created by 郁兵生 on 2018/9/12.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GPhoneContactModel.h"

@implementation GPhoneContactModel
- (NSMutableArray *)phoneArray {
    if (!_phoneArray) {
        _phoneArray = [[NSMutableArray alloc]init];
    }
    return _phoneArray;
}
@end
