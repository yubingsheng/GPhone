//
//  GPhoneCallService.h
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPhoneCallService : NSObject

+(GPhoneCallService *)sharedManager;
- (void) relayLogin ;
- (void)dialWith:(NSString *)phone;

@end
