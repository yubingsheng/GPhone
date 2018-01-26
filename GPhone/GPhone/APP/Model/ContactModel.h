//
//  ContactModel.h
//  GPhone
//
//  Created by 郁兵生 on 2018/1/26.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GPhoneBaseModel.h"
#import <Contacts/Contacts.h>

@interface ContactModel : GPhoneBaseModel

@property (assign, nonatomic) int id;
@property (assign, nonatomic) int time;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *creatTime;

- (instancetype)initWithId:(int)id time:(int)time phoneNumber:(NSString *)phoneNumber fullName:(NSString*)fullName creatTime:(NSString *)creatTime;

@end