//
//  ProviderDelegate.h
//  GPhone
//
//  Created by Mason on 2018/2/11.
//  Copyright © 2016年 Mason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CallKit/CallKit.h>
#import "ADCallKitManager.h"

@protocol ProviderDelegate <NSObject>

@optional
- (void)endCall;
@end

@interface CallKitHandel : NSObject
@property (assign, nonatomic) id<ProviderDelegate> delegate;
@property (nonatomic, strong) NSDate* startConnectingDate;
@property (nonatomic, strong) NSDate* connectedDate;
@property (nonatomic, strong) NSUUID* currentUUID;
@property (nonatomic, strong) NSString* currentHandle;

- (instancetype)init;

- (void)reportIncomingCallWithCallId:(NSString*)callId relaysn:(NSString*)relaysn callingNumber:(NSString*)callingNumber;

@end
