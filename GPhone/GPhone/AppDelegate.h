//
//  AppDelegate.h
//  GPhone
//
//  Created by 郁兵生 on 2017/11/7.
//  Copyright © 2017年 郁兵生. All rights reserved.
//
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>
#import "CallKitHandel.h"
#import "GPhoneCallController.h"

volatile int notification_viberate;
volatile int interface_viberate;
volatile char pushTokenVoIP[128];
volatile unsigned int relaySN;
volatile char pushToken[128];  //puthToken(64) + 0
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) CallKitHandel *callKitHandel;
@property (strong, nonatomic) GPhoneCallController *callController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tb;
@property (assign, nonatomic) BOOL isCalling;


@end

