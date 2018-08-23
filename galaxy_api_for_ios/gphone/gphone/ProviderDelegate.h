//
//  ProviderDelegate.h
//  MyCall
//
//  Created by Mason on 2016/10/11.
//  Copyright © 2016年 Mason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CallKit/CallKit.h>

@interface ProviderDelegate : NSObject <CXProviderDelegate>

@property (nonatomic, strong) CXProvider* provider;
@property (nonatomic, strong) NSUUID* inCallUUID;
@property (nonatomic, strong) NSTimer *timerSessionInvite;

- (instancetype)init;

- (void)reportIncomingCallWithCallId:(NSString*)callId relaysn:(NSString*)relaysn callingNumber:(NSString*)callingNumber;

@end
