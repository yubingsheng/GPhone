//
//  AppDelegate.m
//  gphone
//
//  Created by lixs on 2017/8/21.
//  Copyright © 2017年 lixs. All rights reserved.
//
#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NotificationManager.h"
#import "galaxy.h"

@interface NotificationManager () <UNUserNotificationCenterDelegate>

@end

@implementation NotificationManager

static NotificationManager *instance = nil;

+ (NotificationManager *)sharedClient {
    
    if (instance == nil) {
        
        instance = [[super alloc] init];
    }
    return instance;
}

-(void)initWithServer {
	/*
	UNNotificationAction* answerAction = [UNNotificationAction
		actionWithIdentifier:@"ANSWER_ACTION"
		title:@"接听"
		options:UNNotificationActionOptionNone];

	UNNotificationAction* rejectAction = [UNNotificationAction
		actionWithIdentifier:@"REJECT_ACTION"
		title:@"拒接"
		options:UNNotificationActionOptionNone];
	*/

	UNNotificationCategory* gphoneCategory = [UNNotificationCategory
		categoryWithIdentifier:@"GPHONE_CALLIN"
		//actions:@[answerAction, rejectAction]
		actions:@[]
		intentIdentifiers:@[]
		options:UNNotificationCategoryOptionCustomDismissAction];

	UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
	[center setNotificationCategories:[NSSet setWithObjects:gphoneCategory, nil]];
	center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge + UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
		completionHandler:^(BOOL granted, NSError * _Nullable error) { 
			// Enable or disable features based on authorization.
			if (!error) {
				NSLog(@"requestAuthorizationWithOptions succeeded with granted=%d!", granted);
			}
		}
	];
}

- (void) interfaceViberate
{
	interface_viberate = 1;

	while(interface_viberate) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		usleep(1500000);
	} 
}

#pragma mark -UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
	// Update the app interface directly.
   	NSLog(@"SHAY into willPresentNotification");

	if ([notification.request.content.categoryIdentifier isEqualToString:@"GPHONE_CALLIN"]) {
		notification_viberate = 0;  //停止notification振铃
		[self performSelectorInBackground:@selector(interfaceViberate) withObject:nil];
		if(!galaxy_callInAlerting()) {
			char gerror[32];
			NSLog(@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror));
		}
		NSLog(@"SHAY galaxy_callInAlerting sent");
		//这里APP需要呈现入呼叫振铃界面给用户，demo只是简单的做了log
    	NSLog(@"callin ringing");
	}
	else {
   		NSLog(@"SHAY sms notification got");
    	//实际应用中，galaxy_messageInHello必须按照API文档的说明，使用定时器重发
    	int seqId = rand();
    	if(!galaxy_messageInHello(seqId, [[NSNumber numberWithInteger:[GPhoneConfig.sharedManager relaySN].integerValue] unsignedIntValue])) {
       	 //display.text = @"messageInHello failed";
       	 char gerror[32];
       	 NSLog(@"galaxy_messageInHello failed, gerror=%s", galaxy_error(gerror));
    	}
	}

	completionHandler(UNNotificationPresentationOptionNone); 
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
   	NSLog(@"SHAY into didReceiveNotificationResponse");
	if ([response.notification.request.content.categoryIdentifier isEqualToString:@"GPHONE_CALLIN"]) {
		notification_viberate = 0;  //停止notification振铃
		/*
		   2018.6.8: cannot use ANSWER action since udp closed immediatelly when galaxy_app_enter_background() called
		if ([response.actionIdentifier isEqualToString:@"ANSWER_ACTION"])
		{
    		NSLog(@"SHAY User press the ANSWER");

			//此时，APP处于background，galaxy io 应该处于pause状态，为了要发送MCC01消息，需要把galaxy io resume
			galaxy_io_resume();

			//此种情况下，无需发送callInAlerting，直接发送callInAnswer
			//实际应用中，要启动定时器重发galaxy_callInAnswer
			if(!galaxy_callInAnswer()) {
				char gerror[32];
				NSLog(@"galaxy_callInAnswer failed, gerror=%s", galaxy_error(gerror));
			}
			NSLog(@"SHAY galaxy_callInAnswer sent");
			//发送完需要的MCC01消息后，因为当前APP处于background，需要把galaxy库的io重新置为pause状态
			galaxy_io_pause();
		}
		else if ([response.actionIdentifier isEqualToString:@"REJECT_ACTION"])
		{
    		NSLog(@"SHAY User press the REJECT");
			//此时，APP处于background，galaxy io 应该处于pause状态，为了要发送MCC01消息，需要把galaxy io resume
			galaxy_io_resume();
			if(!galaxy_callRelease()) {
				char gerror[32];
				NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
			}
			else {
				NSLog(@"SHAY galaxy_callInRelease sent");
			}
			//发送完需要的MCC01消息后，因为当前APP处于background，需要把galaxy库的io重新置为pause状态
			galaxy_io_pause();
		}
		else 
		*/
		if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
			// The user dismissed the notification without taking action.
    		NSLog(@"SHAY User dismissed the notification");
			//此时，APP处于background，galaxy io 应该处于pause状态，为了要发送MCC01消息，需要把galaxy io resume
			galaxy_io_resume();
			if(!galaxy_callRelease()) {
				char gerror[32];
				NSLog(@"galaxy_callInRelease failed, gerror=%s", galaxy_error(gerror));
			}
			else {
				NSLog(@"SHAY galaxy_callInRelease sent");
			}
			//发送完需要的MCC01消息后，因为当前APP处于background，需要把galaxy库的io重新置为pause状态
			galaxy_io_pause();
		}
		else if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
			// The user launched the app.
    		NSLog(@"SHAY User launched the app");
			//我们无需在此做任何事情, applicationWillEnterForeground:会处理呼叫相关的事情
		}
	}

	completionHandler();
}

@end
