//
//  ContactModel.m
//  GPhone
//
//  Created by 郁兵生 on 2018/1/26.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel

- (instancetype)initWithId:(int)id time:(int)time identifier:(NSString*)identifier phoneNumber:(NSString *)phoneNumber fullName:(NSString*)fullName creatTime:(NSString *)creatTime; {
    self = [super init];
    if (self) {
        _id = id;
        _time = time;
        _identifier = identifier;
        _phoneNumber = phoneNumber;
        _fullName = fullName;
        _creatTime = creatTime;
        _missedCall = YES;
    }
    return self;
}

@end
