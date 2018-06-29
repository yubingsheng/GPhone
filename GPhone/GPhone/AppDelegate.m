//
//  AppDelegate.m
//  GPhone
//
//  Created by 郁兵生 on 2017/11/7.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "AppDelegate.h"
#import "GPhoneConfig.h"
#import "GPhoneCacheManager.h"
#import <UserNotifications/UserNotifications.h>
#import <Intents/Intents.h>

@interface AppDelegate ()
    
    @end

@implementation AppDelegate
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge + UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              // Enable or disable features based on authorization.
                          }];
    srand(time(0));
    _tb = (UITabBarController*)self.window.rootViewController;
    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    _isCalling = NO;
    [[PushkitManager sharedClient] initWithServer];
    [self reachability];
    [[NotificationManager sharedClient] initWithServer];
    return YES;
}
- (GPhoneCallController *)callController {
    if (!_callController) {
        _callController = [[GPhoneCallController alloc]init];
    }
    return _callController;
}
- (void)reachability { // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        if (_isCalling == NO) {
            return ;
        }else {
            galaxy_callResetAudioStream();
        }
    }];
    // 3.开始监控
    [mgr startMonitoring];
}
    
    
    // Handle remote notification registration.
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString * tokenString = [[[[devToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    strcpy(pushToken, tokenString.UTF8String);
    [GPhoneCacheManager.sharedManager store:tokenString withKey:PUSHTOKEN];
    NSLog(@"device token: %@", tokenString);
}
    
    // Register for VoIP notifications
- (void) voipRegistration {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Create a push registry object
    PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
    // Set the registry's delegate to self
    voipRegistry.delegate = self;
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    _tb.selectedIndex = 1;
    NSLog(@"%@", userInfo[@"aps"][@"alert"]);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
    
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    galaxy_io_pause();
    [GPhoneCacheManager.sharedManager archiveObject:GPhoneConfig.sharedManager.callHistoryArray forKey:CALLHISTORY];
    [GPhoneCacheManager.sharedManager archiveObject:GPhoneConfig.sharedManager.messageArray forKey:MESSAGES];
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
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
- (void) interfaceViberate {
    interface_viberate = 1;
    while(interface_viberate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        usleep(1500000);
    }
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    int seqId = rand();
    if(!galaxy_messageInHello(seqId, [[NSNumber numberWithInteger:[GPhoneConfig.sharedManager relaySN].integerValue] unsignedIntValue])) {
        //display.text = @"messageInHello failed";
        char gerror[32];
        NSLog(@"galaxy_messageInHello failed, gerror=%s", galaxy_error(gerror));
    }
}
    
    
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return YES;
}
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
//    INInteraction *interaction = [userActivity interaction];
//    INIntent *intent = interaction.intent;
//    if ([intent isKindOfClass:[INStartAudioCallIntent class]])  {
//        INStartAudioCallIntent *audioIntent = (INStartAudioCallIntent *)intent;
//        INPerson *person = audioIntent.contacts.firstObject;
//        NSString *phoneNum = person.personHandle.value;
//        ContactModel *model = [[ContactModel alloc]initWithId:0 time:1 identifier:person.identifier phoneNumber:phoneNum fullName:person.displayName creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
//        [GPhoneHandel callHistoryContainWith:model];
//        [GPhoneCallService.sharedManager dialWith:model];
//    }
//    return YES;
//}
//#pragma mark - PKPushRegistryDelegate
//
//- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
//    NSString * tokenString = [[[[pushCredentials.token description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
//    NSLog(@"voip device token: %@", tokenString);
//    [GPhoneCacheManager.sharedManager store:tokenString withKey:PUSHKITTOKEN];
//}
//
//    // Handle incoming pushes
//- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
//    NSLog(@"voip push got");
//    NSDictionary * dic = payload.dictionaryPayload;
//    NSString *callId = dic[@"callid"];
//    if(!callId) {
//        NSLog(@"push payload no callid");
//        return;
//    }
//    NSString *relaysn = dic[@"relaysn"];
//    if(!relaysn) {
//        NSLog(@"push payload no relaysn");
//        return;
//    }
//    NSString *callingNumber = dic[@"number"];
//    if(!callingNumber) {
//        NSLog(@"push payload no number");
//        return;
//    }
//    [_callKitHandel reportIncomingCallWithCallId:callId relaysn:relaysn callingNumber:callingNumber];
//
//    completion();
//}
//
@end
