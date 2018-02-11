//
//  ProviderDelegate.m
//  MyCall
//
//  Created by Mason on 2016/10/11.
//  Copyright © 2016年 Mason. All rights reserved.
//
#import "galaxy.h"
#import "CallKitHandel.h"

@interface CallKitHandel ()<ADContactProtocol>

@property (nonatomic, strong) CXProvider* provider;
@property (nonatomic, strong) CXCallController* callController;
@property (nonatomic, readonly) CXProviderConfiguration* config;



@end

@implementation CallKitHandel

- (CXProviderConfiguration *)config{
    static CXProviderConfiguration* configInternal = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configInternal = [[CXProviderConfiguration alloc] initWithLocalizedName:@"GMobile"];
        configInternal.supportsVideo = NO;
        configInternal.maximumCallsPerCallGroup = 1;
        configInternal.maximumCallGroups = 1;
        configInternal.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
        //UIImage* iconMaskImage = [UIImage imageNamed:@"IconMask"];
        //configInternal.iconTemplateImageData = UIImagePNGRepresentation(iconMaskImage);
        //configInternal.ringtoneSound = @"Ringtone.caf";
    });
    
    return configInternal;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _callController = [[CXCallController alloc] init];
        _provider = [[CXProvider alloc] initWithConfiguration:self.config];
    }
    return self;
}

- (NSString *)displayName {
    return @"xx";
}
- (NSString*)phoneNumber {
    return self.currentHandle;
}
- (void)reportIncomingCallWithCallId:(NSString*)callId relaysn:(NSString*)relaysn callingNumber:(NSString*)callingNumber{
    NSLog(@"SHAY reportIncomingCallWithCallId, callId=%@, relaysn=%@, callingNumber=%@", callId, relaysn, callingNumber);
    self.currentHandle = callingNumber;
    CXCallUpdate* update = [[CXCallUpdate alloc] init];
    update.hasVideo = NO;
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:callingNumber];
    _currentUUID = [NSUUID UUID];
    NSLog(@"uuid == %@", _currentUUID);
    GPhoneCallService.sharedManager.uuid = _currentUUID;
    _startConnectingDate = [NSDate date];
    [[ADCallKitManager sharedInstance] setupWithAppName:@"GMobile" supportsVideo:YES actionNotificationBlock:^(CXCallAction * _Nonnull action, ADCallActionType actionType) {
        switch (actionType) {
            case ADCallActionTypeEnd:
            {
                if(!galaxy_callRelease()) {
                    char gerror[32];
                    NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
                }else {
                    if ([_delegate respondsToSelector:@selector(endCall)]) {
                        [_delegate endCall];
                    }
                }
            }
            case ADCallActionTypeStart:
            {
                CXTransaction* transaction = [[CXTransaction alloc] init];
                [transaction addAction:action];
                [self requestTransaction:transaction];
            }
            case ADCallActionTypeAnswer:
            {
                if(!galaxy_callInAnswer()) {
                    char gerror[32];
                    NSLog(@"galaxy_callInAnswer failed, gerror=%s", galaxy_error(gerror));
                }else {
                    NSLog(@"SHAY galaxy_callInAnswer sent");
                }
            }
            default:
                break;
        }
    }];
    
   [[ADCallKitManager sharedInstance] reportIncomingCallWithContact:self completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"report error");
        }
        else {
            if(!galaxy_callInAlerting([callId intValue], [relaysn intValue])) {
                char gerror[32];
                NSLog(@"error=%s", galaxy_error(gerror));
            }else NSLog(@"callInAlerting sent");
        }
    }];
}

- (void)requestTransaction:(CXTransaction*)transaction{
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"requestTransaction error %@", error);
        }
    }];
}

@end
