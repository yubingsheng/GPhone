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

@interface AppDelegate ()<PKPushRegistryDelegate>

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
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
    }];
    [self voipRegistration];
    _callKitHandel = [[CallKitHandel alloc] init];
    // 13255030725
    [self reachability];
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
//        switch (status) {
//            case AFNetworkReachabilityStatusUnknown:
//                // 未知网络
//                NSLog(@"未知网络");
//                break;
//            case AFNetworkReachabilityStatusNotReachable:
//                // 没有网络(断网)
//                NSLog(@"没有网络(断网)");
//                break;
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//                // 手机自带网络
////
//                break;
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//                // WIFI
//                NSLog(@"WIFI");
//                break;
//        }
    }];
    // 3.开始监控
    [mgr startMonitoring];
    
}


// Handle remote notification registration.
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    // Forward the token to your provider, using a custom method.
    //[self enableRemoteNotificationFeatures];
    //[self forwardTokenToServer:devTokenBytes];
    NSString * tokenString = [[[[devToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
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
    [GPhoneCacheManager.sharedManager archiveObject:GPhoneConfig.sharedManager.callHistoryArray forKey:CALLHISTORY];
    [GPhoneCacheManager.sharedManager archiveObject:GPhoneConfig.sharedManager.messageArray forKey:MESSAGES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
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
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    INInteraction *interaction = [userActivity interaction];
    INIntent *intent = interaction.intent;
    if ([intent isKindOfClass:[INStartAudioCallIntent class]])  {
        INStartAudioCallIntent *audioIntent = (INStartAudioCallIntent *)intent;
        INPerson *person = audioIntent.contacts.firstObject;
        NSString *phoneNum = person.personHandle.value;
        ContactModel *model = [[ContactModel alloc]initWithId:0 time:1 identifier:person.identifier phoneNumber:phoneNum fullName:person.displayName creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
        [GPhoneHandel callHistoryContainWith:model];
        [GPhoneCallService.sharedManager dialWith:model];
    }
    return YES;
}
#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    NSString * tokenString = [[[[pushCredentials.token description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"voip device token: %@", tokenString);
    [GPhoneCacheManager.sharedManager store:tokenString withKey:PUSHKITTOKEN];
}

// Handle incoming pushes
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    NSLog(@"voip push got");
    NSDictionary * dic = payload.dictionaryPayload;
    NSString *callId = dic[@"callid"];
    if(!callId) {
        NSLog(@"push payload no callid");
        return;
    }
    NSString *relaysn = dic[@"relaysn"];
    if(!relaysn) {
        NSLog(@"push payload no relaysn");
        return;
    }
    NSString *callingNumber = dic[@"number"];
    if(!callingNumber) {
        NSLog(@"push payload no number");
        return;
    }
    [_callKitHandel reportIncomingCallWithCallId:callId relaysn:relaysn callingNumber:callingNumber];
    
    completion();
}

@end
