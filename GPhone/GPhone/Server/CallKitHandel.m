//
//  ProviderDelegate.m
//  MyCall
//
//  Created by Mason on 2016/10/11.
//  Copyright © 2016年 Mason. All rights reserved.
//
#import "galaxy.h"
#import "CallKitHandel.h"

@interface CallKitHandel ()

@property (nonatomic, strong) CXProvider* provider;

@property (nonatomic, readonly) CXProviderConfiguration* config;



@end

@implementation CallKitHandel

- (CXProviderConfiguration *)config{
    static CXProviderConfiguration* configInternal = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configInternal = [[CXProviderConfiguration alloc] initWithLocalizedName:@"gphone"];
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
        _provider = [[CXProvider alloc] initWithConfiguration:self.config];
        [_provider setDelegate:self queue:nil];
    }
    
    return self;
}

- (void)reportIncomingCallWithCallId:(NSString*)callId relaysn:(NSString*)relaysn callingNumber:(NSString*)callingNumber{

    NSLog(@"SHAY reportIncomingCallWithCallId, callId=%@, relaysn=%@, callingNumber=%@", callId, relaysn, callingNumber);
    CXCallUpdate* update = [[CXCallUpdate alloc] init];
    update.hasVideo = NO;
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:callingNumber];

    
    NSUUID *uuid = [NSUUID UUID];
    [self.provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"report error");
        }
        else {
            if(!galaxy_callInAlerting([callId intValue], [relaysn intValue])) {
				char gerror[32];
                NSLog(@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror));
            }
            NSLog(@"SHAY galaxy_callInAlerting sent");
        }
    }];
    NSLog(@"SHAY after report NewIncomingCall");
}


#pragma mark - CXProviderDelegate
/// Called when the provider has been reset. Delegates must respond to this callback by cleaning up all internal call state (disconnecting communication channels, releasing network resources, etc.). This callback can be treated as a request to end all calls without the need to respond to any actions
- (void)providerDidReset:(CXProvider *)provider{
    CXEndCallAction* endAction = [[CXEndCallAction alloc] initWithCallUUID:[NSUUID UUID]];
    CXTransaction* transaction = [[CXTransaction alloc] init];
    [transaction addAction:endAction];
     CXCallController *callController = [[CXCallController alloc] init];
    [callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"requestTransaction error %@", error);
        }
    }];

}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action{

	/*
    NSUUID* currentID = self.callController.currentUUID;
    if ([[action.callUUID UUIDString] isEqualToString:[currentID UUIDString]]) {
        
        __weak ProviderDelegate* weakSelf = self;
        self.callController.blockStartConnecting = ^(void){
            [weakSelf.provider reportOutgoingCallWithUUID:currentID startedConnectingAtDate:weakSelf.callController.connectedDate];
            NSLog(@"connecting");
        };
        
        self.callController.blockConnected = ^(void){
            [weakSelf.provider reportOutgoingCallWithUUID:currentID connectedAtDate:weakSelf.callController.connectedDate];
            NSLog(@"connected");
            
        };
        
        [self.callController.callManager startCall:self.callController.currentHandle];
        
        [action fulfill];
    } else {
        [action fail];
    }
	*/
}

// user answered this incoming call
- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action{
	if(!galaxy_callInAnswer()) {
		char gerror[32];
		NSLog(@"galaxy_callInAnswer failed, gerror=%s", galaxy_error(gerror));
    }else {
    }
	NSLog(@"SHAY galaxy_callInAnswer sent");


}

// user end this call
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action{
	if(!galaxy_callRelease()) {
		char gerror[32];
		NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
    }else {
        if ([_delegate respondsToSelector:@selector(endCall)]) {
            [_delegate endCall];
        }
    }
	NSLog(@"SHAY galaxy_callInRelease sent");
    
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession{
	/*
    [self.callController startAudio];
    NSLog(@"session has activate");
	*/
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession{

}

@end
