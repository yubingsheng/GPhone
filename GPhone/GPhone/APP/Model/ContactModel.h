//
//  ContactModel.h
//  GPhone
//
//  Created by 郁兵生 on 2018/1/26.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GPhoneBaseModel.h"

@interface ContactModel : GPhoneBaseModel

@property (assign, nonatomic) int id;
@property (assign, nonatomic) int time;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *creatTime;
@property (strong, nonatomic) NSString *relayName;
@property (strong, nonatomic) NSString *relaySN;
@property (strong, nonatomic) NSMutableArray *messageList;
@property (assign, nonatomic) int unread;
@property (assign, nonatomic) BOOL missedCall;

- (instancetype)initWithId:(int)id time:(int)time identifier:(NSString*)identifier phoneNumber:(NSString *)phoneNumber fullName:(NSString*)fullName creatTime:(NSString *)creatTime;

@end
