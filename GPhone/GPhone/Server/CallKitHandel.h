//
//  ProviderDelegate.h
//  MyCall
//
//  Created by Mason on 2016/10/11.
//  Copyright © 2016年 Mason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CallKit/CallKit.h>

@protocol ProviderDelegate <NSObject>

@optional
- (void)endCall;
@end

@interface CallKitHandel : NSObject <CXProviderDelegate>
@property (assign, nonatomic) id<ProviderDelegate> delegate;
- (instancetype)init;

- (void)reportIncomingCallWithCallId:(NSString*)callId relaysn:(NSString*)relaysn callingNumber:(NSString*)callingNumber;

@end
