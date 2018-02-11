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
@interface AppDelegate ()<PKPushRegistryDelegate,ProviderDelegate>
@property (nonatomic, strong) CallKitHandel* callKitHandel;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge + UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              // Enable or disable features based on authorization.
                          }];
    
    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
    }];
    [self voipRegistration];
    _callKitHandel = [[CallKitHandel alloc] init];
    NSLog(@"SHAY application started");
    // 13255030725
    return YES;
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
     [GPhoneCacheManager.sharedManager archiveObject:GPhoneConfig.sharedManager.callHistoryArray forKey:CALLHISTORY];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
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
#pragma mark - ProviderDelegate
- (void)endCall {
    
}
@end
