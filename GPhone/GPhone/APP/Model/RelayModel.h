//
//  RelayModel.h
//  GPhone
//
//  Created by 郁兵生 on 2018/2/9.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RelayModel : GPhoneBaseModel

@property (assign, nonatomic) unsigned int relaySN;
@property (strong, nonatomic) NSString *relayName;
@property (strong, nonatomic) NSString *authCode;
@end
