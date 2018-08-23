#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>
#import <PushKit/PushKit.h>
#import "PushkitManager.h"
#import "galaxy.h"

@interface PushkitManager ()<PKPushRegistryDelegate>

@end

@implementation PushkitManager

static PushkitManager *instance = nil;

+ (PushkitManager *)sharedClient {

	if (instance == nil) {

		instance = [[super alloc] init];
	}
	return instance;
}

-(void)initWithServer {
	//voip delegate
	PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
	pushRegistry.delegate = self;
	pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];

}

#pragma mark -pushkitDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
	NSString * tokenString = [[[[credentials.token description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
	NSLog(@"voip device token: %@", tokenString);
	strcpy(pushTokenVoIP, tokenString.UTF8String);
}

/*
   - (void) closeGalaxyBackgroundUDP
   {
//如果此时APP仍然在后台，说明用户没有理会此呼叫，我们需要关闭udp socket
if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)  {  
galaxy_close_transport_udp();
NSLog(@"SHAY udp socket closed in viberateWithCompletionHandler");
} 
}
 */

- (void) viberateWithCompletionHandler:(void (^)(void))completion
{
	notification_viberate = 1;

	int i;
	for(i = 0; i < 20 && notification_viberate; i++) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		usleep(1500000);
	} 

	NSLog(@"SHAY out vibrate, i=%d, notification_viberate=%d", i, notification_viberate);
	//[self performSelectorOnMainThread:@selector(closeGalaxyBackgroundUDP) withObject:nil waitUntilDone:YES];

	NSLog(@"SHAY before viberateWithCompletionHandler completion");
	completion();
}


// Handle incoming pushes
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion
{
	NSLog(@"voip push got");
	NSDictionary * dic = payload.dictionaryPayload;
	NSString *message = dic[@"message"];
	if([message isEqualToString:@"setup"]) {
		NSString *relaysn = dic[@"relaysn"];
		if(!relaysn) {
			NSLog(@"push payload no relaysn");
			return;
		}

		//实际应用中，可能存在多个relaySN
		if([relaysn intValue] != GPhoneConfig.sharedManager.relaySN.intValue) {
			NSLog(@"push payload with relaysn not added by APP");
			return;
		}
		NSString *callId = dic[@"callid"];
		if(!callId) {
			NSLog(@"push payload no callid");
			return;
		}

		//g_callin = 1;
		//g_callinId = [callId intValue];
		//g_callin_alerting_sent = 0;

		NSString *callingNumber = dic[@"number"];
		if(!callingNumber) {
			NSLog(@"push payload no number");
			return;
		}

		//[self.providerDelegate reportIncomingCallWithCallId:callId relaysn:relaysn callingNumber:callingNumber];
		UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
		content.title = callingNumber;
		content.body = @"来电";
		content.sound = [UNNotificationSound soundNamed:@"gphone_ring.caf"];
		//content.userInfo = dic;
		//UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:YES];
		content.categoryIdentifier = @"GPHONE_CALLIN";

		UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:callId content:content trigger:nil];
		UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
		[center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
			if (error != nil) {
				NSLog(@"%@", error.localizedDescription);
			}
		}];

		if(!galaxy_callInSetup([callId intValue], [relaysn intValue])) {
			NSLog(@"galaxy_callInSetup failed");
			return;
		}
        
        ContactModel *contactModel = [[ContactModel alloc]initWithId:[dic[@"callid"] intValue] time:1 identifier:@"" phoneNumber:dic[@"number"] fullName:@"" creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
        GPhoneCallService.sharedManager.currentContactModel = contactModel;
		/*
		//实际应用中，要启动定时器重发galaxy_callInAlerting
		if(!galaxy_callInAlerting([callId intValue], [relaysn intValue])) {
		char gerror[32];
		NSLog(@"galaxy_callInAlerting failed, gerror=%s", galaxy_error(gerror));
		}
		NSLog(@"SHAY galaxy_callInAlerting sent");
		 */


		//使用performSelectorInBackground很重要，否则，如果直接执行viberateWithCompletionHandler:，会导致本函数迟迟不退出，
		//使得后续events无法被执行，比如用户虽然点击了notification，但applicationWillEnterForeground就无法被执行，
		//notification_viberate也就无法被置为0，震动也就无法被停止。
		//我们使用performSelectorInBackground执行viberateWithCompletionHandler:后，虽然本函数退出了，但由于completion()
		//未被执行，所以viberateWithCompletionHandler:函数仍然正常执行，震动也就可以继续。
		[self performSelectorInBackground:@selector(viberateWithCompletionHandler:) withObject:completion];
	}
	else {
		//release
		NSString *relaysn = dic[@"relaysn"];
		if(!relaysn) {
			NSLog(@"push payload no relaysn");
			return;
		}
		//实际应用中，可能存在多个relaySN
		if([relaysn intValue] != GPhoneConfig.sharedManager.relaySN.intValue) {
			NSLog(@"push payload with relaysn not added by APP");
			return;
		}
		NSString *callId = dic[@"callid"];
		if(!callId) {
			NSLog(@"push payload no callid");
			return;
		}

		NSString *callingNumber = dic[@"number"];
		if(!callingNumber) {
			NSLog(@"push payload no number");
			return;
		}

		galaxy_callInDrop([callId intValue], [relaysn intValue]);

		UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
		[center removeDeliveredNotificationsWithIdentifiers:@[callId]];

		UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
		content.title = callingNumber;
		content.body = @"未接来电";

		UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:callId content:content trigger:nil];
		
		[center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
			if (error != nil) {
				NSLog(@"%@", error.localizedDescription);
			}
		}];

		notification_viberate = 0;
		interface_viberate = 0;
		completion();
	}
}

@end
