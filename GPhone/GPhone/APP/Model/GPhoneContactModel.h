//
//  GPhoneContactModel.h
//  GPhone
//
//  Created by 郁兵生 on 2018/9/12.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GPhoneBaseModel.h"

@interface GPhoneContactModel : GPhoneBaseModel
@property (strong,nonatomic) NSString *fullName;
@property (strong,nonatomic) NSMutableArray *phoneArray;
@end
