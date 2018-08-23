//
//  AppDelegate.m
//  gphone
//
//  Created by lixs on 2017/8/21.
//  Copyright © 2017年 lixs. All rights reserved.
//
#import <Intents/Intents.h>
#import <notify.h>
#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>

#import "galaxy.h"
#import "ProviderDelegate.h"
#import "CallController.h"
#import "PushkitManager.h"
#import "AppDelegate.h"
#import "NotificationManager.h"
#import "gdata.h"

@interface AppDelegate () 

@end

@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    srand((unsigned int)time(0));
    //AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, soundCompleteCallback, NULL); 
	//CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, handleLockStateNotification, CFSTR("com.apple.springboard.lockstate"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	//CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, handleDisplayStatusNotification, CFSTR("com.apple.iokit.hid.displayStatus"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);


    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];

	[[NotificationManager sharedClient] initWithServer];
    
	[[PushkitManager sharedClient] initWithServer];
    
	//_providerDelegate = [[ProviderDelegate alloc] init];
	//_callController = [[CallController alloc] init];

    return YES;
}

// Handle remote notification registration.
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    // Forward the token to your provider, using a custom method.
    //[self enableRemoteNotificationFeatures];
    //[self forwardTokenToServer:devTokenBytes];
    NSString * tokenString = [[[[devToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"device token: %@", tokenString);
    strcpy(pushToken, tokenString.UTF8String);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error: %@", err);
    //[self disableRemoteNotificationFeatures];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"SHAY into applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"SHAY into applicationDidEnterBackground");
	galaxy_io_pause();
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) interfaceViberate
{
	interface_viberate = 1;

	while(interface_viberate) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		usleep(1500000);
	} 
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"SHAY into applicationWillEnterForeground");
	notification_viberate = 0;
	galaxy_io_resume();

	//APP进入前台，需要检查当前是否有未处理的入呼叫
	if(galaxy_get_call_state() == DIALED && galaxy_get_call_direction() == INBOUND) {
		//下面的情况会导致程序进入这里：APP在background时收到callin notification后，用户点击notification或者点击APP图标启动应用
		//
		//处理步骤：
		//1,首先去除notification
		UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
		[center removeDeliveredNotificationsWithIdentifiers:@[[NSString stringWithFormat:@"%d",galaxy_get_call_id()]]];

		//2,其次震动和发送callinAlerting
		//
		[self performSelectorInBackground:@selector(interfaceViberate) withObject:nil];
		//实际应用中，要启动定时器重发galaxy_callInAlerting
		if(!galaxy_callInAlerting()) {
			char gerror[32];
			NSLog(@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror));
		}
		NSLog(@"SHAY call in DIALED state, galaxy_callInAlerting sent");

		//3, 再要呈现入呼叫振铃界面给用户，demo只是简单的做了log
    	NSLog(@"callin ringing");
	}
	else if(galaxy_get_call_state() == ALERTING && galaxy_get_call_direction() == INBOUND) {
		//下面的情况会导致程序进入这里：在振铃界面时，用户并未应答入呼叫，而是直接把APP切换到后台，之后又切换回前台。
		//
		//处理步骤：
		//1,
		//虽然之前应该已经发送过callinAlerting，但我们仍然需要重新发送，因为在APP处于后台这段时间，对端可能已经结束了呼叫，
		//但由于我们的APP处于后台，无法接收相应的挂机消息。所以我们使用发送callInAlerting的方法主动“探测”呼叫是否仍然在，如果
		//呼叫仍然在，对端会发送ack，如果呼叫已经结束，对方会回应callRelease。
		//实际应用中，要启动定时器重发galaxy_callInAlerting
		if(!galaxy_callInAlerting()) {
			char gerror[32];
			NSLog(@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror));
		}
		NSLog(@"SHAY call in ALERTING state, galaxy_callInAlerting sent");

		//2,
		//呈现入呼叫振铃界面给用户，demo只是简单的做了log
    	NSLog(@"callin ringing");
	}
	/*
	else if(galaxy_get_call_state() == ANSWERED && galaxy_get_call_direction() == INBOUND) {
		//下面的情况会导致程序进入这里：1, 用户在APP处于前台时应答了电话，在电话通话过程中，将程序切换入后台，随后又切换回前台。//2,用户点击notification的ANSWER action应答了呼叫，之后，在电话通话过程中，键程序切换入前台。
		//呈现入呼叫通话界面给用户，demo只是简单的做了log
    	NSLog(@"callin answered");
	}
	*/
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    //实际应用中，galaxy_messageInHello必须按照API文档的说明，使用定时器重发
    int seqId = rand();
    if(!galaxy_messageInHello(seqId, relaySN)) {
        //display.text = @"messageInHello failed";
        char gerror[32];
        NSLog(@"galaxy_messageInHello failed, gerror=%s", galaxy_error(gerror));
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"SHAY into applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"SHAY into applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
	INInteraction *interaction = [userActivity interaction];  
	INIntent *intent = interaction.intent;  
	if ([intent isKindOfClass:[INStartAudioCallIntent class]])  {  
		INStartAudioCallIntent *audioIntent = (INStartAudioCallIntent *)intent;  
		INPerson *person = audioIntent.contacts.firstObject;  
		NSString *phoneNum = person.personHandle.value;      
		[self.callController startCallWithHandle:phoneNum];  
	}
    return YES;
}
*/

@end
