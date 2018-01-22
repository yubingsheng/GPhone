//
//  GPhoneCallService.h
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCView.h"

@interface GPhoneCallService : NSObject <RTCDelegate>
@property (strong, nonatomic) RTCView *callingView;
+(GPhoneCallService *)sharedManager;
- (void) relayLogin:(id) relaySN ;
- (void)dialWithNumber:(NSString *)number nickName:(NSString *)name byRelay:(NSString *)relay;
- (void)hangup;
@end
