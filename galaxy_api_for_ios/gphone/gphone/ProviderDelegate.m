//
//  ProviderDelegate.m
//  MyCall
//
//  Created by Mason on 2016/10/11.
//  Copyright © 2016年 Mason. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "galaxy.h"
#import "ProviderDelegate.h"
#import "gdata.h"


@interface ProviderDelegate ()


@property (nonatomic, readonly) CXProviderConfiguration* config;


@end

@implementation ProviderDelegate {
	BOOL outCall;
	NSString *calledNumberOutCall;
}

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

    
    self.inCallUUID = [NSUUID UUID];
    [self.provider reportNewIncomingCallWithUUID:self.inCallUUID update:update completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"report error");
        }
        else {
			//实际应用中，要启动定时器重发galaxy_callInAlerting
            if(!galaxy_callInAlerting([callId intValue], [relaysn intValue])) {
				char gerror[32];
                NSLog(@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror));
            }
            NSLog(@"SHAY galaxy_callInAlerting sent");
        }
    }];
    NSLog(@"SHAY after report NewIncomingCall");
}

- (BOOL)configureAudioSession {
	AVAudioSession *sess = [AVAudioSession sharedInstance];
	if ([sess respondsToSelector:@selector(setCategory:mode:options:error:)]) {
		if([sess setCategory:AVAudioSessionCategoryPlayAndRecord
			mode:AVAudioSessionModeVoiceChat
			options:AVAudioSessionCategoryOptionAllowBluetooth
			error:nil] != YES) {
    		NSLog(@"Warning: failed setting audio session category mode options");
            return NO;
		}
		else {
    		NSLog(@"SHAY setting audio session category mode options succ");
			return YES;
		}
	}
	else {
		BOOL err;
		if ([sess respondsToSelector:@selector(setCategory:withOptions:error:)]) {
			err = [sess setCategory:AVAudioSessionCategoryPlayAndRecord
				withOptions:AVAudioSessionCategoryOptionAllowBluetooth
				error:nil];
		} else {
			err = [sess setCategory:AVAudioSessionCategoryPlayAndRecord
				error:nil];
		}
		if (err) {
    		NSLog(@"Warning: failed settting audio session category");
			return NO;
		} 
		else {
			if ([sess respondsToSelector:@selector(setMode:error:)] && [sess setMode:AVAudioSessionModeVoiceChat error:nil] != YES) {
    			NSLog(@"Warning: failed settting audio mode");
				return NO;
			}
			else return YES;
		}
	}
}


#pragma mark - CXProviderDelegate
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action{
    NSLog(@"SHAY peformStartCallAction called");
	calledNumberOutCall = action.handle.value;
	outCall = YES;
	if([self configureAudioSession] == YES) [action fulfill];
	else [action fail];
}

// user answered this incoming call
- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action{
	outCall = NO;
	if([self configureAudioSession] == YES) [action fulfill];
	else [action fail];
}

// user end this call
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action{
	//在实际应用中，如果是incall，要停止针对callInAlerting和callInAnswer的重发定时器
	if(!galaxy_callRelease()) {
		char gerror[32];
		NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
		[action fail];
	}
	else {
		NSLog(@"SHAY galaxy_callInRelease sent");
		[action fulfill];
	}
    
}

- (void) startSessionInviteTimer
{
    _timerSessionInvite = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sessionInvite) userInfo:nil repeats:YES];
}

- (void) sessionInvite
{
	if(!galaxy_sessionInvite(calledNumberOutCall.UTF8String, 0, 0, 0, relaySN)) {
		char gerror[32];
		NSLog(@"galaxy_sessionInvite failed, gerror=%s", galaxy_error(gerror));
	}
    
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession{
	/*
    [self.callController startAudio];
     */
    NSLog(@"session has activate");
	if(outCall) {
		NSLog(@"SHAY it's an out call, send sessionInvite");
		[self sessionInvite];
    	[self performSelectorOnMainThread:@selector(startSessionInviteTimer) withObject:nil waitUntilDone:NO];
	}
	else {  //incall
		NSLog(@"SHAY it's an in call, send callInAnswer");
		//实际应用中，要启动定时器重发galaxy_callInAnswer
		if(!galaxy_callInAnswer()) {
			char gerror[32];
			NSLog(@"galaxy_callInAnswer failed, gerror=%s", galaxy_error(gerror));
		}
		else {
			NSLog(@"SHAY galaxy_callInAnswer sent");
		}
	}
	
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession{
    NSLog(@"session has deactivate");
}

- (void)providerDidReset:(nonnull CXProvider *)provider {
	//在实际应用中，如果是incall，要停止针对callInAlerting和callInAnswer的重发定时器
    if(!galaxy_callRelease()) {
        char gerror[32];
        NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
    }
    else {
        NSLog(@"SHAY galaxy_callInRelease sent");      
    }
}


@end
