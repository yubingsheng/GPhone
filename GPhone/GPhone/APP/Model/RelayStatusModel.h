//
//  RelayStatusModel.h
//  GPhone
//
//  Created by 杨正锋 on 2018/1/24.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPhoneBaseModel.h"

@interface RelayStatusModel : GPhoneBaseModel
@property (assign, nonatomic) unsigned int relaySN;
@property (assign, nonatomic) int netWorkStatus;
@property (assign, nonatomic) int signalStrength;

@end
