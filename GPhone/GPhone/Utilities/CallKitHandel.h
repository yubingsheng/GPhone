//
//  ProviderDelegate.h
//  GPhone
//
//  Created by Mason on 2018/2/11.
//  Copyright © 2016年 Mason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CallKit/CallKit.h>


@interface CallKitHandel : NSObject <CXProviderDelegate>

@property (nonatomic, strong) CXProvider* provider;
@property (nonatomic, strong) NSUUID* inCallUUID;
@property (nonatomic, strong) NSTimer *timerSessionInvite;

- (instancetype)init;

- (void)reportIncomingCallWithCallId:(NSString*)callId relaysn:(NSString*)relaysn callingNumber:(NSString*)callingNumber;


@end
